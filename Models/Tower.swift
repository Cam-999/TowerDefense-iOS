import Foundation
import SpriteKit
import SwiftUI

enum TowerType: String, CaseIterable, Identifiable {
    // Forest (original 8)
    case alchemist
    case archer
    case wizard
    case catapult
    case ballista
    case moat
    case blacksmith
    case bellTower

    // Ocean (8)
    case harpoonGun
    case depthCharge
    case coralMage
    case pearlShrine
    case toxicReef
    case fogHorn
    case tridentTower
    case whirlpool

    // Space (8)
    case laserTurret
    case missilePod
    case plasmaBeam
    case shieldGen
    case acidSprayer
    case commsArray
    case railgun
    case gravityWell

    // Desert (8)
    case spearThrower
    case boulderSling
    case sunMirror
    case obelisk
    case venomPit
    case warDrum
    case scorpionBow
    case quicksand

    // Sky (8)
    case windCannon
    case thunderCloud
    case lightningRod
    case skyShrine
    case stormBrew
    case windChime
    case galeForce
    case cloudTrap

    var id: String { rawValue }

    // MARK: - Map

    var map: MapType {
        switch self {
        case .alchemist, .archer, .wizard, .catapult, .ballista, .moat, .blacksmith, .bellTower:
            return .forest
        case .harpoonGun, .depthCharge, .coralMage, .pearlShrine, .toxicReef, .fogHorn, .tridentTower, .whirlpool:
            return .ocean
        case .laserTurret, .missilePod, .plasmaBeam, .shieldGen, .acidSprayer, .commsArray, .railgun, .gravityWell:
            return .space
        case .spearThrower, .boulderSling, .sunMirror, .obelisk, .venomPit, .warDrum, .scorpionBow, .quicksand:
            return .desert
        case .windCannon, .thunderCloud, .lightningRod, .skyShrine, .stormBrew, .windChime, .galeForce, .cloudTrap:
            return .sky
        }
    }

    // MARK: - Display Name

    var displayName: String {
        switch self {
        // Forest
        case .archer:        "Archer"
        case .catapult:      "Catapult"
        case .wizard:        "Wizard"
        case .blacksmith:    "Blacksmith"
        case .alchemist:     "Alchemist"
        case .bellTower:     "Bell Tower"
        case .ballista:      "Ballista"
        case .moat:          "Moat"
        // Ocean
        case .harpoonGun:    "Harpoon Gun"
        case .depthCharge:   "Depth Charge"
        case .coralMage:     "Coral Mage"
        case .pearlShrine:   "Pearl Shrine"
        case .toxicReef:     "Toxic Reef"
        case .fogHorn:       "Fog Horn"
        case .tridentTower:  "Trident Tower"
        case .whirlpool:     "Whirlpool"
        // Space
        case .laserTurret:   "Laser Turret"
        case .missilePod:    "Missile Pod"
        case .plasmaBeam:    "Plasma Beam"
        case .shieldGen:     "Shield Gen"
        case .acidSprayer:   "Acid Sprayer"
        case .commsArray:    "Comms Array"
        case .railgun:       "Railgun"
        case .gravityWell:   "Gravity Well"
        // Desert
        case .spearThrower:  "Spear Thrower"
        case .boulderSling:  "Boulder Sling"
        case .sunMirror:     "Sun Mirror"
        case .obelisk:       "Obelisk"
        case .venomPit:      "Venom Pit"
        case .warDrum:       "War Drum"
        case .scorpionBow:   "Scorpion Bow"
        case .quicksand:     "Quicksand"
        // Sky
        case .windCannon:    "Wind Cannon"
        case .thunderCloud:  "Thunder Cloud"
        case .lightningRod:  "Lightning Rod"
        case .skyShrine:     "Sky Shrine"
        case .stormBrew:     "Storm Brew"
        case .windChime:     "Wind Chime"
        case .galeForce:     "Gale Force"
        case .cloudTrap:     "Cloud Trap"
        }
    }

    // MARK: - Icon (SF Symbols)

    var icon: String {
        switch self {
        // Forest
        case .archer:        "arrow.up.right"
        case .catapult:      "circle.grid.cross.fill"
        case .wizard:        "wand.and.stars"
        case .blacksmith:    "hammer.fill"
        case .alchemist:     "flask.fill"
        case .bellTower:     "bell.fill"
        case .ballista:      "arrow.up.forward"
        case .moat:          "drop.fill"
        // Ocean
        case .harpoonGun:    "arrow.up.right.circle.fill"
        case .depthCharge:   "circle.hexagongrid.fill"
        case .coralMage:     "wand.and.rays"
        case .pearlShrine:   "star.circle.fill"
        case .toxicReef:     "allergens"
        case .fogHorn:       "megaphone.fill"
        case .tridentTower:  "fork.knife.circle.fill"
        case .whirlpool:     "arrow.2.circlepath"
        // Space
        case .laserTurret:   "laser.burst"
        case .missilePod:    "rocket.fill"
        case .plasmaBeam:    "rays"
        case .shieldGen:     "shield.fill"
        case .acidSprayer:   "aqi.medium"
        case .commsArray:    "antenna.radiowaves.left.and.right"
        case .railgun:       "bolt.horizontal.fill"
        case .gravityWell:   "circlebadge.fill"
        // Desert
        case .spearThrower:  "arrow.up.circle.fill"
        case .boulderSling:  "circle.fill"
        case .sunMirror:     "sun.max.fill"
        case .obelisk:       "triangle.fill"
        case .venomPit:      "drop.triangle.fill"
        case .warDrum:       "waveform.circle.fill"
        case .scorpionBow:   "arrow.up.backward.circle.fill"
        case .quicksand:     "square.fill.on.square.fill"
        // Sky
        case .windCannon:    "wind"
        case .thunderCloud:  "cloud.bolt.fill"
        case .lightningRod:  "bolt.fill"
        case .skyShrine:     "cloud.sun.fill"
        case .stormBrew:     "cloud.rain.fill"
        case .windChime:     "music.note"
        case .galeForce:     "tornado"
        case .cloudTrap:     "cloud.fill"
        }
    }

    // MARK: - Icon Color

    var iconColor: Color {
        switch self {
        // Forest
        case .archer:        Color(hex: 0x7B1D1D)
        case .catapult:      Color(hex: 0x6B4226)
        case .wizard:        Color(hex: 0x6B2FA0)
        case .blacksmith:    Color(hex: 0x8B4513)
        case .alchemist:     Color(hex: 0x2E8B57)
        case .bellTower:     Color(hex: 0x7B1D1D)
        case .ballista:      Color(hex: 0x5A5A5A)
        case .moat:          Color(hex: 0x4A90A4)
        // Ocean
        case .harpoonGun:    Color(hex: 0x1A6B8A)
        case .depthCharge:   Color(hex: 0x0D4F6E)
        case .coralMage:     Color(hex: 0x2E7DAF)
        case .pearlShrine:   Color(hex: 0x4E9EC0)
        case .toxicReef:     Color(hex: 0x1F7A4A)
        case .fogHorn:       Color(hex: 0x3A7090)
        case .tridentTower:  Color(hex: 0x0A3D5C)
        case .whirlpool:     Color(hex: 0x1B6CA8)
        // Space
        case .laserTurret:   Color(hex: 0xC0392B)
        case .missilePod:    Color(hex: 0x8E44AD)
        case .plasmaBeam:    Color(hex: 0x2980B9)
        case .shieldGen:     Color(hex: 0x27AE60)
        case .acidSprayer:   Color(hex: 0x16A085)
        case .commsArray:    Color(hex: 0xD35400)
        case .railgun:       Color(hex: 0x7F8C8D)
        case .gravityWell:   Color(hex: 0x6C3483)
        // Desert
        case .spearThrower:  Color(hex: 0xC8860A)
        case .boulderSling:  Color(hex: 0xA0522D)
        case .sunMirror:     Color(hex: 0xF39C12)
        case .obelisk:       Color(hex: 0xB7860B)
        case .venomPit:      Color(hex: 0x6B8E23)
        case .warDrum:       Color(hex: 0xCD5C5C)
        case .scorpionBow:   Color(hex: 0x8B6914)
        case .quicksand:     Color(hex: 0xC2A04A)
        // Sky
        case .windCannon:    Color(hex: 0x87CEEB)
        case .thunderCloud:  Color(hex: 0x4A4A8A)
        case .lightningRod:  Color(hex: 0xFFD700)
        case .skyShrine:     Color(hex: 0x87CEFA)
        case .stormBrew:     Color(hex: 0x5B8FA8)
        case .windChime:     Color(hex: 0xB0C4DE)
        case .galeForce:     Color(hex: 0x4682B4)
        case .cloudTrap:     Color(hex: 0xADD8E6)
        }
    }

    // MARK: - Base Damage

    var baseDamage: CGFloat {
        switch self {
        // Forest
        case .archer:        25
        case .catapult:      90
        case .wizard:        50
        case .blacksmith:    0
        case .alchemist:     8
        case .bellTower:     0
        case .ballista:      100
        case .moat:          5
        // Ocean
        case .harpoonGun:    28
        case .depthCharge:   85
        case .coralMage:     52
        case .pearlShrine:   0
        case .toxicReef:     9
        case .fogHorn:       0
        case .tridentTower:  105
        case .whirlpool:     5
        // Space
        case .laserTurret:   24
        case .missilePod:    88
        case .plasmaBeam:    48
        case .shieldGen:     0
        case .acidSprayer:   10
        case .commsArray:    0
        case .railgun:       110
        case .gravityWell:   5
        // Desert
        case .spearThrower:  26
        case .boulderSling:  92
        case .sunMirror:     50
        case .obelisk:       0
        case .venomPit:      8
        case .warDrum:       0
        case .scorpionBow:   100
        case .quicksand:     5
        // Sky
        case .windCannon:    24
        case .thunderCloud:  87
        case .lightningRod:  55
        case .skyShrine:     0
        case .stormBrew:     9
        case .windChime:     0
        case .galeForce:     102
        case .cloudTrap:     5
        }
    }

    // MARK: - Fire Rate (seconds between shots)

    var fireRate: TimeInterval {
        switch self {
        // Forest
        case .archer:        0.7
        case .catapult:      2.5
        case .wizard:        1.2
        case .blacksmith:    0
        case .alchemist:     1.8
        case .bellTower:     0
        case .ballista:      2.2
        case .moat:          3.0
        // Ocean
        case .harpoonGun:    0.7
        case .depthCharge:   2.4
        case .coralMage:     1.2
        case .pearlShrine:   0
        case .toxicReef:     1.8
        case .fogHorn:       0
        case .tridentTower:  2.2
        case .whirlpool:     3.0
        // Space
        case .laserTurret:   0.65
        case .missilePod:    2.5
        case .plasmaBeam:    1.1
        case .shieldGen:     0
        case .acidSprayer:   1.7
        case .commsArray:    0
        case .railgun:       2.3
        case .gravityWell:   3.0
        // Desert
        case .spearThrower:  0.7
        case .boulderSling:  2.5
        case .sunMirror:     1.2
        case .obelisk:       0
        case .venomPit:      1.8
        case .warDrum:       0
        case .scorpionBow:   2.2
        case .quicksand:     3.0
        // Sky
        case .windCannon:    0.68
        case .thunderCloud:  2.4
        case .lightningRod:  1.25
        case .skyShrine:     0
        case .stormBrew:     1.8
        case .windChime:     0
        case .galeForce:     2.2
        case .cloudTrap:     3.0
        }
    }

    // MARK: - Range

    var range: CGFloat {
        switch self {
        // Forest
        case .archer:        120
        case .catapult:      140
        case .wizard:        100
        case .blacksmith:    90
        case .alchemist:     90
        case .bellTower:     100
        case .ballista:      160
        case .moat:          70
        // Ocean
        case .harpoonGun:    115
        case .depthCharge:   135
        case .coralMage:     100
        case .pearlShrine:   90
        case .toxicReef:     85
        case .fogHorn:       100
        case .tridentTower:  155
        case .whirlpool:     70
        // Space
        case .laserTurret:   125
        case .missilePod:    140
        case .plasmaBeam:    105
        case .shieldGen:     95
        case .acidSprayer:   85
        case .commsArray:    105
        case .railgun:       165
        case .gravityWell:   70
        // Desert
        case .spearThrower:  120
        case .boulderSling:  138
        case .sunMirror:     100
        case .obelisk:       90
        case .venomPit:      90
        case .warDrum:       100
        case .scorpionBow:   160
        case .quicksand:     70
        // Sky
        case .windCannon:    122
        case .thunderCloud:  140
        case .lightningRod:  98
        case .skyShrine:     92
        case .stormBrew:     88
        case .windChime:     100
        case .galeForce:     158
        case .cloudTrap:     70
        }
    }

    // MARK: - Cost

    var cost: Int {
        switch self {
        // Forest
        case .archer:        100
        case .catapult:      150
        case .wizard:        130
        case .blacksmith:    120
        case .alchemist:     80
        case .bellTower:     160
        case .ballista:      180
        case .moat:          90
        // Ocean
        case .harpoonGun:    100
        case .depthCharge:   150
        case .coralMage:     130
        case .pearlShrine:   120
        case .toxicReef:     80
        case .fogHorn:       160
        case .tridentTower:  180
        case .whirlpool:     90
        // Space
        case .laserTurret:   100
        case .missilePod:    150
        case .plasmaBeam:    130
        case .shieldGen:     120
        case .acidSprayer:   80
        case .commsArray:    160
        case .railgun:       180
        case .gravityWell:   90
        // Desert
        case .spearThrower:  100
        case .boulderSling:  150
        case .sunMirror:     130
        case .obelisk:       120
        case .venomPit:      80
        case .warDrum:       160
        case .scorpionBow:   180
        case .quicksand:     90
        // Sky
        case .windCannon:    100
        case .thunderCloud:  150
        case .lightningRod:  130
        case .skyShrine:     120
        case .stormBrew:     80
        case .windChime:     160
        case .galeForce:     180
        case .cloudTrap:     90
        }
    }

    // MARK: - SKColor

    var color: SKColor {
        switch self {
        // Forest
        case .archer:        SKColor(red: 0.482, green: 0.114, blue: 0.114, alpha: 1) // 0x7B1D1D
        case .catapult:      SKColor(red: 0.420, green: 0.259, blue: 0.149, alpha: 1) // 0x6B4226
        case .wizard:        SKColor(red: 0.420, green: 0.184, blue: 0.627, alpha: 1) // 0x6B2FA0
        case .blacksmith:    SKColor(red: 0.545, green: 0.271, blue: 0.075, alpha: 1) // 0x8B4513
        case .alchemist:     SKColor(red: 0.180, green: 0.545, blue: 0.341, alpha: 1) // 0x2E8B57
        case .bellTower:     SKColor(red: 0.482, green: 0.114, blue: 0.114, alpha: 1) // 0x7B1D1D
        case .ballista:      SKColor(red: 0.353, green: 0.353, blue: 0.353, alpha: 1) // 0x5A5A5A
        case .moat:          SKColor(red: 0.290, green: 0.565, blue: 0.643, alpha: 1) // 0x4A90A4
        // Ocean
        case .harpoonGun:    SKColor(red: 0.102, green: 0.420, blue: 0.541, alpha: 1) // 0x1A6B8A
        case .depthCharge:   SKColor(red: 0.051, green: 0.310, blue: 0.431, alpha: 1) // 0x0D4F6E
        case .coralMage:     SKColor(red: 0.180, green: 0.490, blue: 0.686, alpha: 1) // 0x2E7DAF
        case .pearlShrine:   SKColor(red: 0.306, green: 0.620, blue: 0.753, alpha: 1) // 0x4E9EC0
        case .toxicReef:     SKColor(red: 0.122, green: 0.478, blue: 0.290, alpha: 1) // 0x1F7A4A
        case .fogHorn:       SKColor(red: 0.227, green: 0.439, blue: 0.565, alpha: 1) // 0x3A7090
        case .tridentTower:  SKColor(red: 0.039, green: 0.239, blue: 0.361, alpha: 1) // 0x0A3D5C
        case .whirlpool:     SKColor(red: 0.106, green: 0.424, blue: 0.659, alpha: 1) // 0x1B6CA8
        // Space
        case .laserTurret:   SKColor(red: 0.753, green: 0.224, blue: 0.169, alpha: 1) // 0xC0392B
        case .missilePod:    SKColor(red: 0.557, green: 0.267, blue: 0.678, alpha: 1) // 0x8E44AD
        case .plasmaBeam:    SKColor(red: 0.161, green: 0.502, blue: 0.725, alpha: 1) // 0x2980B9
        case .shieldGen:     SKColor(red: 0.153, green: 0.682, blue: 0.376, alpha: 1) // 0x27AE60
        case .acidSprayer:   SKColor(red: 0.086, green: 0.627, blue: 0.522, alpha: 1) // 0x16A085
        case .commsArray:    SKColor(red: 0.827, green: 0.329, blue: 0.000, alpha: 1) // 0xD35400
        case .railgun:       SKColor(red: 0.498, green: 0.549, blue: 0.553, alpha: 1) // 0x7F8C8D
        case .gravityWell:   SKColor(red: 0.424, green: 0.204, blue: 0.514, alpha: 1) // 0x6C3483
        // Desert
        case .spearThrower:  SKColor(red: 0.784, green: 0.525, blue: 0.039, alpha: 1) // 0xC8860A
        case .boulderSling:  SKColor(red: 0.627, green: 0.322, blue: 0.176, alpha: 1) // 0xA0522D
        case .sunMirror:     SKColor(red: 0.953, green: 0.612, blue: 0.071, alpha: 1) // 0xF39C12
        case .obelisk:       SKColor(red: 0.718, green: 0.525, blue: 0.043, alpha: 1) // 0xB7860B
        case .venomPit:      SKColor(red: 0.420, green: 0.557, blue: 0.137, alpha: 1) // 0x6B8E23
        case .warDrum:       SKColor(red: 0.804, green: 0.361, blue: 0.361, alpha: 1) // 0xCD5C5C
        case .scorpionBow:   SKColor(red: 0.545, green: 0.412, blue: 0.078, alpha: 1) // 0x8B6914
        case .quicksand:     SKColor(red: 0.761, green: 0.627, blue: 0.290, alpha: 1) // 0xC2A04A
        // Sky
        case .windCannon:    SKColor(red: 0.529, green: 0.808, blue: 0.922, alpha: 1) // 0x87CEEB
        case .thunderCloud:  SKColor(red: 0.290, green: 0.290, blue: 0.541, alpha: 1) // 0x4A4A8A
        case .lightningRod:  SKColor(red: 1.000, green: 0.843, blue: 0.000, alpha: 1) // 0xFFD700
        case .skyShrine:     SKColor(red: 0.529, green: 0.808, blue: 0.980, alpha: 1) // 0x87CEFA
        case .stormBrew:     SKColor(red: 0.357, green: 0.561, blue: 0.659, alpha: 1) // 0x5B8FA8
        case .windChime:     SKColor(red: 0.690, green: 0.769, blue: 0.871, alpha: 1) // 0xB0C4DE
        case .galeForce:     SKColor(red: 0.275, green: 0.510, blue: 0.706, alpha: 1) // 0x4682B4
        case .cloudTrap:     SKColor(red: 0.678, green: 0.847, blue: 0.902, alpha: 1) // 0xADD8E6
        }
    }

    // MARK: - Armor Ignore

    /// Does this tower ignore armor?
    var ignoresArmor: Bool {
        switch self {
        case .wizard, .coralMage, .plasmaBeam, .sunMirror, .lightningRod: return true
        default: return false
        }
    }

    // MARK: - Splash Radius

    /// AoE splash radius (0 = no splash)
    var splashRadius: CGFloat {
        switch self {
        // AoE towers — 55
        case .catapult, .depthCharge, .missilePod, .boulderSling, .thunderCloud: return 55
        // Poison towers — 35
        case .alchemist, .toxicReef, .acidSprayer, .venomPit, .stormBrew:       return 35
        default: return 0
        }
    }

    // MARK: - Chain Count

    /// Number of chain targets (unused in current version)
    var chainCount: Int { 0 }

    // MARK: - Slow

    /// Slow factor applied by path-control towers (1.0 = no slow)
    var slowFactor: CGFloat {
        switch self {
        case .moat, .whirlpool, .gravityWell, .quicksand, .cloudTrap: return 0.35
        default: return 1.0
        }
    }

    var slowDuration: TimeInterval {
        switch self {
        case .moat, .whirlpool, .gravityWell, .quicksand, .cloudTrap: return 3.0
        default: return 0
        }
    }

    // MARK: - Support

    /// Whether this tower is a support tower (doesn't shoot)
    var isSupport: Bool {
        switch self {
        case .blacksmith, .bellTower,
             .pearlShrine, .fogHorn,
             .shieldGen, .commsArray,
             .obelisk, .warDrum,
             .skyShrine, .windChime:
            return true
        default:
            return false
        }
    }

    // MARK: - Places On Path

    /// Whether this tower is placed on the path (not on empty ground)
    var placesOnPath: Bool {
        switch self {
        case .moat, .whirlpool, .gravityWell, .quicksand, .cloudTrap: return true
        default: return false
        }
    }

    // MARK: - Aura Multipliers

    /// Damage multiplier applied to towers in aura range
    var auraDamageMult: CGFloat {
        switch self {
        // Support-Dmg towers (1.30)
        case .blacksmith, .pearlShrine, .shieldGen, .obelisk, .skyShrine:
            return 1.30
        // Support-Buff towers (1.20)
        case .bellTower, .fogHorn, .commsArray, .warDrum, .windChime:
            return 1.20
        default:
            return 1.0
        }
    }

    /// Fire rate multiplier applied to towers in aura range (lower = faster)
    var auraFireRateMult: CGFloat {
        switch self {
        case .bellTower, .fogHorn, .commsArray, .warDrum, .windChime:
            return 0.85
        default:
            return 1.0
        }
    }

    // MARK: - Can Target Flying

    /// Whether this tower can target flying enemies
    var canTargetFlying: Bool {
        switch self {
        // Forest
        case .archer, .wizard, .bellTower:
            return true
        // Ocean — Fast, Magic, Support-Buff
        case .harpoonGun, .coralMage, .fogHorn:
            return true
        // Space — Fast, Magic, Support-Buff
        case .laserTurret, .plasmaBeam, .commsArray:
            return true
        // Desert — Fast, Magic, Support-Buff
        case .spearThrower, .sunMirror, .warDrum:
            return true
        // Sky — Fast, Magic, Support-Buff
        case .windCannon, .lightningRod, .windChime:
            return true
        default:
            return false
        }
    }

    // MARK: - Subtitle

    /// Short description for the palette
    var subtitle: String {
        switch self {
        // Forest
        case .archer:        "Fast"
        case .catapult:      "AoE"
        case .wizard:        "Magic"
        case .blacksmith:    "Forge"
        case .alchemist:     "Poison"
        case .bellTower:     "Buff"
        case .ballista:      "Pierce"
        case .moat:          "Slow"
        // Ocean
        case .harpoonGun:    "Fast"
        case .depthCharge:   "AoE"
        case .coralMage:     "Magic"
        case .pearlShrine:   "Boost"
        case .toxicReef:     "Poison"
        case .fogHorn:       "Buff"
        case .tridentTower:  "Heavy"
        case .whirlpool:     "Slow"
        // Space
        case .laserTurret:   "Fast"
        case .missilePod:    "AoE"
        case .plasmaBeam:    "Magic"
        case .shieldGen:     "Boost"
        case .acidSprayer:   "Poison"
        case .commsArray:    "Buff"
        case .railgun:       "Heavy"
        case .gravityWell:   "Slow"
        // Desert
        case .spearThrower:  "Fast"
        case .boulderSling:  "AoE"
        case .sunMirror:     "Magic"
        case .obelisk:       "Boost"
        case .venomPit:      "Poison"
        case .warDrum:       "Buff"
        case .scorpionBow:   "Heavy"
        case .quicksand:     "Slow"
        // Sky
        case .windCannon:    "Fast"
        case .thunderCloud:  "AoE"
        case .lightningRod:  "Magic"
        case .skyShrine:     "Boost"
        case .stormBrew:     "Poison"
        case .windChime:     "Buff"
        case .galeForce:     "Heavy"
        case .cloudTrap:     "Slow"
        }
    }
}
