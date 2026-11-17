# App Store submission notes

For the owner to copy into App Store Connect (#29, #30, #31).

## URLs to enter

- **Privacy Policy URL:** https://github.com/pablocolaiacovo/clinkr/blob/main/docs/PRIVACY.md
- **Support URL:** https://github.com/pablocolaiacovo/clinkr/blob/main/docs/SUPPORT.md

The repo is public (see `docs/decisions/2026-11-03-the-repo-stays-public.md`), so these pages open without signing in. Each page holds Spanish and English together. Once the changes are on `main`, check both links open in a private window.

## App Privacy: Data Not Collected

Answer that you do not collect data from this app. The app has no account, backend, network requests, analytics, ads or third-party SDKs. Nights are saved in a file on the Watch and a SwiftData database on the iPhone, and travel between the two with Apple's WatchConnectivity. The developer never receives any of it. Logs use `os.Logger` and MetricKit and stay on the device (`docs/decisions/2026-11-06-logs-stay-on-the-device.md`). Revisit this answer, and the policy, if analytics, crash reporting, iCloud (#34) or Apple Health (#35) are added.

## Export compliance

The app has no encryption of its own and makes no network requests, so it uses no non-exempt encryption. Answer that in App Store Connect. Setting `ITSAppUsesNonExemptEncryption` to `NO` in the build settings skips the question on each upload.

## Age rating

Apple computes the rating from the questionnaire, so answer honestly rather than aiming for a rating.

- **Applies:** "Alcohol, Tobacco, or Drug Use or References". Logging alcoholic drinks is the core of the app. Pick the frequency that honestly describes it.
- **Doesn't apply:** violence, sexual content or nudity, profanity, horror, gambling, medical or health information, mature themes, user-generated content, messaging, social features, ads, web access, loot boxes.

Apple's current definitions (https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions) put infrequent alcohol references at 13+ and frequent ones at 18+, and leave the frequency judgment to the questionnaire. Checked on 2026-11-16. The final rating is whatever App Store Connect computes, so confirm it there. Set availability only to countries where that rating is fine.

## App Review notes (paste this)

```
Clinkr is a drink counter for adults of legal drinking age. The iPhone app shows history only. Nights are created on the Apple Watch app, which is embedded in the iPhone app.

To review the full flow you need an iPhone paired with an Apple Watch:
1. Install the app on the iPhone. The Watch app installs on the paired Watch.
2. Open Clinkr on the Watch. The Tonight screen shows an empty ring.
3. Swipe to Add and tap a drink type or water. A toast with an Undo button shows for 5 seconds.
4. Swipe to Night and tap End night. The Watch says "Night saved. Get home safe."
5. After the 5-second undo window, open Clinkr on the iPhone. The night appears in History. Tap it to see the recap. A night can be renamed or deleted there.

A short screen recording of this flow: [LINK TO VIDEO: the owner adds it]

There is no account or login, and the app makes no network requests.

Guideline 1.4.3: Clinkr does not encourage excessive drinking.
- It never estimates blood alcohol and never comments on amounts. It has no sharing, leaderboards, streaks or scores. A count is a neutral fact, in the same tone at 1 or at 12.
- It logs water, and after 4 drinks in a row with no water it suggests a water break, at most once an hour.
- When a night ends it says "Get home safe".
- It is for adults of legal drinking age.
- All data stays on the user's devices. Nothing is collected or shared.
```

## Owner checklist

- [ ] Record a short screen recording of the Watch-to-iPhone flow and put its link in the review notes.
- [ ] Fill in the effective date in `docs/PRIVACY.md`.
- [ ] Merge to `main`, then enter the two URLs in App Store Connect.
- [ ] Answer the App Privacy (Data Not Collected), export compliance and age-rating questionnaires, and confirm the resulting rating.
- [ ] Enter a contact email for App Review in App Store Connect. It isn't public and isn't in the repo.
- [ ] Take screenshots per language, iPhone 6.9" and Apple Watch, per #30.
- [ ] Paste the review notes.
