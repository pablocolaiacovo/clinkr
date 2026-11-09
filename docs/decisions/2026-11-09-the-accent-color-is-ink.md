# 2026-11-09 · The accent color is ink

- **Decision:** Both apps' `AccentColor` is `ink`: `ink-light` with an `ink` dark appearance on the iPhone, and `ink` on the Watch, which is always dark. System controls that use the tint (back buttons, links, alert buttons, the text cursor, toggles, a future tab bar's selected tab) show the primary text color instead of Apple's default blue.
- **Why:** The system draws the tint as text, so `fizz` would break The Fill, Not Text Rule and add a second `fizz` element to screens that already have one. As a fill it would get white text, which the design system never puts on a pop color. `careful` is kept for pace alerts. `ink` reads at 17:1 or more on every background in both themes.
- **Watch out:** In dark mode `ink` is cream, and white on it is 1.1:1. So no screen uses a system prominent style (`.borderedProminent`, `.glassProminent`), which put white text on the tint. Primary actions use the design system's pills, as they already do.
- **Instead of:** `fizz` for the reasons above, or a different color per app, which would make the same control look different on the iPhone and the Watch for no gain.
- **Issue:** [#94](https://github.com/pablocolaiacovo/clinkr/issues/94)
