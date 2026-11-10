# 2026-11-09 · A rename is kept apart from the Watch's name

- **Decision:** Renaming a night on the iPhone stores the new name in `SavedNight.customName`, and the screens show it instead of the weekday name. Clearing the name, or typing the default one, sets it back to `nil`.
- **Why:** The Watch's `name` is a placeholder that's never shown, and the weekday name is worked out when the screen draws so it follows the phone's language. A separate optional field keeps both: a resend from the Watch never touches it, and an unrenamed night still changes language with the phone. SwiftData adds the new optional field to existing databases on its own.
- **Instead of:** Writing the rename over `name`, which would leave no way to tell a rename from the Watch's placeholder.
- **Open:** Playful names in #21 can replace the default under `customName` without changing this.
- **PR:** #PR
