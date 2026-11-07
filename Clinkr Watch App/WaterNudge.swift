import Foundation
import os

/// When to suggest a water break: after a few drinks in a row with no water, but rarely, so it stays friendly.
struct WaterNudge {
    static let drinksInARow = 4
    static let minimumGap: TimeInterval = 60 * 60
    static let quietAfterDismissal: TimeInterval = 30 * 60

    private(set) var lastShown: Date?
    private(set) var lastDismissed: Date?

    static func drinksSinceLastWater(in night: Night) -> Int {
        night.entries.reversed().prefix { $0.type.countsAsDrink }.count
    }

    /// Whether tonight ends in enough drinks in a row, ignoring the limits.
    static func isDue(in night: Night) -> Bool {
        drinksSinceLastWater(in: night) >= drinksInARow
    }

    func shouldShow(for night: Night, at date: Date) -> Bool {
        guard Self.isDue(in: night) else { return false }
        if let lastShown, date.timeIntervalSince(lastShown) < Self.minimumGap {
            Logger.nudge.info("Water nudge held back: shown less than an hour ago")
            return false
        }
        if let lastDismissed, date.timeIntervalSince(lastDismissed) < Self.quietAfterDismissal {
            Logger.nudge.info("Water nudge held back: dismissed less than 30 minutes ago")
            return false
        }
        Logger.nudge.debug("Water nudge due, waiting for the Undo toast")
        return true
    }

    mutating func markShown(at date: Date) {
        Logger.nudge.info("Water nudge shown")
        lastShown = date
    }

    mutating func markDismissed(at date: Date) {
        Logger.nudge.info("Water nudge dismissed with Later")
        lastDismissed = date
    }
}
