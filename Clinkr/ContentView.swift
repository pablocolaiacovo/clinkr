import SwiftData
import SwiftUI
import os

/// The History screen: every night received from the Watch, newest first, grouped by month.
struct ContentView: View {
    /// UI tests ask for longer: on a slow test machine, finding Undo and tapping it can take more than 5 seconds.
    #if DEBUG
        static let undoDuration: Duration = .seconds(
            ProcessInfo.processInfo.environment["UNDO_SECONDS"].flatMap(Int.init) ?? 5)
    #else
        static let undoDuration: Duration = .seconds(5)
    #endif

    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \SavedNight.startTime, order: .reverse) private var nights: [SavedNight]
    /// The nights just deleted, while their Undo shows. Only the last delete can be undone.
    @State private var deleted: [SavedNight.Copy]?

    var body: some View {
        NavigationStack {
            List {
                ForEach(SavedNight.byMonth(newestFirst: nights), id: \.month) { month in
                    Section {
                        ForEach(month.nights) { night in
                            NavigationLink(value: night) {
                                NightRow(night: night)
                            }
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
                    EmptyHistory()
                }
            }
            .navigationTitle(Text("Tus noches", comment: "Title of the list of nights"))
            .navigationDestination(for: SavedNight.self) { night in
                NightRecap(night: night)
            }
            .toolbar {
                if let deleted {
                    ToolbarItem(placement: .bottomBar) {
                        Text(Self.deletedMessage)
                            .typeStyle(.body)
                            .foregroundStyle(.ink)
                            .fixedSize()
                            .padding(.horizontal, Space.s2)
                    }
                    ToolbarSpacer(.flexible, placement: .bottomBar)
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: undoDelete) {
                            Text("Deshacer", comment: "Button that brings back the night just deleted")
                                .typeStyle(.body)
                        }
                    }
                }
            }
        }
        .task(id: deleted) {
            // VoiceOver needs time to reach Undo, so there it stays until the next delete or an undo.
            guard deleted != nil, !voiceOverEnabled else { return }
            do {
                try await Task.sleep(for: Self.undoDuration)
            } catch {
                return
            }
            withAnimation(motion) { deleted = nil }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .background {
                deleted = nil
            }
        }
    }

    private var motion: Animation? {
        reduceMotion ? nil : Motion.standard
    }

    private static let deletedMessage = LocalizedStringResource(
        "Noche borrada", comment: "Shown with Undo after deleting a night")

    /// Deletes straight away, so the list and the database always agree. Undo saves the nights again.
    private func delete(_ nights: [SavedNight]) {
        do {
            let copies = try SavedNight.delete(nights, from: context)
            Logger.persistence.info("Deleted \(nights.count) nights")
            withAnimation(motion) { deleted = copies }
            if voiceOverEnabled {
                AccessibilityNotification.Announcement(String(localized: Self.deletedMessage))
                    .post()
            }
        } catch {
            // Puts the rows back, so the list never shows a night as gone when it's still saved.
            context.rollback()
            Logger.persistence.error("Couldn't delete nights: \(error, privacy: .public)")
        }
    }

    private func undoDelete() {
        guard let copies = deleted else { return }
        withAnimation(motion) {
            deleted = nil
            do {
                try SavedNight.restore(copies, into: context)
                Logger.persistence.info("Restored \(copies.count) nights")
            } catch {
                // Leaves them deleted, as the list shows.
                context.rollback()
                Logger.persistence.error("Couldn't restore nights: \(error, privacy: .public)")
            }
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
                Text(night.displayName)
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
            for: SavedNight.self, DeletedNight.self,
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
        .modelContainer(for: [SavedNight.self, DeletedNight.self], inMemory: true)
}
