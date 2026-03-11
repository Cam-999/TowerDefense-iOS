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
                    SpriteView(scene: holder.scene,
                              options: [.shouldCullNonVisibleNodes],
                              debugOptions: [.showsFPS, .showsNodeCount])
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

                            Button {
                                gameState.speedMultiplier = gameState.speedMultiplier == 1.0 ? 2.0 : 1.0
                            } label: {
                                Text(gameState.speedMultiplier == 2.0 ? "2X" : "1X")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(gameState.speedMultiplier == 2.0 ? .tdAccentAmber : .tdTextSecondary)
                                    .frame(width: 44, height: 44)
                                    .background(gameState.speedMultiplier == 2.0 ? Color.tdAccentAmber.opacity(0.2) : Color.tdElevated)
                                    .cornerRadius(8)
                            }
                        }
                    } else if gameState.waveInProgress {
                        HStack(spacing: 8) {
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

                            Button {
                                gameState.speedMultiplier = gameState.speedMultiplier == 1.0 ? 2.0 : 1.0
                            } label: {
                                Text(gameState.speedMultiplier == 2.0 ? "2X" : "1X")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(gameState.speedMultiplier == 2.0 ? .tdAccentAmber : .tdTextSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(gameState.speedMultiplier == 2.0 ? Color.tdAccentAmber.opacity(0.2) : Color.tdElevated)
                                    .cornerRadius(8)
                            }
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
        .overlay {
            if let enemy = gameState.selectedEnemy {
                EnemyStatsOverlay(info: enemy) {
                    gameState.selectedEnemy = nil
                }
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
            // Clean up old scene before creating a fresh one (handles new game after game over)
            sceneHolder?.scene.cleanup()
            sceneHolder = nil
            sceneHolder = SceneHolder(gameState: gameState, appState: appState)
        }
        .onDisappear {
            sceneHolder?.scene.cleanup()
            sceneHolder = nil
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("Lv \(tower.upgradeLevel + 1)/\(tower.maxUpgradeLevel + 1)")
                    .font(.system(size: 9))
                    .foregroundColor(.tdTextSecondary)
            }
            .frame(width: 70, alignment: .leading)

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
                            .foregroundColor(.tdGold)
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

// MARK: - Enemy Stats Overlay

private struct EnemyStatsOverlay: View {
    let info: EnemyStatsInfo
    let onDismiss: () -> Void

    private var hpFraction: Double {
        info.maxHP > 0 ? Double(info.currentHP / info.maxHP) : 0
    }

    private var hpColor: Color {
        hpFraction > 0.5 ? .green : hpFraction > 0.25 ? .yellow : .red
    }

    private var armorPercent: Int {
        Int((1.0 - info.type.damageReduction) * 100)
    }

    private var speedLabel: String {
        let s = info.moveSpeed
        if s >= 150 { return "Very Fast" }
        if s >= 100 { return "Fast" }
        if s >= 60  { return "Normal" }
        if s >= 35  { return "Slow" }
        return "Very Slow"
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                // Header
                HStack {
                    enemyPortrait(for: info.type)
                        .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(info.type.displayName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.tdTextPrimary)
                            if info.type.isBoss {
                                Text("BOSS")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.tdDanger)
                                    .cornerRadius(4)
                            }
                        }
                        Text(info.type.lore)
                            .font(.system(size: 11))
                            .foregroundColor(.tdTextSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.tdTextSecondary)
                    }
                }
                .padding(16)

                Divider().background(Color.tdTextSecondary.opacity(0.3))

                // HP Bar
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(hpColor)
                            .font(.system(size: 12))
                        Text("HP")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.tdTextPrimary)
                        Spacer()
                        Text("\(Int(info.currentHP)) / \(Int(info.maxHP))")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.tdTextPrimary)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.tdElevated)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(hpColor)
                                .frame(width: geo.size.width * max(0, hpFraction))
                        }
                    }
                    .frame(height: 10)

                    if info.remainingShield > 0 {
                        HStack {
                            Image(systemName: "shield.fill")
                                .foregroundColor(.tdAccentPurple)
                                .font(.system(size: 11))
                            Text("Shield")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.tdTextSecondary)
                            Spacer()
                            Text("\(Int(info.remainingShield))")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.tdAccentPurple)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().background(Color.tdTextSecondary.opacity(0.3))

                // Stats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    statCell(icon: "figure.walk", label: "Speed", value: speedLabel)
                    statCell(icon: "shield.lefthalf.filled", label: "Armor", value: armorPercent > 0 ? "\(armorPercent)%" : "None")
                    goldRewardCell(value: info.type.goldReward)
                    statCell(icon: "heart.slash", label: "Lives Lost", value: "\(info.type.livesOnEscape)")

                    if info.type.regenPerSecond > 0 {
                        statCell(icon: "cross.vial.fill", label: "Regen", value: "\(Int(info.type.regenPerSecond))/s")
                    }
                    if info.type.dodgeChance > 0 {
                        statCell(icon: "wind", label: "Dodge", value: "\(Int(info.type.dodgeChance * 100))%")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Traits
                let traits = buildTraits()
                if !traits.isEmpty {
                    Divider().background(Color.tdTextSecondary.opacity(0.3))

                    VStack(alignment: .leading, spacing: 6) {
                        Text("TRAITS")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.tdTextSecondary)

                        FlowLayout(spacing: 6) {
                            ForEach(traits, id: \.self) { trait in
                                Text(trait)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.tdTextPrimary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.tdElevated)
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

                // Split spawn info
                if let split = info.type.splitSpawn {
                    Divider().background(Color.tdTextSecondary.opacity(0.3))

                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.branch")
                            .foregroundColor(.tdAccentTeal)
                            .font(.system(size: 12))
                        Text("Spawns \(split.count)x \(split.type.displayName) on death")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.tdTextSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }
            .background(Color.tdSurface.opacity(0.97))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.tdTextSecondary.opacity(0.25), lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
        }
    }

    private func statCell(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.tdAccentTeal)
                .font(.system(size: 13))
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.tdTextSecondary)
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.tdTextPrimary)
            }
            Spacer()
        }
        .padding(8)
        .background(Color.tdBackground.opacity(0.5))
        .cornerRadius(8)
    }

    @ViewBuilder
    private func enemyPortrait(for type: EnemyType) -> some View {
        switch type {
        case .goblin:
            Image("GoblinPortrait")
                .resizable()
                .scaledToFill()
        case .orc:
            Image("OrcPortrait")
                .resizable()
                .scaledToFill()
        default:
            Circle()
                .fill(Color(type.color))
        }
    }

    private func goldRewardCell(value: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.fill")
                .foregroundColor(.tdGold)
                .font(.system(size: 13))
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text("Gold Reward")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.tdTextSecondary)
                Text("\(value)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.tdGold)
            }
            Spacer()
        }
        .padding(8)
        .background(Color.tdBackground.opacity(0.5))
        .cornerRadius(8)
    }

    private func buildTraits() -> [String] {
        var t: [String] = []
        if info.type.isFlying     { t.append("Flying") }
        if info.type.arrowImmune  { t.append("Arrow Immune") }
        if info.type.slowImmune   { t.append("Slow Immune") }
        if info.type.magicVulnerability > 1.0 {
            t.append("Magic Weak x\(String(format: "%.1f", info.type.magicVulnerability))")
        }
        if info.type.shieldHP > 0 { t.append("Shielded") }
        if info.type.isBoss       { t.append("Boss") }
        return t
    }
}

// MARK: - Flow Layout (for trait tags)

private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
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
