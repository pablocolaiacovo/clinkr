# 2026-10-30 · A water break nudge, rarely

- **Decision:** After 4 drinks in a row with no water, the Watch suggests a water break, at most once an hour and never within 30 minutes of a "Later". It shows tonight's totals as facts and offers "Had one", which logs a water. It waits until the drink's Undo toast has had its 5 seconds, so a mis-tapped drink can still be undone, and it closes if the streak no longer holds. The limits are kept in memory only, so a relaunch can show it again sooner.
- **Why:** Water is the app's hero, and a nudge that comes too often turns into nagging, which breaks the "a buddy, not a judge" rule.
- **Instead of:** A nudge based on pace or limits, which is the opt-in alert in #16.
- **PR:** [#68](https://github.com/pablocolaiacovo/clinkr/pull/68)
