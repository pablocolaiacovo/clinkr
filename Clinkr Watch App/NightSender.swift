import Foundation
@preconcurrency import WatchConnectivity
import WatchKit
import os

/// Sends finished nights to the iPhone. `transferUserInfo` is Apple's queued delivery: it carries on while either app
/// isn't running. A night leaves the store's queue only when the iPhone says it's saved. Until then it's sent again
/// whenever the app comes and goes, and by a background refresh, so nobody has to open the app after the night is over.
@MainActor
final class NightSender: NSObject {
    /// Names the background refresh that retries sending.
    nonisolated static let retryTask = "sendNights"
    private static let retryDelay: TimeInterval = 15 * 60

    private let store: NightStore
    private var activationFailed = false
    private nonisolated let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Clinkr",
        category: "NightSender"
    )

    init(store: NightStore) {
        self.store = store
        super.init()
        guard WCSession.isSupported() else { return }
        store.onNightsReady = { [weak self] in self?.send() }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func send() {
        let session = WCSession.default
        if activationFailed {
            activationFailed = false
            session.activate()
            return
        }
        // Sending before the session is active is a programmer error. Activating calls this again.
        guard session.activationState == .activated else { return }
        let nights = Self.nightsToTransfer(
            store.nightsReadyToSend,
            outstanding: session.outstandingUserInfoTransfers.map(\.userInfo)
        )
        for night in nights {
            do {
                session.transferUserInfo(try night.transferUserInfo())
            } catch {
                logger.error("Couldn't encode night \(night.id): \(error)")
            }
        }
    }

    /// Leaves out the nights already on their way.
    static func nightsToTransfer(_ nights: [Night], outstanding: [[String: Any]]) -> [Night] {
        let inFlight = Set(outstanding.compactMap(Night.transferredID(from:)))
        return nights.filter { !inFlight.contains($0.id) }
    }

    func scheduleRetryIfNeeded() {
        guard !store.pendingNights.isEmpty else { return }
        WKApplication.shared().scheduleBackgroundRefresh(
            withPreferredDate: .now + Self.retryDelay,
            userInfo: Self.retryTask as NSString
        ) { [logger] error in
            if let error {
                logger.error("Couldn't schedule a retry: \(error)")
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
            activationFailed = activationState != .activated
            if !activationFailed {
                send()
            }
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didFinish userInfoTransfer: WCSessionUserInfoTransfer,
        error: (any Error)?
    ) {
        guard let error else { return }
        logger.error("Couldn't deliver a night: \(error)")
        Task { @MainActor in
            scheduleRetryIfNeeded()
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        guard let id = Night.savedID(fromReceipt: userInfo) else { return }
        Task { @MainActor in
            store.removePendingNight(id: id)
        }
    }
}
