#!/usr/bin/env bash
# Lints, checks DESIGN.md and its sidecar against Palette.swift, then builds and tests the iPhone and Watch apps on the newest available simulators.
# Also archives the apps unsigned in Release, which compiles differently from the Debug test builds.
# Usage: scripts/test.sh [lint|release|ios|watch|all]   (default: all)
set -euo pipefail
cd "$(dirname "$0")/.."

DERIVED_DATA="build/DerivedData"

# Prints the UDID of an available simulator on the newest runtime for a platform.
# $1: runtime platform (iOS, watchOS)  $2: device name prefix (iPhone, Apple Watch)
simulator_id() {
    xcrun simctl list devices available -j | jq -r --arg platform "$1" --arg device "$2" '
        .devices | to_entries
        | map(select(.key | test("SimRuntime\\." + $platform + "-")))
        | sort_by(.key | capture("-(?<v>[0-9-]+)$").v | split("-") | map(tonumber))
        | reverse | map(.value[] | select(.name | startswith($device))) | first | .udid // empty'
}

# Prints the UDID of a Watch simulator with no iPhone paired on the newest runtime, creating it the first time. A paired
# Watch deletes the app when its iPhone doesn't have the iPhone app, even in the middle of a test.
unpaired_watch_id() {
    local name="Clinkr Test Watch" newest runtime device_type id
    newest="$(simulator_id watchOS "Apple Watch")"
    if [[ -z "$newest" ]]; then
        echo "No Apple Watch simulator found for watchOS" >&2
        exit 1
    fi
    read -r runtime device_type < <(xcrun simctl list devices -j | jq -r --arg id "$newest" '
        .devices | to_entries[] | .key as $runtime | .value[] | select(.udid == $id)
        | "\($runtime) \(.deviceTypeIdentifier)"')
    id="$(xcrun simctl list devices available -j | jq -r --arg runtime "$runtime" --arg name "$name" '
        [.devices[$runtime][]? | select(.name == $name)] | first | .udid // empty')"
    echo "${id:-$(xcrun simctl create "$name" "$device_type" "$runtime")}"
}

lint() {
    echo "==> Lint"
    xcrun swift-format lint --strict --recursive Clinkr "Clinkr Watch App" Shared SharedTests ClinkrTests ClinkrUITests "Clinkr Watch AppTests" "Clinkr Watch AppUITests"
    design_tokens
}

# Prints Palette.swift's colors as "slug #HEX" lines, using the slugs in DESIGN.md.
palette_colors() {
    sed -nE 's/^ *static let ([A-Za-z]+) = ThemeColor\((light: )?0x([0-9A-F]{6})(, dark: 0x([0-9A-F]{6}))?\)$/\1 \3 \5/p' Shared/Palette.swift |
        while read -r name first dark; do
            slug="$(sed -E 's/([A-Z])/-\1/g' <<<"$name" | tr '[:upper:]' '[:lower:]')"
            if [[ -n "$dark" ]]; then
                echo "$slug #$dark"
                echo "$slug-light #$first"
            else
                echo "$slug #$first"
            fi
        done | sort
}

# Prints the app icon script's colors as "slug #HEX" lines, like palette_colors.
icon_colors() {
    sed -nE 's/^let ([a-z][A-Za-z]*) = 0x([0-9A-F]{6})$/\1 \2/p' scripts/make-app-icons.swift |
        while read -r name hex; do
            echo "$(sed -E 's/([A-Z])/-\1/g' <<<"$name" | tr '[:upper:]' '[:lower:]') #$hex"
        done
}

# Prints the iPhone's AccentColor (light, then dark) and the Watch's, as "#HEX" lines.
accent_colors() {
    local hex='.colors[].color.components | "#" + .red[2:] + .green[2:] + .blue[2:]'
    jq -r "$hex" Clinkr/Assets.xcassets/AccentColor.colorset/Contents.json \
        "Clinkr Watch App/Assets.xcassets/AccentColor.colorset/Contents.json"
}

design_tokens() {
    echo "==> Design tokens"
    # The accent color is ink, kept as a copy in each asset catalog.
    diff <(accent_colors) <(palette_colors | awk '$1 == "ink-light" { l = $2 } $1 == "ink" { d = $2 } END { print l; print d; print d }')
    diff <(palette_colors) <(sed -nE 's/^  ([a-z-]+): "(#[0-9A-F]{6})"$/\1 \2/p' DESIGN.md | sort)
    diff <(palette_colors) <(jq -r '.extensions.colorMeta | to_entries[] | "\(.key) \(.value.canonical)"' .impeccable/design.json | sort)
    # The app icon script keeps its own copies of palette colors, so each one must still match.
    comm -23 <(icon_colors | sort) <(palette_colors) | diff /dev/null -
    # The committed icon must be what the script writes, so a color change can't skip running it.
    swift scripts/make-app-icons.swift
    if [[ -n "$(git status --porcelain -- Shared/AppIcon.icon)" ]]; then
        echo "Shared/AppIcon.icon doesn't match scripts/make-app-icons.swift. Commit the script's output." >&2
        git status --short -- Shared/AppIcon.icon >&2
        return 1
    fi
}

# Waits until no other run of this script is testing, since two runs on the same simulator hang each other. A lock left
# behind by a killed run is cleared.
take_test_lock() {
    local lock="/tmp/clinkr-test.lock" pid waiting=""
    until mkdir "$lock" 2>/dev/null; do
        pid="$(cat "$lock/pid" 2>/dev/null || true)"
        if [[ -n "$pid" ]] && ! kill -0 "$pid" 2>/dev/null; then
            rm -rf "$lock"
            continue
        fi
        [[ -z "$waiting" ]] && echo "==> Waiting for another test run${pid:+ (pid $pid)} to finish"
        waiting=1
        sleep 5
    done
    echo $$ >"$lock/pid"
    trap "rm -rf '$lock'" EXIT
}

test_scheme() {
    local scheme="$1" id="$2"
    echo "==> Test $scheme on $id"
    xcodebuild test -project Clinkr.xcodeproj -scheme "$scheme" -destination "id=$id" \
        -derivedDataPath "$DERIVED_DATA" CODE_SIGNING_ALLOWED=NO -quiet
}

# Archives the iPhone app, with the Watch app inside, as TestFlight needs. Needs no simulator, so no test lock.
release() {
    echo "==> Release archive"
    xcodebuild archive -project Clinkr.xcodeproj -scheme Clinkr -destination "generic/platform=iOS" \
        -archivePath build/Release/Clinkr.xcarchive -derivedDataPath build/Release/DerivedData \
        CODE_SIGNING_ALLOWED=NO -quiet
}

test_ios() {
    local id
    id="$(simulator_id iOS "iPhone")"
    if [[ -z "$id" ]]; then
        echo "No iPhone simulator found for iOS" >&2
        exit 1
    fi
    test_scheme "Clinkr" "$id"
}

test_watch() {
    local id
    id="$(unpaired_watch_id)"
    test_scheme "Clinkr Watch App" "$id"
}

case "${1:-all}" in
    lint) lint ;;
    release) release ;;
    ios)
        take_test_lock
        test_ios
        ;;
    watch)
        take_test_lock
        test_watch
        ;;
    all)
        lint
        release
        take_test_lock
        test_ios
        test_watch
        ;;
    *)
        echo "Usage: $0 [lint|release|ios|watch|all]" >&2
        exit 2
        ;;
esac
