import SwiftData
import SwiftUI
import os

@main
struct ClinkrApp: App {
    /// `nil` when the database won't open. Nothing is received then, so the Watch gets no receipts and keeps its nights.
    private let container: ModelContainer?
    private let nightReceiver: NightReceiver?

    init() {
        do {
            let container = try ModelContainer(for: SavedNight.self)
            self.container = container
            nightReceiver = NightReceiver(context: container.mainContext)
        } catch {
            Logger(subsystem: Bundle.main.bundleIdentifier ?? "Clinkr", category: "ClinkrApp")
                .error("Couldn't open the nights database: \(error)")
            container = nil
            nightReceiver = nil
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container {
                ContentView()
                    .modelContainer(container)
            } else {
                Text(
                    "No pudimos abrir tus noches. Probá abrir Clinkr de nuevo.",
                    comment: "Shown when the database won't open"
                )
                .typeStyle(.body)
                .foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
                .padding(Space.s4)
            }
        }
    }
}
