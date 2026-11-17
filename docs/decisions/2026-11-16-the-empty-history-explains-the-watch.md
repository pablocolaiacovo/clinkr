# 2026-11-16 · The empty History explains the Watch

- **Decision:** Before the first night, the iPhone's History screen says how Clinkr works (log on the Watch, the night shows up here) and gives one next step from WatchConnectivity: pair an Apple Watch, install Clinkr from the iPhone's Watch app, or start a night. `NightReceiver` keeps that state, since a session has only one delegate.
- **Why:** Without a Watch, the iPhone app looked empty and gave no reason, which App Review can reject under guidelines 2.1 and 4.2, and new users had no way to know what to do next.
- **Instead of:** An onboarding carousel or a "seen onboarding" flag, which is more screens and state for something one empty state covers. Drink logging on the iPhone stays out, since the iPhone is for looking back.
