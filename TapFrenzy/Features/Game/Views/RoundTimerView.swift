import SwiftUI

struct RoundTimerView: View {
    let secondsRemaining: Int
    let progress: Double

    private var timerColor: Color {
        switch secondsRemaining {
        case 0...3: GameTheme.critical
        case 4...6: GameTheme.warning
        default: GameTheme.accent
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Time remaining")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(GameTheme.secondaryText)
                Spacer()
                Text("\(secondsRemaining)s")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(timerColor)
            }
            GeometryReader { geometry in
                Capsule()
                    .fill(.white.opacity(0.10))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(timerColor)
                            .frame(width: geometry.size.width * CGFloat(progress))
                    }
            }
            .frame(height: 7)
            .accessibilityHidden(true)
        }
        .padding(16)
        .background(GameTheme.surface, in: RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Time remaining")
        .accessibilityValue("\(secondsRemaining) seconds")
    }
}
