# 2026-10-30 · Check pull requests against their issue's acceptance criteria

- **Decision:** Each PR lists its issue's acceptance criteria with evidence, using the PR template, and `/verify-pr` checks each one with tests and the simulators. Results are recorded on the PR while it's open; the issue's boxes are ticked only after merging. A PR that leaves criteria for later says `Part of #N`, not `Closes #N`.
- **Why:** CI and `/code-review` check the code, not the requirements. #8 was closed by #63 with its boxes unticked, and a deferred criterion never reached #7.
- **Instead of:** A CI check that blocks merging on unticked boxes, which is stricter than a light workflow needs.
- **PR:** [#66](https://github.com/pablocolaiacovo/clinkr/pull/66)
