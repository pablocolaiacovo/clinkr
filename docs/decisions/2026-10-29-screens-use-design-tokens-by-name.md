# 2026-10-29 · Screens use design tokens by name

- **Decision:** Colors, text styles, spacing, radii and drink glyphs live in `Shared/` and come from the [design system](https://claude.ai/artifact/MUR9q8zqsWysfgui8mdNsh). Screens use them by name, never raw values or emoji.
- **Why:** Both apps stay consistent with the design system, and a change to a token changes every screen at once.
- **PR:** [#59](https://github.com/pablocolaiacovo/clinkr/pull/59)
