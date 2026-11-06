import MetricKit
import SwiftData
import SwiftUI
import os

@main
struct ClinkrApp: App {
    /// `nil` when the database won't open. Nothing is received then, so the Watch gets no receipts and keeps its nights.
    private let container: ModelContainer?
    private let nightReceiver: NightReceiver?
    private let metricsSubscriber = MetricsSubscriber()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        Logger.lifecycle.info("iPhone app launched")
        MXMetricManager.shared.add(metricsSubscriber)
        do {
            let container = try ModelContainer(for: SavedNight.self)
            self.container = container
            nightReceiver = NightReceiver(context: container.mainContext)
        } catch {
            Logger.persistence.error("Couldn't open the nights database: \(error, privacy: .public)")
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
                    "Couldn't open your nights. Try opening Clinkr again.",
                    comment: "Shown when the database won't open"
                )
                .typeStyle(.body)
                .foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
                .padding(Space.s4)
            }
        }
        .onChange(of: scenePhase) {
            Logger.lifecycle.info("iPhone app is \(String(describing: scenePhase), privacy: .public)")
        }
    }
}
