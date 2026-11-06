# 2026-10-30 · End night has no confirmation

- **Decision:** The Night screen is the third Watch page. "End night" sits at the top in `fizz` and ends the night on one tap, with the `.success` haptic and "Night saved. Get home safe." with an Undo for 5 seconds, then Tonight is empty. Rows are removed with a swipe and a tap on the trash (no full swipe, since a removal has no Undo).
- **Why:** "One tap, no thinking" and no confirmation dialogs; Undo covers a mistaken end, like it covers a mistaken add. Ending is the last thing done in a night, so it goes first on the page rather than below a long list.
- **Instead of:** A confirmation alert, or the button at the end of the list, where it would take a lot of scrolling on a big night.
- **PR:** [#69](https://github.com/pablocolaiacovo/clinkr/pull/69)
