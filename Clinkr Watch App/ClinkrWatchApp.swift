import SwiftUI
import os

@main
struct ClinkrWatchApp: App {
    /// Tonight's drinks, loaded from disk at launch. Screens read it with `@Environment(NightStore.self)`.
    @State private var nightStore: NightStore
    private let nightSender: NightSender
    @Environment(\.scenePhase) private var scenePhase

    init() {
        Logger.lifecycle.info("Watch app launched")
        let store = NightStore()
        _nightStore = State(initialValue: store)
        nightSender = NightSender(store: store)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(nightStore)
        }
        .onChange(of: scenePhase) {
            Logger.lifecycle.info("Watch app is \(String(describing: scenePhase), privacy: .public)")
            nightSender.send()
            if scenePhase == .background {
                nightSender.scheduleRetryIfNeeded()
            }
        }
        .backgroundTask(.appRefresh(NightSender.retryTask)) { [nightSender] in
            Logger.lifecycle.info("Woke for a background refresh")
            await nightSender.send()
            await nightSender.scheduleRetryIfNeeded()
        }
    }
}
