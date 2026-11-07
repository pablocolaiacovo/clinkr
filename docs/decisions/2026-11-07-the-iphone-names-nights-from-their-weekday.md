# 2026-11-07 · The iPhone names nights from their weekday

- **Decision:** In V1 the iPhone shows each night as "Noche del viernes" ("Friday night"), made from the weekday it started, in the phone's language when the screen draws. The name the Watch sends ("Oct 29") is a placeholder and isn't shown.
- **Why:** The issue asks for a simple default from the date that follows the language. Working it out at display time means switching the phone's language renames every night, which a stored name wouldn't.
- **Instead of:** Renaming the night when it's saved, which would freeze it in whatever language the phone had then.
- **Open:** A night that starts after midnight is named for the new day. Playful names and renaming come in #21, which will need to decide when a stored name wins over this default.
- **PR:** PR_LINK
