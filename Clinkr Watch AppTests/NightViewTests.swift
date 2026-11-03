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

    private func spanishSavedMessage(saveFailed: Bool) -> String {
        var message = NightSavedView.message(saveFailed: saveFailed)
        message.locale = Locale(identifier: "es_AR")
        return String(localized: message)
    }

    @Test func aSavedNightSaysSo() {
        #expect(spanishSavedMessage(saveFailed: false) == "Noche guardada. Volvé bien.")
    }

    @Test func aFailedSaveNeverClaimsTheNightIsSaved() {
        #expect(spanishSavedMessage(saveFailed: true) == "Sin guardar. Volvé bien.")
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
