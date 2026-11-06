import Foundation
import Testing

@testable import Clinkr_Watch_App

@MainActor
struct TallyRingTests {
    @Test(arguments: [(0, 8), (1, 8), (8, 8), (9, 16), (16, 16), (17, 24)])
    func ringGrowsEightSlotsAtATime(drinks: Int, slots: Int) {
        #expect(TallyRing.slotCount(forDrinks: drinks) == slots)
    }

    @Test(arguments: [8, 16, 24, 32, 64, 200])
    func everySlotAlwaysDraws(slots: Int) {
        for slot in 0..<slots {
            let arc = TallyRing.arc(forSlot: slot, slots: slots, inset: 0.03)
            #expect(arc.upperBound > arc.lowerBound)
            #expect(arc.lowerBound >= 0 && arc.upperBound <= 1)
        }
    }

    @Test func waterRingFillsWithWatersAgainstDrinks() {
        #expect(TallyRing.waterFraction(waters: 0, drinks: 4) == 0)
        #expect(TallyRing.waterFraction(waters: 1, drinks: 4) == 0.25)
        #expect(TallyRing.waterFraction(waters: 6, drinks: 4) == 1)
    }

    @Test func waterWithNoDrinksFillsTheRing() {
        #expect(TallyRing.waterFraction(waters: 2, drinks: 0) == 1)
    }

    @Test func bubblesRiseOnlyForASingleAddedDrink() {
        #expect(TallyRing.addedSlot(from: [.beer], to: [.beer, .wine]) == 1)
        #expect(TallyRing.addedSlot(from: [], to: [.shot]) == 0)
        #expect(TallyRing.addedSlot(from: [.beer, .wine], to: [.beer]) == nil)
        #expect(TallyRing.addedSlot(from: [], to: [.beer, .wine]) == nil)
        #expect(TallyRing.addedSlot(from: [.beer], to: [.wine, .beer]) == nil)
    }
}

@MainActor
struct TonightCaptionTests {
    private func spanish(_ text: LocalizedStringResource) -> String {
        var text = text
        text.locale = Locale(identifier: "es_AR")
        return String(localized: text)
    }

    @Test func aFailedSaveReplacesTheCaption() {
        let caption = TonightView.caption(forNightStartingAt: .now, saveFailed: true)
        #expect(spanish(caption) == "Sin guardar")
    }

    private func caption(atHour hour: Int) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let start = calendar.date(from: DateComponents(year: 2026, month: 10, day: 30, hour: hour))!
        return TonightView.caption(forNightStartingAt: start, saveFailed: false, calendar: calendar).key
    }

    @Test(arguments: [5, 12, 16])
    func daytimeStartIsToday(hour: Int) {
        #expect(caption(atHour: hour) == "Today")
    }

    @Test(arguments: [17, 21, 0, 4])
    func eveningOrLateStartIsTonight(hour: Int) {
        #expect(caption(atHour: hour) == "Tonight")
    }
}
