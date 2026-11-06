import SwiftUI
import WatchKit

/// The Tonight screen, first in the swipe order: the tally ring with tonight's count in the middle. Tapping the ring
/// adds the last drink again.
struct TonightView: View {
    @Environment(NightStore.self) private var nightStore

    var body: some View {
        let night = nightStore.activeNight
        Group {
            if let lastDrink = night?.lastDrink {
                Button {
                    addAgain(lastDrink.type)
                } label: {
                    ring(night)
                }
                .buttonStyle(.plain)
                .accessibilityHint(Text("Vuelve a sumar lo último"))
            } else {
                ring(night)
            }
        }
        .accessibilityElement(children: .combine)
        .padding(.horizontal, Space.s2)
        .background(.bg)
    }

    private func ring(_ night: Night?) -> some View {
        TallyRing(drinks: night?.drinkTypes ?? [], waterCount: night?.waterCount ?? 0)
            .overlay {
                center(night)
                    .padding(TallyRing.thickness + Space.s1)
            }
            .contentShape(Circle())
    }

    @ViewBuilder
    private func center(_ night: Night?) -> some View {
        if let night {
            details(night)
        } else {
            VStack(spacing: Space.s1) {
                if nightStore.saveFailed {
                    Text(Self.notSaved)
                }
                Text("Deslizá para arrancar la noche", comment: "Tonight screen before the first drink")
            }
            .typeStyle(.watchCaption)
            .foregroundStyle(.inkMuted)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.8)
        }
    }

    /// When space runs out, the count shrinks into what the caption and waters leave, so they keep their size.
    private func details(_ night: Night) -> some View {
        VStack(spacing: 0) {
            Text(night.drinkCount, format: .number)
                .typeStyle(.countHero)
                .foregroundStyle(.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .accessibilityLabel(Text("\(night.drinkCount) bebidas"))
            Text(Self.caption(forNightStartingAt: night.startTime, saveFailed: nightStore.saveFailed))
                .typeStyle(.watchCaption)
                .foregroundStyle(.inkMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .layoutPriority(1)
            waters(night.waterCount)
                .layoutPriority(1)
        }
    }

    private static let notSaved = LocalizedStringResource(
        "Sin guardar",
        comment: "Tonight screen, when saving the night failed"
    )

    /// "Hoy" for a night that started in the daytime, like a lunch, otherwise "Esta noche".
    static func caption(
        forNightStartingAt start: Date,
        saveFailed: Bool,
        calendar: Calendar = .current
    ) -> LocalizedStringResource {
        if saveFailed {
            return notSaved
        }
        let hour = calendar.component(.hour, from: start)
        if (5..<17).contains(hour) {
            return LocalizedStringResource("Hoy", comment: "Tonight screen caption for a night that started by day")
        }
        return LocalizedStringResource(
            "Esta noche", comment: "Tonight screen caption for a night that started after 5 pm")
    }

    private func waters(_ count: Int) -> some View {
        HStack(spacing: Space.s1) {
            DrinkType.water.glyph
                .resizable()
                .frame(width: Size.inlineGlyph, height: Size.inlineGlyph)
                .foregroundStyle(.water)
                .accessibilityHidden(true)
            Text(verbatim: "×\(count.formatted())")
                .typeStyle(.watchCaption)
                .monospacedDigit()
                .foregroundStyle(.inkMuted)
                .lineLimit(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(count) aguas"))
        .padding(.top, Space.s1)
    }

    private func addAgain(_ type: DrinkType) {
        WKInterfaceDevice.current().play(type.addHaptic)
        nightStore.add(type)
    }
}

#Preview("Tonight") {
    let store = NightStore.preview()
    for type in [DrinkType.beer, .beer, .water, .wine, .shot, .water, .beer] {
        store.add(type)
    }
    return TonightView()
        .environment(store)
}

#Preview("Before the night") {
    TonightView()
        .environment(NightStore.preview())
}
