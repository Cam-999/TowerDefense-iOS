import SwiftUI
import SpriteKit

extension Color {
    static let tdBackground    = Color(hex: 0x2B1D0E)  // Dark brown wood
    static let tdSurface       = Color(hex: 0x1A1208)  // Very dark wood
    static let tdElevated      = Color(hex: 0x3D2B14)  // Medium dark wood
    static let tdPath          = Color(hex: 0x8B7355)  // Cobblestone
    static let tdAccentBlue    = Color(hex: 0x8B6914)  // Gold leaf (primary)
    static let tdAccentTeal    = Color(hex: 0x4A90A4)  // Holy water blue
    static let tdAccentPurple  = Color(hex: 0x6B2FA0)  // Wizard purple
    static let tdAccentAmber   = Color(hex: 0xD4A017)  // Gold coin
    static let tdDanger        = Color(hex: 0x8B0000)  // Blood red
    static let tdTextPrimary   = Color(hex: 0xF5E6C8)  // Parchment
    static let tdTextSecondary = Color(hex: 0x9B8B6B)  // Aged text

    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8)  & 0xFF) / 255
        let b = Double( hex        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

extension SKColor {
    static let tdBackground    = SKColor(hex: 0x2B1D0E)
    static let tdSurface       = SKColor(hex: 0x1A1208)
    static let tdElevated      = SKColor(hex: 0x3D2B14)
    static let tdPath          = SKColor(hex: 0x8B7355)
    static let tdGrass         = SKColor(hex: 0x2D5A1E)
    static let tdGrassLight    = SKColor(hex: 0x4A8232)
    static let tdGrassDark     = SKColor(hex: 0x1A3D10)
    static let tdDirt          = SKColor(hex: 0x8B7355)
    static let tdDirtDark      = SKColor(hex: 0x5C4A32)
    static let tdStone         = SKColor(hex: 0x7A7A7A)
    static let tdStoneDark     = SKColor(hex: 0x4A4A4A)
    static let tdIron          = SKColor(hex: 0x5A5A5A)
    static let tdAccentBlue    = SKColor(hex: 0x8B6914)
    static let tdAccentTeal    = SKColor(hex: 0x4A90A4)
    static let tdAccentPurple  = SKColor(hex: 0x6B2FA0)
    static let tdAccentAmber   = SKColor(hex: 0xD4A017)
    static let tdDanger        = SKColor(hex: 0x8B0000)
    static let tdTextPrimary   = SKColor(hex: 0xF5E6C8)
    static let tdTextSecondary = SKColor(hex: 0x9B8B6B)

    convenience init(hex: UInt32) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8)  & 0xFF) / 255
        let b = CGFloat( hex        & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
