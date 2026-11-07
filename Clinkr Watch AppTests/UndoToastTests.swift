import Foundation
import Testing

@testable import Clinkr_Watch_App

@MainActor
struct UndoToastTests {
    private func message(_ type: DrinkType, count: Int, in locale: String = "es_AR") -> String {
        var message = UndoToast.message(for: type, count: count)
        message.locale = Locale(identifier: locale)
        return String(localized: message)
    }

    @Test func drinkMessageIsPluralizedInSpanish() {
        #expect(message(.beer, count: 1) == "¡Salud! Va 1.")
        #expect(message(.shot, count: 4) == "¡Salud! Van 4.")
    }

    @Test func waterHasItsOwnMessage() {
        #expect(message(.water, count: 2) == "¡Agüita! Van 2.")
    }

    @Test func englishIsAnAdaptation() {
        #expect(message(.beer, count: 4, in: "en_US") == "Cheers! That's 4.")
        #expect(message(.water, count: 1, in: "en_US") == "Water! That's 1.")
    }
}
