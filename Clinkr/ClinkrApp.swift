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
        Self.useDisplayStyleForLargeTitles()
        do {
            let container = try Self.makeContainer()
            self.container = container
            nightReceiver = NightReceiver(context: container.mainContext)
        } catch {
            Logger.persistence.error("Couldn't open the nights database: \(error, privacy: .public)")
            container = nil
            nightReceiver = nil
        }
    }

    /// Sets only the large title's font, so the system still draws the bar's glass and scroll-edge effect.
    private static func useDisplayStyleForLargeTitles() {
        let style = TypeStyle.display
        let descriptor = UIFont.systemFont(ofSize: style.size, weight: .bold).fontDescriptor.withDesign(.rounded)
        let font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont(descriptor: descriptor!, size: 0))
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: font, .foregroundColor: UIColor(.ink)]
    }

    private static func makeContainer() throws -> ModelContainer {
        #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-SampleNights") {
                let container = try ModelContainer(
                    for: SavedNight.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                )
                for night in SavedNight.sampleNights() {
                    try SavedNight.insertIfNew(night, into: container.mainContext)
                }
                Logger.persistence.info("Using sample nights in memory")
                return container
            }
        #endif
        return try ModelContainer(for: SavedNight.self)
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
        .onChange(of: scenePhase) {
            Logger.lifecycle.info("iPhone app is \(String(describing: scenePhase), privacy: .public)")
        }
    }
}
