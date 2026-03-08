import Foundation

enum PhysicsCategories {
    static let none:        UInt32 = 0
    static let enemy:       UInt32 = 0b0001
    static let projectile:  UInt32 = 0b0010
    static let towerRange:  UInt32 = 0b0100
}
