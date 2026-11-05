import Foundation
import SwiftData
import Testing

@testable import Clinkr

struct ClinkrTests {
    // Unit tests run inside the app, so Bundle.main is the iPhone app.
    @Test func bundleIdentifierIsSet() {
        #expect(Bundle.main.bundleIdentifier == "com.colaiacovo.clinkr")
    }
}

@MainActor
struct SavedNightTests {
    private let start = Date(timeIntervalSinceReferenceDate: 0)
    private let folderURL = URL.temporaryDirectory.appending(path: "SavedNightTests-\(UUID())")

    private func night() -> Night {
        var night = Night(name: "Oct 29", startTime: start)
        night.add(DrinkEntry(type: .beer, timestamp: start.addingTimeInterval(60)))
        night.add(DrinkEntry(type: .water, timestamp: start.addingTimeInterval(120)))
        night.end(at: start.addingTimeInterval(3600))
        return night
    }

    /// Kept here because a context stops working once its container is gone.
    private let container: ModelContainer

    init() throws {
        container = try ModelContainer(
            for: SavedNight.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    private func savedNights(in context: ModelContext) throws -> [SavedNight] {
        try context.fetch(FetchDescriptor<SavedNight>())
    }

    @Test func aNightSurvivesAnAppRestart() throws {
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folderURL) }
        let configuration = ModelConfiguration(url: folderURL.appending(path: "test.store"))
        let original = night()

        do {
            let firstRun = try ModelContainer(for: SavedNight.self, configurations: configuration)
            try SavedNight.insertIfNew(original, into: firstRun.mainContext)
        }

        let secondRun = try ModelContainer(for: SavedNight.self, configurations: configuration)
        #expect(try savedNights(in: secondRun.mainContext).map(\.night) == [original])
    }

    @Test func aResendMakesNoDuplicate() throws {
        let context = container.mainContext
        let night = night()

        try SavedNight.insertIfNew(night, into: context)
        try SavedNight.insertIfNew(night, into: context)

        #expect(try savedNights(in: context).count == 1)
    }

    @Test func aResendKeepsARename() throws {
        let context = container.mainContext
        let night = night()
        try SavedNight.insertIfNew(night, into: context)
        try savedNights(in: context).first?.name = "Birthday"

        try SavedNight.insertIfNew(night, into: context)

        #expect(try savedNights(in: context).map(\.name) == ["Birthday"])
    }

    @Test func differentNightsAreBothKept() throws {
        let context = container.mainContext

        try SavedNight.insertIfNew(night(), into: context)
        try SavedNight.insertIfNew(night(), into: context)

        #expect(try savedNights(in: context).count == 2)
    }
}
