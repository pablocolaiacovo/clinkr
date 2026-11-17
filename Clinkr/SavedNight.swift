import Foundation
import SwiftData

/// A finished night kept on the iPhone. SwiftData, Apple's on-device database, stores one row per night.
@Model
final class SavedNight {
    var id: UUID
    /// The Watch's placeholder name. Never shown; see `displayName`.
    var name: String
    /// The name the user gave the night on the iPhone, or `nil` to use `defaultName`.
    var customName: String?
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

    /// Adds a night unless it's already saved or the user deleted it, so a resend from the Watch makes no duplicate,
    /// doesn't undo a rename and doesn't bring a deleted night back. Saves either way, which also retries a night whose
    /// earlier save failed. Returns whether it was added.
    @discardableResult
    static func insertIfNew(_ night: Night, into context: ModelContext) throws -> Bool {
        let id = night.id
        let saved = FetchDescriptor<SavedNight>(predicate: #Predicate { $0.id == id })
        let deleted = FetchDescriptor<DeletedNight>(predicate: #Predicate { $0.id == id })
        let isNew = try context.fetchCount(saved) == 0 && context.fetchCount(deleted) == 0
        if isNew {
            context.insert(SavedNight(night))
        }
        try context.save()
        return isNew
    }
}

/// The id of a night the user deleted, so a resend from the Watch is skipped instead of saved again. Kept for good:
/// a UUID per deleted night.
@Model
final class DeletedNight {
    var id: UUID

    init(id: UUID) {
        self.id = id
    }
}

extension SavedNight {
    /// A deleted night as it was, so Undo can put it back with its name.
    struct Copy: Equatable {
        let night: Night
        let customName: String?
    }

    /// Deletes the nights and remembers their ids in the same save. Returns what `restore` needs to undo it.
    @discardableResult
    static func delete(_ nights: [SavedNight], from context: ModelContext) throws -> [Copy] {
        let copies = nights.map { Copy(night: $0.night, customName: $0.customName) }
        for night in nights {
            context.insert(DeletedNight(id: night.id))
            context.delete(night)
        }
        try context.save()
        return copies
    }

    /// Puts deleted nights back and forgets they were deleted, so a resend from the Watch is a duplicate again.
    static func restore(_ copies: [Copy], into context: ModelContext) throws {
        let ids = copies.map(\.night.id)
        let deleted = FetchDescriptor<DeletedNight>(predicate: #Predicate { ids.contains($0.id) })
        for deletedNight in try context.fetch(deleted) {
            context.delete(deletedNight)
        }
        for copy in copies {
            let night = SavedNight(copy.night)
            night.customName = copy.customName
            context.insert(night)
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

    /// The name to show: the user's own if they renamed the night, else `defaultName`.
    var displayName: String {
        customName ?? defaultName
    }

    /// Keeps `newName` as the night's name. A blank name, or the default one, goes back to the default, so the
    /// night still follows the phone's language.
    func rename(to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        customName = trimmed.isEmpty || trimmed == defaultName ? nil : trimmed
    }

    /// The V1 name, like "Noche del viernes", made from the date in the phone's language. Playful names replace
    /// this in #21.
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
