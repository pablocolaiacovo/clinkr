# Debugging Clinkr

Both apps write to Apple's unified log (`os.Logger`), which stays on the device. Nothing is sent anywhere, so the App Store privacy answer stays "Data Not Collected".

## What gets logged

Everything uses one subsystem, `com.colaiacovo.clinkr`, set in `Shared/Log.swift`. The category says which part of the app wrote it:

| Category | App | What |
|---|---|---|
| `sync` | Both | WatchConnectivity: the session activating, each night sent and received (by id), receipts, duplicates skipped, delivery errors |
| `persistence` | Both | Watch: night started, entry added or removed, night ended or reopened, night dropped once the iPhone saved it, save and load errors. iPhone: night saved or already there, database errors |
| `nudge` | Watch | The water nudge shown, dismissed with Later, or held back by the hourly or 30-minute limit |
| `lifecycle` | Both | Launch, active, inactive and background, and background refreshes, so you can see when the Watch app was suspended |
| `metrics` | iPhone | MetricKit's daily reports (launch time, hangs, battery use, crashes), as JSON. MetricKit isn't available on watchOS |

Levels: `debug` is detail, `info` is a normal event, `error` is a failure. Console.app hides `debug` and `info` until you turn them on (below).

Night names are logged as `.private`, so they show as `<private>` unless the device has a logging profile installed. Ids, counts and drink types are public. A night is easiest to follow by its id: the Watch's `Ended night <id>` should be followed by `Sent night <id>`, then the iPhone's `Received night <id>` and `Sent the receipt`, then the Watch's `The iPhone saved night <id>` and `Dropped night <id>`.

## Reading logs in Console.app

1. Connect the iPhone to the Mac with a cable, unlock it, and open **Console.app** on the Mac.
2. Pick the iPhone under **Devices** in the sidebar and press **Start streaming**.
3. In **Action → Include Info Messages** and **Include Debug Messages**, turn both on.
4. In the search field, type `subsystem:com.colaiacovo.clinkr` and press Return. Add `category:sync` (or another category) to narrow it.

**Paired Watch:** the Watch can't be plugged in, so it reaches Console.app through its iPhone. With the iPhone connected and the Watch unlocked and nearby, the Watch appears under **Devices** too. Select it and use the same search. Add `process:"Clinkr Watch App"` to leave out the system. Streaming from a Watch is slower and can drop out when it sleeps, so for a whole night a sysdiagnose (below) is more reliable.

**Simulators** don't show in Console.app's device list. Stream from Terminal instead, using the simulator's id from `xcrun simctl list devices booted`:

```bash
xcrun simctl spawn <udid> log stream --level debug --predicate 'subsystem == "com.colaiacovo.clinkr"'
```

Add `&& category == "sync"` inside the quotes to narrow it. Simulators show private values, like night names, in the clear; only a real device shows `<private>`. The Simulator also can't deliver nights between the apps, so the Watch logs `Not sending yet: the session isn't active`.

## Crash reports

- **Xcode Organizer** (Window → Organizer → Crashes): crashes from TestFlight and App Store users who share analytics with developers, for the iPhone and the Watch app. They show up a day or so later, symbolicated.
- **TestFlight:** testers can send a crash report with a comment when the app crashes, and a screenshot with feedback. Both appear in App Store Connect under TestFlight → Feedback, and the crashes in Organizer.
- **On a device you can plug in:** Xcode → Window → Devices and Simulators → select the device → **View Device Logs**.
- **On the iPhone itself:** Settings → Privacy & Security → Analytics & Improvements → Analytics Data, entries starting with `Clinkr`. Watch crashes are there too once the Watch has synced them to the iPhone.
- **MetricKit:** the iPhone app also logs a day's crash and hang diagnostics under `metrics`, without any upload.

## Getting a sysdiagnose from a tester

A sysdiagnose is a bundle of the device's recent logs, including Clinkr's. Ask the tester to reproduce the problem, then right away:

- **iPhone:** press and hold both volume buttons and the side button for about a second, then let go. The phone vibrates briefly. After about 10 minutes it's ready in Settings → Privacy & Security → Analytics & Improvements → Analytics Data, as a file starting with `sysdiagnose_`. Tap it, then the share button, and send it (AirDrop, Mail or a file link; it can be a few hundred MB).
- **Apple Watch:** press and hold the Digital Crown and the side button for about a second, then let go. Wait about 10 minutes with the Watch near its iPhone. It then shows up on the iPhone in the same Analytics Data list, as `sysdiagnose_..._Watch...`.

Open it on the Mac by double-clicking the `.tar.gz`, then open `system_logs.logarchive` in Console.app and use the same search as above. Note the time the tester reproduced the problem, so you know where to look.

Night names in a sysdiagnose stay `<private>`.
