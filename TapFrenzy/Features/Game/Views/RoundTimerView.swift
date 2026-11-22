import SwiftUI

struct RoundTimerView: View {
    let secondsRemaining: Int
    let progress: Double
    let size: CGFloat
    let isPlaying: Bool
    let action: () -> Void

    private var timerColor: Color {
        switch secondsRemaining {
        case 0...3: GameTheme.critical
        case 4...6: GameTheme.warning
        default: GameTheme.accent
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(GameTheme.track, lineWidth: 9)
                .accessibilityHidden(true)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(timerColor, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .accessibilityHidden(true)
            TapControl(size: size - 32, secondsRemaining: secondsRemaining,
                       isPlaying: isPlaying, action: action)
        }
        .frame(width: size, height: size)
        .padding(5)
    }
}
