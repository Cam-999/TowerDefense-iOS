import Foundation
import SpriteKit

enum EnemyType: String, CaseIterable {
    // Tier 0 — wave 1
    case goblin
    // Tier 1 — wave 11
    case orc
    // Tier 2 — wave 18+
    case darkKnight
    case skeleton
    // Tier 3 — wave 25+
    case troll
    case bandit
    case necromancer
    // Tier 4 — wave 35+
    case skeletonSwarm
    case siegeRam
    // Tier 5 — wave 45+
    case warlock
    // Tier 6 — wave 55+
    case harpy
    // Tier 7 — wave 65+
    case wraith
    // Bosses
    case necroKing    // mini-boss: wave 50+ boss waves
    case dragonLord   // main boss: every 10th wave

    var displayName: String {
        switch self {
        case .goblin:        "Goblin"
        case .orc:           "Orc"
        case .darkKnight:    "Dark Knight"
        case .skeleton:      "Skeleton"
        case .troll:         "Troll"
        case .bandit:        "Bandit"
        case .necromancer:   "Necromancer"
        case .skeletonSwarm: "Skeleton Swarm"
        case .siegeRam:      "Siege Ram"
        case .warlock:       "Warlock"
        case .harpy:         "Harpy"
        case .wraith:        "Wraith"
        case .necroKing:     "Necro King"
        case .dragonLord:    "Dragon Lord"
        }
    }

    var baseHP: CGFloat {
        switch self {
        case .goblin:        70
        case .orc:           280
        case .darkKnight:    220
        case .skeleton:      50
        case .troll:         200
        case .bandit:        100
        case .necromancer:   130
        case .skeletonSwarm: 40
        case .siegeRam:      500
        case .warlock:       300
        case .harpy:         90
        case .wraith:        110
        case .necroKing:     1400
        case .dragonLord:    2200
        }
    }

    var baseSpeed: CGFloat {
        switch self {
        case .goblin:        95
        case .orc:           50
        case .darkKnight:    60
        case .skeleton:      160
        case .troll:         55
        case .bandit:        120
        case .necromancer:   70
        case .skeletonSwarm: 170
        case .siegeRam:      28
        case .warlock:       55
        case .harpy:         140
        case .wraith:        200
        case .necroKing:     30
        case .dragonLord:    35
        }
    }

    var goldReward: Int {
        switch self {
        case .goblin:        6
        case .orc:           14
        case .darkKnight:    16
        case .skeleton:      5
        case .troll:         18
        case .bandit:        12
        case .necromancer:   20
        case .skeletonSwarm: 4
        case .siegeRam:      30
        case .warlock:       35
        case .harpy:         15
        case .wraith:        32
        case .necroKing:     90
        case .dragonLord:    120
        }
    }

    /// Fraction of damage received after armor (1.0 = full damage)
    var damageReduction: CGFloat {
        switch self {
        case .orc:      0.45
        case .troll:    0.30
        case .siegeRam: 0.50
        default:        1.0
        }
    }

    /// HP healed per second
    var regenPerSecond: CGFloat {
        switch self {
        case .troll:   8
        case .warlock: 12
        default:       0
        }
    }

    /// Ablative shield HP absorbed before main HP is hit (warlock only)
    var shieldHP: CGFloat { self == .warlock ? 250 : 0 }

    /// Chance (0–1) to dodge any hit entirely (bandit / wraith)
    var dodgeChance: Double {
        switch self {
        case .bandit: 0.20
        case .wraith: 0.20
        default:      0
        }
    }

    /// Speed multiplier applied when HP drops below 50% (unused in medieval)
    var berserkSpeedMult: CGFloat { 1.0 }

    /// Split on death: which enemy type and how many
    var splitSpawn: (type: EnemyType, count: Int)? {
        switch self {
        case .necromancer:   return (.skeleton, 3)
        case .skeletonSwarm: return (.goblin,   2)
        case .dragonLord:    return (.orc,      4)
        case .necroKing:     return (.darkKnight, 3)
        default:             return nil
        }
    }

    /// Lives drained when this enemy reaches the end
    var livesOnEscape: Int {
        switch self {
        case .goblin:              1
        case .orc:                 1
        case .darkKnight:          2
        case .skeleton:            1
        case .troll:               2
        case .bandit:              1
        case .necromancer:         2
        case .skeletonSwarm:       1
        case .siegeRam:            3
        case .warlock:             3
        case .harpy:               2
        case .wraith:              3
        case .necroKing:           5
        case .dragonLord:          10
        }
    }

    var slowImmune: Bool {
        switch self {
        case .dragonLord, .wraith: true
        default: false
        }
    }

    /// Whether this enemy flies (only targetable by towers with canTargetFlying)
    var isFlying: Bool { self == .harpy }

    /// Whether this enemy is immune to arrow (physical) damage
    var arrowImmune: Bool { self == .darkKnight }

    /// Magic vulnerability multiplier (1.0 = normal, >1 = takes more magic damage)
    var magicVulnerability: CGFloat { self == .darkKnight ? 1.5 : 1.0 }

    var isBoss: Bool { self == .dragonLord || self == .necroKing }

    var size: CGSize {
        switch self {
        case .dragonLord:    CGSize(width: 40, height: 40)
        case .necroKing:     CGSize(width: 36, height: 36)
        case .siegeRam:      CGSize(width: 36, height: 22)
        case .orc:           CGSize(width: 26, height: 26)
        case .troll:         CGSize(width: 28, height: 28)
        case .warlock:       CGSize(width: 26, height: 26)
        case .darkKnight:    CGSize(width: 24, height: 24)
        case .necromancer:   CGSize(width: 24, height: 24)
        case .goblin:        CGSize(width: 22, height: 22)
        case .bandit:        CGSize(width: 20, height: 20)
        case .harpy:         CGSize(width: 22, height: 22)
        case .wraith:        CGSize(width: 22, height: 22)
        case .skeleton:      CGSize(width: 18, height: 18)
        case .skeletonSwarm: CGSize(width: 14, height: 14)
        }
    }

    /// Distinctive color per enemy
    var lore: String {
        switch self {
        case .goblin:        "A small but numerous pest. Weak alone, deadly in swarms."
        case .orc:           "Heavily armored brute. Absorbs punishment and keeps marching."
        case .darkKnight:    "Enchanted armor deflects arrows. Vulnerable to magic."
        case .skeleton:      "Fast-moving bone warrior. Fragile but hard to catch."
        case .troll:         "Regenerates health over time. Kill it fast or not at all."
        case .bandit:        "Agile rogue that dodges attacks with uncanny reflexes."
        case .necromancer:   "Dark mage that summons skeletons upon death."
        case .skeletonSwarm: "Tiny bone fragments that split into goblins when destroyed."
        case .siegeRam:      "Massive battering engine. Slow but extremely durable."
        case .warlock:       "Protected by a magic shield. Regenerates health."
        case .harpy:         "Flying creature that soars above ground defenses."
        case .wraith:        "Ghostly specter. Phases through attacks and immune to slows."
        case .necroKing:     "Lord of the undead. Summons dark knights on death."
        case .dragonLord:    "Ancient wyrm of devastating power. The ultimate threat."
        }
    }

    var color: SKColor {
        switch self {
        case .goblin:        SKColor(red: 0.45, green: 0.65, blue: 0.20, alpha: 1) // sickly green
        case .orc:           SKColor(red: 0.35, green: 0.50, blue: 0.25, alpha: 1) // dark green
        case .darkKnight:    SKColor(red: 0.20, green: 0.20, blue: 0.30, alpha: 1) // dark steel
        case .skeleton:      SKColor(red: 0.85, green: 0.82, blue: 0.75, alpha: 1) // bone white
        case .troll:         SKColor(red: 0.50, green: 0.55, blue: 0.35, alpha: 1) // mossy green
        case .bandit:        SKColor(red: 0.55, green: 0.40, blue: 0.25, alpha: 1) // leather brown
        case .necromancer:   SKColor(red: 0.40, green: 0.15, blue: 0.50, alpha: 1) // dark purple
        case .skeletonSwarm: SKColor(red: 0.80, green: 0.78, blue: 0.70, alpha: 1) // pale bone
        case .siegeRam:      SKColor(red: 0.45, green: 0.30, blue: 0.15, alpha: 1) // dark wood
        case .warlock:       SKColor(red: 0.30, green: 0.10, blue: 0.40, alpha: 1) // deep purple
        case .harpy:         SKColor(red: 0.60, green: 0.50, blue: 0.70, alpha: 1) // lavender
        case .wraith:        SKColor(red: 0.85, green: 0.88, blue: 0.95, alpha: 1) // ghostly white
        case .necroKing:     SKColor(red: 0.30, green: 0.08, blue: 0.35, alpha: 1) // royal purple
        case .dragonLord:    SKColor(red: 0.80, green: 0.15, blue: 0.10, alpha: 1) // dragon red
        }
    }
}
