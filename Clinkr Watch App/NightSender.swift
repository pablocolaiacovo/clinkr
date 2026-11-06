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
            Logger.sync.info("Activating the session again")
            session.activate()
            return
        }
        // Sending before the session is active is a programmer error. Activating calls this again.
        guard session.activationState == .activated else {
            Logger.sync.debug("Not sending yet: the session isn't active")
            return
        }
        let nights = Self.nightsToTransfer(
            store.nightsReadyToSend,
            outstanding: session.outstandingUserInfoTransfers.map(\.userInfo)
        )
        Logger.sync.debug(
            "\(self.store.nightsReadyToSend.count) nights ready, \(nights.count) not already on the way"
        )
        for night in nights {
            do {
                session.transferUserInfo(try night.transferUserInfo())
                Logger.sync.info("Sent night \(night.id, privacy: .public)")
            } catch {
                Logger.sync.error("Couldn't encode night \(night.id, privacy: .public): \(error, privacy: .public)")
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
        ) { error in
            if let error {
                Logger.sync.error("Couldn't schedule a retry: \(error, privacy: .public)")
            } else {
                Logger.sync.debug("Scheduled a retry")
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
            Logger.sync.error("Couldn't activate the session: \(error, privacy: .public)")
        } else {
            Logger.sync.info("Session activated, state \(activationState.rawValue)")
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
        guard let error else {
            Logger.sync.debug("A night reached the iPhone")
            return
        }
        Logger.sync.error("Couldn't deliver a night: \(error, privacy: .public)")
        Task { @MainActor in
            scheduleRetryIfNeeded()
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        guard let id = Night.savedID(fromReceipt: userInfo) else { return }
        Logger.sync.info("The iPhone saved night \(id, privacy: .public)")
        Task { @MainActor in
            store.removePendingNight(id: id)
        }
    }
}
