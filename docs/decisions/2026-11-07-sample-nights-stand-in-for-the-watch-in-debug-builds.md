# 2026-11-07 · Sample nights stand in for the Watch in Debug builds

- **Decision:** Launching a Debug build of the iPhone app with `-SampleNights` fills an in-memory database with a dozen made-up nights over the last few months. It's off by default in the Clinkr scheme, and the iPhone UI tests turn it on.
- **Why:** The simulators can't send nights from the Watch to the iPhone, and real devices wait for the paid developer account (#27), so the History screen had no way to show data. In memory, the samples never mix with real nights and come back fresh on every launch.
- **Instead of:** Seeding the real database, which would leave fake nights behind, or a hidden debug menu, which is more UI to keep.
- **PR:** [#95](https://github.com/pablocolaiacovo/clinkr/pull/95)
