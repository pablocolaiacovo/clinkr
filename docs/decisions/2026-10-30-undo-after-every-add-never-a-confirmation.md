# 2026-10-30 · Undo after every add, never a confirmation

- **Decision:** After any add on the Watch, a toast offers Undo for 5 seconds. It pushes the screen's content up rather than covering it, so every drink button can still be reached. With VoiceOver on, it's read out and stays until the next add or an undo. Its strings live in a Watch-only `Localizable.xcstrings`.
- **Why:** Mistaps happen in the dark, and one tap should take them back. An overlay hid the bottom drink buttons on the 40mm Watch, and 5 seconds isn't enough to reach a button with VoiceOver.
- **Instead of:** Confirmation dialogs, which slow down every add, or putting Watch-only strings in `Shared.xcstrings`, which both apps include.
- **PR:** [#65](https://github.com/pablocolaiacovo/clinkr/pull/65)
