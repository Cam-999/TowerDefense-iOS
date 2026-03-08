import Foundation

typealias UpgradeID = String

enum UpgradeCategory: String, CaseIterable, Identifiable {
    case weaponry      = "Weaponry"
    case swiftness     = "Swiftness"
    case watchfulness  = "Watchfulness"
    case treasury      = "Treasury"
    case fortification = "Fortification"
    case arcane        = "Arcane"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .weaponry:      "hammer.fill"
        case .swiftness:     "hare.fill"
        case .watchfulness:  "eye.fill"
        case .treasury:      "banknote.fill"
        case .fortification: "building.2.fill"
        case .arcane:        "sparkles"
        }
    }
}

enum UpgradeEffect {
    case globalDamageBoost(multiplier: Double)
    case armorPierce
    case overcharge                                         // +20% dmg, -10% rate
    case fireRateBoost(multiplier: Double)
    case enchantedArrows                                    // Archer 2x fire rate
    case arcaneHaste                                        // Wizard 1.5x fire rate
    case rangeBoost(multiplier: Double)
    case goldBonus(multiplier: Double)
    case interest(rate: Double)
    case towerDiscount(factor: Double)                      // resulting cost fraction
    case extraLives(count: Int)
    case shield(count: Int)                                 // blocks per wave
    case lastStand
    case moatMastery(factor: Double, duration: Double)      // slow speed factor, seconds
    case splashBoost(multiplier: Double)
    case critHit(chance: Double, multiplier: Double)
    case eagleSentinel                                      // all towers target flying
}

struct UpgradeDefinition: Identifiable {
    let id: UpgradeID
    let name: String
    let description: String
    let category: UpgradeCategory
    let cost: Int
    let effect: UpgradeEffect
    let icon: String
    var requires: UpgradeID? = nil
}

struct UpgradeChain: Identifiable {
    let id: UpgradeID          // root upgrade id
    let tiers: [UpgradeDefinition]

    /// Returns the next tier to buy, or nil if all owned.
    func currentTier(gameState: GameState) -> UpgradeDefinition? {
        tiers.first { !gameState.hasUpgrade($0.id) }
    }

    /// Number of tiers already purchased.
    func ownedCount(gameState: GameState) -> Int {
        tiers.filter { gameState.hasUpgrade($0.id) }.count
    }

    /// Whether every tier is purchased.
    func isMaxed(gameState: GameState) -> Bool {
        tiers.allSatisfy { gameState.hasUpgrade($0.id) }
    }
}

enum UpgradeCatalog {
    static let all: [UpgradeDefinition] = weaponry + swiftness + watchfulness + treasury + fortification + arcane

    /// Groups upgrades in a category into linear chains.
    static func chains(for category: UpgradeCategory) -> [UpgradeChain] {
        let upgrades = all.filter { $0.category == category }
        var used: Set<UpgradeID> = []
        var result: [UpgradeChain] = []

        // Roots: no requires, or requires something outside this category
        let roots = upgrades.filter { def in
            def.requires == nil || !upgrades.contains(where: { $0.id == def.requires })
        }

        for root in roots {
            var chain = [root]
            used.insert(root.id)
            var current = root
            while let next = upgrades.first(where: { $0.requires == current.id && !used.contains($0.id) }) {
                chain.append(next)
                used.insert(next.id)
                current = next
            }
            result.append(UpgradeChain(id: root.id, tiers: chain))
        }

        // Remaining branch upgrades
        for def in upgrades where !used.contains(def.id) {
            var chain = [def]
            used.insert(def.id)
            var current = def
            while let next = upgrades.first(where: { $0.requires == current.id && !used.contains($0.id) }) {
                chain.append(next)
                used.insert(next.id)
                current = next
            }
            result.append(UpgradeChain(id: def.id, tiers: chain))
        }

        return result
    }

    // MARK: Weaponry (8)
    static let weaponry: [UpgradeDefinition] = [
        .init(id: "d1", name: "Sharpened Blades I",   description: "+8% global damage",        category: .weaponry, cost: 4,   effect: .globalDamageBoost(multiplier: 1.08), icon: "hammer.fill"),
        .init(id: "d2", name: "Sharpened Blades II",  description: "+12% global damage",       category: .weaponry, cost: 7,   effect: .globalDamageBoost(multiplier: 1.12), icon: "hammer.fill",              requires: "d1"),
        .init(id: "d3", name: "Forged Steel III",     description: "+18% global damage",       category: .weaponry, cost: 12,  effect: .globalDamageBoost(multiplier: 1.18), icon: "wrench.fill",             requires: "d2"),
        .init(id: "d4", name: "Dragonforged IV",      description: "+25% global damage",       category: .weaponry, cost: 20,  effect: .globalDamageBoost(multiplier: 1.25), icon: "wrench.and.screwdriver.fill", requires: "d3"),
        .init(id: "d5", name: "Armor Sundering",      description: "All towers ignore armor",  category: .weaponry, cost: 14,  effect: .armorPierce,                         icon: "shield.slash.fill",       requires: "d2"),
        .init(id: "d6", name: "Lucky Strike I",       description: "8% chance x 2x damage",   category: .weaponry, cost: 9,   effect: .critHit(chance: 0.08, multiplier: 2.0), icon: "dice.fill"),
        .init(id: "d7", name: "Lucky Strike II",      description: "15% chance x 3x damage",  category: .weaponry, cost: 15,  effect: .critHit(chance: 0.15, multiplier: 3.0), icon: "dice.fill",             requires: "d6"),
        .init(id: "d8", name: "Battle Fury",          description: "+20% dmg, -10% rate",     category: .weaponry, cost: 8,   effect: .overcharge,                          icon: "bolt.circle.fill"),
    ]

    // MARK: Swiftness (6)
    static let swiftness: [UpgradeDefinition] = [
        .init(id: "r1", name: "Swift Hands I",        description: "+10% fire rate",           category: .swiftness, cost: 5,   effect: .fireRateBoost(multiplier: 1.10), icon: "hare.fill"),
        .init(id: "r2", name: "Swift Hands II",       description: "+15% fire rate",           category: .swiftness, cost: 8,   effect: .fireRateBoost(multiplier: 1.15), icon: "hare.fill",   requires: "r1"),
        .init(id: "r3", name: "Battle Tempo III",     description: "+20% fire rate",           category: .swiftness, cost: 13,  effect: .fireRateBoost(multiplier: 1.20), icon: "hare.fill",   requires: "r2"),
        .init(id: "r4", name: "Warcry IV",            description: "+28% fire rate",           category: .swiftness, cost: 20,  effect: .fireRateBoost(multiplier: 1.28), icon: "hare.fill",   requires: "r3"),
        .init(id: "r5", name: "Enchanted Arrows",     description: "Archer fires 2x faster",   category: .swiftness, cost: 10,  effect: .enchantedArrows,                icon: "arrow.up.right"),
        .init(id: "r6", name: "Arcane Haste",         description: "Wizard fires 1.5x faster", category: .swiftness, cost: 11,  effect: .arcaneHaste,                    icon: "wand.and.stars"),
    ]

    // MARK: Watchfulness (4)
    static let watchfulness: [UpgradeDefinition] = [
        .init(id: "g1", name: "Keen Sight I",         description: "+6% range",   category: .watchfulness, cost: 5,   effect: .rangeBoost(multiplier: 1.06), icon: "eye.fill"),
        .init(id: "g2", name: "Keen Sight II",        description: "+8% range",   category: .watchfulness, cost: 8,   effect: .rangeBoost(multiplier: 1.08), icon: "eye.fill",   requires: "g1"),
        .init(id: "g3", name: "Watchtower III",       description: "+10% range",  category: .watchfulness, cost: 13,  effect: .rangeBoost(multiplier: 1.10), icon: "eye.fill",   requires: "g2"),
        .init(id: "g4", name: "Eagle Vision IV",      description: "+12% range",  category: .watchfulness, cost: 20,  effect: .rangeBoost(multiplier: 1.12), icon: "eye.fill",   requires: "g3"),
    ]

    // MARK: Treasury (7)
    static let treasury: [UpgradeDefinition] = [
        .init(id: "e1", name: "Plunder I",            description: "+12% gold from kills",    category: .treasury, cost: 5,   effect: .goldBonus(multiplier: 1.12), icon: "banknote.fill"),
        .init(id: "e2", name: "Plunder II",           description: "+18% gold from kills",    category: .treasury, cost: 9,   effect: .goldBonus(multiplier: 1.18), icon: "banknote.fill",    requires: "e1"),
        .init(id: "e3", name: "King's Bounty III",    description: "+25% gold from kills",    category: .treasury, cost: 15,  effect: .goldBonus(multiplier: 1.25), icon: "banknote.fill",    requires: "e2"),
        .init(id: "e4", name: "Tax Collector I",      description: "+4% gold each wave",      category: .treasury, cost: 10,  effect: .interest(rate: 0.04),        icon: "chart.line.uptrend.xyaxis"),
        .init(id: "e5", name: "Tax Collector II",     description: "+8% gold each wave",      category: .treasury, cost: 16,  effect: .interest(rate: 0.08),        icon: "chart.line.uptrend.xyaxis", requires: "e4"),
        .init(id: "e6", name: "Haggle",               description: "Towers 12% cheaper",      category: .treasury, cost: 7,   effect: .towerDiscount(factor: 0.88), icon: "tag.fill"),
        .init(id: "e7", name: "Royal Decree",         description: "Towers 22% cheaper",      category: .treasury, cost: 12,  effect: .towerDiscount(factor: 0.78), icon: "tag.fill",                  requires: "e6"),
    ]

    // MARK: Fortification (6)
    static let fortification: [UpgradeDefinition] = [
        .init(id: "v1", name: "Stone Walls I",        description: "+2 lives",               category: .fortification, cost: 7,   effect: .extraLives(count: 2), icon: "heart.fill"),
        .init(id: "v2", name: "Stone Walls II",       description: "+3 lives",               category: .fortification, cost: 11,  effect: .extraLives(count: 3), icon: "heart.fill",        requires: "v1"),
        .init(id: "v3", name: "Castle Keep III",      description: "+5 lives",               category: .fortification, cost: 18,  effect: .extraLives(count: 5), icon: "building.2.fill",   requires: "v2"),
        .init(id: "v4", name: "Gate Guard I",         description: "Block 1 enemy/wave",     category: .fortification, cost: 13,  effect: .shield(count: 1),     icon: "shield.fill"),
        .init(id: "v5", name: "Gate Guard II",        description: "Block 2 enemies/wave",   category: .fortification, cost: 20,  effect: .shield(count: 2),     icon: "shield.fill",       requires: "v4"),
        .init(id: "v6", name: "Last Stand",           description: "2x dmg when 3 or fewer lives", category: .fortification, cost: 20,  effect: .lastStand,       icon: "bolt.shield.fill"),
    ]

    // MARK: Arcane (7)
    static let arcane: [UpgradeDefinition] = [
        .init(id: "s1", name: "Moat Mastery I",       description: "Moat slows 65% for 2.5s",  category: .arcane, cost: 10,  effect: .moatMastery(factor: 0.35, duration: 2.5), icon: "drop.fill"),
        .init(id: "s2", name: "Moat Mastery II",      description: "Moat slows 80% for 3.5s",  category: .arcane, cost: 16,  effect: .moatMastery(factor: 0.20, duration: 3.5), icon: "drop.fill",          requires: "s1"),
        .init(id: "s5", name: "Greek Fire I",         description: "+30% AoE radius",          category: .arcane, cost: 10,  effect: .splashBoost(multiplier: 1.3),             icon: "burst.fill"),
        .init(id: "s6", name: "Greek Fire II",        description: "+60% AoE radius",          category: .arcane, cost: 16,  effect: .splashBoost(multiplier: 1.6),             icon: "burst.fill",         requires: "s5"),
        .init(id: "s7", name: "Eagle Sentinel",       description: "All towers target flying", category: .arcane, cost: 18,  effect: .eagleSentinel,                            icon: "bird.fill"),
    ]
}
