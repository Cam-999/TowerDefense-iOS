import SwiftUI

struct TowerPaletteView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(TowerType.allCases) { type in
                    TowerCell(type: type, isSelected: gameState.selectedTowerType == type)
                        .onTapGesture {
                            gameState.selectedTowerType = type
                            gameState.selectedPlacedTower = nil
                            HapticManager.towerSelected()
                        }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .frame(maxWidth: .infinity)
        .background(Color.tdSurface.opacity(0.95).ignoresSafeArea(edges: .horizontal))
    }
}

private struct TowerCell: View {
    let type: TowerType
    let isSelected: Bool
    @EnvironmentObject var gameState: GameState

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: type.icon)
                .font(.system(size: 14))
                .foregroundColor(type.iconColor)

            VStack(alignment: .leading, spacing: 1) {
                Text(type.displayName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.tdTextPrimary)
                Text(type.subtitle)
                    .font(.system(size: 8))
                    .foregroundColor(type.isSupport ? type.iconColor : .tdTextSecondary)
            }

            Text("\(gameState.effectiveCost(for: type))g")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(gameState.canAfford(type) ? .tdAccentAmber : .tdDanger)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(minHeight: 44)
        .background(
            isSelected
                ? Color.tdAccentBlue.opacity(0.3)
                : type.isSupport
                    ? type.iconColor.opacity(0.08)
                    : Color.tdElevated
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.tdAccentBlue : Color.clear, lineWidth: 1.5)
        )
        .opacity(gameState.canAfford(type) ? 1.0 : 0.5)
    }
}
