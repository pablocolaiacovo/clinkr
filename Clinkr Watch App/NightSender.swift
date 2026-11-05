import Foundation
@preconcurrency import WatchConnectivity
import os

/// Sends finished nights to the iPhone. `transferUserInfo` is Apple's queued delivery: it carries on while either app
/// isn't running. A night leaves the store's queue only once the system reports it delivered, so a transfer that fails
/// is sent again the next time the app comes and goes.
@MainActor
final class NightSender: NSObject {
    private let store: NightStore
    /// What to send once the session is active, since sending before that is a programmer error.
    private var nightsToSend: [Night] = []
    private nonisolated let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Clinkr",
        category: "NightSender"
    )

    init(store: NightStore) {
        self.store = store
        super.init()
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func send(_ nights: [Night]) {
        nightsToSend = nights
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        let inFlight = Set(session.outstandingUserInfoTransfers.compactMap { try? Night(transfer: $0.userInfo).id })
        for night in nights where !inFlight.contains(night.id) {
            do {
                session.transferUserInfo(try night.transferUserInfo())
            } catch {
                logger.error("Couldn't encode night \(night.id): \(error)")
            }
        }
    }
}

extension NightSender: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        if let error {
            logger.error("Couldn't activate the session: \(error)")
        }
        Task { @MainActor in
            send(nightsToSend)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didFinish userInfoTransfer: WCSessionUserInfoTransfer,
        error: (any Error)?
    ) {
        if let error {
            logger.error("Couldn't deliver a night: \(error)")
            return
        }
        guard let id = try? Night(transfer: userInfoTransfer.userInfo).id else { return }
        Task { @MainActor in
            store.removePendingNight(id: id)
        }
    }
}
