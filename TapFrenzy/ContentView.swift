import Foundation
import SwiftUI

struct ContentView: View {
    @AppStorage("highScore") private var highScore = 0
    @AppStorage("gamesPlayed") private var gamesPlayed = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.scenePhase) private var scenePhase
    @State private var round = GameRound()
    @State private var isNewBest = false

    private let background = Color(red: 0.055, green: 0.069, blue: 0.108)
    private let panel = Color(red: 0.10, green: 0.12, blue: 0.18)
    private let muted = Color(red: 0.71, green: 0.75, blue: 0.83)
    private let mint = Color(red: 0.45, green: 0.97, blue: 0.76)

    var body: some View {
        GeometryReader { geometry in
            let isWide = geometry.size.width >= 620
                && geometry.size.width > geometry.size.height
                && !dynamicTypeSize.isAccessibilitySize

            ScrollView {
                Group {
                    if isWide {
                        HStack(spacing: 44) {
                            VStack(alignment: .leading, spacing: 18) {
                                header
                                timer
                                stats
                            }
                            controls(buttonSize: 158)
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        VStack(spacing: 24) {
                            header
                            timer
                            controls(buttonSize: 196)
                            stats
                        }
                    }
                }
                .frame(maxWidth: isWide ? 780 : 440)
                .padding(.horizontal, 24)
                .padding(.vertical, isWide ? 16 : 24)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
        }
        .foregroundStyle(.white)
        .background {
            background.overlay(alignment: .top) {
                RadialGradient(
                    colors: [Color(red: 0.12, green: 0.24, blue: 0.24), .clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 450
                )
            }
            .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
        .task(id: round.phase) {
            guard round.phase == .playing else { return }
            while round.phase == .playing {
                do {
                    try await Task.sleep(for: .milliseconds(33))
                } catch {
                    return
                }
                updateRound()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                updateRound()
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "bolt.fill")
                .font(.headline)
                .foregroundStyle(mint)
                .frame(width: 40, height: 40)
                .background(mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)

            Text("Tap Frenzy")
                .font(.title2.weight(.bold))
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)
        }
    }

    private var timerColor: Color {
        switch round.secondsRemaining {
        case 0...3: Color(red: 1, green: 0.51, blue: 0.53)
        case 4...6: Color(red: 1, green: 0.76, blue: 0.42)
        default: mint
        }
    }

    private var timer: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Time remaining")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(muted)
                Spacer()
                Text("\(round.secondsRemaining)s")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(timerColor)
            }
            GeometryReader { geometry in
                Capsule()
                    .fill(.white.opacity(0.10))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(timerColor)
                            .frame(width: geometry.size.width * CGFloat(round.progress))
                    }
            }
            .frame(height: 7)
            .accessibilityHidden(true)
        }
        .padding(16)
        .background(panel, in: RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Time remaining")
        .accessibilityValue("\(round.secondsRemaining) seconds")
    }

    private func controls(buttonSize: CGFloat) -> some View {
        VStack(spacing: 14) {
            VStack(spacing: 0) {
                Text(round.phase == .over ? "Final score" : "Score")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(muted)
                Text(round.score.formatted())
                    .font(.system(size: 58, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: round.score)
            }
            .accessibilityElement(children: .combine)

            Button(action: handleTap) {
                VStack(spacing: 6) {
                    Image(systemName: round.phase == .over ? "arrow.clockwise" : "bolt.fill")
                        .font(.title3.weight(.bold))
                        .accessibilityHidden(true)
                    Text(round.phase == .over ? "Try again" : "TAP")
                        .font(.title2.weight(.black))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .foregroundStyle(background)
                .frame(width: buttonSize, height: buttonSize)
                .background {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.69, green: 1, blue: 0.83), mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: mint.opacity(0.25), radius: 22, y: 9)
                }
                .overlay {
                    Circle().strokeBorder(.white.opacity(0.45), lineWidth: 1)
                }
                .contentShape(Circle())
            }
            .buttonStyle(TapButtonStyle())
            .accessibilityLabel(buttonLabel)

            Text(roundMessage)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isNewBest && round.phase == .over ? mint : muted)
                .multilineTextAlignment(.center)
                .frame(minHeight: 24)
        }
        .padding(.vertical, 2)
    }

    private var buttonLabel: String {
        switch round.phase {
        case .idle: "Start round"
        case .playing: "Tap to score"
        case .over: "Try again"
        }
    }

    private var roundMessage: String {
        switch round.phase {
        case .idle: "First tap starts the 10-second round."
        case .playing: "Keep tapping!"
        case .over: isNewBest ? "Time’s up · New personal best!" : "Time’s up!"
        }
    }

    private var stats: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 8))
            : AnyLayout(HStackLayout(spacing: 10))

        return layout {
            stat("Best score", value: highScore, icon: "trophy")
            stat("Games played", value: gamesPlayed, icon: "flag.checkered")
        }
    }

    private func stat(_ title: String, value: Int, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(muted)
            Text(value.formatted())
                .font(.title3.weight(.bold).monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(panel, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private func handleTap() {
        let now = ProcessInfo.processInfo.systemUptime
        switch round.phase {
        case .idle, .over:
            isNewBest = false
            round.start(at: now)
        case .playing:
            round.tap(at: now)
            saveResultIfOver()
        }
    }

    private func updateRound() {
        guard round.phase == .playing else { return }
        round.advance(to: ProcessInfo.processInfo.systemUptime)
        saveResultIfOver()
    }

    private func saveResultIfOver() {
        guard round.phase == .over else { return }
        gamesPlayed += 1
        isNewBest = round.score > highScore
        if isNewBest {
            highScore = round.score
        }
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

#Preview {
    ContentView()
}
