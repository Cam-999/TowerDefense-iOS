import Foundation
import SpriteKit
import SwiftUI

enum TowerType: String, CaseIterable, Identifiable {
    case alchemist, archer, wizard, catapult, ballista, moat, blacksmith, bellTower

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .archer:     "Archer"
        case .catapult:   "Catapult"
        case .wizard:     "Wizard"
        case .blacksmith: "Blacksmith"
        case .alchemist:  "Alchemist"
        case .bellTower:  "Bell Tower"
        case .ballista:   "Ballista"
        case .moat:       "Moat"
        }
    }

    var icon: String {
        switch self {
        case .archer:     "arrow.up.right"
        case .catapult:   "circle.grid.cross.fill"
        case .wizard:     "wand.and.stars"
        case .blacksmith: "hammer.fill"
        case .alchemist:  "flask.fill"
        case .bellTower:  "bell.fill"
        case .ballista:   "arrow.up.forward"
        case .moat:       "drop.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .archer:     Color(hex: 0x7B1D1D)
        case .catapult:   Color(hex: 0x6B4226)
        case .wizard:     Color(hex: 0x6B2FA0)
        case .blacksmith: Color(hex: 0x8B4513)
        case .alchemist:  Color(hex: 0x2E8B57)
        case .bellTower:  Color(hex: 0x7B1D1D)
        case .ballista:   Color(hex: 0x5A5A5A)
        case .moat:       Color(hex: 0x4A90A4)
        }
    }

    var baseDamage: CGFloat {
        switch self {
        case .archer:     25
        case .catapult:   90
        case .wizard:     50
        case .blacksmith: 0
        case .alchemist:  8
        case .bellTower:  0
        case .ballista:   100
        case .moat:       5
        }
    }

    var fireRate: TimeInterval {   // seconds between shots
        switch self {
        case .archer:     0.7
        case .catapult:   2.5
        case .wizard:     1.2
        case .blacksmith: 0
        case .alchemist:  1.8
        case .bellTower:  0
        case .ballista:   2.2
        case .moat:       3.0
        }
    }

    var range: CGFloat {
        switch self {
        case .archer:     120
        case .catapult:   140
        case .wizard:     100
        case .blacksmith: 90
        case .alchemist:  90
        case .bellTower:  100
        case .ballista:   160
        case .moat:       70
        }
    }

    var cost: Int {
        switch self {
        case .archer:     100
        case .catapult:   150
        case .wizard:     130
        case .blacksmith: 120
        case .alchemist:  80
        case .bellTower:  160
        case .ballista:   180
        case .moat:       90
        }
    }

    var color: SKColor {
        switch self {
        case .archer:     SKColor(red: 0.482, green: 0.114, blue: 0.114, alpha: 1) // 0x7B1D1D
        case .catapult:   SKColor(red: 0.420, green: 0.259, blue: 0.149, alpha: 1) // 0x6B4226
        case .wizard:     SKColor(red: 0.420, green: 0.184, blue: 0.627, alpha: 1) // 0x6B2FA0
        case .blacksmith: SKColor(red: 0.545, green: 0.271, blue: 0.075, alpha: 1) // 0x8B4513
        case .alchemist:  SKColor(red: 0.180, green: 0.545, blue: 0.341, alpha: 1) // 0x2E8B57
        case .bellTower:  SKColor(red: 0.482, green: 0.114, blue: 0.114, alpha: 1) // 0x7B1D1D
        case .ballista:   SKColor(red: 0.353, green: 0.353, blue: 0.353, alpha: 1) // 0x5A5A5A
        case .moat:       SKColor(red: 0.290, green: 0.565, blue: 0.643, alpha: 1) // 0x4A90A4
        }
    }

    /// Does this tower ignore armor?
    var ignoresArmor: Bool { self == .wizard }

    /// AoE splash radius (0 = no splash)
    var splashRadius: CGFloat {
        switch self {
        case .catapult:  55
        case .alchemist: 35
        default:         0
        }
    }

    /// Number of chain targets (unused in medieval version)
    var chainCount: Int { 0 }

    /// Slow factor applied by Moat (1.0 = no slow)
    var slowFactor: CGFloat { self == .moat ? 0.35 : 1.0 }
    var slowDuration: TimeInterval { self == .moat ? 3.0 : 0 }

    /// Whether this tower is a support tower (doesn't shoot)
    var isSupport: Bool { self == .bellTower || self == .blacksmith }

    /// Whether this tower is placed on the path (not on empty ground)
    var placesOnPath: Bool { self == .moat }

    /// Damage multiplier applied to towers in aura range
    var auraDamageMult: CGFloat { self == .blacksmith ? 1.30 : self == .bellTower ? 1.20 : 1.0 }

    /// Fire rate multiplier applied to towers in aura range (lower = faster)
    var auraFireRateMult: CGFloat { self == .bellTower ? 0.85 : 1.0 }

    /// Whether this tower can target flying enemies
    var canTargetFlying: Bool {
        switch self {
        case .archer, .wizard, .bellTower: return true
        default: return false
        }
    }

    /// Short description for the palette
    var subtitle: String {
        switch self {
        case .archer:     "Fast"
        case .catapult:   "AoE"
        case .wizard:     "Magic"
        case .blacksmith: "Forge"
        case .alchemist:  "Poison"
        case .bellTower:  "Buff"
        case .ballista:   "Pierce"
        case .moat:       "Slow"
        }
    }
}
