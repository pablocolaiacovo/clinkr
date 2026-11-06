# 2026-10-30 · Comments only where code can't explain itself

- **Decision:** Comments are only for complex blocks that stay complex after simplifying, and for legally required headers. Changes delete unnecessary comments in the files they touch.
- **Why:** Clear names and small pieces explain code better than comments, which go stale.
- **PR:** [#62](https://github.com/pablocolaiacovo/clinkr/pull/62)
