# 2026-11-04 · Resolve review conversations before merging

- **Decision:** A pull request can't merge while a review conversation is open. The rule is a pull request rule with no required approvals, in the "CI must pass" ruleset.
- **Why:** A review comment shouldn't get lost by merging past it.
- **Instead of:** Adding it to "Protect main", which has no bypass and would block the direct pushes to `main` that small changes use. The cost is that admins can bypass this rule too, so for the repo's owner it's a guard against forgetting, not a hard stop. People without admin access must now use a pull request to change `main`.
- **PR:** [#74](https://github.com/pablocolaiacovo/clinkr/pull/74)
