import Foundation

struct TowerUpgrade {
    let name: String
    let description: String
    let cost: Int
    /// Multiplier applied to base damage (stacks with previous tiers)
    let damageMult: CGFloat
    /// Multiplier applied to fire rate interval (lower = faster)
    let fireRateMult: CGFloat
    /// Multiplier applied to range
    let rangeMult: CGFloat
    /// Extra value for type-specific bonuses (e.g. splash radius, slow)
    let specialBonus: CGFloat
}

enum TowerUpgrades {
    static func tiers(for type: TowerType) -> [TowerUpgrade] {
        switch type {
        case .archer:
            return [
                TowerUpgrade(name: "Keen Eyes",        description: "+20% Range, +15% DMG",  cost: 80,  damageMult: 1.15, fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 0),
                TowerUpgrade(name: "Barbed Arrows",    description: "+30% DMG, +15% Rate",   cost: 150, damageMult: 1.3,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Elven Precision",  description: "+40% DMG, +15% Range",  cost: 280, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        case .catapult:
            return [
                TowerUpgrade(name: "Heavier Stones",   description: "+25% DMG, +10% Splash", cost: 120, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.0,  specialBonus: 1.1),
                TowerUpgrade(name: "Burning Pitch",    description: "+30% DMG, +15% Rate",   cost: 220, damageMult: 1.3,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 1.0),
                TowerUpgrade(name: "Trebuchet",        description: "+40% DMG, +20% Range",  cost: 380, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 1.15),
            ]
        case .wizard:
            return [
                TowerUpgrade(name: "Arcane Focus",     description: "+25% DMG, +10% Range",  cost: 110, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0),
                TowerUpgrade(name: "Elemental Mastery", description: "+30% DMG, +20% Rate",  cost: 200, damageMult: 1.3,  fireRateMult: 0.8,  rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Archmage",         description: "+45% DMG, +15% Range",  cost: 350, damageMult: 1.45, fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        case .blacksmith:
            return [
                TowerUpgrade(name: "Tempered Steel",   description: "+10% Aura Range, +5% DMG Boost",  cost: 100, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.10, specialBonus: 0.05),
                TowerUpgrade(name: "Master Forge",     description: "+10% DMG Boost",                  cost: 190, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.0,  specialBonus: 0.10),
                TowerUpgrade(name: "Legendary Anvil",  description: "+15% Aura Range, +10% DMG Boost", cost: 320, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.15, specialBonus: 0.10),
            ]
        case .alchemist:
            return [
                TowerUpgrade(name: "Potent Brew",      description: "+25% DMG, +15% Splash", cost: 100, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.0,  specialBonus: 1.15),
                TowerUpgrade(name: "Acid Flask",       description: "+20% DMG, +15% Rate",   cost: 180, damageMult: 1.2,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 1.0),
                TowerUpgrade(name: "Plague Vials",     description: "+35% DMG, +20% Range",  cost: 310, damageMult: 1.35, fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 1.1),
            ]
        case .bellTower:
            return [
                TowerUpgrade(name: "Wider Bell",       description: "+15% Aura Range",       cost: 130, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0.05),
                TowerUpgrade(name: "War Drums",        description: "+10% DMG Boost",        cost: 240, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0.10),
                TowerUpgrade(name: "Grand Carillon",   description: "+15% Aura, +10% Boost", cost: 390, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0.10),
            ]
        case .ballista:
            return [
                TowerUpgrade(name: "Steel Bolts",      description: "+20% DMG, +10% Range",  cost: 140, damageMult: 1.2,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0),
                TowerUpgrade(name: "Repeating Mech",   description: "+25% Rate, +15% DMG",   cost: 250, damageMult: 1.15, fireRateMult: 0.75, rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Siege Ballista",   description: "+40% DMG, +15% Range",  cost: 400, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        case .moat:
            return [
                TowerUpgrade(name: "Deeper Trenches",  description: "+20% Slow, +10% Range", cost: 75,  damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0.10),
                TowerUpgrade(name: "Tar Pits",         description: "+15% Rate, +10% Slow",  cost: 140, damageMult: 1.2,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 0.08),
                TowerUpgrade(name: "Boiling Oil",      description: "+25% Range, +15% Slow", cost: 250, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.25, specialBonus: 0.12),
            ]
        }
    }
}
