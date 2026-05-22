import Foundation

public enum CourtTapTeam: Int, CaseIterable, Sendable {
    case a = 0
    case b = 1

    public var opponent: CourtTapTeam {
        self == .a ? .b : .a
    }
}

public enum CourtTapScoreLabel: Equatable, Sendable {
    case points(String)
    case game
}

public struct CourtTapMatchState: Equatable, Sendable {
    public var points: [Int]
    public var games: [Int]
    public var server: CourtTapTeam
    public var gameWinner: CourtTapTeam?
    public var canUndo: Bool

    public init(
        points: [Int] = [0, 0],
        games: [Int] = [0, 0],
        server: CourtTapTeam = .a,
        gameWinner: CourtTapTeam? = nil,
        canUndo: Bool = false
    ) {
        self.points = points
        self.games = games
        self.server = server
        self.gameWinner = gameWinner
        self.canUndo = canUndo
    }

    public func scoreLabel(for team: CourtTapTeam) -> CourtTapScoreLabel {
        if gameWinner == team {
            return .game
        }

        let teamPoints = points[team.rawValue]
        let opponentPoints = points[team.opponent.rawValue]

        if teamPoints >= 3 && opponentPoints >= 3 {
            if teamPoints == opponentPoints {
                return .points("40")
            }

            return teamPoints > opponentPoints ? .points("Adv") : .points("40")
        }

        let labels = ["0", "15", "30", "40"]
        return .points(labels[min(teamPoints, labels.count - 1)])
    }
}

public final class CourtTapScoringEngine {
    private struct Snapshot: Equatable {
        var points: [Int]
        var games: [Int]
        var server: CourtTapTeam
    }

    private var points = [0, 0]
    private var games = [0, 0]
    private var server: CourtTapTeam = .a
    private var gameWinner: CourtTapTeam?
    private var history: [Snapshot] = []
    private var isGameBoundary = false

    public init() {}

    public var state: CourtTapMatchState {
        CourtTapMatchState(
            points: points,
            games: games,
            server: server,
            gameWinner: gameWinner,
            canUndo: gameWinner == nil && !history.isEmpty
        )
    }

    public func addPoint(to team: CourtTapTeam) {
        guard gameWinner == nil else {
            return
        }

        let previous = snapshot()
        let teamPoints = points[team.rawValue]
        let opponentPoints = points[team.opponent.rawValue]
        let winsGame = teamPoints >= 3 && (opponentPoints < 3 || teamPoints - opponentPoints >= 1)

        if winsGame {
            history = [previous]
            isGameBoundary = true
            games[team.rawValue] += 1
            server = server.opponent
            gameWinner = team
            return
        }

        if isGameBoundary {
            history = []
            isGameBoundary = false
        }

        history.append(previous)
        points[team.rawValue] += 1
    }

    public func clearGameBanner() {
        guard gameWinner != nil else {
            return
        }

        points = [0, 0]
        gameWinner = nil
    }

    public func undo() {
        guard gameWinner == nil, let previous = history.popLast() else {
            return
        }

        points = previous.points
        games = previous.games
        server = previous.server

        if isGameBoundary {
            history = []
            isGameBoundary = false
        }
    }

    private func snapshot() -> Snapshot {
        Snapshot(points: points, games: games, server: server)
    }
}
