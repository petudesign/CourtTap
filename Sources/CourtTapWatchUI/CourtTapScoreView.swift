import CourtTapCore
import SwiftUI

public struct CourtTapScoreView: View {
    @StateObject private var viewModel: CourtTapViewModel

    public init(viewModel: CourtTapViewModel = CourtTapViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            Color(red: 0.03, green: 0.06, blue: 0.05)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                MatchHeader(state: viewModel.matchState)

                ZStack(alignment: .leading) {
                    VStack(spacing: 12) {
                        ScoreHalf(
                            team: .a,
                            state: viewModel.matchState,
                            gradient: LinearGradient(
                                colors: [
                                    Color(red: 0.92, green: 0.06, blue: 0.62),
                                    Color(red: 0.70, green: 0.05, blue: 0.88)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        ) {
                            viewModel.addPoint(to: .a)
                        }

                        ScoreHalf(
                            team: .b,
                            state: viewModel.matchState,
                            gradient: LinearGradient(
                                colors: [
                                    Color(red: 1.00, green: 0.50, blue: 0.12),
                                    Color(red: 0.95, green: 0.24, blue: 0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        ) {
                            viewModel.addPoint(to: .b)
                        }
                    }

                    UndoButton(isEnabled: viewModel.matchState.canUndo) {
                        viewModel.undo()
                    }
                    .offset(x: -2)
                }

                WatchNav()
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 10)
        }
    }
}

private struct MatchHeader: View {
    let state: CourtTapMatchState

    var body: some View {
        HStack {
            Text("PADEL")
            Spacer()
            Text("\(state.games[CourtTapTeam.a.rawValue])-\(state.games[CourtTapTeam.b.rawValue])")
                .foregroundStyle(Color(red: 0.87, green: 1.0, blue: 0.18))
            Spacer()
            Text("SET 1")
        }
        .font(.system(size: 10, weight: .heavy, design: .rounded))
        .foregroundStyle(Color(red: 0.75, green: 0.88, blue: 0.82))
        .textCase(.uppercase)
    }
}

private struct ScoreHalf: View {
    let team: CourtTapTeam
    let state: CourtTapMatchState
    let gradient: LinearGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                HStack(spacing: 4) {
                    Text(team == .a ? "A" : "B")

                    if state.server == team {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                    }
                }
                .font(.system(size: 12, weight: .heavy, design: .rounded))

                scoreText

                Spacer(minLength: 4)

                Text("TAP")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.white)
            .background(NotchedScoreBackground(team: team, gradient: gradient))
        }
        .buttonStyle(.plain)
        .disabled(state.gameWinner != nil)
    }

    @ViewBuilder
    private var scoreText: some View {
        switch state.scoreLabel(for: team) {
        case .game:
            Text("Game!")
                .font(.system(size: 27, weight: .black, design: .rounded))
        case .points(let label):
            Text(label)
                .font(.system(size: label == "Adv" ? 34 : 56, weight: .black, design: .rounded))
        }
    }
}

private struct UndoButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.uturn.backward")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(isEnabled ? .white : Color(red: 0.54, green: 0.58, blue: 0.56))
                .frame(width: 38, height: 38)
                .background(isEnabled ? Color(red: 1.0, green: 0.29, blue: 0.29) : Color(red: 0.91, green: 0.93, blue: 0.91))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.28), radius: 8, x: 0, y: 4)
                .overlay(Circle().stroke(Color(red: 0.03, green: 0.06, blue: 0.05), lineWidth: 4))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

private struct WatchNav: View {
    var body: some View {
        HStack {
            NavItem(symbol: "plus", label: "Pts", isActive: true)
            Spacer()
            NavItem(symbol: "number", label: "Sets", isActive: false)
            Spacer()
            NavItem(symbol: "ellipsis", label: "More", isActive: false)
        }
        .padding(.horizontal, 34)
    }
}

private struct NavItem: View {
    let symbol: String
    let label: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 1) {
            Image(systemName: symbol)
                .font(.system(size: 10, weight: .heavy))
            Text(label)
                .font(.system(size: 8, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(isActive ? Color(red: 0.87, green: 1.0, blue: 0.18) : Color(red: 0.42, green: 0.53, blue: 0.48))
    }
}

private struct NotchedScoreBackground: View {
    let team: CourtTapTeam
    let gradient: LinearGradient

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(gradient)

                Circle()
                    .fill(Color(red: 0.03, green: 0.06, blue: 0.05))
                    .frame(width: 56, height: 56)
                    .position(
                        x: 26,
                        y: team == .a ? proxy.size.height + 6 : -6
                    )
            }
        }
    }
}
