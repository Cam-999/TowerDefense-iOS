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

        // ─────────────────────────────────────────
        // MARK: Forest Map
        // ─────────────────────────────────────────

        case .archer:
            return [
                TowerUpgrade(name: "Keen Eyes",         description: "+20% Range, +15% DMG",  cost: 80,  damageMult: 1.15, fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 0),
                TowerUpgrade(name: "Barbed Arrows",     description: "+30% DMG, +15% Rate",   cost: 150, damageMult: 1.3,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Elven Precision",   description: "+40% DMG, +15% Range",  cost: 280, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        case .catapult:
            return [
                TowerUpgrade(name: "Heavier Stones",    description: "+25% DMG, +10% Splash", cost: 120, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.0,  specialBonus: 1.1),
                TowerUpgrade(name: "Burning Pitch",     description: "+30% DMG, +15% Rate",   cost: 220, damageMult: 1.3,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 1.0),
                TowerUpgrade(name: "Trebuchet",         description: "+40% DMG, +20% Range",  cost: 380, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 1.15),
            ]
        case .wizard:
            return [
                TowerUpgrade(name: "Arcane Focus",      description: "+25% DMG, +10% Range",  cost: 110, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0),
                TowerUpgrade(name: "Elemental Mastery", description: "+30% DMG, +20% Rate",   cost: 200, damageMult: 1.3,  fireRateMult: 0.8,  rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Archmage",          description: "+45% DMG, +15% Range",  cost: 350, damageMult: 1.45, fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        case .blacksmith:
            return [
                TowerUpgrade(name: "Tempered Steel",    description: "+10% Aura Range, +5% DMG Boost",  cost: 100, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.10, specialBonus: 0.05),
                TowerUpgrade(name: "Master Forge",      description: "+10% DMG Boost",                  cost: 190, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.0,  specialBonus: 0.10),
                TowerUpgrade(name: "Legendary Anvil",   description: "+15% Aura Range, +10% DMG Boost", cost: 320, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.15, specialBonus: 0.10),
            ]
        case .alchemist:
            return [
                TowerUpgrade(name: "Potent Brew",       description: "+25% DMG, +15% Splash", cost: 100, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.0,  specialBonus: 1.15),
                TowerUpgrade(name: "Acid Flask",        description: "+20% DMG, +15% Rate",   cost: 180, damageMult: 1.2,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 1.0),
                TowerUpgrade(name: "Plague Vials",      description: "+35% DMG, +20% Range",  cost: 310, damageMult: 1.35, fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 1.1),
            ]
        case .bellTower:
            return [
                TowerUpgrade(name: "Wider Bell",        description: "+15% Aura Range",       cost: 130, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0.05),
                TowerUpgrade(name: "War Drums",         description: "+10% DMG Boost",        cost: 240, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0.10),
                TowerUpgrade(name: "Grand Carillon",    description: "+15% Aura, +10% Boost", cost: 390, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0.10),
            ]
        case .ballista:
            return [
                TowerUpgrade(name: "Steel Bolts",       description: "+20% DMG, +10% Range",  cost: 140, damageMult: 1.2,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0),
                TowerUpgrade(name: "Repeating Mech",    description: "+25% Rate, +15% DMG",   cost: 250, damageMult: 1.15, fireRateMult: 0.75, rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Siege Ballista",    description: "+40% DMG, +15% Range",  cost: 400, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        case .moat:
            return [
                TowerUpgrade(name: "Deeper Trenches",   description: "+20% Slow, +10% Range", cost: 75,  damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0.10),
                TowerUpgrade(name: "Tar Pits",          description: "+15% Rate, +10% Slow",  cost: 140, damageMult: 1.2,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 0.08),
                TowerUpgrade(name: "Boiling Oil",       description: "+25% Range, +15% Slow", cost: 250, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.25, specialBonus: 0.12),
            ]

        // ─────────────────────────────────────────
        // MARK: Ocean Map
        // ─────────────────────────────────────────

        // Fast shooter — same pattern as archer
        case .harpoonGun:
            return [
                TowerUpgrade(name: "Sharpened Barbs",   description: "+20% Range, +15% DMG",  cost: 80,  damageMult: 1.15, fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 0),
                TowerUpgrade(name: "Tidal Surge",       description: "+30% DMG, +15% Rate",   cost: 150, damageMult: 1.3,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Abyssal Power",     description: "+40% DMG, +15% Range",  cost: 280, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        // AoE — same pattern as catapult
        case .depthCharge:
            return [
                TowerUpgrade(name: "Pressurized Casing",description: "+25% DMG, +10% Splash", cost: 120, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.0,  specialBonus: 1.1),
                TowerUpgrade(name: "Concussive Wave",   description: "+30% DMG, +15% Rate",   cost: 220, damageMult: 1.3,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 1.0),
                TowerUpgrade(name: "Kraken's Wrath",    description: "+40% DMG, +20% Range",  cost: 380, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 1.15),
            ]
        // Magic — same pattern as wizard
        case .coralMage:
            return [
                TowerUpgrade(name: "Tidal Focus",       description: "+25% DMG, +10% Range",  cost: 110, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0),
                TowerUpgrade(name: "Reef Channeling",   description: "+30% DMG, +20% Rate",   cost: 200, damageMult: 1.3,  fireRateMult: 0.8,  rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Deep Sea Sorcery",  description: "+45% DMG, +15% Range",  cost: 350, damageMult: 1.45, fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        // Support-Dmg — same pattern as blacksmith
        case .pearlShrine:
            return [
                TowerUpgrade(name: "Polished Pearl",    description: "+10% Aura Range, +5% DMG Boost",  cost: 100, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.10, specialBonus: 0.05),
                TowerUpgrade(name: "Ocean's Blessing",  description: "+10% DMG Boost",                  cost: 190, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.0,  specialBonus: 0.10),
                TowerUpgrade(name: "Abyssal Shrine",    description: "+15% Aura Range, +10% DMG Boost", cost: 320, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.15, specialBonus: 0.10),
            ]
        // Poison — same pattern as alchemist
        case .toxicReef:
            return [
                TowerUpgrade(name: "Toxic Spores",      description: "+25% DMG, +15% Splash", cost: 100, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.0,  specialBonus: 1.15),
                TowerUpgrade(name: "Venomous Current",  description: "+20% DMG, +15% Rate",   cost: 180, damageMult: 1.2,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 1.0),
                TowerUpgrade(name: "Plague Tide",       description: "+35% DMG, +20% Range",  cost: 310, damageMult: 1.35, fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 1.1),
            ]
        // Support-Buff — same pattern as bellTower
        case .fogHorn:
            return [
                TowerUpgrade(name: "Resonant Horn",     description: "+15% Aura Range",       cost: 130, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0.05),
                TowerUpgrade(name: "Rallying Call",     description: "+10% DMG Boost",        cost: 240, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0.10),
                TowerUpgrade(name: "Siren's Song",      description: "+15% Aura, +10% Boost", cost: 390, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0.10),
            ]
        // Heavy — same pattern as ballista
        case .tridentTower:
            return [
                TowerUpgrade(name: "Forged Tines",      description: "+20% DMG, +10% Range",  cost: 140, damageMult: 1.2,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0),
                TowerUpgrade(name: "Rapid Volley",      description: "+25% Rate, +15% DMG",   cost: 250, damageMult: 1.15, fireRateMult: 0.75, rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Poseidon's Fury",   description: "+40% DMG, +15% Range",  cost: 400, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        // Slow/Path — same pattern as moat
        case .whirlpool:
            return [
                TowerUpgrade(name: "Churning Depths",   description: "+20% Slow, +10% Range", cost: 75,  damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0.10),
                TowerUpgrade(name: "Riptide",           description: "+15% Rate, +10% Slow",  cost: 140, damageMult: 1.2,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 0.08),
                TowerUpgrade(name: "Maelstrom",         description: "+25% Range, +15% Slow", cost: 250, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.25, specialBonus: 0.12),
            ]

        // ─────────────────────────────────────────
        // MARK: Space Map
        // ─────────────────────────────────────────

        // Fast shooter — same pattern as archer
        case .laserTurret:
            return [
                TowerUpgrade(name: "Enhanced Optics",   description: "+20% Range, +15% DMG",  cost: 80,  damageMult: 1.15, fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 0),
                TowerUpgrade(name: "Quantum Core",      description: "+30% DMG, +15% Rate",   cost: 150, damageMult: 1.3,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Overclocked Systems",description: "+40% DMG, +15% Range", cost: 280, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        // AoE — same pattern as catapult
        case .missilePod:
            return [
                TowerUpgrade(name: "Payload Upgrade",   description: "+25% DMG, +10% Splash", cost: 120, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.0,  specialBonus: 1.1),
                TowerUpgrade(name: "Cluster Warhead",   description: "+30% DMG, +15% Rate",   cost: 220, damageMult: 1.3,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 1.0),
                TowerUpgrade(name: "Orbital Strike",    description: "+40% DMG, +20% Range",  cost: 380, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 1.15),
            ]
        // Magic — same pattern as wizard
        case .plasmaBeam:
            return [
                TowerUpgrade(name: "Focused Emitter",   description: "+25% DMG, +10% Range",  cost: 110, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0),
                TowerUpgrade(name: "Resonance Field",   description: "+30% DMG, +20% Rate",   cost: 200, damageMult: 1.3,  fireRateMult: 0.8,  rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Singularity Pulse", description: "+45% DMG, +15% Range",  cost: 350, damageMult: 1.45, fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        // Support-Dmg — same pattern as blacksmith
        case .shieldGen:
            return [
                TowerUpgrade(name: "Hardened Emitters", description: "+10% Aura Range, +5% DMG Boost",  cost: 100, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.10, specialBonus: 0.05),
                TowerUpgrade(name: "Overload Matrix",   description: "+10% DMG Boost",                  cost: 190, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.0,  specialBonus: 0.10),
                TowerUpgrade(name: "Aegis Protocol",    description: "+15% Aura Range, +10% DMG Boost", cost: 320, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.15, specialBonus: 0.10),
            ]
        // Poison — same pattern as alchemist
        case .acidSprayer:
            return [
                TowerUpgrade(name: "Corrosive Mix",     description: "+25% DMG, +15% Splash", cost: 100, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.0,  specialBonus: 1.15),
                TowerUpgrade(name: "Bio-Catalyst",      description: "+20% DMG, +15% Rate",   cost: 180, damageMult: 1.2,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 1.0),
                TowerUpgrade(name: "Viral Payload",     description: "+35% DMG, +20% Range",  cost: 310, damageMult: 1.35, fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 1.1),
            ]
        // Support-Buff — same pattern as bellTower
        case .commsArray:
            return [
                TowerUpgrade(name: "Boosted Antenna",   description: "+15% Aura Range",       cost: 130, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0.05),
                TowerUpgrade(name: "Tactical Uplink",   description: "+10% DMG Boost",        cost: 240, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0.10),
                TowerUpgrade(name: "Command Network",   description: "+15% Aura, +10% Boost", cost: 390, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0.10),
            ]
        // Heavy — same pattern as ballista
        case .railgun:
            return [
                TowerUpgrade(name: "Magnetic Coils",    description: "+20% DMG, +10% Range",  cost: 140, damageMult: 1.2,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0),
                TowerUpgrade(name: "Rapid Capacitor",   description: "+25% Rate, +15% DMG",   cost: 250, damageMult: 1.15, fireRateMult: 0.75, rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Hypersonic Round",  description: "+40% DMG, +15% Range",  cost: 400, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        // Slow/Path — same pattern as moat
        case .gravityWell:
            return [
                TowerUpgrade(name: "Densified Core",    description: "+20% Slow, +10% Range", cost: 75,  damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0.10),
                TowerUpgrade(name: "Event Horizon",     description: "+15% Rate, +10% Slow",  cost: 140, damageMult: 1.2,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 0.08),
                TowerUpgrade(name: "Black Hole Matrix", description: "+25% Range, +15% Slow", cost: 250, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.25, specialBonus: 0.12),
            ]

        // ─────────────────────────────────────────
        // MARK: Desert Map
        // ─────────────────────────────────────────

        // Fast shooter — same pattern as archer
        case .spearThrower:
            return [
                TowerUpgrade(name: "Tempered Bronze",   description: "+20% Range, +15% DMG",  cost: 80,  damageMult: 1.15, fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 0),
                TowerUpgrade(name: "Sandstorm Fury",    description: "+30% DMG, +15% Rate",   cost: 150, damageMult: 1.3,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Pharaoh's Blessing",description: "+40% DMG, +15% Range",  cost: 280, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        // AoE — same pattern as catapult
        case .boulderSling:
            return [
                TowerUpgrade(name: "Carved Granite",    description: "+25% DMG, +10% Splash", cost: 120, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.0,  specialBonus: 1.1),
                TowerUpgrade(name: "Desert Fury",       description: "+30% DMG, +15% Rate",   cost: 220, damageMult: 1.3,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 1.0),
                TowerUpgrade(name: "Sphinx's Ruin",     description: "+40% DMG, +20% Range",  cost: 380, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 1.15),
            ]
        // Magic — same pattern as wizard
        case .sunMirror:
            return [
                TowerUpgrade(name: "Polished Lens",     description: "+25% DMG, +10% Range",  cost: 110, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0),
                TowerUpgrade(name: "Solar Convergence", description: "+30% DMG, +20% Rate",   cost: 200, damageMult: 1.3,  fireRateMult: 0.8,  rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Ra's Judgment",     description: "+45% DMG, +15% Range",  cost: 350, damageMult: 1.45, fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        // Support-Dmg — same pattern as blacksmith
        case .obelisk:
            return [
                TowerUpgrade(name: "Ancient Runes",     description: "+10% Aura Range, +5% DMG Boost",  cost: 100, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.10, specialBonus: 0.05),
                TowerUpgrade(name: "Hieroglyph Power",  description: "+10% DMG Boost",                  cost: 190, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.0,  specialBonus: 0.10),
                TowerUpgrade(name: "Pharaoh's Decree",  description: "+15% Aura Range, +10% DMG Boost", cost: 320, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.15, specialBonus: 0.10),
            ]
        // Poison — same pattern as alchemist
        case .venomPit:
            return [
                TowerUpgrade(name: "Desert Asp Venom",  description: "+25% DMG, +15% Splash", cost: 100, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.0,  specialBonus: 1.15),
                TowerUpgrade(name: "Scorpion Toxin",    description: "+20% DMG, +15% Rate",   cost: 180, damageMult: 1.2,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 1.0),
                TowerUpgrade(name: "Cursed Sands",      description: "+35% DMG, +20% Range",  cost: 310, damageMult: 1.35, fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 1.1),
            ]
        // Support-Buff — same pattern as bellTower
        case .warDrum:
            return [
                TowerUpgrade(name: "Resonant Hide",     description: "+15% Aura Range",       cost: 130, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0.05),
                TowerUpgrade(name: "War Chant",         description: "+10% DMG Boost",        cost: 240, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0.10),
                TowerUpgrade(name: "Pharaoh's March",   description: "+15% Aura, +10% Boost", cost: 390, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0.10),
            ]
        // Heavy — same pattern as ballista
        case .scorpionBow:
            return [
                TowerUpgrade(name: "Iron Limbs",        description: "+20% DMG, +10% Range",  cost: 140, damageMult: 1.2,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0),
                TowerUpgrade(name: "Rapid Reload",      description: "+25% Rate, +15% DMG",   cost: 250, damageMult: 1.15, fireRateMult: 0.75, rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Siege Scorpion",    description: "+40% DMG, +15% Range",  cost: 400, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        // Slow/Path — same pattern as moat
        case .quicksand:
            return [
                TowerUpgrade(name: "Deep Sands",        description: "+20% Slow, +10% Range", cost: 75,  damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0.10),
                TowerUpgrade(name: "Sinking Dunes",     description: "+15% Rate, +10% Slow",  cost: 140, damageMult: 1.2,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 0.08),
                TowerUpgrade(name: "Cursed Mire",       description: "+25% Range, +15% Slow", cost: 250, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.25, specialBonus: 0.12),
            ]

        // ─────────────────────────────────────────
        // MARK: Sky Map
        // ─────────────────────────────────────────

        // Fast shooter — same pattern as archer
        case .windCannon:
            return [
                TowerUpgrade(name: "Gust Force",        description: "+20% Range, +15% DMG",  cost: 80,  damageMult: 1.15, fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 0),
                TowerUpgrade(name: "Thunder Strike",    description: "+30% DMG, +15% Rate",   cost: 150, damageMult: 1.3,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Celestial Power",   description: "+40% DMG, +15% Range",  cost: 280, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        // AoE — same pattern as catapult
        case .thunderCloud:
            return [
                TowerUpgrade(name: "Charged Vapor",     description: "+25% DMG, +10% Splash", cost: 120, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.0,  specialBonus: 1.1),
                TowerUpgrade(name: "Stormfront",        description: "+30% DMG, +15% Rate",   cost: 220, damageMult: 1.3,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 1.0),
                TowerUpgrade(name: "Tempest's Eye",     description: "+40% DMG, +20% Range",  cost: 380, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 1.15),
            ]
        // Magic — same pattern as wizard
        case .lightningRod:
            return [
                TowerUpgrade(name: "Conductive Tip",    description: "+25% DMG, +10% Range",  cost: 110, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0),
                TowerUpgrade(name: "Arc Mastery",       description: "+30% DMG, +20% Rate",   cost: 200, damageMult: 1.3,  fireRateMult: 0.8,  rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Storm Caller",      description: "+45% DMG, +15% Range",  cost: 350, damageMult: 1.45, fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        // Support-Dmg — same pattern as blacksmith
        case .skyShrine:
            return [
                TowerUpgrade(name: "Wind Blessing",     description: "+10% Aura Range, +5% DMG Boost",  cost: 100, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.10, specialBonus: 0.05),
                TowerUpgrade(name: "Storm Rite",        description: "+10% DMG Boost",                  cost: 190, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.0,  specialBonus: 0.10),
                TowerUpgrade(name: "Celestial Shrine",  description: "+15% Aura Range, +10% DMG Boost", cost: 320, damageMult: 1.0, fireRateMult: 1.0, rangeMult: 1.15, specialBonus: 0.10),
            ]
        // Poison — same pattern as alchemist
        case .stormBrew:
            return [
                TowerUpgrade(name: "Charged Drizzle",   description: "+25% DMG, +15% Splash", cost: 100, damageMult: 1.25, fireRateMult: 1.0,  rangeMult: 1.0,  specialBonus: 1.15),
                TowerUpgrade(name: "Acid Rain",         description: "+20% DMG, +15% Rate",   cost: 180, damageMult: 1.2,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 1.0),
                TowerUpgrade(name: "Tempest Vials",     description: "+35% DMG, +20% Range",  cost: 310, damageMult: 1.35, fireRateMult: 1.0,  rangeMult: 1.2,  specialBonus: 1.1),
            ]
        // Support-Buff — same pattern as bellTower
        case .windChime:
            return [
                TowerUpgrade(name: "Crystal Chimes",    description: "+15% Aura Range",       cost: 130, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0.05),
                TowerUpgrade(name: "Gale Song",         description: "+10% DMG Boost",        cost: 240, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0.10),
                TowerUpgrade(name: "Heaven's Chorus",   description: "+15% Aura, +10% Boost", cost: 390, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0.10),
            ]
        // Heavy — same pattern as ballista
        case .galeForce:
            return [
                TowerUpgrade(name: "Compressed Gusts",  description: "+20% DMG, +10% Range",  cost: 140, damageMult: 1.2,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0),
                TowerUpgrade(name: "Cyclone Engine",    description: "+25% Rate, +15% DMG",   cost: 250, damageMult: 1.15, fireRateMult: 0.75, rangeMult: 1.0,  specialBonus: 0),
                TowerUpgrade(name: "Typhoon Cannon",    description: "+40% DMG, +15% Range",  cost: 400, damageMult: 1.4,  fireRateMult: 1.0,  rangeMult: 1.15, specialBonus: 0),
            ]
        // Slow/Path — same pattern as moat
        case .cloudTrap:
            return [
                TowerUpgrade(name: "Thick Nimbus",      description: "+20% Slow, +10% Range", cost: 75,  damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.1,  specialBonus: 0.10),
                TowerUpgrade(name: "Freezing Mist",     description: "+15% Rate, +10% Slow",  cost: 140, damageMult: 1.2,  fireRateMult: 0.85, rangeMult: 1.0,  specialBonus: 0.08),
                TowerUpgrade(name: "Storm Veil",        description: "+25% Range, +15% Slow", cost: 250, damageMult: 1.0,  fireRateMult: 1.0,  rangeMult: 1.25, specialBonus: 0.12),
            ]
        }
    }
}
