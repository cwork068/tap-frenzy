struct LightItUpRound {
    enum Phase: Equatable { case idle, playing, over }
    enum TapResult: Equatable { case started, correct, wrong, missed, completed, ignored }

    static let duration = 60.0

    private(set) var phase = Phase.idle
    private(set) var score = 0
    private(set) var lives = 3
    private(set) var remaining = LightItUpRound.duration
    private(set) var level = 1
    private(set) var litCard: Int?
    private(set) var bestScore: Int
    private(set) var isNewBest = false

    private var startedAt: ContinuousClock.Instant?
    private var deadline: ContinuousClock.Instant?
    private var litUntil: ContinuousClock.Instant?
    private var nextLightAt: ContinuousClock.Instant?

    init(bestScore: Int = 0) { self.bestScore = bestScore }

    var secondsRemaining: Int { Int(remaining.rounded(.up)) }
    var cardCount: Int { [3, 4, 6, 9][level - 1] }
    var lightWindow: Double { [1.2, 0.9, 0.7, 0.5][level - 1] }

    mutating func tap(card: Int, at now: ContinuousClock.Instant, nextCard: Int) -> TapResult {
        if phase == .idle {
            start(at: now, card: nextCard)
            return .started
        }
        guard phase == .playing else { return .ignored }
        let justMissed = litUntil.map { now >= $0 } ?? false
        if advance(to: now, nextCard: nextCard) { return .completed }
        if justMissed { return .missed }
        if card == litCard {
            score += 1
            clearLight(at: now)
            return .correct
        }
        lives -= 1
        clearLight(at: now)
        return lives == 0 ? (finish() ? .completed : .ignored) : .wrong
    }

    // Returns true only when this call completes the round.
    @discardableResult
    mutating func advance(to now: ContinuousClock.Instant, nextCard: Int) -> Bool {
        guard phase == .playing, let deadline, let startedAt else { return false }
        if now >= deadline {
            remaining = 0
            return finish()
        }
        let parts = now.duration(to: deadline).components
        remaining = Double(parts.seconds) + Double(parts.attoseconds) / 1e18
        let elapsed = startedAt.duration(to: now).components
        let elapsedSeconds = Double(elapsed.seconds) + Double(elapsed.attoseconds) / 1e18
        level = min(4, max(1, Int(elapsedSeconds / 15) + 1))

        if let litUntil, now >= litUntil {
            lives -= 1
            clearLight(at: now)
            if lives == 0 { return finish() }
        }
        if litCard == nil, let nextLightAt, now >= nextLightAt {
            light(card: nextCard, at: now)
        }
        return false
    }

    mutating func reset() {
        guard phase == .over else { return }
        phase = .idle
        score = 0
        lives = 3
        remaining = Self.duration
        level = 1
        litCard = nil
        litUntil = nil
        nextLightAt = nil
        startedAt = nil
        deadline = nil
        isNewBest = false
    }

    private mutating func start(at now: ContinuousClock.Instant, card: Int) {
        phase = .playing
        startedAt = now
        deadline = now + .seconds(60)
        light(card: card, at: now)
    }

    private mutating func light(card: Int, at now: ContinuousClock.Instant) {
        litCard = abs(card % cardCount)
        litUntil = now + .seconds(lightWindow)
        nextLightAt = nil
    }

    private mutating func clearLight(at now: ContinuousClock.Instant) {
        litCard = nil
        litUntil = nil
        nextLightAt = now + .milliseconds(350)
    }

    private mutating func finish() -> Bool {
        guard phase == .playing else { return false }
        phase = .over
        litCard = nil
        litUntil = nil
        nextLightAt = nil
        isNewBest = score > bestScore
        if isNewBest { bestScore = score }
        return true
    }
}
