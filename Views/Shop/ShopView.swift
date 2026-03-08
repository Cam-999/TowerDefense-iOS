import SwiftUI

struct ShopView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var shopState: ShopState
    @EnvironmentObject var appState: AppState

    let onContinue: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tdBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Gems display
                    HStack {
                        Image(systemName: "diamond.fill")
                            .foregroundColor(.cyan)
                        Text("\(gameState.gems) crystals")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Text("Siege \(gameState.wave) Survived")
                            .font(.subheadline)
                            .foregroundColor(Color(white: 0.65))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.tdSurface)

                    // Category tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(UpgradeCategory.allCases) { cat in
                                categoryTab(cat)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .background(Color.tdSurface)

                    // Upgrade grid — one card per chain, showing current tier
                    let chains = UpgradeCatalog.chains(for: shopState.selectedCategory)
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(chains) { chain in
                                ShopChainCard(chain: chain)
                                    .environmentObject(gameState)
                                    .environmentObject(shopState)
                            }
                        }
                        .padding(16)
                    }

                    // Continue button
                    Button {
                        gameState.shopIsOpen = false
                        onContinue()
                    } label: {
                        Text("RETURN TO BATTLE")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.tdAccentBlue)
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationTitle("The Blacksmith")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.tdSurface, for: .navigationBar)
        }
    }

    private func categoryTab(_ category: UpgradeCategory) -> some View {
        let isSelected = shopState.selectedCategory == category
        return Button {
            shopState.selectedCategory = category
        } label: {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .white : .tdTextSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.tdAccentBlue : Color(white: 0.15))
            .cornerRadius(8)
        }
    }
}
