# 2026-11-06 · Logs stay on the device

- **Decision:** Both apps log with Apple's `os.Logger` under one subsystem, `com.colaiacovo.clinkr`, in the categories `sync`, `persistence`, `nudge`, `lifecycle` and `metrics`. The iPhone app subscribes to MetricKit and logs its daily reports. Nothing is uploaded: no analytics events, no third-party crash reporter. Crashes come from Xcode Organizer and TestFlight, and a tester's logs from a sysdiagnose.
- **Why:** Sync and saving are hard to debug on real devices without logs, but anything sent off the device changes the App Store privacy answer from "Data Not Collected" (#29) and adds an SDK to a small hobby app. Night names are logged as `.private`, so a shared sysdiagnose doesn't show them, while ids and counts stay readable.
- **Instead of:** TelemetryDeck or Sentry, worth another look after launch along with the privacy answers. The cost is that we only see a problem when someone sends a sysdiagnose or shares analytics with developers. MetricKit isn't available on watchOS, so the Watch has no `metrics`, only the crash reports Organizer shows.
- **PR:** [#91](https://github.com/pablocolaiacovo/clinkr/pull/91)
