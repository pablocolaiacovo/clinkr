# 2026-11-07 · The sticker look stays next to the glass bar

- **Decision:** The History screen's month cards keep the light-mode sticker look (2px ink outline and hard shadow) under the system's glass navigation bar, which is used as it is. The cards are content, so they stay solid; the bar gets no outline, shadow or background of its own.
- **Why:** Checked in the iPhone simulator in light and dark, scrolled: the scroll-edge effect softens the cards as they pass under the title, and the outline never reads as part of the bar. Nothing clashed, so the open question in the glass decision is settled for this screen.
- **Instead of:** A quieter outline on iPhone cards, which would have lost the sticker look for no visible gain.
- **PR:** [#95](https://github.com/pablocolaiacovo/clinkr/pull/95)
