import Foundation
import Testing

@testable import Clinkr_Watch_App

struct NightViewTests {
    private let start = Date(timeIntervalSinceReferenceDate: 0)

    private func night(lastEntryAfter hours: Double) -> Night {
        Night(
            name: "Test night",
            startTime: start,
            entries: [
                DrinkEntry(type: .beer, timestamp: start),
                DrinkEntry(type: .wine, timestamp: start.addingTimeInterval(hours * 3600)),
            ]
        )
    }

    @Test func theSavedMessageNeverClaimsAFailedSaveWorked() {
        #expect(NightSavedView.message(saved: true).key == "Night saved. Get home safe.")
        #expect(NightSavedView.message(saved: false).key == "Not saved. Get home safe.")
    }

    @Test func aNormalNightShowsOnlyTimes() {
        #expect(NightView.timeFormat(for: night(lastEntryAfter: 6)) == .dateTime.hour().minute())
    }

    @Test func aNightOverADayAlsoShowsTheWeekday() {
        #expect(
            NightView.timeFormat(for: night(lastEntryAfter: 25))
                == .dateTime.weekday(.abbreviated).hour().minute()
        )
    }
}
