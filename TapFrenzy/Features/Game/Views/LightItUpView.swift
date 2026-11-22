import SwiftUI
import UIKit

@MainActor
struct LightItUpView: View {
    @AppStorage("lightItUpHighScore") private var highScore = 0
    @AppStorage("lightItUpRounds") private var roundsPlayed = 0
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var round = LightItUpRound(
        bestScore: UserDefaults.standard.integer(forKey: "lightItUpHighScore"))
    @State private var roundID = 0
    @State private var feedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        GeometryReader { geometry in
            let landscape = geometry.size.width > geometry.size.height && geometry.size.width > 600
            ScrollView {
                Group {
                    if landscape {
                        HStack(alignment: .center, spacing: 28) {
                            statusPanel
                                .frame(maxWidth: 270)
                            playArea
                        }
                    } else {
                        VStack(spacing: 22) {
                            statusPanel
                            playArea
                        }
                    }
                }
                .frame(maxWidth: 760)
                .padding(20)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
        }
        .foregroundStyle(GameTheme.text)
        .background(GameTheme.background.ignoresSafeArea())
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { feedback.prepare() }
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

    private var statusPanel: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Light It Up")
                        .font(.title2.weight(.bold))
                    Text("Catch the glowing card")
                        .font(.caption)
                        .foregroundStyle(GameTheme.secondaryText)
                }
                Spacer()
                AppearanceMenu()
            }
            HStack(spacing: 10) {
                statusItem("SCORE", value: "\(round.score)")
                statusItem("LEVEL", value: "\(round.level)")
                statusItem("LIVES", value: "\(round.lives)")
            }
            VStack(spacing: 6) {
                HStack {
                    Text("TIME LEFT")
                        .font(.caption.weight(.bold))
                    Spacer()
                    Text("\(round.secondsRemaining)s")
                        .font(.headline.monospacedDigit())
                }
                ProgressView(value: round.remaining, total: LightItUpRound.duration)
                    .tint(round.secondsRemaining <= 5 ? GameTheme.critical : GameTheme.accent)
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Time remaining, \(round.secondsRemaining) seconds")
        }
    }

    private func statusItem(_ title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(GameTheme.secondaryText)
            Text(value)
                .font(.title2.weight(.bold).monospacedDigit())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(GameTheme.surface, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(value)")
    }

    @ViewBuilder
    private var playArea: some View {
        if round.phase == .over {
            VStack(spacing: 14) {
                Text("Round Complete")
                    .font(.title.weight(.bold))
                Text("Final score: \(round.score)")
                    .font(.title2.monospacedDigit())
                Text(round.isNewBest ? "New Personal Best" : "Best: \(round.bestScore)")
                    .font(.headline)
                Button(action: playAgain) {
                    Text("Play Again")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(GameTheme.buttonText)
                        .frame(maxWidth: 220, minHeight: 56)
                        .background(GameTheme.buttonFill, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 10)
                Text("Rounds played: \(roundsPlayed)")
                    .font(.footnote)
                    .foregroundStyle(GameTheme.secondaryText)
            }
            .frame(maxWidth: .infinity, minHeight: 260)
            .multilineTextAlignment(.center)
        } else {
            VStack(spacing: 18) {
                Text(round.phase == .idle ? "Tap any card to start" : "Tap the lit card before it fades")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(GameTheme.secondaryText)
                    .multilineTextAlignment(.center)
                let columns = round.cardCount == 4 ? 2 : 3
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12),
                                         count: columns), spacing: 12) {
                    ForEach(0..<round.cardCount, id: \.self) { card in
                        Button { handleCard(card) } label: {
                            Image(systemName: round.litCard == card ? "sparkle" : "circle.fill")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(round.litCard == card
                                                 ? GameTheme.buttonText : GameTheme.secondaryText)
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .background(round.litCard == card
                                            ? GameTheme.buttonFill : GameTheme.surface,
                                            in: RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Card \(card + 1)\(round.litCard == card ? ", lit" : "")")
                    }
                }
                .frame(maxWidth: 420)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: round.litCard)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func handleCard(_ card: Int) {
        let wasIdle = round.phase == .idle
        // 36 is divisible by every level's card count, so modulo selection stays even.
        let result = round.tap(card: card, at: .now, nextCard: Int.random(in: 0..<36))
        switch result {
        case .started:
            if wasIdle { roundID += 1 }
        case .correct:
            feedback.impactOccurred(intensity: 0.55)
            feedback.prepare()
        case .completed:
            saveCompletion()
        case .wrong, .missed, .ignored: break
        }
    }

    private func reconcile() {
        if round.advance(to: .now, nextCard: Int.random(in: 0..<36)) {
            saveCompletion()
        }
    }

    private func saveCompletion() {
        roundsPlayed += 1
        if round.bestScore > highScore { highScore = round.bestScore }
    }

    private func playAgain() {
        round.reset()
        roundID += 1
    }
}
