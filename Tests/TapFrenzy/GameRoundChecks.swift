@main
struct GameRoundChecks {
    static func main() {
        let start = ContinuousClock.now
        var round = GameRound(bestScore: 3)
        precondition(round.tap(at: start) == .ignored)
        precondition(round.start(at: start))
        precondition(!round.start(at: start))
        precondition(round.phase == .playing && round.score == 1)
        precondition(round.secondsRemaining == 10 && round.progress == 1)

        precondition(round.tap(at: start + .seconds(9.999)) == .accepted)
        precondition(round.score == 2 && round.secondsRemaining == 1)
        precondition(round.tap(at: start + .seconds(10)) == .completed)
        precondition(round.score == 2 && round.phase == .over)
        precondition(round.remaining == 0 && round.progress == 0)
        precondition(!round.isNewBest && round.bestScore == 3)
        precondition(!round.advance(to: start + .seconds(11)))
        precondition(round.tap(at: start + .seconds(11)) == .ignored)

        round.reset()
        precondition(round.phase == .idle && round.score == 0)
        precondition(round.bestScore == 3 && !round.isNewBest)
        precondition(round.start(at: start + .seconds(20)))
        precondition(round.tap(at: start + .seconds(21)) == .accepted)
        precondition(round.tap(at: start + .seconds(22)) == .accepted)
        precondition(round.advance(to: start + .seconds(30)))
        precondition(round.score == 3 && !round.isNewBest)

        round.reset()
        precondition(round.start(at: start + .seconds(40)))
        for index in 1...3 {
            precondition(round.tap(at: start + .seconds(40 + index)) == .accepted)
        }
        precondition(round.advance(to: start + .seconds(50)))
        precondition(round.score == 4 && round.bestScore == 4 && round.isNewBest)
        precondition(!round.advance(to: start + .seconds(51)))
        round.reset()
        precondition(round.bestScore == 4 && !round.isNewBest)
        print("Round checks passed")
    }
}
