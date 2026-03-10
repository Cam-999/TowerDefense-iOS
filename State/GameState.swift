import Foundation
import Combine
import SpriteKit

@MainActor
final class GameState: ObservableObject {
    @Published var wave: Int = 0
    @Published var gold: Int = 100
    @Published var gems: Int = 0
    @Published var lives: Int = 20
    @Published var score: Int = 0
    @Published var selectedTowerType: TowerType? = .archer
    @Published var selectedPlacedTower: TowerNode? = nil
    @Published var ownedUpgrades: Set<UpgradeID> = [] {
        didSet { rebuildUpgradeCache() }
    }
    @Published var shopIsOpen: Bool = false
    @Published var waveInProgress: Bool = false
    @Published var shieldsRemaining: Int = 0
    @Published var autoPlay: Bool = false
    @Published var speedMultiplier: Double = 1.0
    @Published var selectedMap: MapType = .forest

    // MARK: - Cached upgrade effects (rebuilt when ownedUpgrades changes)

    private(set) var globalDamageMultiplier: Double = 1.0
    private(set) var globalFireRateMultiplier: Double = 1.0
    private(set) var globalRangeMultiplier: Double = 1.0
    private(set) var goldBonusMultiplier: Double = 1.0
    private(set) var towerCostDiscount: Double = 1.0
    private(set) var interestRate: Double = 0.0
    private(set) var critChance: Double = 0.0
    private(set) var critMultiplier: Double = 2.0
    private(set) var splashMultiplier: Double = 1.0
    private(set) var cryoFactor: Double = 0.5
    private(set) var cryoDuration: Double = 2.0
    private(set) var shieldMax: Int = 0

    // Lives-dependent damage multiplier must still be computed dynamically
    var effectiveDamageMultiplier: Double {
        var mult = globalDamageMultiplier
        if hasUpgrade("v6") && lives <= 3 { mult *= 2.0 }
        return mult
    }

    private static let upgradeLookup: [UpgradeID: UpgradeDefinition] = {
        var dict: [UpgradeID: UpgradeDefinition] = [:]
        for u in UpgradeCatalog.all { dict[u.id] = u }
        return dict
    }()

    private func rebuildUpgradeCache() {
        var dmg = 1.0, fire = 1.0, range = 1.0, gold = 1.0
        var discount = 1.0, interest = 0.0
        var critC = 0.0, critM = 2.0, splash = 1.0
        var cryoF = 0.5, cryoD = 2.0
        var shields = 0

        for id in ownedUpgrades {
            guard let def = Self.upgradeLookup[id] else { continue }
            switch def.effect {
            case .globalDamageBoost(let m): dmg *= m
            case .fireRateBoost(let m):     fire *= m
            case .rangeBoost(let m):        range *= m
            case .goldBonus(let m):         gold *= m
            case .towerDiscount(let f):     discount = min(discount, f)
            case .interest(let r):          interest = max(interest, r)
            case .critHit(let c, let m):    critC = max(critC, c); critM = max(critM, m)
            case .splashBoost(let m):       splash = max(splash, m)
            case .moatMastery(let f, let d): cryoF = min(cryoF, f); cryoD = max(cryoD, d)
            case .shield(let c):            shields = max(shields, c)
            default: break
            }
        }

        if hasUpgrade("d8") { dmg *= 1.20; fire *= 0.90 }

        globalDamageMultiplier = dmg
        globalFireRateMultiplier = fire
        globalRangeMultiplier = range
        goldBonusMultiplier = gold
        towerCostDiscount = discount
        interestRate = interest
        critChance = critC
        critMultiplier = critM
        splashMultiplier = splash
        cryoFactor = cryoF
        cryoDuration = cryoD
        shieldMax = shields
    }

    // MARK: - Helpers

    func hasUpgrade(_ id: UpgradeID) -> Bool { ownedUpgrades.contains(id) }

    func effectiveCost(for type: TowerType) -> Int {
        Int(Double(type.cost) * towerCostDiscount)
    }

    func canAfford(_ type: TowerType) -> Bool {
        gold >= effectiveCost(for: type)
    }

    func purchase(tower type: TowerType) -> Bool {
        let cost = effectiveCost(for: type)
        guard gold >= cost else { return false }
        gold -= cost
        return true
    }

    func earnGold(_ base: Int) {
        let earned = Int(Double(base) * goldBonusMultiplier)
        gold += earned
        score += earned
    }

    func earnGems(_ count: Int) {
        gems += count
    }

    func loseLife() {
        lives = max(0, lives - 1)
    }

    /// Returns 60% of total invested (purchase + upgrades)
    func sellRefund(for tower: TowerNode) -> Int {
        Int(Double(tower.totalInvested) * 0.6)
    }

    func applyInterest() {
        guard interestRate > 0 else { return }
        gold += Int(Double(gold) * interestRate)
    }

    // MARK: - Wave High Score Persistence

    static func waveHighScore(for map: MapType) -> Int {
        UserDefaults.standard.integer(forKey: "waveHighScore_\(map.rawValue)")
    }

    static func saveWaveHighScore(_ wave: Int, for map: MapType) {
        let current = waveHighScore(for: map)
        if wave > current {
            UserDefaults.standard.set(wave, forKey: "waveHighScore_\(map.rawValue)")
        }
    }

    func resetShields() {
        shieldsRemaining = shieldMax
    }

    func reset() {
        wave = 0
        gold = 100
        gems = 0
        lives = 20
        score = 0
        selectedTowerType = .archer
        selectedPlacedTower = nil
        ownedUpgrades = []
        shopIsOpen = false
        waveInProgress = false
        shieldsRemaining = 0
        autoPlay = false
        speedMultiplier = 1.0
    }
}
