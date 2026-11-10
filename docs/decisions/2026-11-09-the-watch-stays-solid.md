# 2026-11-09 · The Watch stays solid

- **Decision:** The Watch's Undo toast and the ghost "Después" pill keep their solid `surface-raised` fill. Liquid Glass in Clinkr is the iPhone's system bars and sheets, used as they are, plus the app icon. The glass split in DESIGN.md is now decided rather than proposed.
- **Why:** Tried on the smallest Watch simulator (SE 3 40mm, watchOS 27) with `.glassEffect()` on the toast and the `.glass` button style on the pill ([screenshots](../images/2026-11-09-watch-glass.png): solid on top, glass below). Over the ring the glass toast looked fine (9.3:1), but on the Add page it floats over the drink buttons, so `cocktail` and `shot` showed through it, breaking The Content Stays Solid Rule, and its cream message fell to 2.75:1, under 4.5:1. Reduce Transparency fixed the contrast (13.5:1) only by making the glass nearly opaque, which is the solid toast again. The pill sits on flat black, where glass has nothing to refract and only turned the fill into a grey sheen. The solid toast reads at 13.7:1 everywhere.
- **Instead of:** Glass on the toast only over Tonight, which would make one control look different depending on the page under it.
- **Also:** Checked in the simulator only. A look on a real Watch is in #31's real-device checks.
- **PR:** pending
