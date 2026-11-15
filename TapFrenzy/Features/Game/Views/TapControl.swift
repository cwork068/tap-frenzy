import SwiftUI

struct TapControl: View {
    let phase: GameRound.Phase
    let size: CGFloat
    let action: () -> Void

    private var buttonLabel: String {
        switch phase {
        case .idle: "Start round"
        case .playing: "Tap to score"
        case .over: "Try again"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: phase == .over ? "arrow.clockwise" : "bolt.fill")
                    .font(.title3.weight(.bold))
                    .accessibilityHidden(true)
                Text(phase == .over ? "Try again" : "TAP")
                    .font(.title2.weight(.black))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .foregroundStyle(GameTheme.background)
            .frame(width: size, height: size)
            .background {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [GameTheme.accentHighlight, GameTheme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: GameTheme.accent.opacity(0.25), radius: 22, y: 9)
            }
            .overlay {
                Circle().strokeBorder(.white.opacity(0.45), lineWidth: 1)
            }
            .contentShape(Circle())
        }
        .buttonStyle(TapButtonStyle())
        .accessibilityLabel(buttonLabel)
    }
}

private struct TapButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.13), value: configuration.isPressed)
    }
}
