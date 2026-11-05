import SwiftUI

@main
struct ClinkrWatchApp: App {
    /// Tonight's drinks, loaded from disk at launch. Screens read it with `@Environment(NightStore.self)`.
    @State private var nightStore: NightStore
    private let nightSender: NightSender

    init() {
        let store = NightStore()
        _nightStore = State(initialValue: store)
        nightSender = NightSender(store: store)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(sendNights: nightSender.send)
                .environment(nightStore)
        }
    }
}
