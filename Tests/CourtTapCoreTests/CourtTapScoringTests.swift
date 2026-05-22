import CourtTapCore
import XCTest

final class CourtTapScoringTests: XCTestCase {
    func testAdvantageScoringReturnsToDeuce() {
        let engine = CourtTapScoringEngine()

        repeatPoint(.a, times: 3, engine: engine)
        repeatPoint(.b, times: 3, engine: engine)
        engine.addPoint(to: .a)

        XCTAssertEqual(engine.state.scoreLabel(for: .a), .points("Adv"))
        XCTAssertEqual(engine.state.scoreLabel(for: .b), .points("40"))

        engine.addPoint(to: .b)

        XCTAssertEqual(engine.state.scoreLabel(for: .a), .points("40"))
        XCTAssertEqual(engine.state.scoreLabel(for: .b), .points("40"))
    }

    func testAdvantageWinsGameAndCanBeCleared() {
        let engine = CourtTapScoringEngine()

        repeatPoint(.a, times: 3, engine: engine)
        repeatPoint(.b, times: 3, engine: engine)
        engine.addPoint(to: .a)
        engine.addPoint(to: .a)

        XCTAssertEqual(engine.state.gameWinner, .a)
        XCTAssertEqual(engine.state.games, [1, 0])
        XCTAssertEqual(engine.state.server, .b)

        engine.clearGameBanner()

        XCTAssertEqual(engine.state.points, [0, 0])
        XCTAssertNil(engine.state.gameWinner)
    }

    func testUndoCanWalkBackCurrentGameOnly() {
        let engine = CourtTapScoringEngine()

        repeatPoint(.a, times: 3, engine: engine)

        XCTAssertEqual(engine.state.scoreLabel(for: .a), .points("40"))

        engine.undo()
        XCTAssertEqual(engine.state.scoreLabel(for: .a), .points("30"))

        engine.undo()
        XCTAssertEqual(engine.state.scoreLabel(for: .a), .points("15"))

        engine.undo()
        XCTAssertEqual(engine.state.scoreLabel(for: .a), .points("0"))

        engine.undo()
        XCTAssertEqual(engine.state.scoreLabel(for: .a), .points("0"))
    }

    func testUndoAtNewGameBoundaryOnlyRestoresFinalPoint() {
        let engine = CourtTapScoringEngine()

        repeatPoint(.a, times: 4, engine: engine)
        engine.clearGameBanner()

        XCTAssertEqual(engine.state.games, [1, 0])
        XCTAssertEqual(engine.state.points, [0, 0])

        engine.undo()

        XCTAssertEqual(engine.state.games, [0, 0])
        XCTAssertEqual(engine.state.scoreLabel(for: .a), .points("40"))

        engine.undo()

        XCTAssertEqual(engine.state.games, [0, 0])
        XCTAssertEqual(engine.state.scoreLabel(for: .a), .points("40"))
    }

    private func repeatPoint(_ team: CourtTapTeam, times: Int, engine: CourtTapScoringEngine) {
        for _ in 0..<times {
            engine.addPoint(to: team)
        }
    }
}
