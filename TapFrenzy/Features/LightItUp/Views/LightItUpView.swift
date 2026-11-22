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
    @State private var feedbackText: String?
    @State private var feedbackIsPositive = false
    @State private var feedbackID = 0

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
        .task(id: feedbackID) {
            guard feedbackText != nil else { return }
            let currentFeedback = feedbackID
            do { try await Task.sleep(for: .milliseconds(700)) }
            catch { return }
            if feedbackID == currentFeedback { feedbackText = nil }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { reconcile() }
        }
    }

    private var statusPanel: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Find the light")
                    .font(.title2.weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Catch the glowing card before it fades")
                    .font(.caption)
                    .foregroundStyle(GameTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            AppearancePicker()
            if round.phase != .over {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SCORE")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(GameTheme.secondaryText)
                        Text(round.score.formatted())
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .monospacedDigit()
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 7) {
                        Text("LIVES")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(GameTheme.secondaryText)
                        HStack(spacing: 5) {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: index < round.lives ? "heart.fill" : "heart")
                                    .foregroundStyle(index < round.lives
                                                     ? GameTheme.critical : GameTheme.track)
                            }
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(round.lives) of 3 lives")
                    }
                }
                VStack(spacing: 8) {
                    HStack {
                        Text("LEVEL \(round.level) OF 4")
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
                .accessibilityLabel("Level \(round.level) of 4, \(round.secondsRemaining) seconds remaining")
                Text("Personal best: \(highScore.formatted())")
                    .font(.footnote)
                    .foregroundStyle(GameTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(GameTheme.surface, in: RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private var playArea: some View {
        if round.phase == .over {
            VStack(spacing: 12) {
                Image(systemName: round.isNewBest ? "star.circle.fill" : "checkmark.circle.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(GameTheme.accent)
                    .accessibilityHidden(true)
                Text(round.isNewBest ? "New Personal Best" : "Round Complete")
                    .font(.title2.weight(.bold))
                Text("FINAL SCORE")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(GameTheme.secondaryText)
                Text(round.score.formatted())
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .monospacedDigit()
                Text("All-time best: \(round.bestScore.formatted())")
                    .font(.subheadline)
                    .foregroundStyle(GameTheme.secondaryText)
                Button(action: playAgain) {
                    Text("Play Again")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(GameTheme.buttonText)
                        .frame(maxWidth: 240, minHeight: 56)
                        .background(GameTheme.buttonFill, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 14)
                Text("Rounds played: \(roundsPlayed)")
                    .font(.footnote)
                    .foregroundStyle(GameTheme.secondaryText)
            }
            .frame(maxWidth: .infinity, minHeight: 300)
            .multilineTextAlignment(.center)
        } else {
            VStack(spacing: 14) {
                Text(round.phase == .idle ? "Tap any card to start" : "Tap the glowing card")
                    .font(.headline.weight(.semibold))
                    .multilineTextAlignment(.center)
                let columns = round.cardCount == 4 ? 2 : 3
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12),
                                         count: columns), spacing: 12) {
                    ForEach(0..<round.cardCount, id: \.self) { card in
                        Button { handleCard(card) } label: {
                            VStack(spacing: 5) {
                                Image(systemName: round.litCard == card ? "bolt.fill" : "circle.fill")
                                    .font(.title2.weight(.bold))
                                Text(round.litCard == card ? "TAP" : "\(card + 1)")
                                    .font(.caption.weight(.bold).monospacedDigit())
                            }
                                .foregroundStyle(round.litCard == card
                                                 ? GameTheme.buttonText : GameTheme.secondaryText)
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .background(round.litCard == card
                                            ? GameTheme.buttonFill : GameTheme.surface,
                                            in: RoundedRectangle(cornerRadius: 18))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18)
                                        .strokeBorder(round.litCard == card
                                                      ? GameTheme.buttonText.opacity(0.4)
                                                      : GameTheme.track.opacity(0.45), lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Card \(card + 1)\(round.litCard == card ? ", lit" : "")")
                    }
                }
                .frame(maxWidth: 420)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: round.litCard)
                Text("Level \(round.level) · \(round.cardCount) cards · \(round.lightWindow, specifier: "%.1f")s window")
                    .font(.caption)
                    .foregroundStyle(GameTheme.secondaryText)
                if let feedbackText {
                    HStack(spacing: 8) {
                        Image(systemName: feedbackIsPositive
                              ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundStyle(feedbackIsPositive
                                             ? GameTheme.accent : GameTheme.critical)
                            .accessibilityHidden(true)
                        Text(feedbackText)
                    }
                    .font(.subheadline.weight(.medium))
                    .frame(minHeight: 26)
                } else {
                    Text("Three lives. Misses and wrong taps cost one.")
                        .font(.footnote)
                        .foregroundStyle(GameTheme.secondaryText)
                        .frame(minHeight: 26)
                }
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
            showFeedback("Go! Catch the lit card", positive: true)
        case .correct:
            feedback.impactOccurred(intensity: 0.55)
            feedback.prepare()
            showFeedback("Great hit · +1", positive: true)
        case .completed:
            saveCompletion()
        case .wrong:
            showFeedback("Wrong card · one life lost", positive: false)
        case .missed:
            showFeedback("Too slow · one life lost", positive: false)
        case .ignored: break
        }
    }

    private func reconcile() {
        let previousLives = round.lives
        if round.advance(to: .now, nextCard: Int.random(in: 0..<36)) {
            saveCompletion()
        } else if round.lives < previousLives {
            showFeedback("Too slow · one life lost", positive: false)
        }
    }

    private func showFeedback(_ text: String, positive: Bool) {
        feedbackText = text
        feedbackIsPositive = positive
        feedbackID += 1
    }

    private func saveCompletion() {
        roundsPlayed += 1
        if round.bestScore > highScore { highScore = round.bestScore }
    }

    private func playAgain() {
        round.reset()
        roundID += 1
        feedbackText = nil
        feedbackID += 1
    }
}
