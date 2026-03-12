import Foundation
import SpriteKit

enum EnemyType: String, CaseIterable {
    // MARK: - Forest enemies
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

    // MARK: - Ocean enemies
    case crab
    case pirate
    case jellyfish
    case siren
    case seaSerpent
    case anglerFish
    case sharkSwarm
    case turtleTank
    case stormCaster
    case flyingFish
    case ghostShip
    case tidalLord    // mini-boss
    case kraken       // main boss

    // MARK: - Space enemies
    case alienDrone
    case mechSoldier
    case speedster
    case phaseShifter
    case plasmaGolem
    case hiveMind
    case naniteSwarm
    case battleCruiser
    case voidCaster
    case starfighter
    case darkMatter
    case admiralZyx       // mini-boss
    case mothershipOmega  // main boss

    // MARK: - Desert enemies
    case scarab
    case sandGolem
    case dustDevil
    case mirage
    case sandWorm
    case mummy
    case scorpionPack
    case siegeElephant
    case sandSorcerer
    case desertHawk
    case sphinxWraith
    case pharaohKing      // mini-boss
    case ancientColossus  // main boss

    // MARK: - Sky enemies
    case cloudWisp
    case stormKnight
    case windSprite
    case fogPhantom
    case thunderBeast
    case cloudWeaver
    case featherSwarm
    case skyFortress
    case galeWizard
    case stormEagle
    case voidZephyr
    case skylordAres     // mini-boss
    case thunderDragon   // main boss

    // MARK: - Map

    var map: MapType {
        switch self {
        case .goblin, .orc, .darkKnight, .skeleton, .troll, .bandit,
             .necromancer, .skeletonSwarm, .siegeRam, .warlock, .harpy,
             .wraith, .necroKing, .dragonLord:
            return .forest
        case .crab, .pirate, .jellyfish, .siren, .seaSerpent, .anglerFish,
             .sharkSwarm, .turtleTank, .stormCaster, .flyingFish, .ghostShip,
             .tidalLord, .kraken:
            return .ocean
        case .alienDrone, .mechSoldier, .speedster, .phaseShifter, .plasmaGolem,
             .hiveMind, .naniteSwarm, .battleCruiser, .voidCaster, .starfighter,
             .darkMatter, .admiralZyx, .mothershipOmega:
            return .space
        case .scarab, .sandGolem, .dustDevil, .mirage, .sandWorm, .mummy,
             .scorpionPack, .siegeElephant, .sandSorcerer, .desertHawk,
             .sphinxWraith, .pharaohKing, .ancientColossus:
            return .desert
        case .cloudWisp, .stormKnight, .windSprite, .fogPhantom, .thunderBeast,
             .cloudWeaver, .featherSwarm, .skyFortress, .galeWizard, .stormEagle,
             .voidZephyr, .skylordAres, .thunderDragon:
            return .sky
        }
    }

    // MARK: - Display Name

    var displayName: String {
        switch self {
        // Forest
        case .goblin:           "Goblin"
        case .orc:              "Orc"
        case .darkKnight:       "Dark Knight"
        case .skeleton:         "Skeleton"
        case .troll:            "Troll"
        case .bandit:           "Bandit"
        case .necromancer:      "Necromancer"
        case .skeletonSwarm:    "Skeleton Swarm"
        case .siegeRam:         "Siege Ram"
        case .warlock:          "Warlock"
        case .harpy:            "Harpy"
        case .wraith:           "Wraith"
        case .necroKing:        "Necro King"
        case .dragonLord:       "Dragon Lord"
        // Ocean
        case .crab:             "Crab"
        case .pirate:           "Pirate"
        case .jellyfish:        "Jellyfish"
        case .siren:            "Siren"
        case .seaSerpent:       "Sea Serpent"
        case .anglerFish:       "Angler Fish"
        case .sharkSwarm:       "Shark Swarm"
        case .turtleTank:       "Turtle Tank"
        case .stormCaster:      "Storm Caster"
        case .flyingFish:       "Flying Fish"
        case .ghostShip:        "Ghost Ship"
        case .tidalLord:        "Tidal Lord"
        case .kraken:           "Kraken"
        // Space
        case .alienDrone:       "Alien Drone"
        case .mechSoldier:      "Mech Soldier"
        case .speedster:        "Speedster"
        case .phaseShifter:     "Phase Shifter"
        case .plasmaGolem:      "Plasma Golem"
        case .hiveMind:         "Hive Mind"
        case .naniteSwarm:      "Nanite Swarm"
        case .battleCruiser:    "Battle Cruiser"
        case .voidCaster:       "Void Caster"
        case .starfighter:      "Starfighter"
        case .darkMatter:       "Dark Matter"
        case .admiralZyx:       "Admiral Zyx"
        case .mothershipOmega:  "Mothership Omega"
        // Desert
        case .scarab:           "Scarab"
        case .sandGolem:        "Sand Golem"
        case .dustDevil:        "Dust Devil"
        case .mirage:           "Mirage"
        case .sandWorm:         "Sand Worm"
        case .mummy:            "Mummy"
        case .scorpionPack:     "Scorpion Pack"
        case .siegeElephant:    "Siege Elephant"
        case .sandSorcerer:     "Sand Sorcerer"
        case .desertHawk:       "Desert Hawk"
        case .sphinxWraith:     "Sphinx Wraith"
        case .pharaohKing:      "Pharaoh King"
        case .ancientColossus:  "Ancient Colossus"
        // Sky
        case .cloudWisp:        "Cloud Wisp"
        case .stormKnight:      "Storm Knight"
        case .windSprite:       "Wind Sprite"
        case .fogPhantom:       "Fog Phantom"
        case .thunderBeast:     "Thunder Beast"
        case .cloudWeaver:      "Cloud Weaver"
        case .featherSwarm:     "Feather Swarm"
        case .skyFortress:      "Sky Fortress"
        case .galeWizard:       "Gale Wizard"
        case .stormEagle:       "Storm Eagle"
        case .voidZephyr:       "Void Zephyr"
        case .skylordAres:      "Skylord Ares"
        case .thunderDragon:    "Thunder Dragon"
        }
    }

    // MARK: - Base HP

    var baseHP: CGFloat {
        switch self {
        // Forest
        case .goblin:           70
        case .orc:              280
        case .darkKnight:       220
        case .skeleton:         50
        case .troll:            200
        case .bandit:           100
        case .necromancer:      130
        case .skeletonSwarm:    40
        case .siegeRam:         500
        case .warlock:          300
        case .harpy:            90
        case .wraith:           110
        case .necroKing:        1400
        case .dragonLord:       2200
        // Ocean
        case .crab:             70
        case .pirate:           260
        case .jellyfish:        55
        case .siren:            100
        case .seaSerpent:       200
        case .anglerFish:       130
        case .sharkSwarm:       40
        case .turtleTank:       480
        case .stormCaster:      280
        case .flyingFish:       85
        case .ghostShip:        110
        case .tidalLord:        1300
        case .kraken:           2100
        // Space
        case .alienDrone:       65
        case .mechSoldier:      270
        case .speedster:        50
        case .phaseShifter:     95
        case .plasmaGolem:      210
        case .hiveMind:         120
        case .naniteSwarm:      35
        case .battleCruiser:    520
        case .voidCaster:       310
        case .starfighter:      80
        case .darkMatter:       105
        case .admiralZyx:       1350
        case .mothershipOmega:  2300
        // Desert
        case .scarab:           65
        case .sandGolem:        290
        case .dustDevil:        45
        case .mirage:           90
        case .sandWorm:         220
        case .mummy:            140
        case .scorpionPack:     40
        case .siegeElephant:    500
        case .sandSorcerer:     290
        case .desertHawk:       90
        case .sphinxWraith:     115
        case .pharaohKing:      1400
        case .ancientColossus:  2200
        // Sky
        case .cloudWisp:        60
        case .stormKnight:      275
        case .windSprite:       48
        case .fogPhantom:       95
        case .thunderBeast:     210
        case .cloudWeaver:      125
        case .featherSwarm:     38
        case .skyFortress:      490
        case .galeWizard:       300
        case .stormEagle:       88
        case .voidZephyr:       108
        case .skylordAres:      1350
        case .thunderDragon:    2150
        }
    }

    // MARK: - Base Speed

    var baseSpeed: CGFloat {
        switch self {
        // Forest
        case .goblin:           95
        case .orc:              50
        case .darkKnight:       60
        case .skeleton:         160
        case .troll:            55
        case .bandit:           120
        case .necromancer:      70
        case .skeletonSwarm:    170
        case .siegeRam:         28
        case .warlock:          55
        case .harpy:            140
        case .wraith:           200
        case .necroKing:        30
        case .dragonLord:       35
        // Ocean
        case .crab:             90
        case .pirate:           55
        case .jellyfish:        155
        case .siren:            115
        case .seaSerpent:       50
        case .anglerFish:       65
        case .sharkSwarm:       165
        case .turtleTank:       30
        case .stormCaster:      55
        case .flyingFish:       135
        case .ghostShip:        190
        case .tidalLord:        32
        case .kraken:           35
        // Space
        case .alienDrone:       100
        case .mechSoldier:      52
        case .speedster:        165
        case .phaseShifter:     120
        case .plasmaGolem:      50
        case .hiveMind:         70
        case .naniteSwarm:      175
        case .battleCruiser:    26
        case .voidCaster:       52
        case .starfighter:      145
        case .darkMatter:       205
        case .admiralZyx:       30
        case .mothershipOmega:  33
        // Desert
        case .scarab:           95
        case .sandGolem:        48
        case .dustDevil:        170
        case .mirage:           125
        case .sandWorm:         45
        case .mummy:            65
        case .scorpionPack:     160
        case .siegeElephant:    28
        case .sandSorcerer:     55
        case .desertHawk:       130
        case .sphinxWraith:     195
        case .pharaohKing:      28
        case .ancientColossus:  34
        // Sky
        case .cloudWisp:        100
        case .stormKnight:      52
        case .windSprite:       168
        case .fogPhantom:       118
        case .thunderBeast:     50
        case .cloudWeaver:      68
        case .featherSwarm:     170
        case .skyFortress:      27
        case .galeWizard:       53
        case .stormEagle:       138
        case .voidZephyr:       200
        case .skylordAres:      30
        case .thunderDragon:    35
        }
    }

    // MARK: - Gold Reward

    var goldReward: Int {
        switch self {
        // Forest
        case .goblin:           6
        case .orc:              14
        case .darkKnight:       16
        case .skeleton:         5
        case .troll:            18
        case .bandit:           12
        case .necromancer:      20
        case .skeletonSwarm:    4
        case .siegeRam:         30
        case .warlock:          35
        case .harpy:            15
        case .wraith:           32
        case .necroKing:        90
        case .dragonLord:       120
        // Ocean
        case .crab:             6
        case .pirate:           14
        case .jellyfish:        5
        case .siren:            12
        case .seaSerpent:       18
        case .anglerFish:       20
        case .sharkSwarm:       4
        case .turtleTank:       30
        case .stormCaster:      35
        case .flyingFish:       15
        case .ghostShip:        32
        case .tidalLord:        90
        case .kraken:           120
        // Space
        case .alienDrone:       6
        case .mechSoldier:      14
        case .speedster:        5
        case .phaseShifter:     12
        case .plasmaGolem:      18
        case .hiveMind:         20
        case .naniteSwarm:      4
        case .battleCruiser:    30
        case .voidCaster:       35
        case .starfighter:      15
        case .darkMatter:       32
        case .admiralZyx:       90
        case .mothershipOmega:  120
        // Desert
        case .scarab:           6
        case .sandGolem:        14
        case .dustDevil:        5
        case .mirage:           12
        case .sandWorm:         18
        case .mummy:            20
        case .scorpionPack:     4
        case .siegeElephant:    30
        case .sandSorcerer:     35
        case .desertHawk:       15
        case .sphinxWraith:     32
        case .pharaohKing:      90
        case .ancientColossus:  120
        // Sky
        case .cloudWisp:        6
        case .stormKnight:      14
        case .windSprite:       5
        case .fogPhantom:       12
        case .thunderBeast:     18
        case .cloudWeaver:      20
        case .featherSwarm:     4
        case .skyFortress:      30
        case .galeWizard:       35
        case .stormEagle:       15
        case .voidZephyr:       32
        case .skylordAres:      90
        case .thunderDragon:    120
        }
    }

    // MARK: - Damage Reduction

    /// Fraction of damage received after armor (1.0 = full damage)
    var damageReduction: CGFloat {
        switch self {
        // Forest
        case .orc:              0.45
        case .troll:            0.30
        case .siegeRam:         0.50
        // Ocean
        case .pirate:           0.60
        case .seaSerpent:       0.70
        case .turtleTank:       0.50
        // Space
        case .mechSoldier:      0.55
        case .plasmaGolem:      0.65
        case .battleCruiser:    0.50
        // Desert
        case .sandGolem:        0.55
        case .sandWorm:         0.65
        case .siegeElephant:    0.50
        // Sky
        case .stormKnight:      0.60
        case .thunderBeast:     0.70
        case .skyFortress:      0.50
        default:                1.0
        }
    }

    // MARK: - Regen Per Second

    /// HP healed per second
    var regenPerSecond: CGFloat {
        switch self {
        // Forest
        case .troll:            8
        case .warlock:          12
        // Ocean
        case .seaSerpent:       8
        case .stormCaster:      10
        // Space
        case .plasmaGolem:      9
        case .voidCaster:       12
        // Desert
        case .sandWorm:         10
        case .sandSorcerer:     11
        // Sky
        case .thunderBeast:     9
        case .galeWizard:       11
        default:                0
        }
    }

    // MARK: - Shield HP

    /// Ablative shield HP absorbed before main HP is hit
    var shieldHP: CGFloat {
        switch self {
        case .warlock:      250
        case .stormCaster:  250
        case .voidCaster:   270
        case .sandSorcerer: 240
        case .galeWizard:   260
        default:            0
        }
    }

    // MARK: - Dodge Chance

    /// Chance (0–1) to dodge any hit entirely
    var dodgeChance: Double {
        switch self {
        // Forest
        case .bandit:       0.20
        case .wraith:       0.20
        // Ocean
        case .siren:        0.20
        case .ghostShip:    0.20
        // Space
        case .phaseShifter: 0.25
        case .darkMatter:   0.20
        // Desert
        case .mirage:       0.25
        case .sphinxWraith: 0.20
        // Sky
        case .fogPhantom:   0.22
        case .voidZephyr:   0.20
        default:            0
        }
    }

    // MARK: - Berserk Speed Multiplier

    /// Speed multiplier applied when HP drops below 50%
    var berserkSpeedMult: CGFloat { 1.0 }

    // MARK: - Split Spawn

    /// Split on death: which enemy type and how many
    var splitSpawn: (type: EnemyType, count: Int)? {
        switch self {
        // Forest
        case .necromancer:      return (.skeleton,    3)
        case .skeletonSwarm:    return (.goblin,      2)
        case .dragonLord:       return (.orc,         4)
        case .necroKing:        return (.darkKnight,  3)
        // Ocean
        case .anglerFish:       return (.jellyfish,   3)
        case .sharkSwarm:       return (.crab,        2)
        case .tidalLord:        return (.pirate,      3)
        case .kraken:           return (.seaSerpent,  4)
        // Space
        case .hiveMind:         return (.speedster,   3)
        case .naniteSwarm:      return (.alienDrone,  2)
        case .admiralZyx:       return (.mechSoldier, 3)
        case .mothershipOmega:  return (.plasmaGolem, 4)
        // Desert
        case .mummy:            return (.dustDevil,   3)
        case .scorpionPack:     return (.scarab,      2)
        case .pharaohKing:      return (.sandGolem,   3)
        case .ancientColossus:  return (.sandWorm,    4)
        // Sky
        case .cloudWeaver:      return (.windSprite,  3)
        case .featherSwarm:     return (.cloudWisp,   2)
        case .skylordAres:      return (.stormKnight, 3)
        case .thunderDragon:    return (.thunderBeast, 4)
        default:                return nil
        }
    }

    // MARK: - Lives On Escape

    /// Lives drained when this enemy reaches the end
    var livesOnEscape: Int {
        switch self {
        // Forest
        case .goblin:           1
        case .orc:              1
        case .darkKnight:       2
        case .skeleton:         1
        case .troll:            2
        case .bandit:           1
        case .necromancer:      2
        case .skeletonSwarm:    1
        case .siegeRam:         3
        case .warlock:          3
        case .harpy:            2
        case .wraith:           3
        case .necroKing:        5
        case .dragonLord:       10
        // Ocean
        case .crab:             1
        case .pirate:           2
        case .jellyfish:        1
        case .siren:            1
        case .seaSerpent:       2
        case .anglerFish:       2
        case .sharkSwarm:       1
        case .turtleTank:       3
        case .stormCaster:      3
        case .flyingFish:       2
        case .ghostShip:        3
        case .tidalLord:        5
        case .kraken:           10
        // Space
        case .alienDrone:       1
        case .mechSoldier:      2
        case .speedster:        1
        case .phaseShifter:     1
        case .plasmaGolem:      2
        case .hiveMind:         2
        case .naniteSwarm:      1
        case .battleCruiser:    3
        case .voidCaster:       3
        case .starfighter:      2
        case .darkMatter:       3
        case .admiralZyx:       5
        case .mothershipOmega:  10
        // Desert
        case .scarab:           1
        case .sandGolem:        2
        case .dustDevil:        1
        case .mirage:           1
        case .sandWorm:         2
        case .mummy:            2
        case .scorpionPack:     1
        case .siegeElephant:    3
        case .sandSorcerer:     3
        case .desertHawk:       2
        case .sphinxWraith:     3
        case .pharaohKing:      5
        case .ancientColossus:  10
        // Sky
        case .cloudWisp:        1
        case .stormKnight:      2
        case .windSprite:       1
        case .fogPhantom:       1
        case .thunderBeast:     2
        case .cloudWeaver:      2
        case .featherSwarm:     1
        case .skyFortress:      3
        case .galeWizard:       3
        case .stormEagle:       2
        case .voidZephyr:       3
        case .skylordAres:      5
        case .thunderDragon:    10
        }
    }

    // MARK: - Slow Immune

    var slowImmune: Bool {
        switch self {
        case .dragonLord, .wraith,
             .ghostShip, .darkMatter, .sphinxWraith, .voidZephyr:
            return true
        default:
            return false
        }
    }

    // MARK: - Flying

    /// Whether this enemy flies (only targetable by towers with canTargetFlying)
    var isFlying: Bool {
        switch self {
        case .harpy, .flyingFish, .starfighter, .desertHawk, .stormEagle:
            return true
        default:
            return false
        }
    }

    // MARK: - Arrow Immune

    /// Whether this enemy is immune to arrow (physical) damage
    var arrowImmune: Bool { self == .darkKnight }

    // MARK: - Magic Vulnerability

    /// Magic vulnerability multiplier (1.0 = normal, >1 = takes more magic damage)
    var magicVulnerability: CGFloat { self == .darkKnight ? 1.5 : 1.0 }

    // MARK: - Is Boss

    var isBoss: Bool {
        switch self {
        case .necroKing, .dragonLord,
             .tidalLord, .kraken,
             .admiralZyx, .mothershipOmega,
             .pharaohKing, .ancientColossus,
             .skylordAres, .thunderDragon:
            return true
        default:
            return false
        }
    }

    // MARK: - Size

    var size: CGSize {
        switch self {
        // Forest
        case .dragonLord:       CGSize(width: 40, height: 40)
        case .necroKing:        CGSize(width: 36, height: 36)
        case .siegeRam:         CGSize(width: 36, height: 22)
        case .orc:              CGSize(width: 26, height: 26)
        case .troll:            CGSize(width: 28, height: 28)
        case .warlock:          CGSize(width: 26, height: 26)
        case .darkKnight:       CGSize(width: 24, height: 24)
        case .necromancer:      CGSize(width: 24, height: 24)
        case .goblin:           CGSize(width: 22, height: 22)
        case .bandit:           CGSize(width: 20, height: 20)
        case .harpy:            CGSize(width: 22, height: 22)
        case .wraith:           CGSize(width: 22, height: 22)
        case .skeleton:         CGSize(width: 18, height: 18)
        case .skeletonSwarm:    CGSize(width: 14, height: 14)
        // Ocean
        case .kraken:           CGSize(width: 40, height: 40)
        case .tidalLord:        CGSize(width: 36, height: 36)
        case .turtleTank:       CGSize(width: 36, height: 22)
        case .pirate:           CGSize(width: 26, height: 26)
        case .seaSerpent:       CGSize(width: 28, height: 28)
        case .stormCaster:      CGSize(width: 26, height: 26)
        case .anglerFish:       CGSize(width: 24, height: 24)
        case .siren:            CGSize(width: 24, height: 24)
        case .crab:             CGSize(width: 22, height: 22)
        case .ghostShip:        CGSize(width: 22, height: 22)
        case .flyingFish:       CGSize(width: 20, height: 20)
        case .jellyfish:        CGSize(width: 20, height: 20)
        case .sharkSwarm:       CGSize(width: 14, height: 14)
        // Space
        case .mothershipOmega:  CGSize(width: 40, height: 40)
        case .admiralZyx:       CGSize(width: 36, height: 36)
        case .battleCruiser:    CGSize(width: 36, height: 22)
        case .mechSoldier:      CGSize(width: 26, height: 26)
        case .plasmaGolem:      CGSize(width: 28, height: 28)
        case .voidCaster:       CGSize(width: 26, height: 26)
        case .hiveMind:         CGSize(width: 24, height: 24)
        case .phaseShifter:     CGSize(width: 24, height: 24)
        case .alienDrone:       CGSize(width: 22, height: 22)
        case .darkMatter:       CGSize(width: 22, height: 22)
        case .starfighter:      CGSize(width: 20, height: 20)
        case .speedster:        CGSize(width: 20, height: 20)
        case .naniteSwarm:      CGSize(width: 14, height: 14)
        // Desert
        case .ancientColossus:  CGSize(width: 40, height: 40)
        case .pharaohKing:      CGSize(width: 36, height: 36)
        case .siegeElephant:    CGSize(width: 36, height: 22)
        case .sandGolem:        CGSize(width: 26, height: 26)
        case .sandWorm:         CGSize(width: 28, height: 28)
        case .sandSorcerer:     CGSize(width: 26, height: 26)
        case .mummy:            CGSize(width: 24, height: 24)
        case .mirage:           CGSize(width: 24, height: 24)
        case .scarab:           CGSize(width: 22, height: 22)
        case .sphinxWraith:     CGSize(width: 22, height: 22)
        case .desertHawk:       CGSize(width: 20, height: 20)
        case .dustDevil:        CGSize(width: 20, height: 20)
        case .scorpionPack:     CGSize(width: 14, height: 14)
        // Sky
        case .thunderDragon:    CGSize(width: 40, height: 40)
        case .skylordAres:      CGSize(width: 36, height: 36)
        case .skyFortress:      CGSize(width: 36, height: 22)
        case .stormKnight:      CGSize(width: 26, height: 26)
        case .thunderBeast:     CGSize(width: 28, height: 28)
        case .galeWizard:       CGSize(width: 26, height: 26)
        case .cloudWeaver:      CGSize(width: 24, height: 24)
        case .fogPhantom:       CGSize(width: 24, height: 24)
        case .cloudWisp:        CGSize(width: 22, height: 22)
        case .voidZephyr:       CGSize(width: 22, height: 22)
        case .stormEagle:       CGSize(width: 20, height: 20)
        case .windSprite:       CGSize(width: 20, height: 20)
        case .featherSwarm:     CGSize(width: 14, height: 14)
        }
    }

    // MARK: - Lore

    var lore: String {
        switch self {
        // Forest
        case .goblin:           "A small but numerous pest. Weak alone, deadly in swarms."
        case .orc:              "Heavily armored brute. Absorbs punishment and keeps marching."
        case .darkKnight:       "Enchanted armor deflects arrows. Vulnerable to magic."
        case .skeleton:         "Fast-moving bone warrior. Fragile but hard to catch."
        case .troll:            "Regenerates health over time. Kill it fast or not at all."
        case .bandit:           "Agile rogue that dodges attacks with uncanny reflexes."
        case .necromancer:      "Dark mage that summons skeletons upon death."
        case .skeletonSwarm:    "Tiny bone fragments that split into goblins when destroyed."
        case .siegeRam:         "Massive battering engine. Slow but extremely durable."
        case .warlock:          "Protected by a magic shield. Regenerates health."
        case .harpy:            "Flying creature that soars above ground defenses."
        case .wraith:           "Ghostly specter. Phases through attacks and immune to slows."
        case .necroKing:        "Lord of the undead. Summons dark knights on death."
        case .dragonLord:       "Ancient wyrm of devastating power. The ultimate threat."
        // Ocean
        case .crab:             "A hardy crustacean that skitters across the ocean floor toward your gates."
        case .pirate:           "Seasoned corsair clad in thick leather and iron plate."
        case .jellyfish:        "A translucent terror that pulses through the water at alarming speed."
        case .siren:            "Enchanting sea-spirit whose fluid movements help her evade attacks."
        case .seaSerpent:       "Colossal sea snake armored in scales as hard as steel."
        case .anglerFish:       "Deep-sea predator whose death releases a swarm of jellyfish."
        case .sharkSwarm:       "Pack of frenzied sharks that splits into crabs when scattered."
        case .turtleTank:       "An ancient sea turtle whose shell is nearly impenetrable."
        case .stormCaster:      "Ocean witch shielded by a tempest barrier that regenerates her health."
        case .flyingFish:       "Silver fish that leap from the waves and glide over your defenses."
        case .ghostShip:        "Phantom vessel that phases through attacks and cannot be slowed."
        case .tidalLord:        "Sovereign of the tides whose death unleashes a crew of pirates."
        case .kraken:           "Titan of the deep that spawns sea serpents from its thrashing tentacles."
        // Space
        case .alienDrone:       "Scout unit of the invading alien fleet, cheap and expendable."
        case .mechSoldier:      "Combat automaton encased in reinforced alloy plating."
        case .speedster:        "Sleek alien runner built for rapid infiltration."
        case .phaseShifter:     "Phase-tech warrior that can briefly shift out of physical reality."
        case .plasmaGolem:      "Animated construct of living plasma hardened into armor."
        case .hiveMind:         "Collective intelligence node that spawns speedsters on destruction."
        case .naniteSwarm:      "Cloud of microscopic robots that splits into drones when dispersed."
        case .battleCruiser:    "Heavily plated warship that absorbs enormous amounts of fire."
        case .voidCaster:       "Psion protected by a void-energy barrier that slowly regenerates."
        case .starfighter:      "Single-pilot interceptor that streaks through the air above ground towers."
        case .darkMatter:       "Anomalous entity immune to slows and capable of phasing through attacks."
        case .admiralZyx:       "Alien fleet commander who deploys mech soldiers from his flagship."
        case .mothershipOmega:  "Colossal command vessel that births plasma golems to overwhelm defenses."
        // Desert
        case .scarab:           "Sacred beetle that scurries across the sands in relentless columns."
        case .sandGolem:        "Animated dune of compacted sand reinforced with ancient stone."
        case .dustDevil:        "Whirling vortex of sand that moves at terrifying speed."
        case .mirage:           "Flickering illusion-warrior that is maddeningly difficult to pin down."
        case .sandWorm:         "Burrowing leviathan armored in hardened chitin that heals underground."
        case .mummy:            "Cursed pharaoh's guardian that releases dust devils when destroyed."
        case .scorpionPack:     "Cluster of desert scorpions that scatter into scarabs when disrupted."
        case .siegeElephant:    "War elephant clad in bronze plate, nearly impossible to stop."
        case .sandSorcerer:     "Desert mage whose arcane barrier regenerates even under sustained fire."
        case .desertHawk:       "Fierce raptor that dives from the blazing sky beyond tower range."
        case .sphinxWraith:     "Undead guardian of ancient tombs, immune to slowing and hard to hit."
        case .pharaohKing:      "Resurrected desert ruler who summons sand golems upon his death."
        case .ancientColossus:  "Titanic statue animated by forgotten sorcery, spawning sand worms in its wake."
        // Sky
        case .cloudWisp:        "Gentle wisp of living cloud, harmless-looking but relentlessly persistent."
        case .stormKnight:      "Armored warrior who rides the storm winds toward your towers."
        case .windSprite:       "Mercurial air spirit that zips through defenses in a blur."
        case .fogPhantom:       "Wraith of rolling fog whose shifting form deflects many attacks."
        case .thunderBeast:     "Behemoth of crackling lightning armored in condensed storm clouds."
        case .cloudWeaver:      "Sky mage who unravels wind sprites from the clouds on death."
        case .featherSwarm:     "Cyclone of razor feathers that breaks apart into cloud wisps."
        case .skyFortress:      "Floating citadel bristling with armor plating, nearly indestructible."
        case .galeWizard:       "Aerial sorcerer shielded by howling gales that restore his vitality."
        case .stormEagle:       "Massive eagle of living lightning that soars far above ground towers."
        case .voidZephyr:       "Wind anomaly from the edge of existence, immune to slows and strikes."
        case .skylordAres:      "God of the storm sky who sends storm knights ahead before his arrival."
        case .thunderDragon:    "Dragon born of a thousand storms, unleashing thunder beasts upon its death."
        }
    }

    // MARK: - Color

    var color: SKColor {
        switch self {
        // Forest
        case .goblin:           SKColor(red: 0.45, green: 0.65, blue: 0.20, alpha: 1) // sickly green
        case .orc:              SKColor(red: 0.35, green: 0.50, blue: 0.25, alpha: 1) // dark green
        case .darkKnight:       SKColor(red: 0.20, green: 0.20, blue: 0.30, alpha: 1) // dark steel
        case .skeleton:         SKColor(red: 0.85, green: 0.82, blue: 0.75, alpha: 1) // bone white
        case .troll:            SKColor(red: 0.50, green: 0.55, blue: 0.35, alpha: 1) // mossy green
        case .bandit:           SKColor(red: 0.55, green: 0.40, blue: 0.25, alpha: 1) // leather brown
        case .necromancer:      SKColor(red: 0.40, green: 0.15, blue: 0.50, alpha: 1) // dark purple
        case .skeletonSwarm:    SKColor(red: 0.80, green: 0.78, blue: 0.70, alpha: 1) // pale bone
        case .siegeRam:         SKColor(red: 0.45, green: 0.30, blue: 0.15, alpha: 1) // dark wood
        case .warlock:          SKColor(red: 0.30, green: 0.10, blue: 0.40, alpha: 1) // deep purple
        case .harpy:            SKColor(red: 0.60, green: 0.50, blue: 0.70, alpha: 1) // lavender
        case .wraith:           SKColor(red: 0.85, green: 0.88, blue: 0.95, alpha: 1) // ghostly white
        case .necroKing:        SKColor(red: 0.30, green: 0.08, blue: 0.35, alpha: 1) // royal purple
        case .dragonLord:       SKColor(red: 0.80, green: 0.15, blue: 0.10, alpha: 1) // dragon red
        // Ocean
        case .crab:             SKColor(red: 0.85, green: 0.35, blue: 0.15, alpha: 1) // burnt orange-red
        case .pirate:           SKColor(red: 0.25, green: 0.40, blue: 0.55, alpha: 1) // deep sea blue
        case .jellyfish:        SKColor(red: 0.50, green: 0.82, blue: 0.90, alpha: 1) // translucent aqua
        case .siren:            SKColor(red: 0.20, green: 0.65, blue: 0.80, alpha: 1) // ocean teal
        case .seaSerpent:       SKColor(red: 0.10, green: 0.50, blue: 0.40, alpha: 1) // dark teal
        case .anglerFish:       SKColor(red: 0.15, green: 0.25, blue: 0.45, alpha: 1) // abyssal blue
        case .sharkSwarm:       SKColor(red: 0.55, green: 0.65, blue: 0.75, alpha: 1) // shark grey-blue
        case .turtleTank:       SKColor(red: 0.20, green: 0.45, blue: 0.30, alpha: 1) // deep green
        case .stormCaster:      SKColor(red: 0.30, green: 0.55, blue: 0.85, alpha: 1) // storm blue
        case .flyingFish:       SKColor(red: 0.60, green: 0.88, blue: 0.95, alpha: 1) // bright aqua
        case .ghostShip:        SKColor(red: 0.80, green: 0.88, blue: 0.92, alpha: 1) // pale misty blue
        case .tidalLord:        SKColor(red: 0.05, green: 0.35, blue: 0.65, alpha: 1) // deep ocean blue
        case .kraken:           SKColor(red: 0.10, green: 0.15, blue: 0.40, alpha: 1) // midnight blue
        // Space
        case .alienDrone:       SKColor(red: 0.45, green: 0.85, blue: 0.55, alpha: 1) // alien green
        case .mechSoldier:      SKColor(red: 0.50, green: 0.55, blue: 0.65, alpha: 1) // metallic grey
        case .speedster:        SKColor(red: 0.65, green: 0.30, blue: 0.90, alpha: 1) // vivid purple
        case .phaseShifter:     SKColor(red: 0.40, green: 0.75, blue: 0.95, alpha: 1) // phase cyan
        case .plasmaGolem:      SKColor(red: 0.80, green: 0.45, blue: 0.95, alpha: 1) // plasma magenta
        case .hiveMind:         SKColor(red: 0.35, green: 0.60, blue: 0.35, alpha: 1) // hive green
        case .naniteSwarm:      SKColor(red: 0.70, green: 0.70, blue: 0.80, alpha: 1) // pale silver
        case .battleCruiser:    SKColor(red: 0.30, green: 0.35, blue: 0.45, alpha: 1) // dark metallic
        case .voidCaster:       SKColor(red: 0.25, green: 0.10, blue: 0.55, alpha: 1) // void purple
        case .starfighter:      SKColor(red: 0.55, green: 0.85, blue: 0.95, alpha: 1) // bright cyan
        case .darkMatter:       SKColor(red: 0.15, green: 0.10, blue: 0.25, alpha: 1) // dark void
        case .admiralZyx:       SKColor(red: 0.60, green: 0.20, blue: 0.80, alpha: 1) // commander purple
        case .mothershipOmega:  SKColor(red: 0.20, green: 0.20, blue: 0.50, alpha: 1) // deep space indigo
        // Desert
        case .scarab:           SKColor(red: 0.70, green: 0.55, blue: 0.15, alpha: 1) // gold-brown
        case .sandGolem:        SKColor(red: 0.80, green: 0.65, blue: 0.35, alpha: 1) // sand gold
        case .dustDevil:        SKColor(red: 0.85, green: 0.78, blue: 0.55, alpha: 1) // pale dust
        case .mirage:           SKColor(red: 0.90, green: 0.85, blue: 0.65, alpha: 1) // shimmering sand
        case .sandWorm:         SKColor(red: 0.60, green: 0.42, blue: 0.18, alpha: 1) // earthy brown
        case .mummy:            SKColor(red: 0.82, green: 0.75, blue: 0.55, alpha: 1) // linen beige
        case .scorpionPack:     SKColor(red: 0.50, green: 0.35, blue: 0.10, alpha: 1) // dark amber
        case .siegeElephant:    SKColor(red: 0.55, green: 0.48, blue: 0.35, alpha: 1) // stone grey-brown
        case .sandSorcerer:     SKColor(red: 0.90, green: 0.70, blue: 0.20, alpha: 1) // bright gold
        case .desertHawk:       SKColor(red: 0.75, green: 0.55, blue: 0.25, alpha: 1) // tawny gold
        case .sphinxWraith:     SKColor(red: 0.88, green: 0.82, blue: 0.62, alpha: 1) // pale sandstone
        case .pharaohKing:      SKColor(red: 0.85, green: 0.65, blue: 0.10, alpha: 1) // royal gold
        case .ancientColossus:  SKColor(red: 0.65, green: 0.50, blue: 0.25, alpha: 1) // ancient stone
        // Sky
        case .cloudWisp:        SKColor(red: 0.88, green: 0.92, blue: 0.98, alpha: 1) // soft cloud white
        case .stormKnight:      SKColor(red: 0.55, green: 0.65, blue: 0.80, alpha: 1) // steel sky blue
        case .windSprite:       SKColor(red: 0.70, green: 0.90, blue: 0.95, alpha: 1) // pale sky blue
        case .fogPhantom:       SKColor(red: 0.80, green: 0.85, blue: 0.88, alpha: 1) // foggy grey-white
        case .thunderBeast:     SKColor(red: 0.55, green: 0.55, blue: 0.85, alpha: 1) // electric blue
        case .cloudWeaver:      SKColor(red: 0.75, green: 0.88, blue: 0.98, alpha: 1) // light cloud blue
        case .featherSwarm:     SKColor(red: 0.92, green: 0.90, blue: 0.85, alpha: 1) // off-white
        case .skyFortress:      SKColor(red: 0.60, green: 0.68, blue: 0.78, alpha: 1) // slate blue
        case .galeWizard:       SKColor(red: 0.50, green: 0.78, blue: 0.90, alpha: 1) // gale cyan
        case .stormEagle:       SKColor(red: 0.45, green: 0.58, blue: 0.75, alpha: 1) // storm blue
        case .voidZephyr:       SKColor(red: 0.82, green: 0.85, blue: 0.95, alpha: 1) // silver-white
        case .skylordAres:      SKColor(red: 0.40, green: 0.50, blue: 0.80, alpha: 1) // deep sky blue
        case .thunderDragon:    SKColor(red: 0.65, green: 0.70, blue: 0.95, alpha: 1) // lightning blue
        }
    }
}
