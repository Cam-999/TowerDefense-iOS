import SwiftUI

struct ShopChainCard: View {
    let chain: UpgradeChain
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var shopState: ShopState

    var body: some View {
        let current = chain.currentTier(gameState: gameState)
        let owned = chain.ownedCount(gameState: gameState)
        let maxed = chain.isMaxed(gameState: gameState)
        let totalTiers = chain.tiers.count
        // Use current tier or last tier for display
        let display = current ?? chain.tiers.last!

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: display.icon)
                    .font(.title2)
                    .foregroundColor(.tdAccentBlue)
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text(display.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    if totalTiers > 1 {
                        Text("Tier \(owned + (maxed ? 0 : 1))/\(totalTiers)")
                            .font(.caption2)
                            .foregroundColor(Color(white: 0.65))
                    }
                }
                Spacer()
                if maxed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            Text(display.description)
                .font(.caption)
                .foregroundColor(Color(white: 0.65))
                .lineLimit(2)

            // Prerequisite warning
            if let current, let req = current.requires,
               !gameState.hasUpgrade(req),
               !chain.tiers.contains(where: { $0.id == req }) {
                Text("Requires: \(req)")
                    .font(.caption2)
                    .foregroundColor(.tdDanger)
            }

            HStack {
                Spacer()
                if maxed {
                    Text("MAX")
                        .font(.caption.bold())
                        .foregroundColor(.tdAccentAmber)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color(white: 0.25))
                        .cornerRadius(8)
                } else if let current {
                    let canBuy = shopState.canPurchase(current, gameState: gameState)
                    Button {
                        shopState.purchase(current, gameState: gameState)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "diamond.fill")
                                .font(.caption)
                                .foregroundColor(.cyan)
                            Text("\(current.cost)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(canBuy ? Color.tdAccentBlue : Color.tdTextSecondary.opacity(0.3))
                        .cornerRadius(8)
                    }
                    .disabled(!canBuy)
                }
            }
        }
        .padding(12)
        .background(Color(white: 0.15))
        .cornerRadius(12)
        .opacity(maxed || (current != nil && shopState.canPurchase(current!, gameState: gameState)) ? 1.0 : 0.55)
    }
}
