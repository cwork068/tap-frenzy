struct GameRound {
    enum Phase: Equatable {
        case idle
        case playing
        case over
    }

    enum TapResult: Equatable {
        case accepted
        case completed
        case ignored
    }

    static let duration = 10.0

    private(set) var phase = Phase.idle
    private(set) var score = 0
    private(set) var remaining = GameRound.duration
    private(set) var bestScore: Int
    private(set) var isNewBest = false
    private var deadline: ContinuousClock.Instant?

    init(bestScore: Int = 0) {
        self.bestScore = bestScore
    }

    var secondsRemaining: Int { Int(remaining.rounded(.up)) }
    var progress: Double { remaining / Self.duration }

    mutating func start(at now: ContinuousClock.Instant) -> Bool {
        guard phase == .idle else { return false }
        score = 1
        remaining = Self.duration
        isNewBest = false
        deadline = now + .seconds(10)
        phase = .playing
        return true
    }

    mutating func tap(at now: ContinuousClock.Instant) -> TapResult {
        guard phase == .playing else { return .ignored }
        if advance(to: now) { return .completed }
        score += 1
        return .accepted
    }

    // Returns true only for the transition into game over.
    @discardableResult
    mutating func advance(to now: ContinuousClock.Instant) -> Bool {
        guard phase == .playing, let deadline else { return false }
        let timeLeft = now.duration(to: deadline)
        guard now < deadline else {
            remaining = 0
            phase = .over
            isNewBest = score > bestScore
            if isNewBest { bestScore = score }
            return true
        }
        let parts = timeLeft.components
        remaining = min(Self.duration,
                        max(0, Double(parts.seconds) + Double(parts.attoseconds) / 1e18))
        return false
    }

    mutating func reset() {
        guard phase == .over else { return }
        phase = .idle
        score = 0
        remaining = Self.duration
        deadline = nil
        isNewBest = false
    }
}
