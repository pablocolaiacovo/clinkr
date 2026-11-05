import Foundation
import SwiftData
@preconcurrency import WatchConnectivity
import os

/// Saves the nights the Watch sends. The system wakes the app in the background to deliver them, so this has to be
/// running from launch, before any screen appears.
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

    private func save(_ night: Night) {
        do {
            try SavedNight.insertIfNew(night, into: context)
        } catch {
            logger.error("Couldn't save night \(night.id): \(error)")
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
            Task { @MainActor in
                save(night)
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
