# 2026-11-06 · Real-device checks wait for the V1 beta in #31

- **Decision:** A criterion only a real iPhone or Watch can show is deferred to the **Real-device checks** section of #31 (TestFlight beta). The source issue marks it "checked in #31" and can close once its simulator checks pass. `/verify-pr` counts these as Deferred, not Can't verify.
- **Why:** There's no paid developer account yet (#27), so nothing can be installed on a device. Leaving those criteria in each issue kept issues open and PRs stuck on "Needs a manual check", with the device checks scattered across many issues.
- **Instead of:** Keeping issues open until a device test, or marking them `Part of #N`.
- **PR:** [#90](https://github.com/pablocolaiacovo/clinkr/pull/90)
