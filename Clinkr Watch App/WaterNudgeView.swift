import SwiftUI

/// The water break nudge: a friendly suggestion, never a warning. "Ya tomé uno" logs a water and "Después" puts it off.
struct WaterNudgeView: View {
    static let animation = Motion.standard

    let drinkCount: Int
    let waterCount: Int
    let onHadOne: () -> Void
    let onLater: () -> Void
    /// Undoes the drink that brought the nudge on, while its toast is still up. With VoiceOver the toast stays, but the
    /// nudge covers it, so this offers its Undo as an action on the headline, where VoiceOver lands.
    var onUndo: (() -> Void)? = nil

    var body: some View {
        // Its own stack, so content scrolling up fades under the clock like any other screen.
        NavigationStack {
            content
        }
        // Moves VoiceOver to the nudge, which would otherwise come up unannounced over the screen it was on.
        .onAppear {
            AccessibilityNotification.ScreenChanged(nil).post()
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.s2) {
                HStack(spacing: Space.s2) {
                    DrinkType.water.glyph
                        .resizable()
                        .frame(width: Size.glyph, height: Size.glyph)
                        .foregroundStyle(.water)
                        .accessibilityHidden(true)
                    Text("¿Un vasito de agua?")
                        .typeStyle(.watchTitle)
                        .foregroundStyle(.ink)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityActions {
                            if let onUndo {
                                Button("Deshacer", action: onUndo)
                            }
                        }
                }
                message
                    .typeStyle(.watchBody)
                    .foregroundStyle(.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, Space.s1)
                Button(action: onHadOne) {
                    Text("Ya tomé uno")
                        .typeStyle(.watchBody)
                        .foregroundStyle(.onPop)
                        .frame(maxWidth: .infinity, minHeight: Size.primaryPill)
                        .background(.water, in: Capsule())
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .handGestureShortcut(.primaryAction)
                Button(action: onLater) {
                    Text("Después")
                        .typeStyle(.watchBody)
                        .foregroundStyle(.ink)
                        .frame(maxWidth: .infinity, minHeight: Size.secondaryPill)
                        .background(.surfaceRaised, in: Capsule())
                        .frame(minHeight: Size.minTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Space.s2)
        }
        .background(.bg)
        .accessibilityAddTraits(.isModal)
    }

    private var message: Text {
        let drinks = Text("\(drinkCount) tragos").foregroundStyle(.ink)
        let waters = Text("\(waterCount) aguas").foregroundStyle(.ink)
        return Text("\(drinks), \(waters). Tu compa tiene sed.")
    }
}

#Preview {
    WaterNudgeView(drinkCount: 4, waterCount: 0, onHadOne: {}, onLater: {})
}
