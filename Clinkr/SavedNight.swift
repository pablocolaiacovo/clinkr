import Foundation
import SwiftData

/// A finished night kept on the iPhone. SwiftData, Apple's on-device database, stores one row per night.
@Model
final class SavedNight {
    var id: UUID
    var name: String
    var startTime: Date
    var endTime: Date?
    var entries: [DrinkEntry]

    init(_ night: Night) {
        id = night.id
        name = night.name
        startTime = night.startTime
        endTime = night.endTime
        entries = night.entries
    }

    var night: Night {
        Night(id: id, name: name, startTime: startTime, endTime: endTime, entries: entries)
    }

    /// Adds a night unless it's already saved, so a resend from the Watch makes no duplicate and doesn't undo a rename.
    /// Saves either way, which also retries a night whose earlier save failed. Returns whether it was new.
    @discardableResult
    static func insertIfNew(_ night: Night, into context: ModelContext) throws -> Bool {
        let id = night.id
        let matching = FetchDescriptor<SavedNight>(predicate: #Predicate { $0.id == id })
        let isNew = try context.fetchCount(matching) == 0
        if isNew {
            context.insert(SavedNight(night))
        }
        try context.save()
        return isNew
    }
}

extension SavedNight {
    static func delete(_ nights: [SavedNight], from context: ModelContext) throws {
        for night in nights {
            context.delete(night)
        }
        try context.save()
    }

    /// The nights in each month, newest month first. `nights` must already be newest first, as the History screen
    /// queries them.
    static func byMonth(
        newestFirst nights: [SavedNight],
        calendar: Calendar = .current
    ) -> [(month: Date, nights: [SavedNight])] {
        var months: [(month: Date, nights: [SavedNight])] = []
        for night in nights {
            let month = calendar.dateInterval(of: .month, for: night.startTime)?.start ?? night.startTime
            if months.last?.month == month {
                months[months.count - 1].nights.append(night)
            } else {
                months.append((month, [night]))
            }
        }
        return months
    }

    /// The V1 name, like "Noche del viernes", made from the date in the phone's language. The Watch's placeholder in
    /// `name` isn't shown; playful names replace this in #21.
    var defaultName: String {
        String(
            localized: "Noche del \(startTime.formatted(.dateTime.weekday(.wide)))",
            comment: "Default night name. The value is the weekday it started, like \"viernes\""
        )
    }
}

#if DEBUG
    extension SavedNight {
        /// Nights over the last three months, for trying the History screen in the simulator, where no Watch sends any.
        /// Launch with `-SampleNights` (in the Clinkr scheme, off by default) to get them in an in-memory database.
        static func sampleNights(now: Date = .now) -> [Night] {
            let drinks: [[DrinkType]] = [
                [.beer, .beer, .water, .cocktail, .shot, .shot, .beer],
                [.wine, .wine, .water, .wine],
                [.beer, .shot, .beer, .water, .water],
                [.cocktail, .cocktail, .beer, .wine, .shot, .water, .cocktail],
                [.water],
                [.beer, .beer, .beer],
            ]
            return (drinks + drinks).enumerated().map { index, types in
                let start = now.addingTimeInterval(-Double(index) * 9 * 24 * 3600 - 6 * 3600)
                let entries = types.enumerated().map { offset, type in
                    DrinkEntry(type: type, timestamp: start.addingTimeInterval(Double(offset) * 25 * 60))
                }
                return Night(
                    name: "Sample",
                    startTime: start,
                    endTime: start.addingTimeInterval(4 * 3600),
                    entries: entries
                )
            }
        }
    }
#endif
