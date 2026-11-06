# 2026-10-27 · One test script for local runs and CI

- **Decision:** `scripts/test.sh` runs lint and the iPhone and Watch tests, and GitHub Actions runs the same script.
- **Why:** What passes locally passes in CI, with one place to change.
- **PR:** [#2](https://github.com/pablocolaiacovo/clinkr/pull/2)
