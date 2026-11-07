# 2026-10-29 · Save tonight on the Watch, in a file

- **Decision:** The Watch keeps tonight's night and the finished nights waiting for the iPhone in `nights.json`, written atomically after every change. A drink 12 hours or more after the last one ends the forgotten night and starts a new one.
- **Why:** Force-quitting the app, a restart or a dead battery must never lose tonight's drinks.
- **PR:** [#60](https://github.com/pablocolaiacovo/clinkr/pull/60)
