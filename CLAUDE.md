# Clinkr

An iPhone app with a companion Apple Watch app, written in SwiftUI. It's a hobby project, and the owner is new to iOS development, so explain Apple-specific concepts briefly when they come up.

## Layout

| Path | Target | Notes |
|---|---|---|
| `Clinkr/` | Clinkr (iOS 26+) | iPhone app. Bundle ID `com.colaiacovo.clinkr` |
| `Clinkr Watch App/` | Clinkr Watch App (watchOS 26+) | Watch app, embedded in the iPhone app. Bundle ID `com.colaiacovo.clinkr.watchkitapp` |
| `Shared/` | Clinkr and Clinkr Watch App | Code and strings both apps use: the data model, the design system tokens and drink glyphs, and `Shared.xcstrings` |
| `SharedTests/` | ClinkrTests and Clinkr Watch AppTests | Tests for `Shared/`, run on both platforms |
| `ClinkrTests/` | ClinkrTests | iPhone unit tests (Swift Testing) |
| `ClinkrUITests/` | ClinkrUITests | iPhone UI tests (XCTest) |
| `Clinkr Watch AppTests/` | Clinkr Watch AppTests | Watch unit tests (Swift Testing) |
| `Clinkr Watch AppUITests/` | Clinkr Watch AppUITests | Watch UI tests (XCTest) |
| `scripts/test.sh` | | Lint and tests, used by CI too |
| `docs/ARCHITECTURE.md` | | Mermaid diagrams of how the apps fit together |
| `docs/DECISIONS.md` | | Decisions and the reasons behind them, newest first. Read it before changing something that looks deliberate |
| `PRODUCT.md` | | Who the app is for, what it's for, and its voice and principles. Read it before designing a screen or writing copy |
| `DESIGN.md` | | The look of the apps as built: tokens, components and visual rules. `.impeccable/design.json` is its generated sidecar |

Swift 6 language mode, so strict concurrency checking is on.

## Commands

```bash
scripts/test.sh          # lint + iPhone tests + Watch tests
scripts/test.sh lint     # swift-format lint, and DESIGN.md's colors against Shared/Palette.swift
scripts/test.sh ios      # iPhone unit + UI tests
scripts/test.sh watch    # Watch unit + UI tests
xcrun swift-format format --in-place --recursive Clinkr "Clinkr Watch App" Shared SharedTests ClinkrTests ClinkrUITests "Clinkr Watch AppTests" "Clinkr Watch AppUITests"
```

Run `scripts/test.sh` before calling a change done. Build output goes to `build/` (gitignored).

## Rules

- Follow `CONTRIBUTING.md` for how to work on the repo, such as branches, commit messages, pull requests (including the required `/code-review`, and `/verify-pr` for PRs linked to an issue), code comments and releases. Bigger changes go on a `feature/`, `fix/` or `chore/` branch with a pull request, merged with squash.
- `main` is protected: never force-push it.
- Code style comes from `.swift-format` (4-space indent, 120-column lines). CI fails on lint errors.
- The project file `Clinkr.xcodeproj/project.pbxproj` is managed in Xcode. When adding files, put them in the target's folder and make sure they're added to the right target. When editing the file by hand, keep Debug and Release settings in sync.
- Version (`MARKETING_VERSION`) and build (`CURRENT_PROJECT_VERSION`) are set at the project level, so the iPhone and Watch apps always match. Apple requires that.
- Put code that both apps need in `Shared/`, added to both the Clinkr and Clinkr Watch App targets, rather than copying it.
- Screens use the design system by name (`.foregroundStyle(.ink)`, `.typeStyle(.title)`, `Space.s4`, `Radius.card`, `type.glyph`), never raw colors, sizes or emoji. The design system lives at https://claude.ai/artifact/MUR9q8zqsWysfgui8mdNsh; keep `Shared/`, `DESIGN.md` and the design system in step, in the same pull request. Its `README.md` links back to this repo.
