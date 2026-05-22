import Combine
import CourtTapCore
import Foundation

@MainActor
public final class CourtTapViewModel: ObservableObject {
    @Published public private(set) var matchState: CourtTapMatchState

    private let scoringEngine: CourtTapScoringEngine
    private var gameBannerTask: Task<Void, Never>?

    public init(scoringEngine: CourtTapScoringEngine = CourtTapScoringEngine()) {
        self.scoringEngine = scoringEngine
        self.matchState = scoringEngine.state
    }

    public func addPoint(to team: CourtTapTeam) {
        scoringEngine.addPoint(to: team)
        sync()

        guard matchState.gameWinner != nil else {
            return
        }

        gameBannerTask?.cancel()
        gameBannerTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(900))
            guard !Task.isCancelled else {
                return
            }

            await self?.clearGameBanner()
        }
    }

    public func undo() {
        gameBannerTask?.cancel()
        scoringEngine.undo()
        sync()
    }

    private func clearGameBanner() {
        scoringEngine.clearGameBanner()
        sync()
    }

    private func sync() {
        matchState = scoringEngine.state
    }
}
