# 2026-10-29 · One data model in `Shared/`

- **Decision:** `DrinkType`, `DrinkEntry` and `Night` live in `Shared/`, compiled into both apps, and are `Codable`. Pace is left out for nights under 15 minutes.
- **Why:** Both apps work with the same nights, which need to travel between the Watch and the iPhone. A one-hour floor on pace would understate short nights.
- **PR:** [#47](https://github.com/pablocolaiacovo/clinkr/pull/47)
