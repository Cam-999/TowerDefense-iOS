import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            Color.tdBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Image("CrossedSwords")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)

                    Text("DEFENSE")
                        .font(.system(size: 52, weight: .black, design: .serif))
                        .foregroundColor(.tdAccentAmber)
                    Text("ODYSSEY")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(.tdTextPrimary)
                }

                Text("100 Waves. Defend Every World.")
                    .font(.subheadline)
                    .foregroundColor(.tdTextSecondary)

                // Map selection
                VStack(spacing: 10) {
                    Text("CHOOSE YOUR BATTLEFIELD")
                        .font(.caption.bold())
                        .foregroundColor(.tdTextSecondary)
                        .tracking(1.5)

                    ForEach(MapType.allCases) { map in
                        Button {
                            gameState.selectedMap = map
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: map.icon)
                                    .font(.title3)
                                    .foregroundColor(gameState.selectedMap == map ? .tdAccentAmber : .tdTextSecondary)
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(map.displayName)
                                        .font(.subheadline.bold())
                                        .foregroundColor(gameState.selectedMap == map ? .tdTextPrimary : .tdTextSecondary)
                                    Text(map.description)
                                        .font(.caption2)
                                        .foregroundColor(.tdTextSecondary)
                                    if GameState.waveHighScore(for: map) > 0 {
                                        Text("Best: Wave \(GameState.waveHighScore(for: map))")
                                            .font(.caption2.bold())
                                            .foregroundColor(.tdAccentAmber)
                                    }
                                }

                                Spacer()

                                if gameState.selectedMap == map {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.tdAccentAmber)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(gameState.selectedMap == map ? Color.tdElevated : Color.tdSurface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(gameState.selectedMap == map ? Color.tdAccentAmber.opacity(0.5) : Color.clear, lineWidth: 1.5)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 30)

                Spacer()

                // Decorative sword spacer
                HStack(spacing: 8) {
                    Rectangle().frame(height: 1).foregroundColor(.tdTextSecondary.opacity(0.4))
                    Image(systemName: "chevron.left")
                        .font(.caption2)
                        .foregroundColor(.tdTextSecondary)
                    Image(systemName: "shield.fill")
                        .font(.caption)
                        .foregroundColor(.tdAccentAmber)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.tdTextSecondary)
                    Rectangle().frame(height: 1).foregroundColor(.tdTextSecondary.opacity(0.4))
                }
                .padding(.horizontal, 40)

                Button {
                    let map = gameState.selectedMap
                    gameState.reset()
                    gameState.selectedMap = map
                    appState.phase = .playing
                } label: {
                    Text("DEFEND")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.tdAccentBlue)
                        .cornerRadius(14)
                        .padding(.horizontal, 40)
                }

                Spacer().frame(height: 40)
            }
        }
    }
}
