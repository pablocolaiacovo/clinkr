import Charts
import SwiftData
import SwiftUI
import os

/// The detail screen for one night: four headline numbers and a timeline of when each drink and water happened.
struct NightRecap: View {
    let night: SavedNight
    @Environment(\.modelContext) private var context
    @State private var isRenaming = false
    @State private var draftName = ""

    var body: some View {
        let summary = night.night
        ScrollView {
            VStack(alignment: .leading, spacing: Space.s6) {
                header(summary)
                StatTiles(night: summary)
                Timeline(night: summary)
            }
            .padding(Space.s4)
        }
        .background(.bg)
        .navigationBarTitleDisplayMode(.inline)
        .alert(Text("Cambiar el nombre", comment: "Title of the rename alert"), isPresented: $isRenaming) {
            TextField(text: $draftName, prompt: Text(night.defaultName)) {
                Text("Nombre", comment: "Placeholder of the night name field")
            }
            Button(String(localized: "Guardar", comment: "Saves the night's new name")) {
                rename(to: draftName)
            }
            Button(role: .cancel) {}
        }
    }

    private func header(_ summary: Night) -> some View {
        VStack(alignment: .leading, spacing: Space.s1) {
            Text(verbatim: Self.dateLine(for: summary))
                .typeStyle(.label)
                .foregroundStyle(.inkMuted)
            Button {
                draftName = night.displayName
                isRenaming = true
            } label: {
                Text(night.displayName)
                    .typeStyle(.display)
                    .foregroundStyle(.ink)
                    .multilineTextAlignment(.leading)
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text("Cambia el nombre de la noche", comment: "VoiceOver hint on the night's name"))
            .accessibilityAddTraits(.isHeader)
        }
    }

    /// Like "VIE 17 OCT · 21:14–02:05", in the phone's language.
    static func dateLine(for night: Night) -> String {
        let date = night.startTime.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        return "\(date) · \(timeRange(of: night))"
    }

    /// Like "21:14–02:05", in the phone's language.
    static func timeRange(of night: Night) -> String {
        (night.startTime..<end(of: night)).formatted(.interval.hour().minute())
    }

    /// When the night ended, or its last entry while it's still going.
    static func end(of night: Night) -> Date {
        night.endTime ?? night.entries.last?.timestamp ?? night.startTime
    }

    private func rename(to newName: String) {
        night.rename(to: newName)
        do {
            try context.save()
            Logger.persistence.info("Renamed night \(night.id, privacy: .public)")
        } catch {
            // Puts the old name back, so the screen never shows a name that isn't saved.
            context.rollback()
            Logger.persistence.error("Couldn't rename night: \(error, privacy: .public)")
        }
    }
}

private struct StatTiles: View {
    let night: Night

    var body: some View {
        Grid(horizontalSpacing: Space.s3, verticalSpacing: Space.s3) {
            GridRow {
                StatTile(
                    label: Text("Tragos", comment: "Recap tile: number of drinks"),
                    value: AttributedString(night.drinkCount.formatted())
                )
                StatTile(
                    label: Text("Aguas", comment: "Recap tile: number of waters"),
                    value: AttributedString(night.waterCount.formatted()),
                    showsWaterDot: true
                )
            }
            GridRow {
                let duration = Duration.seconds(night.duration())
                StatTile(
                    label: Text("Afuera", comment: "Recap tile: how long the night lasted"),
                    value: Self.mutingUnits(duration.formatted(Self.durationStyle(width: .narrow).attributed)),
                    accessibilityValue: Text(duration.formatted(Self.durationStyle(width: .wide)))
                )
                paceTile
            }
        }
    }

    @ViewBuilder
    private var paceTile: some View {
        let label = Text("Ritmo", comment: "Recap tile: drinks per hour")
        if let pace = night.pace() {
            let value = pace.formatted(.number.precision(.fractionLength(1)))
            let unit = AttributedString(localized: "/h", comment: "Unit after the drinks-per-hour pace, like 1.9/h")
                .settingAttributes(AttributeContainer().foregroundColor(.inkMuted))
            StatTile(
                label: label,
                value: AttributedString(value) + unit,
                accessibilityValue: Text("\(value) por hora", comment: "VoiceOver value of the pace, like 1.9 per hour")
            )
        } else {
            StatTile(
                label: label,
                value: AttributedString("–"),
                accessibilityValue: Text("Muy corta para saber", comment: "VoiceOver pace of a night under 15 minutes")
            )
        }
    }

    private static func durationStyle(width: Duration.UnitsFormatStyle.UnitWidth) -> Duration.UnitsFormatStyle {
        .units(allowed: [.hours, .minutes], width: width)
    }

    /// Draws the unit parts of a formatted value, like the "h" in "4h 51m", in `inkMuted`.
    static func mutingUnits(_ value: AttributedString) -> AttributedString {
        var value = value
        for run in value.runs where run.measurement == .unit {
            value[run.range].foregroundColor = .inkMuted
        }
        return value
    }
}

private struct StatTile: View {
    let label: Text
    let value: AttributedString
    var accessibilityValue: Text?
    var showsWaterDot = false

    var body: some View {
        VStack(alignment: .leading, spacing: Space.s1) {
            HStack(spacing: Space.s1) {
                if showsWaterDot {
                    Dot(type: .water)
                }
                label
                    .typeStyle(.label)
                    .foregroundStyle(.inkMuted)
            }
            Text(value)
                .typeStyle(.stat)
                .monospacedDigit()
                .foregroundStyle(.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Space.s3)
        .padding(.horizontal, Space.s4)
        .card()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(accessibilityValue ?? Text(value))
    }
}

private struct Timeline: View {
    let night: Night
    @State private var selectedTime: Date?

    var body: some View {
        let points = TimelinePoint.layout(night.entries)
        VStack(alignment: .leading, spacing: Space.s3) {
            Text("Cómo fue la noche", comment: "Title of the recap's timeline card")
                .typeStyle(.title)
                .foregroundStyle(.ink)
            chart(points)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Línea de tiempo", comment: "VoiceOver label of the recap's timeline"))
                .accessibilityValue(Text(verbatim: summary))
            Legend(countsByType: night.countsByType)
        }
        .padding(Space.s4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private func chart(_ points: [TimelinePoint]) -> some View {
        let start = night.startTime
        let end = NightRecap.end(of: night)
        let padding: TimeInterval = 15 * 60
        let topLane = points.map(\.lane).max() ?? 1
        let selected = selected(in: points)
        return Chart(points) { point in
            PointMark(x: .value("Hora", point.entry.timestamp), y: .value("Carril", point.lane))
                .symbol {
                    let size = point.entry.type.countsAsDrink ? Size.drinkDot : Size.waterDot
                    Dot(type: point.entry.type, size: size)
                }
                .annotation(
                    position: .top, spacing: Space.s1, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
                ) {
                    if point == selected {
                        Tooltip(entry: point.entry)
                    }
                }
        }
        .chartXScale(domain: start.addingTimeInterval(-padding)...end.addingTimeInterval(padding))
        .chartYScale(domain: -0.5...(Double(max(topLane, 2)) + 0.5))
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour)) { value in
                AxisGridLine().foregroundStyle(.surfaceRaised)
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.hour(.defaultDigits(amPM: .narrow)))
                            .typeStyle(.label)
                            .foregroundStyle(.inkMuted)
                    }
                }
            }
        }
        .chartXSelection(value: $selectedTime)
        .frame(height: Size.minTarget * 3)
    }

    /// The entry closest in time to where the finger is on the chart.
    private func selected(in points: [TimelinePoint]) -> TimelinePoint? {
        guard let selectedTime else { return nil }
        return points.min {
            abs($0.entry.timestamp.timeIntervalSince(selectedTime))
                < abs($1.entry.timestamp.timeIntervalSince(selectedTime))
        }
    }

    /// What VoiceOver reads for the chart, like "7 drinks, 2 waters, 21:14–02:05".
    private var summary: String {
        [
            String(localized: "\(night.drinkCount) tragos", comment: "VoiceOver label for a night's count"),
            String(localized: "\(night.waterCount) aguas", comment: "VoiceOver count of waters in the timeline"),
            NightRecap.timeRange(of: night),
        ].joined(separator: ", ")
    }
}

/// One entry placed on the timeline: water on lane 0, drinks on lane 1 and up.
struct TimelinePoint: Identifiable, Equatable {
    /// Drinks closer together than this stack upward instead of overlapping.
    static let stackWindow: TimeInterval = 12 * 60

    let entry: DrinkEntry
    let lane: Int

    var id: DrinkEntry.ID { entry.id }

    /// `entries` must be in time order, as `Night` keeps them.
    static func layout(_ entries: [DrinkEntry]) -> [TimelinePoint] {
        var lastDrink: Date?
        var stack = 0
        return entries.map { entry in
            guard entry.type.countsAsDrink else { return TimelinePoint(entry: entry, lane: 0) }
            if let lastDrink, entry.timestamp.timeIntervalSince(lastDrink) < stackWindow {
                stack += 1
            } else {
                stack = 0
            }
            lastDrink = entry.timestamp
            return TimelinePoint(entry: entry, lane: 1 + stack)
        }
    }
}

private struct Tooltip: View {
    let entry: DrinkEntry

    var body: some View {
        Text(
            verbatim:
                "\(String(localized: entry.type.displayName)) · \(entry.timestamp.formatted(date: .omitted, time: .shortened))"
        )
        .typeStyle(.label)
        .foregroundStyle(.bg)
        .padding(.horizontal, Space.s2)
        .padding(.vertical, Space.s1)
        .background(.ink, in: .rect(cornerRadius: Radius.chip))
    }
}

/// Every type logged tonight with its count, so the chart never relies on color alone.
private struct Legend: View {
    let countsByType: [DrinkType: Int]

    var body: some View {
        let types = DrinkType.allCases.filter { countsByType[$0, default: 0] > 0 }
        LazyVGrid(columns: [GridItem(.adaptive(minimum: Size.minTarget * 2), alignment: .leading)], spacing: Space.s2) {
            ForEach(types, id: \.self) { type in
                HStack(spacing: Space.s1) {
                    Dot(type: type)
                    Text(type.displayName)
                    Text(countsByType[type, default: 0], format: .number)
                        .monospacedDigit()
                }
                .typeStyle(.label)
                .foregroundStyle(.inkMuted)
                .accessibilityElement(children: .combine)
            }
        }
    }
}

/// A drink's color as a round mark with the hairline outline, which pop colors need on white.
private struct Dot: View {
    let type: DrinkType
    var size = Size.waterDot

    var body: some View {
        Circle()
            .fill(type.color)
            .strokeBorder(.hairline, lineWidth: Size.chartOutline)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

extension View {
    /// A solid sticker card: `surface` with the hairline outline and, in light mode, the hard shadow.
    fileprivate func card() -> some View {
        background {
            RoundedRectangle(cornerRadius: Radius.card)
                .fill(.surface)
                .strokeBorder(.hairline, lineWidth: Size.outline)
                .compositingGroup()
                .stickerShadow()
        }
    }
}

#if DEBUG
    #Preview("Recap") {
        let container = try! ModelContainer(
            for: SavedNight.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let night = SavedNight(SavedNight.sampleNights()[0])
        container.mainContext.insert(night)
        return NavigationStack {
            NightRecap(night: night)
        }
        .modelContainer(container)
    }
#endif
