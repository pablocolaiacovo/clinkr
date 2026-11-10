# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

## Users

Adults of legal drinking age on a night out with friends, starting in Argentina. They want to keep track of the night, and nothing assumes they want to cut down. People actively trying to moderate are not the primary audience.

During the night, the user has a drink in the other hand, is often in the dark, and may be a little tipsy. The morning after, they're on their iPhone, wanting to know what happened.

## Product Purpose

Clinkr is a wrist-first drink counter for a night out. It has two jobs of equal weight:

- **During the night:** log with one tap on the Watch, and get a rare nudge to drink water.
- **The morning after:** see what happened through the recap and history on the iPhone.

Success means the night is easy to log, the user looks after themselves a little better, and they know what they did the night before.

## Positioning

A buddy, not a judge. Logging happens in one tap on the wrist, without taking out a phone, and the record becomes a memory of the night rather than a score. Water, friends and getting home are what the product celebrates.

## Operating Context

- The Watch is the tool during the night and the iPhone is the companion afterwards. The Watch app comes embedded in the iPhone app.
- The iPhone is planned for looking back, not logging: no adding drinks, and the only edits are renaming or deleting a night.
- A night starts with the first thing logged, water included. It ends with End night, or when the next entry comes after a 12-hour gap.
- Mistakes are expected, so every add and End night can be undone for 5 seconds, and there are no confirmation dialogs.
- Force-quitting, a restart or a dead battery must never lose tonight's drinks.

## Capabilities and Constraints

**Built:** the Watch screens Tonight, Add and Night, the Undo toast, the water break nudge, saving nights to a file on the Watch, sending them to the iPhone, and the iPhone's History and Night Recap screens.

**Not built yet:** the recap, Settings, Get home and most other features are open GitHub issues.

**Terminology:**
- A **night** is the unit of use, and **Tonight** is the current one.
- The drink types are beer, wine, cocktail, shot and water.
- Water is logged, but never counts as a drink.

**Constraints:**
- iOS 26+ and watchOS 26+, in SwiftUI.
- Apple's App Store Review Guideline 1.4.3 rejects apps that encourage excessive drinking.
- Watch button labels and toast messages must fit one line, including in Spanish, which runs longer than English. Cut words before cutting size. Longer messages, like the water break nudge, may wrap.

**Undecided:**
- The privacy position. Today's data lives on the Watch, and there is no account or backend, but iCloud backup (#34) and Apple Health (#35) are open ideas. Don't claim anything about privacy yet.
- The App Store age rating and listing (#29, #30).

## Brand Commitments

- **Name:** Clinkr.
- **Voice:** a friend at the bar. Short, warm and a bit cheeky, in second person and sentence case.
- **Language:** Spanish first, written in Argentine Spanish with voseo and local words, such as Birra and Trago. English comes second, as an adaptation in the same tone rather than a literal translation. Example: "Noche guardada. Volvé bien." becomes "Night saved. Get home safe."
- **Counts are friendly facts, not praise.** "Cheers! That's 4." acknowledges a tap and states a number, and the tone is the same at 1 or at 12.- **Never:** comment on body weight or blood alcohol, use guilt, or judge amounts. Safety copy is direct and kind. A week with no drinks reads "Night off", not a zero.
- **Design system:** the visual authority lives at https://claude.ai/artifact/MUR9q8zqsWysfgui8mdNsh and in `Shared/`.

## Evidence on Hand

- Real product copy is in `Clinkr Watch App/Localizable.xcstrings` and `Shared/Shared.xcstrings`.
- The reasons behind past decisions are in `docs/decisions/`, and the planned features are in the GitHub issues.
- The app is pre-release, on `0.x`, and not yet on TestFlight or the App Store. There are no users, testimonials, reviews, press or usage data. Don't fabricate any.

## Product Principles

1. **One tap, no thinking.** Every action during the night is one large target and one glance, usable tipsy and in the dark.
2. **Reward the night, never the number.** Fun features reward the night, friends, water and getting home. The tally is never a score or a streak to beat.
3. **Water is the hero, and nudges stay rare.** A nudge that comes too often turns into nagging. Pace and limits are opt-in and set by the user, and the default nudge is about water.
4. **Mistakes are cheap.** Undo instead of confirming.
5. **Never lose the night.** Remembering it is half the product, so the record has to survive anything.

## Accessibility & Inclusion

Every V1 screen must be checked on the Watch and iPhone simulators, in both Spanish and English (#14):

- VoiceOver labels on the ring, drink buttons, toasts and charts. Timed toasts stay until the next add or an undo when VoiceOver is on.
- Dynamic Type up to accessibility sizes.
- Reduce Motion turns off decorative motion.
- Drink colors are never the only way to tell things apart.
- Text contrast of at least 4.5:1 in both themes.
- The primary context, in the dark and possibly tipsy, is itself an accessibility requirement: large targets and glanceable content.
