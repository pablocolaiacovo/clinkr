# 2026-11-03 · A UI test for the Watch's main flow

- **Decision:** `Clinkr Watch AppUITests` runs one test on the real screens: add, Undo, the water nudge, End night and its Undo. Two more check that removing a drink calls off a waiting nudge, and that a failed save shows on screen. The app reads two settings only a test passes: `UNDO_SECONDS` makes Undo last longer, and `NIGHTS_FILE` names another file, which lets a test make saving fail. Each run ends any night left over from an earlier one, which leaves more finished nights in the simulator's file.
- **Why:** The timing of the toast, the nudge and End night's Undo lives in `ContentView`, where unit tests can't reach it, so breaking it failed no test. On CI, finding Undo and tapping it took longer than its 5 seconds, so no wait in the test could make it reliable.
- **Instead of:** Moving that timing out of the view only to test it, or leaving the Undo taps out of the test.
- **Also:** `scripts/test.sh` runs the Watch tests on its own simulator with no iPhone paired, because a paired Watch deletes the app mid-test when its iPhone doesn't have the iPhone app.
- **PR:** [#72](https://github.com/pablocolaiacovo/clinkr/pull/72)
