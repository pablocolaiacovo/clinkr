# 2026-11-06 · Re-run `/verify-pr` after any push when a criterion is Met

- **Decision:** If `/verify-pr` marked any acceptance criterion Met, run it again after every push to the PR, however small. If it marked none Met, re-run only for more than small tweaks. After merging, `/verify-pr` stops early when nothing is Met, before comparing commits.
- **Why:** After merging, `/verify-pr` only ticks an issue's boxes when its last check was on the merged commit, so a box never claims work on code nobody checked. `CONTRIBUTING.md` let small fixes skip the re-run, so the check stopped after every such PR, even when there was nothing to tick, as on #82.
- **Instead of:** Dropping the commit check, which would let a later push break a Met criterion unnoticed, or moving the after-merge step into its own skill, which would have to keep the result comment's format in step with this one.
- **PR:** [#85](https://github.com/pablocolaiacovo/clinkr/pull/85)
