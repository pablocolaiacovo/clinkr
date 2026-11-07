# 2026-11-04 · `/verify-pr` is the one review on every pull request

- **Decision:** Every pull request gets a `/verify-pr` before merging, however small. With a linked issue it checks the acceptance criteria too. Without one it only does the code review (`/ponytail-review`) and records the result. `/code-review` is optional, for changes where a bug hunt is worth it.
- **Why:** Two reviews on the same PR repeated each other, and `/verify-pr` already ran a review. One required review keeps the process short, and PRs without an issue use the same skill.
- **Instead of:** Requiring both. The cost is that `/ponytail-review` checks logic, safety, tests and unneeded code, not the bug hunt `/code-review` does, so a plain bug can pass.
- **PR:** [#76](https://github.com/pablocolaiacovo/clinkr/pull/76)
