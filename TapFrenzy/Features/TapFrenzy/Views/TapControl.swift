import SwiftUI

struct TapControl: View {
    let size: CGFloat
    let secondsRemaining: Int
    let isPlaying: Bool
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                if !dynamicTypeSize.isAccessibilitySize {
                    Image(systemName: "bolt.fill")
                        .font(.title2.weight(.bold))
                        .accessibilityHidden(true)
                }
                Text("TAP")
                    .font(.system(.largeTitle, design: .rounded).weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(secondsRemaining)s")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .accessibilityHidden(true)
            }
            .foregroundStyle(GameTheme.buttonText)
            .frame(width: size, height: size)
            .background(GameTheme.buttonFill, in: Circle())
            .contentShape(Circle())
        }
        .buttonStyle(TapButtonStyle(reduceMotion: reduceMotion))
        .accessibilityLabel(isPlaying ? "Tap to score" : "Start round")
        .accessibilityValue("\(secondsRemaining) seconds remaining")
    }
}

private struct TapButtonStyle: ButtonStyle {
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.10), value: configuration.isPressed)
    }
}
