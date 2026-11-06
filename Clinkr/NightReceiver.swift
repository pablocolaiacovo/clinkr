import Foundation
import SwiftData
@preconcurrency import WatchConnectivity
import os

/// Saves the nights the Watch sends and tells it once each one is safe, so it can let go of its copy. The system wakes
/// the app in the background to deliver them, so this has to be running from launch, before any screen appears.
@MainActor
final class NightReceiver: NSObject {
    private let context: ModelContext
    private nonisolated let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Clinkr",
        category: "NightReceiver"
    )

    init(context: ModelContext) {
        self.context = context
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func save(_ night: Night) -> Bool {
        do {
            try SavedNight.insertIfNew(night, into: context)
            return true
        } catch {
            logger.error("Couldn't save night \(night.id): \(error)")
            return false
        }
    }
}

extension NightReceiver: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        if let error {
            logger.error("Couldn't activate the session: \(error)")
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        do {
            let night = try Night(transfer: userInfo)
            // Waits for the save, so a background wake can't end with the night only in memory. With no receipt, the
            // Watch keeps the night and sends it again. The system calls this off the main thread, so this can't deadlock.
            let saved = DispatchQueue.main.sync { MainActor.assumeIsolated { save(night) } }
            if saved, session.activationState == .activated, session.isWatchAppInstalled {
                session.transferUserInfo(Night.savedReceipt(id: night.id))
            }
        } catch {
            logger.error("Couldn't read a night from the Watch: \(error)")
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    /// The user switched to another Watch. Activating again connects to it.
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}
