import Foundation
import Testing
@preconcurrency import WatchConnectivity

@testable import Clinkr_Watch_App

struct ClinkrWatchAppTests {
    // Unit tests run inside the app, so Bundle.main is the Watch app.
    @Test func bundleIdentifierIsSet() {
        #expect(Bundle.main.bundleIdentifier == "com.colaiacovo.clinkr.watchkitapp")
    }
}

@MainActor
struct NightSenderTests {
    private let fileURL = URL.temporaryDirectory.appending(path: "NightSenderTests-\(UUID()).json")

    private func storeWithAFinishedNight() throws -> (NightStore, Night) {
        let store = NightStore(fileURL: fileURL)
        store.add(.beer, at: Date(timeIntervalSinceReferenceDate: 0))
        store.endNight(at: Date(timeIntervalSinceReferenceDate: 600))
        return (store, try #require(store.pendingNights.first))
    }

    /// Delegate calls hop to the main actor in a task, so give that task a chance to run.
    private func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<1000 where !condition() {
            await Task.yield()
        }
    }

    @Test func nightsAlreadyOnTheirWayAreNotSentAgain() throws {
        let onItsWay = Night(name: "Oct 29", startTime: .now)
        let waiting = Night(name: "Oct 30", startTime: .now)

        let nights = NightSender.nightsToTransfer(
            [onItsWay, waiting],
            outstanding: [try onItsWay.transferUserInfo(), ["something": "else"]]
        )

        #expect(nights == [waiting])
    }

    @Test func aReceiptRemovesTheNight() async throws {
        let (store, night) = try storeWithAFinishedNight()
        let sender = NightSender(store: store)

        sender.session(.default, didReceiveUserInfo: Night.savedReceipt(id: night.id))
        await waitUntil { store.pendingNights.isEmpty }

        #expect(store.pendingNights.isEmpty)
    }

    @Test func aReceiptForAnotherNightKeepsThisOne() async throws {
        let (store, night) = try storeWithAFinishedNight()
        let sender = NightSender(store: store)

        sender.session(.default, didReceiveUserInfo: Night.savedReceipt(id: UUID()))
        for _ in 0..<100 {
            await Task.yield()
        }

        #expect(store.pendingNights == [night])
    }

    @Test func aMessageThatIsNotAReceiptKeepsTheNight() async throws {
        let (store, night) = try storeWithAFinishedNight()
        let sender = NightSender(store: store)

        sender.session(.default, didReceiveUserInfo: ["something": "else"])
        for _ in 0..<100 {
            await Task.yield()
        }

        #expect(store.pendingNights == [night])
    }
}
