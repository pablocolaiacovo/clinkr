# 2026-11-07 · CI archives a Release build

- **Decision:** `scripts/test.sh` (and so CI) makes an unsigned Release archive of the iPhone app, with the Watch app inside, before the tests. `scripts/test.sh release` runs only that step.
- **Why:** The tests build Debug, so code that only breaks in Release went unnoticed. A `#Preview` used `SavedNight.sampleNights()`, which exists only in Debug builds, and the Release archive crashed the compiler while CI stayed green. TestFlight (#27, #31) needs Release archives. The step takes about 20 seconds on a laptop and needs no simulator.
- **Instead of:** Archiving only when releasing, which finds the break after it has landed on `main`, when the person releasing no longer knows what caused it.
- **PR:** to be added
