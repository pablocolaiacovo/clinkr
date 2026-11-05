---
name: Clinkr
description: A wrist-first drink counter, built around one round, chunky tap.
colors:
  fizz: "#FF5C39"
  beer: "#FFB81C"
  wine: "#E8478F"
  cocktail: "#C6F432"
  shot: "#B98CFF"
  water: "#4FD8FF"
  careful: "#FF6B81"
  careful-light: "#C4123A"
  on-pop: "#1A1220"
  bg: "#000000"
  bg-light: "#FFF6EA"
  surface: "#1C1A24"
  surface-light: "#FFFFFF"
  surface-raised: "#2A2735"
  surface-raised-light: "#FFEEDD"
  ink: "#FFF7EC"
  ink-light: "#1A1220"
  ink-muted: "#A89CAE"
  ink-muted-light: "#6B5D70"
  hairline: "#3A3646"
  hairline-light: "#1A1220"
typography:
  count-hero:
    fontFamily: "SF Pro Rounded"
    fontSize: "56px"
    fontWeight: 700
  watch-title:
    fontFamily: "SF Pro Rounded"
    fontSize: "20px"
    fontWeight: 600
  watch-body:
    fontFamily: "SF Pro Rounded"
    fontSize: "16px"
    fontWeight: 600
  watch-caption:
    fontFamily: "SF Pro Rounded"
    fontSize: "13px"
    fontWeight: 700
  display:
    fontFamily: "SF Pro Rounded"
    fontSize: "40px"
    fontWeight: 700
  title:
    fontFamily: "SF Pro Rounded"
    fontSize: "24px"
    fontWeight: 600
  body:
    fontFamily: "SF Pro Rounded"
    fontSize: "16px"
    fontWeight: 500
  label:
    fontFamily: "SF Pro Rounded"
    fontSize: "12px"
    fontWeight: 800
    letterSpacing: "0.08em"
rounded:
  chip: "12px"
  card: "22px"
  pill: "999px"
spacing:
  s1: "4px"
  s2: "8px"
  s3: "12px"
  s4: "16px"
  s6: "24px"
components:
  drink-button:
    backgroundColor: "{colors.beer}"
    textColor: "{colors.on-pop}"
    typography: "{typography.watch-body}"
    rounded: "{rounded.card}"
    padding: "12px 4px"
  water-button:
    backgroundColor: "{colors.water}"
    textColor: "{colors.on-pop}"
    typography: "{typography.watch-body}"
    rounded: "{rounded.pill}"
    padding: "12px 4px"
  button-primary:
    backgroundColor: "{colors.fizz}"
    textColor: "{colors.on-pop}"
    typography: "{typography.watch-body}"
    rounded: "{rounded.pill}"
    padding: "0 12px"
    height: "48px"
  button-nudge:
    backgroundColor: "{colors.water}"
    textColor: "{colors.on-pop}"
    typography: "{typography.watch-body}"
    rounded: "{rounded.pill}"
    height: "48px"
  button-ghost:
    backgroundColor: "{colors.surface-raised}"
    textColor: "{colors.ink}"
    typography: "{typography.watch-body}"
    rounded: "{rounded.pill}"
    height: "40px"
  button-undo:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.bg}"
    typography: "{typography.watch-body}"
    rounded: "{rounded.pill}"
    padding: "0 12px"
    height: "44px"
  toast:
    backgroundColor: "{colors.surface-raised}"
    textColor: "{colors.ink}"
    typography: "{typography.watch-body}"
    rounded: "{rounded.pill}"
    padding: "4px 4px 4px 12px"
  list-row:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.watch-body}"
    rounded: "{rounded.card}"
    height: "44px"
---

# Design System: Clinkr

## Overview

**Creative North Star: "The Clink"**

Everything in Clinkr is built around one physical moment: you tap, it clinks, the ring fills. Shapes are round and chunky, fills are solid, and every add answers with a haptic. A tap on a drink button also clinks, with a short spring. The system exists for a thumb in the dark, so one large target and one glance beat any detail that needs a steady hand.

The Watch is the built expression of this world: saturated color on pure black, where the off pixels disappear and only the content remains. Density is low and scale is loud. A single number and a ring fill Tonight, and the drink colors carry the meaning so the screen needs few words. Color does the playing, and the shapes stay simple enough that it never turns noisy.

The iPhone is not built yet. Its light theme, with warm cream and a sticker look, is specified but provisional, and is marked as such throughout this file. Shipped values live in `Shared/`, and the wider design system lives at https://claude.ai/artifact/MUR9q8zqsWysfgui8mdNsh. Keep all three in step.

**Key Characteristics:**
- Solid, saturated fills on black, with no outlines or gradients on the Watch
- Round everywhere: pills, large-radius cards, round-capped ring segments
- SF Pro Rounded at heavy weights, with nothing on the Watch lighter than semibold
- Flat on the Watch, with depth from tone alone
- Motion under 400ms and reduced under Reduce Motion, with a haptic on every add

## Colors

Six loud pop colors do the work against a quiet set of neutrals, and the color of a drink is its label.

### Primary
- **Fizz** (`fizz`): the brand and the primary action, such as End night. It's a hot coral, and it also marks the app icon (the big circle in the dark icon, the background in the light one) and the selected tab once that exists.

### Secondary
- **Beer** (`beer`): amber fill for beer.
- **Wine** (`wine`): berry fill for wine.
- **Cocktail** (`cocktail`): lime fill for cocktails.
- **Shot** (`shot`): lilac fill for shots.
- **Water** (`water`): cyan fill for water, the inner ring and the water break nudge. It's a drink color with a hero's role, and it never adds to the tally.

### Tertiary
- **Careful** (`careful`, `careful-light`): reserved for the opt-in pace alerts. No shipped screen uses it yet.

### Neutral
- **On Pop** (`on-pop`): text and glyphs on any pop fill, in both themes.
- **Background** (`bg`, `bg-light`): pure black on the Watch so the OLED stays off, and warm cream on the iPhone in light mode.
- **Surface** (`surface`, `surface-light`): Night screen rows on the Watch, and cards and sheets on the iPhone.
- **Surface Raised** (`surface-raised`, `surface-raised-light`): empty ring slots, the water ring's track, toasts and ghost pills.
- **Ink** (`ink`, `ink-light`): primary text, plus the fill of the Undo pill.
- **Ink Muted** (`ink-muted`, `ink-muted-light`): captions, timestamps and supporting text.
- **Hairline** (`hairline`, `hairline-light`): a quiet divider in dark, and the full-ink sticker outline in light. No shipped screen uses it yet.

The Watch is dark only and uses the unsuffixed values. The iPhone follows the system appearance and uses the `-light` values in light mode. The pop colors and `on-pop` are the same in both.

### Named Rules

**The One Fizz Rule.** One `fizz` element per screen. Its rarity is what makes it the primary action.

**The Fill, Not Text Rule.** Pop colors are fills, never text. Anything on them uses `on-pop`, never white. A glyph may stand alone in its drink color on a dark `bg`, but never on cream.

**The Careful Alone Rule.** `careful` always comes with an icon and words, and never shares a screen with a `fizz` fill, because the two sit close in hue.

**The Friendly Nudge Rule.** The water break nudge is drawn in `water`. A suggestion never borrows the look of an alert.

## Typography

**Display Font:** SF Pro Rounded (the system's `.rounded` design)
**Body Font:** SF Pro Rounded

**Character:** One round family at heavy weights, so letters share the shape language of the buttons and ring. Hierarchy comes from size and weight alone. Web previews of the design system fall back to Fredoka and Nunito, which are not part of the apps.

### Hierarchy

Sizes are points and scale with Dynamic Type. Line spacing is left to the system on shipped screens.

**Watch**
- **Count hero** (700, 56pt): the night's drink count in the center of the ring, and nothing else.
- **Watch title** (600, 20pt): screen titles and the nudge headline.
- **Watch body** (600, 16pt): button labels, list rows and one-line messages.
- **Watch caption** (700, 13pt): timestamps, units and counters, in `ink-muted`. Also the fallback for a drink name too long for its tile.

**iPhone (provisional)**
- **Display** (700, 40pt): once per screen, for the history header or recap headline.
- **Title** (600, 24pt): night names, card titles and section headers.
- **Body** (500, 16pt): paragraphs and recap copy.
- **Label** (800, 12pt, 0.08em, uppercase): dates and chip labels, in `ink-muted` unless on a fill.

### Named Rules

**The Hero Shrinks First Rule.** When space runs out, on a small Watch or at a large text size, the count shrinks before the caption and waters do. Labels stay readable.

**The Steady Count Rule.** Counts always use tabular figures, so the number doesn't jump as it ticks up.

**The Semibold Floor Rule.** Nothing on the Watch is lighter than semibold.

## Layout

The Watch is three vertical pages, moved with a swipe or the Digital Crown: Tonight, Add, then Night. Side margins and gaps are `s2`. Add is a two-column grid of drink buttons with a full-width water button beneath. Nothing tappable is shorter than 44pt, and a smaller visual, such as the 40pt ghost pill, keeps a 44pt tap area.

The ring fills whatever square Tonight leaves it, with the count, caption and waters inset inside it. The Undo toast covers the lower part of the ring on Tonight, so the ring never resizes. On Add it pushes the content up, so every button stays reachable.

Layout adapts to content rather than to breakpoints. A toast drops its Undo title, then stacks into a card, before its message is cut. A drink name falls back from `watch-body` to `watch-caption`, and at the largest text sizes the caption shrinks too. Layouts are sized for Spanish, which runs longer than English.

The iPhone plan is provisional: an `s4` screen gutter and card padding, `s6` between sections, and three tabs at most.

## Elevation & Depth

The Watch is flat. There are no shadows, and depth comes only from tone: `bg`, then `surface`, then `surface-raised`. The nudge and the Night saved message replace the screen rather than float above it. The Undo toast is the one exception, sitting over the lower part of the ring on Tonight.

### Shadow Vocabulary

- **Sticker (provisional)** (`0 4px 0 0` in `ink-light`, no blur): iPhone cards and primary buttons in light mode only, like a sticker on a page. It's defined in `Shared/`, but no screen uses it yet.

### Named Rules

**The Flat Wrist Rule.** No shadows on the Watch, ever. The `stickerShadow()` modifier draws nothing in dark mode, so it can't appear there.

## Shapes

Everything is round. The `card` radius (22px) echoes the Watch's own corner and is used on drink buttons and rows. The `pill` radius is for primary actions, Undo, toasts and the water button, which sets water apart from the drink tiles. The `chip` radius (12px) is planned for iPhone chips and tags. Ring segments and the water ring use round caps.

Drink glyphs are solid, chunky silhouettes on a 24pt grid with rounded joins, drawn as fills with no strokes. They're template images that take their color from context: `on-pop` on their drink's color, or the drink's color on a dark `bg`. They appear at 30pt on buttons and in the nudge, 20pt in rows, and 12pt beside a caption. Anything that isn't a drink uses an SF Symbol, in its `.fill` variant where one exists, and the UI uses no emoji.

## Components

Chunky and tactile throughout: big, solid fills you could hit with a thumb in the dark.

### Buttons
- **Shape:** full pills, except the drink tiles.
- **Primary:** a `fizz` pill, 48pt tall, with `on-pop` text. End night is the example, at the top of the Night screen.
- **Nudge action:** the same pill in `water`, for "Had one".
- **Ghost:** a `surface-raised` pill, 40pt tall in a 44pt tap area, for "Later".
- **Undo:** an `ink` pill with `bg` text, 44pt tall. It's the only `ink`-filled control on the Watch, so a mistap is easy to take back. It drops to its SF Symbol when space runs out.
- **States:** there are no hover or focus treatments on the Watch. Feedback is the spring and the haptic.

### Drink Button
The signature control. A solid tile in the drink's color with its 30pt glyph above the name, both in `on-pop`, using the `card` radius. Water is a full-width pill with the glyph beside the name.

Every tap plays the clink, which scales the button 1 → 0.92 → 1.06 → 1 over 380ms, with a click haptic for drinks and a rising tap for water.

### Tally Ring
The signature display. One segment per drink in its color, in the order added, with a 16pt stroke and round caps, and empty slots in `surface-raised`. A thin 5pt inner ring fills with `water` against the drink count, and is full once waters match drinks.

The ring grows 8 slots at a time, so it's never shown as full or over. Tapping it adds the last drink again. Two planned details are not built: the fizz bubbles (#23), and using the user's own plan for the night as the slot count.

### Undo Toast
A `surface-raised` capsule with a `watch-body` message and the Undo pill, shown for 5 seconds after every add. With VoiceOver on, it stays until the next add or an undo.

### Night Saved Message
A full-screen message on `bg` after End night, fading in with a success haptic: a centered `watch-title` line above the Undo pill. Undo lasts 5 seconds, or until the message is closed with VoiceOver on. Tapping the message closes it, and a tap that just misses Undo does nothing, so a near miss doesn't throw the undo away. If the last save failed, the line reads "Not saved. Get home safe.", and Tonight's caption reads "Not saved" in `ink-muted`.

### Water Break Nudge
A full-screen takeover on `bg`, not a banner: the water glyph and a `watch-title` headline, then tonight's totals in `ink` within a line of `ink-muted`, then the nudge and ghost pills. It arrives with a notification haptic and never plays sound. The opt-in pace alert is planned as the same layout in `careful`, with its alert glyph, stating facts such as "3 in 40 min".

### Night Rows
Rows on `surface` with the `card` radius, at least 44pt tall: a 20pt glyph in its drink color, the name, and a right-aligned time in `watch-caption`. Removing a row takes a swipe and then a tap on the trash.

### Navigation
System vertical pages on the Watch, inside a navigation stack that keeps content clear of the clock. No custom navigation.

### iPhone Cards and Chips (provisional)
Not built. In light mode the plan is white `surface` cards on cream, with a 2px outline in `hairline-light` and the sticker shadow. In dark mode they match the Watch's tonal surfaces. Chips use a drink-color fill, `on-pop` text and the `chip` radius.

Only `wine` reaches 3:1 against cream (3.43:1), and `fizz` falls just short (2.87:1), so every pop-colored card or chip on cream needs the outline. Chart marks get a thinner 1.5px outline for the same reason.

The design system specifies four planned iPhone components, whose full specs live there: `HistoryList`, `NightCard`, `NightRecap` and `TrendChart`. Water never appears in a stacked bar or trend chart, and every chart keeps a legend, so identity is never color alone.

## Do's and Don'ts

### Do:
- **Do** use tokens by name, as in `.foregroundStyle(.ink)`, `.typeStyle(.title)`, `Space.s4` and `type.glyph`.
- **Do** give every add a haptic: click for drinks, a rising tap for water, success for End night.
- **Do** keep motion under 400ms using `Motion.standard` (a 0.3s snappy curve), and replace slides with fades under Reduce Motion.
- **Do** tell drinks apart with glyphs and labels as well as color.
- **Do** check Watch screens in Spanish on the smallest Watch, and cut words before cutting size.
- **Do** keep tap targets at 44pt or more, even when the visual is smaller.

### Don't:
- **Don't** use raw colors, sizes or emoji on a screen.
- **Don't** use more than one `fizz` element on a screen.
- **Don't** put white on a pop color, or set text in a pop color.
- **Don't** add shadows, outlines or gradients on the Watch.
- **Don't** show the ring as full or over, or put a big night's count in red.
- **Don't** use confirmation dialogs. Offer Undo instead.
- **Don't** auto-play sound.
