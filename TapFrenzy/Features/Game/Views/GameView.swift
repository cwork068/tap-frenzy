import Foundation
import SwiftUI

struct GameView: View {
    @AppStorage("highScore") private var highScore = 0
    @AppStorage("gamesPlayed") private var gamesPlayed = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.scenePhase) private var scenePhase
    @State private var round = GameRound()
    @State private var isNewBest = false

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
            GameTheme.background.overlay(alignment: .top) {
                RadialGradient(
                    colors: [GameTheme.backgroundGlow, .clear],
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
                .foregroundStyle(GameTheme.accent)
                .frame(width: 40, height: 40)
                .background(GameTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)

            Text("Tap Frenzy")
                .font(.title2.weight(.bold))
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)
        }
    }

    private var timer: some View {
        RoundTimerView(secondsRemaining: round.secondsRemaining, progress: round.progress)
    }

    private func controls(buttonSize: CGFloat) -> some View {
        VStack(spacing: 14) {
            VStack(spacing: 0) {
                Text(round.phase == .over ? "Final score" : "Score")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(GameTheme.secondaryText)
                Text(round.score.formatted())
                    .font(.system(size: 58, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: round.score)
            }
            .accessibilityElement(children: .combine)

            TapControl(phase: round.phase, size: buttonSize, action: handleTap)

            Text(roundMessage)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(
                    isNewBest && round.phase == .over ? GameTheme.accent : GameTheme.secondaryText
                )
                .multilineTextAlignment(.center)
                .frame(minHeight: 24)
        }
        .padding(.vertical, 2)
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
                .foregroundStyle(GameTheme.secondaryText)
            Text(value.formatted())
                .font(.title3.weight(.bold).monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(GameTheme.surface, in: RoundedRectangle(cornerRadius: 16))
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

#Preview {
    GameView()
}
