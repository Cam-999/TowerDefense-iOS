import SpriteKit

/// A poison zone left by alchemist projectiles that damages enemies inside it over time.
final class PoisonZoneNode: SKNode {
    let damagePerTick: CGFloat
    let tickInterval: TimeInterval = 0.5
    let totalDuration: TimeInterval = 4.0
    let radius: CGFloat

    private var elapsed: TimeInterval = 0
    private var tickTimer: TimeInterval = 0
    var isExpired = false

    init(at point: CGPoint, damage: CGFloat, radius: CGFloat) {
        self.damagePerTick = damage
        self.radius = radius
        super.init()
        self.position = point

        // Green poison circle
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor   = SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 0.25)
        circle.strokeColor = SKColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 0.5)
        circle.lineWidth   = 1.5
        addChild(circle)

        // Fade in
        circle.alpha = 0
        circle.run(.fadeAlpha(to: 1.0, duration: 0.2))
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(deltaTime: TimeInterval, enemies: [EnemyNode], onHit: (EnemyNode, CGFloat) -> Void) {
        elapsed += deltaTime
        tickTimer += deltaTime

        if elapsed >= totalDuration {
            isExpired = true
            run(.sequence([.fadeOut(withDuration: 0.3), .removeFromParent()]))
            return
        }

        if tickTimer >= tickInterval {
            tickTimer -= tickInterval
            // Damage all enemies inside radius
            for enemy in enemies {
                guard !enemy.isDead, enemy.parent != nil else { continue }
                if position.distance(to: enemy.position) <= radius {
                    onHit(enemy, damagePerTick)
                    enemy.applyHitEffect(from: .alchemist)
                }
            }
        }
    }
}
