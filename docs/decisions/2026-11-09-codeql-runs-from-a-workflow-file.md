# 2026-11-09 · CodeQL runs from a workflow file

- **Decision:** CodeQL scans from `.github/workflows/codeql.yml` instead of GitHub's default setup. Pull requests and pushes to `main` run it only when Swift files, the Xcode project or a workflow change, plus once a week. Each scan stops after 40 minutes, and the Swift scan builds the iPhone scheme once (which builds the Watch app too) rather than letting Autobuild guess.
- **Why:** The default setup ran the full Swift build on every push, including PR #99, which changed only color assets, docs and a shell script. After that PR was merged, its scan hung for 52 minutes when GitHub's macOS runner lost contact, and default setup runs can't be retried or given a time limit. A Swift scan normally takes 14 to 24 minutes.
- **Instead of:** Keeping default setup and waiting for the next push or the weekly scan after each flake, or adding a "changes" job like CI's, which would need more code for the same result here.
- **PR:** [#100](https://github.com/pablocolaiacovo/clinkr/pull/100)
