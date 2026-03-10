import SpriteKit

final class ProjectileNode: SKNode {
    let towerType: TowerType
    private weak var target: EnemyNode?
    var trackingSpeed: CGFloat = 250
    var onReachTarget: ((CGPoint) -> Void)?

    // Pierce support (ballista)
    var piercesRemaining: Int = 0
    var pierced: Set<ObjectIdentifier> = []
    var pierceDirection: CGPoint = .zero
    var onPierceHit: ((EnemyNode, CGPoint) -> Void)?
    private var isPiercing = false

    private let sprite: SKNode
    private var arrowSprite: SKSpriteNode?

    init(towerType: TowerType, startPosition: CGPoint, target: EnemyNode) {
        self.towerType = towerType
        self.target    = target

        let node: SKNode
        switch towerType {
        case .archer:
            // Pixel art arrow
            let tex = SKTexture(imageNamed: "ArrowProjectile")
            tex.filteringMode = .nearest
            let arrow = SKSpriteNode(texture: tex)
            arrow.size = CGSize(width: 20, height: 20)
            node = arrow
            self.sprite = arrow
            // Store for rotation — source image points upper-right (~45°)
            self.arrowSprite = arrow
        case .ballista:
            // Thick bolt
            let shape = SKShapeNode(rectOf: CGSize(width: 4, height: 16), cornerRadius: 1)
            shape.fillColor   = SKColor(white: 0.8, alpha: 1)
            shape.strokeColor = .clear
            node = shape
            self.sprite = shape
        case .wizard:
            // Glowing magic orb
            let shape = SKShapeNode(circleOfRadius: 5)
            shape.fillColor   = SKColor(red: 0.6, green: 0.3, blue: 1.0, alpha: 0.9)
            shape.strokeColor = SKColor(white: 1, alpha: 0.5)
            shape.lineWidth   = 1
            node = shape
            self.sprite = shape
        case .catapult:
            // Larger stone
            let shape = SKShapeNode(circleOfRadius: 7)
            shape.fillColor   = SKColor(white: 0.55, alpha: 1)
            shape.strokeColor = .clear
            node = shape
            self.sprite = shape
        case .alchemist:
            // Green potion glob
            let shape = SKShapeNode(circleOfRadius: 5)
            shape.fillColor   = SKColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 0.9)
            shape.strokeColor = .clear
            node = shape
            self.sprite = shape
        case .moat:
            // Water splash
            let shape = SKShapeNode(circleOfRadius: 4)
            shape.fillColor   = SKColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.8)
            shape.strokeColor = .clear
            node = shape
            self.sprite = shape
        default:
            // Generic projectile
            let shape = SKShapeNode(circleOfRadius: 4)
            shape.fillColor   = towerType.color
            shape.strokeColor = .clear
            node = shape
            self.sprite = shape
        }

        super.init()
        position = startPosition
        addChild(node)

        if towerType == .archer { trackingSpeed = 350 }
        if towerType == .ballista { trackingSpeed = 300 }
    }

    required init?(coder: NSCoder) { fatalError() }

    func prepareForReuse(startPosition: CGPoint, target: EnemyNode) {
        self.target = target
        self.position = startPosition
        self.piercesRemaining = 0
        self.pierced.removeAll(keepingCapacity: true)
        self.pierceDirection = .zero
        self.isPiercing = false
        self.onReachTarget = nil
        self.onPierceHit = nil
        self.alpha = 1
        self.isHidden = false
        if towerType == .archer { trackingSpeed = 350 }
        else if towerType == .ballista { trackingSpeed = 300 }
        else { trackingSpeed = 250 }
    }

    func update(deltaTime: TimeInterval) {
        // Pierce mode — continue in straight line
        if isPiercing {
            updatePierce(deltaTime: deltaTime)
            return
        }

        guard let target, !target.isDead, target.parent != nil else {
            onReachTarget?(position)
            onReachTarget = nil
            onPierceHit = nil
            return
        }
        let dest = target.position
        let diff = dest - position
        let dist = diff.length
        let step = trackingSpeed * CGFloat(deltaTime)

        if dist <= step {
            // First hit
            pierceDirection = diff.normalized()
            pierced.insert(ObjectIdentifier(target))
            onReachTarget?(dest)
            onReachTarget = nil
            // If pierces remain, switch to pierce mode instead of removing
            if piercesRemaining > 0 {
                isPiercing = true
                position = dest
            } else {
                onPierceHit = nil
            }
        } else {
            let dir = diff.normalized()
            position = position + dir * step

            // Rotate sprite toward movement direction
            let angle = atan2(diff.y, diff.x)
            if arrowSprite != nil {
                // Source image points upper-right (~45°), offset accordingly
                sprite.zRotation = angle - .pi / 4
            } else {
                sprite.zRotation = angle - .pi / 2
            }
        }
    }

    private func updatePierce(deltaTime: TimeInterval) {
        guard piercesRemaining > 0 else {
            ProjectileSystem.release(self)
            return
        }
        let step = trackingSpeed * CGFloat(deltaTime)
        position = position + pierceDirection * step

        // Remove if off-screen
        guard let scene = self.scene else {
            ProjectileSystem.release(self)
            return
        }
        if position.x < -20 || position.x > scene.size.width + 20 ||
           position.y < -20 || position.y > scene.size.height + 20 {
            ProjectileSystem.release(self)
        }
    }

    /// Check if this piercing projectile hits an enemy (called from GameScene update)
    func checkPierceHit(against enemies: [EnemyNode], hitRadius: CGFloat = 15) {
        guard isPiercing, piercesRemaining > 0 else { return }
        let hitRadiusSq = hitRadius * hitRadius
        for enemy in enemies {
            guard !enemy.isDead, enemy.parent != nil else { continue }
            let eid = ObjectIdentifier(enemy)
            guard !pierced.contains(eid) else { continue }
            if position.distanceSquared(to: enemy.position) <= hitRadiusSq {
                pierced.insert(eid)
                piercesRemaining -= 1
                onPierceHit?(enemy, position)
                if piercesRemaining <= 0 {
                    onPierceHit = nil
                    ProjectileSystem.release(self)
                    return
                }
            }
        }
    }
}
