import SpriteKit

final class TowerNode: SKNode {
    let towerType: TowerType
    var effectiveRange: CGFloat
    var effectiveDamage: CGFloat
    var effectiveFireRate: TimeInterval
    var paidCost: Int = 0
    var totalInvested: Int = 0   // purchase + all upgrades
    var gridCoord: GridCoord = GridCoord(col: 0, row: 0)

    // Upgrade state
    private(set) var upgradeLevel: Int = 0  // 0 = base, 1-3 = upgraded
    private(set) var upgradeDamageMult: CGFloat = 1.0
    private(set) var upgradeFireRateMult: CGFloat = 1.0
    private(set) var upgradeRangeMult: CGFloat = 1.0
    var extraChainTargets: Int = 0
    var extraSlowFactor: CGFloat = 0  // added slow strength
    var upgradeSplashMult: CGFloat = 1.0
    var upgradeAuraBonus: CGFloat = 0  // extra aura boost beyond base

    // Support tower buff multipliers (recomputed each frame)
    var supportDamageMult: CGFloat = 1.0
    var supportFireRateMult: CGFloat = 1.0

    private let baseSprite: SKNode
    private let rangeRing: SKShapeNode
    private var auraRing: SKShapeNode?
    private var tierOverlays: [SKNode] = []
    private var towerSprite: SKSpriteNode?

    var lastFireTime: TimeInterval = 0

    init(type: TowerType, gameState: GameState) {
        self.towerType        = type
        self.effectiveRange   = type.range      * CGFloat(gameState.globalRangeMultiplier) * upgradeRangeMult
        self.effectiveDamage  = type.baseDamage * CGFloat(gameState.effectiveDamageMultiplier) * upgradeDamageMult
        self.effectiveFireRate = TowerNode.computeFireRate(type: type, gameState: gameState) * Double(upgradeFireRateMult)

        // Build unique visual per tower type
        let base = TowerNode.buildSprite(for: type)
        self.baseSprite = base

        // Range ring
        let ring = SKShapeNode(circleOfRadius: effectiveRange)
        ring.strokeColor = type.color.withAlphaComponent(0.35)
        ring.lineWidth   = 1
        ring.fillColor   = type.color.withAlphaComponent(0.05)
        ring.isHidden    = true
        self.rangeRing   = ring

        super.init()
        addChild(base)
        addChild(ring)

        // Store sprite reference for towers using pixel art
        if let sprite = base.childNode(withName: "towerSprite") as? SKSpriteNode {
            towerSprite = sprite
        }

        // Support towers get a visible aura ring
        if type.isSupport {
            let aura = SKShapeNode(circleOfRadius: effectiveRange)
            aura.strokeColor = type.color.withAlphaComponent(0.25)
            aura.lineWidth   = 1.5
            aura.fillColor   = type.color.withAlphaComponent(0.04)
            aura.run(.repeatForever(.sequence([
                .scale(to: 1.06, duration: 1.2),
                .scale(to: 0.94, duration: 1.2)
            ])))
            insertChild(aura, at: 0)
            auraRing = aura
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func showRangeRing(_ show: Bool) {
        // Support towers already have a visible aura ring — don't show a second one
        guard !towerType.isSupport else { return }
        rangeRing.isHidden = !show
    }

    func canFire(at currentTime: TimeInterval, speedMultiplier: Double = 1.0) -> Bool {
        guard !towerType.isSupport, !towerType.placesOnPath else { return false }
        let rate = effectiveFireRate * TimeInterval(supportFireRateMult) / speedMultiplier
        return currentTime - lastFireTime >= rate
    }

    func aimAt(target: EnemyNode) {
        // Don't rotate sprite-based towers
        guard towerSprite == nil else { return }
        let angle = position.angle(to: target.position) - (.pi / 2)
        baseSprite.run(.rotate(toAngle: angle, duration: 0.05, shortestUnitArc: true))
    }

    func didFire(at time: TimeInterval) { lastFireTime = time }

    func refreshStats(from gameState: GameState) {
        effectiveRange    = towerType.range * CGFloat(gameState.globalRangeMultiplier) * upgradeRangeMult
        effectiveDamage   = towerType.baseDamage * CGFloat(gameState.effectiveDamageMultiplier) * upgradeDamageMult
        effectiveFireRate = TowerNode.computeFireRate(type: towerType, gameState: gameState) * Double(upgradeFireRateMult)
        rangeRing.path    = CGPath(ellipseIn: CGRect(
            x: -effectiveRange, y: -effectiveRange,
            width: effectiveRange * 2, height: effectiveRange * 2
        ), transform: nil)
    }

    // MARK: - Upgrades

    var maxUpgradeLevel: Int { TowerUpgrades.tiers(for: towerType).count }

    var nextUpgrade: TowerUpgrade? {
        let tiers = TowerUpgrades.tiers(for: towerType)
        guard upgradeLevel < tiers.count else { return nil }
        return tiers[upgradeLevel]
    }

    func applyUpgrade(gameState: GameState) {
        guard let upgrade = nextUpgrade else { return }
        upgradeLevel += 1
        totalInvested += upgrade.cost

        // Stack multipliers
        upgradeDamageMult *= upgrade.damageMult
        upgradeFireRateMult *= upgrade.fireRateMult
        upgradeRangeMult *= upgrade.rangeMult

        // Type-specific bonuses
        switch towerType {
        case .moat:
            extraSlowFactor += upgrade.specialBonus
        case .catapult, .alchemist:
            upgradeSplashMult *= upgrade.specialBonus
        case .bellTower, .blacksmith:
            upgradeAuraBonus += upgrade.specialBonus
        default:
            break
        }

        // Recalc stats
        refreshStats(from: gameState)

        // Update aura ring for support towers
        if towerType.isSupport, let aura = auraRing {
            aura.run(.scale(to: effectiveRange / (towerType.range), duration: 0.2))
        }

        updateTierVisuals()
    }

    private func updateTierVisuals() {
        // Clean up any legacy overlays
        tierOverlays.forEach { $0.removeFromParent() }
        tierOverlays.removeAll()
        guard upgradeLevel > 0 else { return }

        // Sprite-based towers: swap texture
        if let sprite = towerSprite {
            let prefix: String
            switch towerType {
            case .archer: prefix = "ArcherTower"
            case .wizard: prefix = "WizardTower"
            default:      prefix = ""
            }
            guard !prefix.isEmpty else { return }
            let tex = SKTexture(imageNamed: "\(prefix)\(upgradeLevel)")
            tex.filteringMode = .nearest
            sprite.texture = tex
            return
        }

        guard let body = baseSprite as? SKShapeNode else { return }

        let tierGold = SKColor(red: 0.83, green: 0.63, blue: 0.09, alpha: 1.0)

        // Evolve the body fill color
        body.fillColor = tierColor(base: towerType.color, level: upgradeLevel)

        // Stroke accent by tier
        switch upgradeLevel {
        case 1:
            body.strokeColor = SKColor(white: 1, alpha: 1.0)
            body.lineWidth = 2.0
        case 2:
            body.strokeColor = tierGold
            body.lineWidth = 2.0
        case 3:
            body.strokeColor = tierGold
            body.lineWidth = 2.5
        default:
            break
        }

        // Tier 3: recolor barrel/accent child nodes to gold tint
        if upgradeLevel >= 3 {
            recolorAccents(in: body, accent: tierGold)
        }
    }

    private func tierColor(base: SKColor, level: Int) -> SKColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        base.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

        switch level {
        case 1:
            return SKColor(hue: h, saturation: min(s + 0.08, 1), brightness: min(b + 0.08, 1), alpha: a)
        case 2:
            return SKColor(hue: h, saturation: min(s + 0.12, 1), brightness: min(b + 0.14, 1), alpha: a)
        case 3:
            let goldHue: CGFloat = 0.12
            let blendH = h + (goldHue - h) * 0.08
            return SKColor(hue: blendH, saturation: min(s + 0.05, 1), brightness: min(b + 0.18, 1), alpha: a)
        default:
            return base
        }
    }

    private func recolorAccents(in parent: SKShapeNode, accent: SKColor) {
        let accentLight = SKColor(red: 0.9, green: 0.75, blue: 0.3, alpha: 1.0)
        for child in parent.children {
            guard let shape = child as? SKShapeNode else { continue }
            if shape.fillColor == .clear { continue }
            shape.fillColor = accentLight
        }
    }

    // MARK: - Unique tower shapes

    private static func buildSprite(for type: TowerType) -> SKNode {
        switch type {

        case .archer:
            // Pixel art sprite — tier 0 by default
            let container = SKNode()
            let tex = SKTexture(imageNamed: "ArcherTower0")
            tex.filteringMode = .nearest
            let sprite = SKSpriteNode(texture: tex)
            sprite.size = CGSize(width: 40, height: 48)
            sprite.name = "towerSprite"
            container.addChild(sprite)
            return container

        case .catapult:
            // Wide wood rectangle + angled arm + bucket
            let base = SKShapeNode(rectOf: CGSize(width: 34, height: 22), cornerRadius: 3)
            base.fillColor   = type.color
            base.strokeColor = SKColor(white: 0.7, alpha: 0.8)
            base.lineWidth   = 1.5
            // Arm
            let arm = SKShapeNode(rectOf: CGSize(width: 4, height: 22), cornerRadius: 1)
            arm.fillColor   = SKColor(red: 0.55, green: 0.38, blue: 0.18, alpha: 1)
            arm.strokeColor = .clear
            arm.position    = CGPoint(x: 0, y: 12)
            arm.zRotation   = 0.3
            base.addChild(arm)
            // Bucket
            let bucket = SKShapeNode(rectOf: CGSize(width: 8, height: 6), cornerRadius: 2)
            bucket.fillColor   = SKColor(white: 0.6, alpha: 1)
            bucket.strokeColor = .clear
            bucket.position    = CGPoint(x: -5, y: 22)
            base.addChild(bucket)
            return base

        case .wizard:
            // Pixel art sprite — tier 0 by default
            let container = SKNode()
            let tex = SKTexture(imageNamed: "WizardTower0")
            tex.filteringMode = .nearest
            let sprite = SKSpriteNode(texture: tex)
            sprite.size = CGSize(width: 36, height: 44)
            sprite.name = "towerSprite"
            container.addChild(sprite)
            return container

        case .blacksmith:
            // Diamond/rhombus base (saddle brown) + anvil + forge sparks
            let r: CGFloat = 16
            let diamondPath = CGMutablePath()
            diamondPath.move(to: CGPoint(x: 0, y: r))
            diamondPath.addLine(to: CGPoint(x: r, y: 0))
            diamondPath.addLine(to: CGPoint(x: 0, y: -r))
            diamondPath.addLine(to: CGPoint(x: -r, y: 0))
            diamondPath.closeSubpath()
            let base = SKShapeNode(path: diamondPath)
            base.fillColor   = type.color
            base.strokeColor = SKColor(red: 0.7, green: 0.45, blue: 0.2, alpha: 0.9)
            base.lineWidth   = 2
            // Anvil (dark gray trapezoid)
            let anvilPath = CGMutablePath()
            anvilPath.move(to: CGPoint(x: -6, y: -2))
            anvilPath.addLine(to: CGPoint(x: 6, y: -2))
            anvilPath.addLine(to: CGPoint(x: 8, y: 4))
            anvilPath.addLine(to: CGPoint(x: -8, y: 4))
            anvilPath.closeSubpath()
            let anvil = SKShapeNode(path: anvilPath)
            anvil.fillColor   = SKColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
            anvil.strokeColor = .clear
            anvil.position    = CGPoint(x: 0, y: -1)
            base.addChild(anvil)
            // Forge spark dots
            for i in 0..<3 {
                let spark = SKShapeNode(circleOfRadius: 1.5)
                spark.fillColor   = SKColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 0.9)
                spark.strokeColor = .clear
                spark.position    = CGPoint(x: CGFloat(i - 1) * 5, y: 5)
                spark.run(.repeatForever(.sequence([
                    .moveBy(x: 0, y: 5, duration: 0.4 + Double(i) * 0.15),
                    .fadeOut(withDuration: 0.1),
                    .move(to: CGPoint(x: CGFloat(i - 1) * 5, y: 5), duration: 0),
                    .fadeIn(withDuration: 0.1)
                ])))
                base.addChild(spark)
            }
            return base

        case .alchemist:
            // Hexagon (emerald) + flask shape + bubbling dots
            let r: CGFloat = 16
            let path = CGMutablePath()
            for i in 0...6 {
                let angle = -CGFloat.pi / 2 + CGFloat(i) * (.pi / 3)
                let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
            let base = SKShapeNode(path: path)
            base.fillColor   = type.color
            base.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 0.5, alpha: 0.9)
            base.lineWidth   = 2
            // Flask shape
            let flask = SKShapeNode(rectOf: CGSize(width: 8, height: 12), cornerRadius: 3)
            flask.fillColor   = SKColor(red: 0.4, green: 0.9, blue: 0.5, alpha: 0.7)
            flask.strokeColor = .clear
            flask.position    = CGPoint(x: 0, y: 0)
            base.addChild(flask)
            let neck = SKShapeNode(rectOf: CGSize(width: 3, height: 6))
            neck.fillColor   = SKColor(red: 0.4, green: 0.9, blue: 0.5, alpha: 0.7)
            neck.strokeColor = .clear
            neck.position    = CGPoint(x: 0, y: 9)
            base.addChild(neck)
            // Bubbling dots
            for i in 0..<3 {
                let bubble = SKShapeNode(circleOfRadius: 2)
                bubble.fillColor   = SKColor(red: 0.5, green: 1.0, blue: 0.6, alpha: 0.7)
                bubble.strokeColor = .clear
                bubble.position    = CGPoint(x: CGFloat(i - 1) * 4, y: -2)
                bubble.run(.repeatForever(.sequence([
                    .moveBy(x: 0, y: 6, duration: 0.6 + Double(i) * 0.2),
                    .fadeOut(withDuration: 0.1),
                    .move(to: CGPoint(x: CGFloat(i - 1) * 4, y: -2), duration: 0),
                    .fadeIn(withDuration: 0.1)
                ])))
                base.addChild(bubble)
            }
            return base

        case .bellTower:
            // Tall narrow rectangle (stone) + arch opening + gold bell
            let base = SKShapeNode(rectOf: CGSize(width: 22, height: 32), cornerRadius: 3)
            base.fillColor   = SKColor(red: 0.48, green: 0.48, blue: 0.48, alpha: 1) // stone
            base.strokeColor = SKColor(red: 0.83, green: 0.63, blue: 0.09, alpha: 0.9)
            base.lineWidth   = 2
            // Arch opening
            let arch = SKShapeNode(rectOf: CGSize(width: 12, height: 10), cornerRadius: 5)
            arch.fillColor   = SKColor(white: 0.2, alpha: 0.8)
            arch.strokeColor = .clear
            arch.position    = CGPoint(x: 0, y: 2)
            base.addChild(arch)
            // Gold bell
            let bell = SKShapeNode(circleOfRadius: 5)
            bell.fillColor   = type.color
            bell.strokeColor = SKColor(white: 1, alpha: 0.7)
            bell.lineWidth   = 1
            bell.position    = CGPoint(x: 0, y: 3)
            bell.run(.repeatForever(.sequence([
                .rotate(byAngle: 0.15, duration: 0.3),
                .rotate(byAngle: -0.30, duration: 0.6),
                .rotate(byAngle: 0.15, duration: 0.3)
            ])))
            base.addChild(bell)
            return base

        case .ballista:
            // Circle base (iron) + X-frame crossbow + thick bolt
            let base = SKShapeNode(circleOfRadius: 16)
            base.fillColor   = type.color
            base.strokeColor = SKColor(white: 0.7, alpha: 0.8)
            base.lineWidth   = 1.5
            // X-frame arms
            for angle: CGFloat in [-0.4, 0.4] {
                let arm = SKShapeNode(rectOf: CGSize(width: 3, height: 18), cornerRadius: 1)
                arm.fillColor   = SKColor(red: 0.45, green: 0.35, blue: 0.25, alpha: 1)
                arm.strokeColor = .clear
                arm.position    = CGPoint(x: 0, y: 10)
                arm.zRotation   = angle
                base.addChild(arm)
            }
            // Thick bolt
            let bolt = SKShapeNode(rectOf: CGSize(width: 4, height: 24), cornerRadius: 1)
            bolt.fillColor   = SKColor(white: 0.8, alpha: 1)
            bolt.strokeColor = .clear
            bolt.position    = CGPoint(x: 0, y: 14)
            base.addChild(bolt)
            return base

        case .moat:
            // Pixel art moat sprite
            let container = SKNode()
            let tex = SKTexture(imageNamed: "MoatTower")
            tex.filteringMode = .nearest
            let sprite = SKSpriteNode(texture: tex)
            sprite.size = CGSize(width: 44, height: 44)
            sprite.name = "towerSprite"
            container.addChild(sprite)
            return container
        }
    }

    // MARK: - Fire rate helper

    private static func computeFireRate(type: TowerType, gameState: GameState) -> TimeInterval {
        guard !type.isSupport else { return 0 }
        var rate = type.fireRate / gameState.globalFireRateMultiplier
        if type == .archer && gameState.hasUpgrade("r5") { rate /= 2.0 }
        if type == .wizard && gameState.hasUpgrade("r6") { rate /= 1.5 }
        return rate
    }
}
