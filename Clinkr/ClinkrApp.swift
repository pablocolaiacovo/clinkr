import SwiftData
import SwiftUI

@main
struct ClinkrApp: App {
    private let container: ModelContainer
    private let nightReceiver: NightReceiver

    init() {
        do {
            container = try ModelContainer(for: SavedNight.self)
        } catch {
            // Stopping before the receiver starts leaves undelivered nights safe in the system's queue.
            fatalError("Couldn't open the nights database: \(error)")
        }
        nightReceiver = NightReceiver(context: container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
