# 2026-11-06 · Glass for controls, solid for content (proposed)

- **Decision:** If Clinkr adopts Liquid Glass, it's for the control and navigation layer only: the system bars, tab bar and sheets on the iPhone, and floating controls such as the Watch Undo toast. Drink buttons, the ring, rows, cards and charts stay solid. Nothing is built yet, and the Watch stays flat until a toast prototype on a device proves glass reads better than `surface-raised`.
- **Why:** The code requires iOS 26 and watchOS 26 but used no glass and the design system never said why. Apple's split is glass for controls floating above content, and the drink colors are the content and the brand, so a translucent fill would change what a drink looks like. Solid fills also suit a thumb in the dark.
- **Instead of:** Glass on everything, which hurts contrast and legibility, or no position at all, which left the sticker look (outlines and a hard shadow) on a collision course with the system bars.
- **Open:** Concentric corners against the fixed 22pt card radius, whether the sticker look survives next to system bars, and contrast of `on-pop` text on any tinted glass. The details are in `DESIGN.md`.
- **PR:** [#82](https://github.com/pablocolaiacovo/clinkr/pull/82)
