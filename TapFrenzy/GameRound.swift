struct GameRound {
    enum Phase: Equatable {
        case idle
        case playing
        case over
    }

    static let duration = 10.0

    private(set) var phase = Phase.idle
    private(set) var score = 0
    private(set) var remaining = GameRound.duration
    private var deadline = 0.0

    var secondsRemaining: Int {
        Int(remaining.rounded(.up))
    }

    var progress: Double {
        remaining / Self.duration
    }

    mutating func start(at now: Double) {
        score = 1
        remaining = Self.duration
        deadline = now + Self.duration
        phase = .playing
    }

    mutating func tap(at now: Double) {
        guard phase == .playing else { return }
        advance(to: now)
        if phase == .playing {
            score += 1
        }
    }

    mutating func advance(to now: Double) {
        guard phase == .playing else { return }
        remaining = min(Self.duration, max(0, deadline - now))
        if remaining == 0 {
            phase = .over
        }
    }
}
