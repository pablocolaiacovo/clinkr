# 2026-11-06 · CI skips the build on docs-only pull requests

- **Decision:** A small `changes` job on Ubuntu diffs the pull request against its base with plain git. If every changed file is Markdown or under `docs/`, the **Build and test** job is skipped by a job-level `if:`. `DESIGN.md` and `.impeccable/` still run it, and so does every push to `main`.
- **Why:** Docs-only pull requests waited about 10 minutes on a macOS runner for nothing. A job skipped by `if:` reports as passing, so the required check doesn't block the merge. Lint compares `DESIGN.md` and the sidecar against `Shared/Palette.swift`, so those aren't docs-only. If the `changes` job fails, the build runs anyway, so a broken check never lets code through.
- **Instead of:** `paths-ignore` on the workflow, which leaves a required check pending forever and blocks the merge, or a third-party paths-filter action, which is one more dependency to trust and update for a few lines of shell.
- **PR:** [#88](https://github.com/pablocolaiacovo/clinkr/pull/88)
