# 2026-11-03 · The repo stays public

- **Decision:** The repo is public, with GitHub's free code scanning, secret scanning and push protection on. A "Protect main" ruleset blocks force-pushes and deleting `main`, with no bypass, and sits beside the "CI must pass" ruleset, which admins can bypass.
- **Why:** On a private repo under a personal plan, GitHub stops enforcing rulesets, turns off scanning and charges for macOS CI, and the free allowance only covers about 20 to 25 runs a month. The security products can't be bought without a Team or Enterprise plan. The rule is separate so direct pushes to `main` stay possible while force-pushes never are.
- **Instead of:** Private on GitHub Pro, which brings the rulesets back but not the scanning, and still runs out of CI minutes in a busy week.
- **PR:** [#71](https://github.com/pablocolaiacovo/clinkr/pull/71)
