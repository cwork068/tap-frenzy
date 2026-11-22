import SwiftUI
import UIKit

@MainActor
struct GameView: View {
    @AppStorage("highScore") private var highScore = 0
    @AppStorage("gamesPlayed") private var gamesPlayed = 0
    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.system.rawValue
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.scenePhase) private var scenePhase
    @ScaledMetric(relativeTo: .largeTitle) private var scoreSize: CGFloat = 68
    @State private var round = GameRound(bestScore: UserDefaults.standard.integer(forKey: "highScore"))
    @State private var roundID = 0
    @State private var tapFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        GeometryReader { geometry in
            let wide = geometry.size.width > geometry.size.height
                && geometry.size.width >= 620
                && !dynamicTypeSize.isAccessibilitySize
            let ringSize = wide ? CGFloat(200) : min(244, max(174, geometry.size.height * 0.36))

            ScrollView {
                Group {
                    if wide {
                        HStack(alignment: .center, spacing: 32) {
                            VStack(alignment: .leading, spacing: 22) {
                                header
                                scoreView
                                if round.phase == .over { resultStatus }
                                roundsPlayed
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            primaryControl(ringSize: ringSize)
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        VStack(spacing: 18) {
                            header
                            scoreView
                            if round.phase == .over {
                                resultStatus
                                primaryControl(ringSize: ringSize)
                            } else {
                                primaryControl(ringSize: ringSize)
                                instruction
                            }
                            roundsPlayed
                        }
                    }
                }
                .frame(maxWidth: 760)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
        }
        .foregroundStyle(GameTheme.text)
        .background(GameTheme.background.ignoresSafeArea())
        .onAppear { tapFeedback.prepare() }
        .task(id: roundID) {
            let currentRound = roundID
            while !Task.isCancelled && roundID == currentRound && round.phase == .playing {
                do { try await Task.sleep(for: .milliseconds(50)) }
                catch { return }
                guard !Task.isCancelled && roundID == currentRound else { return }
                reconcile()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { reconcile() }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("Tap Frenzy")
                .font(.headline.weight(.heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 4)
            VStack(alignment: .trailing, spacing: 0) {
                Text("BEST")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(GameTheme.secondaryText)
                Text(highScore.formatted())
                    .font(.headline.monospacedDigit())
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("All-time best, \(highScore)")
            appearanceMenu
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(GameTheme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    private var appearanceMenu: some View {
        let current = AppearanceMode(rawValue: appearanceMode) ?? .system
        return Menu {
            ForEach(AppearanceMode.allCases) { mode in
                Button {
                    appearanceMode = mode.rawValue
                } label: {
                    if mode == current {
                        Label(mode.title, systemImage: "checkmark")
                    } else {
                        Text(mode.title)
                    }
                }
            }
        } label: {
            Image(systemName: "circle.lefthalf.filled")
                .font(.title3)
                .foregroundStyle(GameTheme.accent)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Appearance, \(current.title) selected")
        .accessibilityHint("Choose System, Light, or Dark")
    }

    private var scoreView: some View {
        VStack(spacing: 0) {
            Text(round.phase == .over ? "FINAL SCORE" : "SCORE")
                .font(.caption.weight(.bold))
                .tracking(2)
                .foregroundStyle(GameTheme.secondaryText)
            Text(round.score.formatted())
                .font(.system(size: scoreSize, weight: .black, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: round.score)
                .frame(minWidth: 140)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(round.phase == .over ? "Final score" : "Score"), \(round.score)")
    }

    @ViewBuilder
    private func primaryControl(ringSize: CGFloat) -> some View {
        if round.phase == .over {
            Button(action: playAgain) {
                Text("Play Again")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: 220)
                    .frame(height: 56)
                    .foregroundStyle(GameTheme.buttonText)
                    .background(GameTheme.buttonFill, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.vertical, 28)
        } else {
            RoundTimerView(secondsRemaining: round.secondsRemaining,
                           progress: round.progress,
                           size: ringSize,
                           isPlaying: round.phase == .playing,
                           action: handleTap)
        }
    }

    private var resultStatus: some View {
        VStack(spacing: 6) {
            Text(round.isNewBest ? "New Personal Best" : "Round Complete")
                .font(.title3.weight(.bold))
                .foregroundStyle(round.isNewBest ? GameTheme.accent : GameTheme.text)
            Text("All-time best: \(round.bestScore.formatted())")
                .font(.subheadline)
                .foregroundStyle(GameTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .transition(.opacity)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: round.phase)
    }

    private var instruction: some View {
        Text(round.phase == .idle ? "First tap starts the 10-second round." : "Keep tapping!")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(GameTheme.secondaryText)
            .multilineTextAlignment(.center)
    }

    private var roundsPlayed: some View {
        Text("Rounds played: \(gamesPlayed)")
            .font(.footnote)
            .foregroundStyle(GameTheme.secondaryText)
            .frame(maxWidth: .infinity)
    }

    private func handleTap() {
        let now = ContinuousClock.now
        switch round.phase {
        case .idle:
            if round.start(at: now) {
                roundID += 1
                acceptedTapFeedback()
            }
        case .playing:
            switch round.tap(at: now) {
            case .accepted: acceptedTapFeedback()
            case .completed: saveCompletion()
            case .ignored: break
            }
        case .over: break
        }
    }

    private func reconcile() {
        if round.advance(to: ContinuousClock.now) { saveCompletion() }
    }

    private func saveCompletion() {
        gamesPlayed += 1
        if round.bestScore > highScore { highScore = round.bestScore }
    }

    private func playAgain() {
        round.reset()
        roundID += 1
        tapFeedback.prepare()
    }

    private func acceptedTapFeedback() {
        tapFeedback.impactOccurred(intensity: 0.55)
        tapFeedback.prepare()
    }
}

#Preview {
    GameView()
}
