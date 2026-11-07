import SwiftData
import SwiftUI
import os

/// The History screen: every night received from the Watch, newest first, grouped by month.
struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SavedNight.startTime, order: .reverse) private var nights: [SavedNight]

    var body: some View {
        NavigationStack {
            List {
                ForEach(SavedNight.byMonth(newestFirst: nights), id: \.month) { month in
                    Section {
                        ForEach(month.nights) { night in
                            NightRow(night: night)
                                .listRowInsets(
                                    EdgeInsets(
                                        top: Space.s3, leading: Space.s4 * 2, bottom: Space.s3, trailing: Space.s4 * 2)
                                )
                                .listRowSeparator(.hidden)
                                .listRowBackground(
                                    CardSlice(
                                        isFirst: night.id == month.nights.first?.id,
                                        isLast: night.id == month.nights.last?.id
                                    )
                                )
                        }
                        .onDelete { offsets in
                            delete(offsets.map { month.nights[$0] })
                        }
                    } header: {
                        MonthHeader(month: month.month)
                    }
                }
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(.bg)
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

    private func delete(_ nights: [SavedNight]) {
        do {
            try SavedNight.delete(nights, from: context)
            Logger.persistence.info("Deleted \(nights.count) nights")
        } catch {
            // Puts the rows back, so the list never shows a night as gone when it's still saved.
            context.rollback()
            Logger.persistence.error("Couldn't delete nights: \(error, privacy: .public)")
        }
    }
}

private struct MonthHeader: View {
    let month: Date

    var body: some View {
        let isThisYear = Calendar.current.isDate(month, equalTo: .now, toGranularity: .year)
        Text(month, format: isThisYear ? .dateTime.month(.wide) : .dateTime.month(.wide).year())
            .typeStyle(.label)
            .foregroundStyle(.inkMuted)
            .padding(.leading, Space.s1)
    }
}

private struct NightRow: View {
    let night: SavedNight

    var body: some View {
        let summary = night.night
        HStack(spacing: Space.s3) {
            VStack(spacing: 0) {
                Text(night.startTime, format: .dateTime.day())
                    .typeStyle(.title)
                    .monospacedDigit()
                Text(night.startTime, format: .dateTime.weekday(.abbreviated))
                    .typeStyle(.label)
                    .foregroundStyle(.inkMuted)
            }
            .frame(minWidth: Size.minTarget)
            VStack(alignment: .leading, spacing: Space.s1) {
                Text(night.defaultName)
                    .typeStyle(.title)
                    .lineLimit(2)
                MiniBar(countsByType: summary.countsByType)
            }
            Spacer(minLength: 0)
            Text(summary.drinkCount, format: .number)
                .typeStyle(.title)
                .monospacedDigit()
                .accessibilityLabel(
                    Text("\(summary.drinkCount) tragos", comment: "VoiceOver label for a night's count"))
        }
        .foregroundStyle(.ink)
        .accessibilityElement(children: .combine)
    }
}

/// The night's drinks by type as one 8pt bar, in the same order as everywhere else. Water is never in it.
private struct MiniBar: View {
    let countsByType: [DrinkType: Int]

    var body: some View {
        let segments = DrinkType.allCases.filter { $0.countsAsDrink && countsByType[$0, default: 0] > 0 }
        let total = segments.reduce(0) { $0 + countsByType[$1, default: 0] }
        GeometryReader { geometry in
            let width = geometry.size.width - Space.s1 * CGFloat(max(segments.count - 1, 0))
            HStack(spacing: Space.s1) {
                ForEach(segments, id: \.self) { type in
                    Capsule()
                        .fill(type.color)
                        .frame(width: width * CGFloat(countsByType[type, default: 0]) / CGFloat(total))
                }
            }
        }
        .frame(height: Size.miniBar)
        .accessibilityHidden(true)
    }
}

/// One row's piece of its month's card. Together the pieces draw one sticker card: the outline runs around the
/// whole month, with a rule between rows, and only the last piece casts the shadow.
private struct CardSlice: View {
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: isFirst ? Radius.card : 0,
            bottomLeadingRadius: isLast ? Radius.card : 0,
            bottomTrailingRadius: isLast ? Radius.card : 0,
            topTrailingRadius: isFirst ? Radius.card : 0
        )
        shape
            .fill(.surface)
            .overlay {
                // Strokes past the open edges and clips them, so pieces join without an outline between them.
                shape
                    .strokeBorder(.hairline, lineWidth: Size.outline)
                    .padding(.top, isFirst ? 0 : -Size.outline)
                    .padding(.bottom, isLast ? 0 : -Size.outline)
            }
            .clipped()
            .overlay(alignment: .top) {
                if !isFirst {
                    Rectangle()
                        .fill(.surfaceRaised)
                        .frame(height: Size.outline)
                        .padding(.horizontal, Size.outline)
                }
            }
            .compositingGroup()
            .stickerShadow(isLast)
            .padding(.horizontal, Space.s4)
    }
}

extension View {
    @ViewBuilder
    fileprivate func stickerShadow(_ isOn: Bool) -> some View {
        if isOn {
            stickerShadow()
        } else {
            self
        }
    }
}

// sampleNights() exists only in Debug builds, and Release still compiles previews.
#if DEBUG
    #Preview("Nights") {
        let container = try! ModelContainer(
            for: SavedNight.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        for night in SavedNight.sampleNights() {
            _ = try? SavedNight.insertIfNew(night, into: container.mainContext)
        }
        return ContentView()
            .modelContainer(container)
    }
#endif

#Preview("Empty") {
    ContentView()
        .modelContainer(for: SavedNight.self, inMemory: true)
}
