# 2026-11-06 · Double tap repeats the last drink only on the Tonight page

- **Decision:** On watches with double tap, the gesture presses the ring on Tonight, which adds the last drink again, and "Had one" on the water nudge. It does nothing on the Add and Night pages, and while the nudge is up it only means "Had one".
- **Why:** A double tap is made without looking, and SwiftUI sends it to the first control with the shortcut anywhere in the app, not the one on screen. Left on everywhere, it could log a drink from a page you aren't on, or a drink instead of a water over the nudge.
- **Instead of:** Double tap repeating the last drink from any page. The cost is that you have to swipe back to Tonight first.
- **PR:** [#78](https://github.com/pablocolaiacovo/clinkr/pull/78)
