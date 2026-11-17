import SwiftUI

/// What the iPhone knows about the Watch side, which decides how to get the first night.
enum WatchSetup: Equatable, Sendable {
    case noWatch
    case appNotInstalled
    case ready

    /// `nil` until the session is activated, since `isPaired` and `isWatchAppInstalled` mean nothing before that.
    init?(isActivated: Bool, isPaired: Bool, isWatchAppInstalled: Bool) {
        guard isActivated else { return nil }
        if !isPaired {
            self = .noWatch
        } else if !isWatchAppInstalled {
            self = .appNotInstalled
        } else {
            self = .ready
        }
    }

    var nextStep: Text {
        switch self {
        case .noWatch:
            Text(
                "Para usar Clinkr necesitás un Apple Watch vinculado a este iPhone.",
                comment: "Empty list of nights, when no Apple Watch is paired with the iPhone"
            )
        case .appNotInstalled:
            Text(
                "Instalá Clinkr en tu reloj desde la app Watch de este iPhone.",
                comment: "Empty list of nights, when the Watch is paired but the Clinkr Watch app isn't installed"
            )
        case .ready:
            Text(
                "Todavía no hay noches. Las que anotes en el reloj aparecen acá.",
                comment: "Empty list of nights, when the Clinkr Watch app is installed"
            )
        }
    }
}

/// The History screen before the first night: how Clinkr works, and the next step for this user's Watch.
struct EmptyHistory: View {
    @Environment(NightReceiver.self) private var receiver: NightReceiver?

    var body: some View {
        ViewThatFits(in: .vertical) {
            content
            ScrollView { content }
        }
    }

    private var content: some View {
        VStack(spacing: Space.s3) {
            Text("Así funciona Clinkr", comment: "Title of the empty list of nights, before an explanation")
                .typeStyle(.title)
                .foregroundStyle(.ink)
            Text(
                "Anotá cada trago y cada agua con un toque en el Apple Watch. Cuando terminás la noche, aparece acá.",
                comment: "Empty list of nights: how the Watch and the iPhone work together"
            )
            .typeStyle(.body)
            .foregroundStyle(.inkMuted)
            if let setup = receiver?.watchSetup {
                setup.nextStep
                    .typeStyle(.body)
                    .foregroundStyle(.ink)
                    .padding(.top, Space.s3)
            }
        }
        .multilineTextAlignment(.center)
        .padding(Space.s4)
    }
}

#Preview {
    EmptyHistory()
        .background(.bg)
}
