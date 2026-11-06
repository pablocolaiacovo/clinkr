import SwiftData
import SwiftUI

/// A plain list of the nights received from the Watch. The History screen (#12) replaces it.
struct ContentView: View {
    @Query(sort: \SavedNight.startTime, order: .reverse) private var nights: [SavedNight]

    var body: some View {
        NavigationStack {
            List(nights) { night in
                VStack(alignment: .leading, spacing: Space.s1) {
                    Text(night.name)
                        .typeStyle(.title)
                        .foregroundStyle(.ink)
                    Text(night.startTime, format: .dateTime.weekday(.wide).day().month().year())
                        .typeStyle(.body)
                        .foregroundStyle(.inkMuted)
                }
            }
            .overlay {
                if nights.isEmpty {
                    Text(
                        "Todavía no hay noches. Arrancá una en tu reloj.", comment: "Empty state of the list of nights"
                    )
                    .typeStyle(.body)
                    .foregroundStyle(.inkMuted)
                    .multilineTextAlignment(.center)
                    .padding(Space.s4)
                }
            }
            .navigationTitle(Text("Tus noches", comment: "Title of the list of nights"))
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SavedNight.self, inMemory: true)
}
