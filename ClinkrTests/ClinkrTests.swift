import Foundation
import SwiftData
import Testing
@preconcurrency import WatchConnectivity

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

        #expect(try SavedNight.insertIfNew(night, into: context))
        #expect(try !SavedNight.insertIfNew(night, into: context))

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

    @Test func aDeletedNightStaysGoneAfterAnAppRestart() throws {
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folderURL) }
        let configuration = ModelConfiguration(url: folderURL.appending(path: "test.store"))
        let kept = night()

        do {
            let firstRun = try ModelContainer(for: SavedNight.self, configurations: configuration)
            try SavedNight.insertIfNew(night(), into: firstRun.mainContext)
            try SavedNight.insertIfNew(kept, into: firstRun.mainContext)
            let deleted = try savedNights(in: firstRun.mainContext).filter { $0.id != kept.id }
            try SavedNight.delete(deleted, from: firstRun.mainContext)
        }

        let secondRun = try ModelContainer(for: SavedNight.self, configurations: configuration)
        #expect(try savedNights(in: secondRun.mainContext).map(\.id) == [kept.id])
    }

    @Test func nightsAreGroupedByMonthNewestFirst() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        func saved(_ month: Int, _ day: Int) -> SavedNight {
            let date = calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: 22))!
            return SavedNight(Night(name: "", startTime: date))
        }
        let nights = [saved(10, 17), saved(10, 3), saved(9, 27), saved(8, 31), saved(8, 1)]

        let months = SavedNight.byMonth(newestFirst: nights, calendar: calendar)

        #expect(months.map { calendar.component(.month, from: $0.month) } == [10, 9, 8])
        let ids = nights.map(\.id)
        let expected: [[UUID]] = [[ids[0], ids[1]], [ids[2]], [ids[3], ids[4]]]
        #expect(months.map { $0.nights.map(\.id) } == expected)
    }

    @Test func differentNightsAreBothKept() throws {
        let context = container.mainContext

        try SavedNight.insertIfNew(night(), into: context)
        try SavedNight.insertIfNew(night(), into: context)

        #expect(try savedNights(in: context).count == 2)
    }
}

struct NightReceiverTests {
    private let container: ModelContainer

    init() throws {
        container = try ModelContainer(
            for: SavedNight.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    private func savedCount() async throws -> Int {
        try await MainActor.run { try container.mainContext.fetchCount(FetchDescriptor<SavedNight>()) }
    }

    /// Runs off the main thread, like the system's calls, since the receiver waits for the main thread to save.
    @Test func aNightIsSavedByTheTimeTheCallReturns() async throws {
        let receiver = await MainActor.run { NightReceiver(context: container.mainContext) }
        let night = Night(name: "Oct 29", startTime: .now)

        receiver.session(.default, didReceiveUserInfo: try night.transferUserInfo())

        #expect(try await savedCount() == 1)
    }

    @Test func aResentNightIsSavedOnce() async throws {
        let receiver = await MainActor.run { NightReceiver(context: container.mainContext) }
        let userInfo = try Night(name: "Oct 29", startTime: .now).transferUserInfo()

        receiver.session(.default, didReceiveUserInfo: userInfo)
        receiver.session(.default, didReceiveUserInfo: userInfo)

        #expect(try await savedCount() == 1)
    }

    @Test func aMessageWithNoNightSavesNothing() async throws {
        let receiver = await MainActor.run { NightReceiver(context: container.mainContext) }

        receiver.session(.default, didReceiveUserInfo: ["something": "else"])

        #expect(try await savedCount() == 0)
    }
}
