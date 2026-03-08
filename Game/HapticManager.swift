import UIKit

enum HapticManager {
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private static let notification = UINotificationFeedbackGenerator()

    static func towerPlaced() {
        mediumImpact.impactOccurred()
    }

    static func towerSelected() {
        lightImpact.impactOccurred(intensity: 0.6)
    }

    static func towerUpgraded() {
        mediumImpact.impactOccurred(intensity: 0.8)
    }

    static func towerSold() {
        lightImpact.impactOccurred(intensity: 0.4)
    }

    static func waveStarted() {
        heavyImpact.impactOccurred()
    }

    static func lifeLost() {
        notification.notificationOccurred(.warning)
    }

    static func gameOver() {
        notification.notificationOccurred(.error)
    }
}
