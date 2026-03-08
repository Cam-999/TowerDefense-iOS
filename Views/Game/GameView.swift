import SwiftUI
import SpriteKit
import Combine

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var shopState: ShopState

    @State private var sceneHolder: SceneHolder?

    var body: some View {
        VStack(spacing: 0) {
            // Game map with HUD overlay
            ZStack(alignment: .top) {
                if let holder = sceneHolder {
                    SpriteView(scene: holder.scene)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                HUDView()
            }
            .clipped()
            .ignoresSafeArea(edges: .horizontal)

            // Bottom bar — fixed height action row + palette
            VStack(spacing: 0) {
                ZStack {
                    Color.tdSurface.opacity(0.95).ignoresSafeArea(edges: .horizontal)

                    if let tower = gameState.selectedPlacedTower {
                        TowerInfoBar(tower: tower, sceneHolder: sceneHolder)
                            .environmentObject(gameState)
                    } else if !gameState.waveInProgress && !gameState.shopIsOpen {
                        HStack(spacing: 12) {
                            Button {
                                let nextWave = gameState.wave + 1
                                guard nextWave <= 100 else { return }
                                sceneHolder?.scene.startWave(nextWave)
                            } label: {
                                Text(gameState.wave == 0 ? "BEGIN SIEGE" : "SUMMON WAVE \(gameState.wave + 1)")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(Color.tdAccentBlue)
                                    .cornerRadius(8)
                            }

                            Button {
                                gameState.autoPlay.toggle()
                            } label: {
                                Image(systemName: gameState.autoPlay ? "forward.fill" : "forward")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(gameState.autoPlay ? .tdAccentAmber : .tdTextSecondary)
                                    .frame(width: 44, height: 44)
                                    .background(gameState.autoPlay ? Color.tdAccentAmber.opacity(0.2) : Color.tdElevated)
                                    .cornerRadius(8)
                            }
                        }
                    } else if gameState.waveInProgress {
                        Button {
                            gameState.autoPlay.toggle()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: gameState.autoPlay ? "forward.fill" : "forward")
                                    .font(.system(size: 13, weight: .bold))
                                Text(gameState.autoPlay ? "AUTO ON" : "AUTO OFF")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(gameState.autoPlay ? .tdAccentAmber : .tdTextSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(gameState.autoPlay ? Color.tdAccentAmber.opacity(0.2) : Color.tdElevated)
                            .cornerRadius(8)
                        }
                        .frame(minHeight: 44)
                    }
                }
                .frame(height: 44)

                TowerPaletteView()
            }
        }
        .overlay {
            if appState.isPaused {
                PauseOverlay()
                    .environmentObject(appState)
                    .environmentObject(gameState)
            }
        }
        .background(Color.tdSurface.opacity(0.95).ignoresSafeArea())
        .sheet(isPresented: $gameState.shopIsOpen) {
            ShopView { }
                .environmentObject(gameState)
                .environmentObject(shopState)
                .environmentObject(appState)
        }
        .onAppear {
            if sceneHolder == nil {
                sceneHolder = SceneHolder(gameState: gameState, appState: appState)
            }
        }
    }
}

// MARK: - Tower info bar (shown when a placed tower is selected)

private struct TowerInfoBar: View {
    let tower: TowerNode
    let sceneHolder: SceneHolder?
    @EnvironmentObject var gameState: GameState

    var body: some View {
        HStack(spacing: 8) {
            // Tower name + level
            VStack(alignment: .leading, spacing: 1) {
                Text(tower.towerType.displayName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.tdTextPrimary)
                Text("Lv \(tower.upgradeLevel + 1)/\(tower.maxUpgradeLevel + 1)")
                    .font(.system(size: 9))
                    .foregroundColor(.tdTextSecondary)
            }
            .frame(width: 60, alignment: .leading)

            // Upgrade button (replaces itself per tier)
            if let upgrade = tower.nextUpgrade {
                Button {
                    sceneHolder?.scene.upgradeSelectedTower()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 12))
                        VStack(alignment: .leading, spacing: 0) {
                            Text(upgrade.name)
                                .font(.system(size: 10, weight: .bold))
                            Text(upgrade.description)
                                .font(.system(size: 8))
                        }
                        Text("\(upgrade.cost)g")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.tdAccentAmber)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(minHeight: 44)
                    .background(gameState.gold >= upgrade.cost ? Color.tdAccentBlue : Color.tdElevated)
                    .cornerRadius(8)
                }
                .disabled(gameState.gold < upgrade.cost)
                .opacity(gameState.gold >= upgrade.cost ? 1.0 : 0.5)
            } else {
                Text("MAX")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.tdAccentAmber)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.tdElevated)
                    .cornerRadius(6)
            }

            Spacer()

            // Sell button
            Button {
                sceneHolder?.scene.sellSelectedTower()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 11))
                    Text("\(gameState.sellRefund(for: tower))g")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(minHeight: 44)
                .background(Color.tdDanger)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 10)
    }
}

// MARK: - Pause Overlay

private struct PauseOverlay: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.tdAccentAmber)

                Text("BATTLE PAUSED")
                    .font(.title.bold())
                    .foregroundColor(.tdTextPrimary)

                Button {
                    appState.isPaused = false
                    SoundSystem.shared.resumeEngine()
                } label: {
                    Text("RESUME")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(Color.tdAccentBlue)
                        .cornerRadius(12)
                }
                .frame(minHeight: 44)

                Button {
                    appState.isPaused = false
                    SoundSystem.shared.resumeEngine()
                    gameState.reset()
                    appState.phase = .menu
                } label: {
                    Text("RESTART")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(Color.tdDanger)
                        .cornerRadius(12)
                }
                .frame(minHeight: 44)
            }
        }
    }
}

final class SceneHolder: ObservableObject {
    let scene: GameScene

    init(gameState: GameState, appState: AppState) {
        let s = GameScene(gameState: gameState, appState: appState)
        s.scaleMode = .resizeFill
        self.scene  = s
    }
}
