# 2026-11-03 · Product and design context live in `PRODUCT.md` and `DESIGN.md`

- **Decision:** `PRODUCT.md` records who Clinkr is for and why, and `DESIGN.md` records the look as built, with the iPhone's sticker look marked provisional until a real screen proves it. Both were written with the Impeccable plugin, which also generates `.impeccable/design.json` from `DESIGN.md`.
- **Why:** Design work, by people or agents, needs one place to read the product's purpose and visual rules, instead of piecing them together from issues, the decision log and the code.
- **Instead of:** Relying on the design system artifact alone, which sits outside the repo. The cost is more copies of the tokens: `DESIGN.md` and its sidecar, beside `Shared/` and the design system. `scripts/test.sh` fails if the colors in the two new files differ from `Shared/Palette.swift`. The design system sits outside the repo, so nothing can check it, and updating it is a step in `CONTRIBUTING.md`, like `/code-review`. Its README links back to the repo.
- **PR:** [#73](https://github.com/pablocolaiacovo/clinkr/pull/73)
