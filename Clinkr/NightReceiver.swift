import Foundation
import SwiftData
@preconcurrency import WatchConnectivity
import os

/// Saves the nights the Watch sends and tells it once each one is safe, so it can let go of its copy. The system wakes
/// the app in the background to deliver them, so this has to be running from launch, before any screen appears. As the
/// session's one delegate, it also keeps the Watch's setup for the empty History screen.
@MainActor
@Observable
final class NightReceiver: NSObject {
    private let context: ModelContext
    private(set) var watchSetup: WatchSetup?

    init(context: ModelContext) {
        self.context = context
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Returns whether the Watch can have its receipt: true for a night saved now, before, or deleted by the user.
    func save(_ night: Night) -> Bool {
        do {
            if try SavedNight.insertIfNew(night, into: context) {
                Logger.persistence.info("Saved night \(night.id, privacy: .public)")
            } else {
                Logger.persistence.info("Night \(night.id, privacy: .public) was already saved or deleted, skipped it")
            }
            return true
        } catch {
            // The error can describe the saved object, name included, so only its domain and code are public.
            let nsError = error as NSError
            Logger.persistence.error(
                """
                Couldn't save night \(night.id, privacy: .public): \(nsError.domain, privacy: .public) \(nsError.code), \
                \(error, privacy: .private)
                """
            )
            return false
        }
    }

    nonisolated private func updateWatchSetup(from session: WCSession) {
        let setup = WatchSetup(
            isActivated: session.activationState == .activated,
            isPaired: session.isPaired,
            isWatchAppInstalled: session.isWatchAppInstalled
        )
        Task { @MainActor in self.watchSetup = setup }
    }
}

extension NightReceiver: WCSessionDelegate {
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
        updateWatchSetup(from: session)
    }

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Logger.sync.info(
            "Watch state changed, paired \(session.isPaired), app installed \(session.isWatchAppInstalled)")
        updateWatchSetup(from: session)
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        do {
            let night = try Night(transfer: userInfo)
            Logger.sync.info(
                """
                Received night \(night.id, privacy: .public) "\(night.name, privacy: .private)", \
                \(night.entries.count) entries
                """
            )
            // Waits for the save, so a background wake can't end with the night only in memory. With no receipt, the
            // Watch keeps the night and sends it again. The system calls this off the main thread, so this can't deadlock.
            let saved = DispatchQueue.main.sync { MainActor.assumeIsolated { save(night) } }
            if saved, session.activationState == .activated, session.isWatchAppInstalled {
                session.transferUserInfo(Night.savedReceipt(id: night.id))
                Logger.sync.info("Sent the receipt for night \(night.id, privacy: .public)")
            } else {
                Logger.sync.debug("No receipt for night \(night.id, privacy: .public): not saved or the Watch is away")
            }
        } catch {
            Logger.sync.error("Couldn't read a night from the Watch: \(error, privacy: .public)")
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        Logger.sync.info("Session inactive")
    }

    /// The user switched to another Watch. Activating again connects to it.
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        Logger.sync.info("Session deactivated, activating again")
        session.activate()
    }
}
