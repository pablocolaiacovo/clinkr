# 2026-11-03 · `/verify-pr` also runs `/ponytail-review`

- **Decision:** `/verify-pr` runs `/ponytail-review` on the PR's commit, and a Must fix finding makes the result **Not ready**, unless the PR explains why it doesn't apply. The result comment on the PR lists the findings and the result. (The part about `/code-review` being required is replaced by 2026-11-04 · `/verify-pr` is the one review on every pull request.)
- **Why:** It reads the code connected to the change, not only the diff, and explains each finding in plain English.
- **PR:** [#70](https://github.com/pablocolaiacovo/clinkr/pull/70)
