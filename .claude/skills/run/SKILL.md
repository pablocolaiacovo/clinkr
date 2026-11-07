---
name: run
description: Build and launch Clinkr on the iOS and watchOS simulators to see a change working. Use when asked to run, launch, try, or screenshot the iPhone or Watch app.
---

# Run Clinkr in the simulators

The iPhone app and the Watch app run on separate simulators. Run whichever one the change touches, or both.

Before using a simulator, check whether it's already running with `xcrun simctl list devices booted`. Remember the UDIDs of the ones you boot yourself, so [When you're done](#when-youre-done) shuts down only those. If a simulator shuts down while you're using it, another session finished with it: boot it again, remember it as yours, and carry on.

## iPhone app

1. Pick an available iPhone simulator on the newest iOS runtime. `scripts/test.sh` has a `simulator_id` helper that shows how.
2. Build:

   ```bash
   xcodebuild build -project Clinkr.xcodeproj -scheme Clinkr -destination "id=<iphone-udid>" -derivedDataPath build/DerivedData -quiet
   ```

3. The app is at `build/DerivedData/Build/Products/Debug-iphonesimulator/Clinkr.app`.
4. If the iOS Simulator tool is available, open its live panel first (`attach`) so the user can watch. Then `launch` the app with that path. Otherwise:

   ```bash
   xcrun simctl boot <iphone-udid> || true
   open -a Simulator
   xcrun simctl install <iphone-udid> build/DerivedData/Build/Products/Debug-iphonesimulator/Clinkr.app
   xcrun simctl launch <iphone-udid> com.colaiacovo.clinkr
   ```

## Watch app

1. Pick an available Apple Watch simulator on the newest watchOS runtime.
2. Build the `Clinkr Watch App` scheme the same way with `-destination "id=<watch-udid>"`.
3. The app is at `build/DerivedData/Build/Products/Debug-watchsimulator/Clinkr Watch App.app`. Its bundle ID is `com.colaiacovo.clinkr.watchkitapp`.
4. Install and launch it on the Watch simulator as above.

## Checking the result

The apps follow the simulator's language. To see them in Spanish (Argentina) or English whatever it's set to, add launch arguments, like `xcrun simctl launch --terminate-running-process <udid> <bundle-id> -AppleLanguages "(es-AR)" -AppleLocale es_AR`, or `"(en)"` and `en_US`. Check new text in both.

Take a screenshot and confirm the change is visible. Report what you saw. If the build fails, show the first error rather than the whole log.

## When you're done

Booted simulators keep using memory and CPU. Once the check is finished (at the end of `/verify-pr`, or when the user says they're done looking), shut down the ones you booted:

1. If you opened the iOS Simulator tool's live panel, close it (`detach`).
2. Shut down each simulator you booted, and only those. Another session or a `scripts/test.sh` run may be using the others, so never `shutdown all`:

   ```bash
   xcrun simctl shutdown <udid>
   ```

3. Quit the Simulator app if no simulator is left booted:

   ```bash
   xcrun simctl list devices booted | grep -q Booted || osascript -e 'quit app "Simulator"'
   ```
