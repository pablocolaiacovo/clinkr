# 2026-11-06 · One file per decision

- **Decision:** Decisions live in `docs/decisions/`, one file each, named by date and title. `docs/DECISIONS.md` is gone.
- **Why:** Every pull request added its entry at the top of the one file, so any two open pull requests with a decision conflicted. Separate files never touch the same lines, and they stay in the repo, so they're added and reviewed in the same pull request and Claude can read them from the checkout.
- **Instead of:** A GitHub wiki, Discussions or issues, or Claude Docs, which all avoid the conflict but sit outside the pull request, so recording a decision would be a separate step that's easy to forget. Git's `merge=union` setting, which GitHub ignores, so pull requests would still show the conflict. Numbered files, which two open pull requests would both number the same.
