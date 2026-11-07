# 2026-11-07 · One test run at a time

- **Decision:** `scripts/test.sh` takes a lock (`/tmp/clinkr-test.lock`) before it runs the iPhone or Watch tests, so a second run on the same Mac waits for the first. A lock left by a killed run is cleared, by checking whether its process is still alive. Lint doesn't wait.
- **Why:** The script always picks the same simulators, so two runs at once, for example from agents in different worktrees, shared one simulator and both hung for over an hour.
- **Instead of:** A fresh iPhone and Watch simulator for each run, which would let runs overlap, but costs 30 to 60 seconds to start, a few GB of memory per simulator, and cleanup that has to survive failed and killed runs. Two UI test suites at once on a laptop are slow and flaky anyway.
- **PR:** [#93](https://github.com/pablocolaiacovo/clinkr/pull/93)
