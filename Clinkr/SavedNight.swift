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
    /// Saves either way, which also retries a night whose earlier save failed.
    static func insertIfNew(_ night: Night, into context: ModelContext) throws {
        let id = night.id
        let matching = FetchDescriptor<SavedNight>(predicate: #Predicate { $0.id == id })
        if try context.fetchCount(matching) == 0 {
            context.insert(SavedNight(night))
        }
        try context.save()
    }
}
