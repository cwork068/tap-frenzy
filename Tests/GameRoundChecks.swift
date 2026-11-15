@main
struct GameRoundChecks {
    static func main() {
        var round = GameRound()
        round.tap(at: 99)
        precondition(round.phase == .idle && round.score == 0)

        round.start(at: 100)
        precondition(round.phase == .playing && round.score == 1)
        precondition(round.secondsRemaining == 10 && round.progress == 1)

        for index in 1...50 {
            round.tap(at: 100 + Double(index) / 100)
        }
        precondition(round.score == 51)

        round.tap(at: 109.99)
        precondition(round.score == 52 && round.secondsRemaining == 1)
        round.tap(at: 110)
        precondition(round.phase == .over && round.score == 52)
        precondition(round.secondsRemaining == 0 && round.progress == 0)
        round.tap(at: 111)
        precondition(round.score == 52)

        round.start(at: 120)
        precondition(round.phase == .playing && round.score == 1)
        round.advance(to: 135)
        precondition(round.phase == .over && round.score == 1)
        print("Round checks passed")
    }
}
