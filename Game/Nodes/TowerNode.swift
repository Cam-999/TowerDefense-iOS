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
        case .moat,
             .whirlpool, .gravityWell, .quicksand, .cloudTrap:
            extraSlowFactor += upgrade.specialBonus

        case .catapult, .alchemist,
             .depthCharge, .missilePod, .boulderSling, .thunderCloud,
             .toxicReef, .acidSprayer, .venomPit, .stormBrew:
            upgradeSplashMult *= upgrade.specialBonus

        case .bellTower, .blacksmith,
             .pearlShrine, .fogHorn, .shieldGen, .commsArray,
             .obelisk, .warDrum, .skyShrine, .windChime:
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

        // MARK: Ocean Towers

        case .harpoonGun:
            // Circle base (teal) + tall narrow rect as harpoon shaft + triangle tip
            let base = SKShapeNode(circleOfRadius: 14)
            base.fillColor   = SKColor(red: 0.0, green: 0.55, blue: 0.55, alpha: 1)
            base.strokeColor = SKColor(red: 0.0, green: 0.75, blue: 0.75, alpha: 0.9)
            base.lineWidth   = 1.5
            // Shaft
            let shaft = SKShapeNode(rectOf: CGSize(width: 4, height: 22), cornerRadius: 1)
            shaft.fillColor   = SKColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1)
            shaft.strokeColor = .clear
            shaft.position    = CGPoint(x: 0, y: 18)
            base.addChild(shaft)
            // Triangle tip
            let tipPath = CGMutablePath()
            tipPath.move(to: CGPoint(x: 0, y: 12))
            tipPath.addLine(to: CGPoint(x: -3, y: 2))
            tipPath.addLine(to: CGPoint(x: 3, y: 2))
            tipPath.closeSubpath()
            let tip = SKShapeNode(path: tipPath)
            tip.fillColor   = SKColor(white: 0.85, alpha: 1)
            tip.strokeColor = .clear
            tip.position    = CGPoint(x: 0, y: 27)
            base.addChild(tip)
            return base

        case .depthCharge:
            // Wide rect base (navy) + circle "bomb" shape on top
            let base = SKShapeNode(rectOf: CGSize(width: 32, height: 18), cornerRadius: 3)
            base.fillColor   = SKColor(red: 0.05, green: 0.1, blue: 0.35, alpha: 1)
            base.strokeColor = SKColor(red: 0.3, green: 0.4, blue: 0.7, alpha: 0.9)
            base.lineWidth   = 1.5
            // Bomb circle
            let bomb = SKShapeNode(circleOfRadius: 9)
            bomb.fillColor   = SKColor(red: 0.15, green: 0.2, blue: 0.5, alpha: 1)
            bomb.strokeColor = SKColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 0.9)
            bomb.lineWidth   = 1.5
            bomb.position    = CGPoint(x: 0, y: 14)
            base.addChild(bomb)
            // Fuse dot
            let fuse = SKShapeNode(circleOfRadius: 2)
            fuse.fillColor   = SKColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 1)
            fuse.strokeColor = .clear
            fuse.position    = CGPoint(x: 0, y: 23)
            base.addChild(fuse)
            return base

        case .coralMage:
            // Hexagon base (coral pink) + small crystal shapes
            let r: CGFloat = 15
            let hexPath = CGMutablePath()
            for i in 0...6 {
                let angle = -CGFloat.pi / 2 + CGFloat(i) * (.pi / 3)
                let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
                if i == 0 { hexPath.move(to: pt) } else { hexPath.addLine(to: pt) }
            }
            hexPath.closeSubpath()
            let base = SKShapeNode(path: hexPath)
            base.fillColor   = SKColor(red: 0.85, green: 0.4, blue: 0.55, alpha: 1)
            base.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 0.9)
            base.lineWidth   = 1.5
            // Crystal shapes
            let crystalOffsets: [CGPoint] = [CGPoint(x: -6, y: 6), CGPoint(x: 6, y: 6), CGPoint(x: 0, y: -6)]
            for offset in crystalOffsets {
                let crystalPath = CGMutablePath()
                crystalPath.move(to: CGPoint(x: 0, y: 6))
                crystalPath.addLine(to: CGPoint(x: -3, y: 0))
                crystalPath.addLine(to: CGPoint(x: 0, y: -4))
                crystalPath.addLine(to: CGPoint(x: 3, y: 0))
                crystalPath.closeSubpath()
                let crystal = SKShapeNode(path: crystalPath)
                crystal.fillColor   = SKColor(red: 1.0, green: 0.75, blue: 0.85, alpha: 0.9)
                crystal.strokeColor = .clear
                crystal.position    = offset
                base.addChild(crystal)
            }
            return base

        case .pearlShrine:
            // Diamond base (pearl white/iridescent) + pulsing glow
            let r: CGFloat = 16
            let diamondPath = CGMutablePath()
            diamondPath.move(to: CGPoint(x: 0, y: r))
            diamondPath.addLine(to: CGPoint(x: r * 0.8, y: 0))
            diamondPath.addLine(to: CGPoint(x: 0, y: -r))
            diamondPath.addLine(to: CGPoint(x: -r * 0.8, y: 0))
            diamondPath.closeSubpath()
            let base = SKShapeNode(path: diamondPath)
            base.fillColor   = SKColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1)
            base.strokeColor = SKColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 0.9)
            base.lineWidth   = 2
            // Pearl center
            let pearl = SKShapeNode(circleOfRadius: 5)
            pearl.fillColor   = SKColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1)
            pearl.strokeColor = SKColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.8)
            pearl.lineWidth   = 1.5
            pearl.run(.repeatForever(.sequence([
                .scale(to: 1.2, duration: 1.0),
                .scale(to: 0.9, duration: 1.0)
            ])))
            base.addChild(pearl)
            return base

        case .toxicReef:
            // Hexagon base (dark green/teal) + bubbling dots
            let r: CGFloat = 15
            let hexPath = CGMutablePath()
            for i in 0...6 {
                let angle = -CGFloat.pi / 2 + CGFloat(i) * (.pi / 3)
                let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
                if i == 0 { hexPath.move(to: pt) } else { hexPath.addLine(to: pt) }
            }
            hexPath.closeSubpath()
            let base = SKShapeNode(path: hexPath)
            base.fillColor   = SKColor(red: 0.1, green: 0.3, blue: 0.25, alpha: 1)
            base.strokeColor = SKColor(red: 0.2, green: 0.6, blue: 0.45, alpha: 0.9)
            base.lineWidth   = 1.5
            // Bubbling dots
            for i in 0..<4 {
                let bubble = SKShapeNode(circleOfRadius: 2)
                bubble.fillColor   = SKColor(red: 0.2, green: 0.75, blue: 0.5, alpha: 0.8)
                bubble.strokeColor = .clear
                bubble.position    = CGPoint(x: CGFloat(i - 1) * 5, y: -3)
                bubble.run(.repeatForever(.sequence([
                    .moveBy(x: 0, y: 8, duration: 0.7 + Double(i) * 0.15),
                    .fadeOut(withDuration: 0.15),
                    .move(to: CGPoint(x: CGFloat(i - 1) * 5, y: -3), duration: 0),
                    .fadeIn(withDuration: 0.1)
                ])))
                base.addChild(bubble)
            }
            return base

        case .fogHorn:
            // Tall rect (gray) + arch + horn shape
            let base = SKShapeNode(rectOf: CGSize(width: 20, height: 30), cornerRadius: 3)
            base.fillColor   = SKColor(red: 0.5, green: 0.52, blue: 0.55, alpha: 1)
            base.strokeColor = SKColor(white: 0.75, alpha: 0.8)
            base.lineWidth   = 1.5
            // Arch
            let archPath = CGMutablePath()
            archPath.move(to: CGPoint(x: -7, y: 0))
            archPath.addQuadCurve(to: CGPoint(x: 7, y: 0), control: CGPoint(x: 0, y: 10))
            let arch = SKShapeNode(path: archPath)
            arch.strokeColor = SKColor(white: 0.85, alpha: 0.9)
            arch.lineWidth   = 2
            arch.fillColor   = .clear
            arch.position    = CGPoint(x: 0, y: 4)
            base.addChild(arch)
            // Horn
            let hornPath = CGMutablePath()
            hornPath.move(to: CGPoint(x: -4, y: 0))
            hornPath.addLine(to: CGPoint(x: 4, y: 0))
            hornPath.addLine(to: CGPoint(x: 7, y: 8))
            hornPath.addLine(to: CGPoint(x: -7, y: 8))
            hornPath.closeSubpath()
            let horn = SKShapeNode(path: hornPath)
            horn.fillColor   = SKColor(red: 0.35, green: 0.37, blue: 0.4, alpha: 1)
            horn.strokeColor = .clear
            horn.position    = CGPoint(x: 0, y: 15)
            base.addChild(horn)
            return base

        case .tridentTower:
            // Circle base (deep blue) + three-pronged fork shape
            let base = SKShapeNode(circleOfRadius: 15)
            base.fillColor   = SKColor(red: 0.05, green: 0.15, blue: 0.5, alpha: 1)
            base.strokeColor = SKColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.9)
            base.lineWidth   = 1.5
            // Shaft
            let shaft = SKShapeNode(rectOf: CGSize(width: 3, height: 20), cornerRadius: 1)
            shaft.fillColor   = SKColor(red: 0.6, green: 0.65, blue: 0.8, alpha: 1)
            shaft.strokeColor = .clear
            shaft.position    = CGPoint(x: 0, y: 17)
            base.addChild(shaft)
            // Three prongs
            let prongOffsets: [CGFloat] = [-6, 0, 6]
            for xOffset in prongOffsets {
                let prong = SKShapeNode(rectOf: CGSize(width: 2, height: 8), cornerRadius: 1)
                prong.fillColor   = SKColor(red: 0.7, green: 0.75, blue: 0.9, alpha: 1)
                prong.strokeColor = .clear
                prong.position    = CGPoint(x: xOffset, y: 31)
                base.addChild(prong)
            }
            return base

        case .whirlpool:
            // Circle base (blue) + spiral animation
            let base = SKShapeNode(circleOfRadius: 15)
            base.fillColor   = SKColor(red: 0.1, green: 0.35, blue: 0.7, alpha: 1)
            base.strokeColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.9)
            base.lineWidth   = 1.5
            // Spiral rings
            for i in 1...3 {
                let ring = SKShapeNode(circleOfRadius: CGFloat(i) * 4)
                ring.strokeColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.7 - CGFloat(i) * 0.15)
                ring.lineWidth   = 1.5
                ring.fillColor   = .clear
                ring.run(.repeatForever(.rotate(byAngle: -.pi * 2, duration: 1.8 + Double(i) * 0.4)))
                base.addChild(ring)
            }
            return base

        // MARK: Space Towers

        case .laserTurret:
            // Circle base (dark metal) + thin rect barrel
            let base = SKShapeNode(circleOfRadius: 14)
            base.fillColor   = SKColor(red: 0.2, green: 0.22, blue: 0.25, alpha: 1)
            base.strokeColor = SKColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 0.9)
            base.lineWidth   = 1.5
            // Barrel
            let barrel = SKShapeNode(rectOf: CGSize(width: 3, height: 22), cornerRadius: 1)
            barrel.fillColor   = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1)
            barrel.strokeColor = .clear
            barrel.position    = CGPoint(x: 0, y: 17)
            base.addChild(barrel)
            return base

        case .missilePod:
            // Wide rect (gunmetal) + small rect "missiles" on top
            let base = SKShapeNode(rectOf: CGSize(width: 32, height: 18), cornerRadius: 3)
            base.fillColor   = SKColor(red: 0.28, green: 0.3, blue: 0.32, alpha: 1)
            base.strokeColor = SKColor(white: 0.6, alpha: 0.8)
            base.lineWidth   = 1.5
            // Missiles
            for i in 0..<4 {
                let missile = SKShapeNode(rectOf: CGSize(width: 5, height: 10), cornerRadius: 2)
                missile.fillColor   = SKColor(red: 0.7, green: 0.7, blue: 0.75, alpha: 1)
                missile.strokeColor = .clear
                missile.position    = CGPoint(x: CGFloat(i - 1) * 8 - 4, y: 14)
                base.addChild(missile)
            }
            return base

        case .plasmaBeam:
            // Hexagon base (electric blue) + glowing center dot
            let r: CGFloat = 15
            let hexPath = CGMutablePath()
            for i in 0...6 {
                let angle = -CGFloat.pi / 2 + CGFloat(i) * (.pi / 3)
                let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
                if i == 0 { hexPath.move(to: pt) } else { hexPath.addLine(to: pt) }
            }
            hexPath.closeSubpath()
            let base = SKShapeNode(path: hexPath)
            base.fillColor   = SKColor(red: 0.05, green: 0.3, blue: 0.8, alpha: 1)
            base.strokeColor = SKColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.9)
            base.lineWidth   = 2
            // Glowing center
            let glow = SKShapeNode(circleOfRadius: 5)
            glow.fillColor   = SKColor(red: 0.5, green: 0.85, blue: 1.0, alpha: 1)
            glow.strokeColor = SKColor(red: 0.7, green: 0.95, blue: 1.0, alpha: 0.8)
            glow.lineWidth   = 2
            glow.run(.repeatForever(.sequence([
                .scale(to: 1.3, duration: 0.6),
                .scale(to: 0.85, duration: 0.6)
            ])))
            base.addChild(glow)
            return base

        case .shieldGen:
            // Diamond base (cyan) + pulsing ring animation
            let r: CGFloat = 16
            let diamondPath = CGMutablePath()
            diamondPath.move(to: CGPoint(x: 0, y: r))
            diamondPath.addLine(to: CGPoint(x: r * 0.8, y: 0))
            diamondPath.addLine(to: CGPoint(x: 0, y: -r))
            diamondPath.addLine(to: CGPoint(x: -r * 0.8, y: 0))
            diamondPath.closeSubpath()
            let base = SKShapeNode(path: diamondPath)
            base.fillColor   = SKColor(red: 0.0, green: 0.7, blue: 0.8, alpha: 1)
            base.strokeColor = SKColor(red: 0.4, green: 0.9, blue: 1.0, alpha: 0.9)
            base.lineWidth   = 2
            // Pulsing ring
            let ring = SKShapeNode(circleOfRadius: 10)
            ring.strokeColor = SKColor(red: 0.6, green: 1.0, blue: 1.0, alpha: 0.8)
            ring.lineWidth   = 2
            ring.fillColor   = .clear
            ring.run(.repeatForever(.sequence([
                .scale(to: 1.5, duration: 0.8),
                .fadeOut(withDuration: 0.2),
                .scale(to: 0.8, duration: 0),
                .fadeIn(withDuration: 0.2)
            ])))
            base.addChild(ring)
            return base

        case .acidSprayer:
            // Hexagon base (toxic green) + bubbling dots
            let r: CGFloat = 15
            let hexPath = CGMutablePath()
            for i in 0...6 {
                let angle = -CGFloat.pi / 2 + CGFloat(i) * (.pi / 3)
                let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
                if i == 0 { hexPath.move(to: pt) } else { hexPath.addLine(to: pt) }
            }
            hexPath.closeSubpath()
            let base = SKShapeNode(path: hexPath)
            base.fillColor   = SKColor(red: 0.2, green: 0.55, blue: 0.05, alpha: 1)
            base.strokeColor = SKColor(red: 0.45, green: 0.9, blue: 0.1, alpha: 0.9)
            base.lineWidth   = 1.5
            // Bubbling dots
            for i in 0..<4 {
                let bubble = SKShapeNode(circleOfRadius: 2)
                bubble.fillColor   = SKColor(red: 0.6, green: 1.0, blue: 0.1, alpha: 0.8)
                bubble.strokeColor = .clear
                bubble.position    = CGPoint(x: CGFloat(i - 1) * 5, y: -3)
                bubble.run(.repeatForever(.sequence([
                    .moveBy(x: 0, y: 8, duration: 0.65 + Double(i) * 0.15),
                    .fadeOut(withDuration: 0.15),
                    .move(to: CGPoint(x: CGFloat(i - 1) * 5, y: -3), duration: 0),
                    .fadeIn(withDuration: 0.1)
                ])))
                base.addChild(bubble)
            }
            return base

        case .commsArray:
            // Tall rect (dark gray) + satellite dish (small triangle)
            let base = SKShapeNode(rectOf: CGSize(width: 18, height: 28), cornerRadius: 3)
            base.fillColor   = SKColor(red: 0.18, green: 0.2, blue: 0.22, alpha: 1)
            base.strokeColor = SKColor(white: 0.5, alpha: 0.8)
            base.lineWidth   = 1.5
            // Dish triangle
            let dishPath = CGMutablePath()
            dishPath.move(to: CGPoint(x: 0, y: 10))
            dishPath.addLine(to: CGPoint(x: -9, y: -2))
            dishPath.addLine(to: CGPoint(x: 9, y: -2))
            dishPath.closeSubpath()
            let dish = SKShapeNode(path: dishPath)
            dish.fillColor   = SKColor(red: 0.55, green: 0.6, blue: 0.65, alpha: 1)
            dish.strokeColor = .clear
            dish.position    = CGPoint(x: 0, y: 20)
            base.addChild(dish)
            return base

        case .railgun:
            // Circle base (chrome) + long rect barrel + bolt
            let base = SKShapeNode(circleOfRadius: 14)
            base.fillColor   = SKColor(red: 0.55, green: 0.6, blue: 0.65, alpha: 1)
            base.strokeColor = SKColor(red: 0.8, green: 0.85, blue: 0.9, alpha: 0.9)
            base.lineWidth   = 1.5
            // Long barrel
            let barrel = SKShapeNode(rectOf: CGSize(width: 5, height: 28), cornerRadius: 1)
            barrel.fillColor   = SKColor(red: 0.7, green: 0.75, blue: 0.8, alpha: 1)
            barrel.strokeColor = .clear
            barrel.position    = CGPoint(x: 0, y: 20)
            base.addChild(barrel)
            // Bolt accent
            let bolt = SKShapeNode(rectOf: CGSize(width: 2, height: 10), cornerRadius: 1)
            bolt.fillColor   = SKColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1)
            bolt.strokeColor = .clear
            bolt.position    = CGPoint(x: 4, y: 20)
            base.addChild(bolt)
            return base

        case .gravityWell:
            // Circle base (dark purple) + shrinking ring animation
            let base = SKShapeNode(circleOfRadius: 15)
            base.fillColor   = SKColor(red: 0.22, green: 0.05, blue: 0.38, alpha: 1)
            base.strokeColor = SKColor(red: 0.6, green: 0.2, blue: 0.9, alpha: 0.9)
            base.lineWidth   = 1.5
            // Shrinking rings
            for i in 1...3 {
                let ring = SKShapeNode(circleOfRadius: CGFloat(i) * 4 + 2)
                ring.strokeColor = SKColor(red: 0.7, green: 0.35, blue: 1.0, alpha: 0.8 - CGFloat(i) * 0.15)
                ring.lineWidth   = 1.5
                ring.fillColor   = .clear
                ring.run(.repeatForever(.sequence([
                    .scale(to: 0.3, duration: 1.0 + Double(i) * 0.3),
                    .fadeOut(withDuration: 0.1),
                    .scale(to: 1.0, duration: 0),
                    .fadeIn(withDuration: 0.1)
                ])))
                base.addChild(ring)
            }
            return base

        // MARK: Desert Towers

        case .spearThrower:
            // Circle base (sandstone) + angled spear shaft
            let base = SKShapeNode(circleOfRadius: 14)
            base.fillColor   = SKColor(red: 0.76, green: 0.6, blue: 0.38, alpha: 1)
            base.strokeColor = SKColor(red: 0.9, green: 0.75, blue: 0.5, alpha: 0.9)
            base.lineWidth   = 1.5
            // Spear shaft
            let shaft = SKShapeNode(rectOf: CGSize(width: 3, height: 26), cornerRadius: 1)
            shaft.fillColor   = SKColor(red: 0.55, green: 0.4, blue: 0.2, alpha: 1)
            shaft.strokeColor = .clear
            shaft.position    = CGPoint(x: 4, y: 18)
            shaft.zRotation   = 0.2
            base.addChild(shaft)
            // Spear tip
            let tipPath = CGMutablePath()
            tipPath.move(to: CGPoint(x: 0, y: 8))
            tipPath.addLine(to: CGPoint(x: -3, y: 0))
            tipPath.addLine(to: CGPoint(x: 3, y: 0))
            tipPath.closeSubpath()
            let tip = SKShapeNode(path: tipPath)
            tip.fillColor   = SKColor(white: 0.8, alpha: 1)
            tip.strokeColor = .clear
            tip.position    = CGPoint(x: 6, y: 31)
            tip.zRotation   = 0.2
            base.addChild(tip)
            return base

        case .boulderSling:
            // Wide rect (clay) + arm + boulder
            let base = SKShapeNode(rectOf: CGSize(width: 30, height: 18), cornerRadius: 3)
            base.fillColor   = SKColor(red: 0.65, green: 0.38, blue: 0.22, alpha: 1)
            base.strokeColor = SKColor(red: 0.8, green: 0.55, blue: 0.35, alpha: 0.9)
            base.lineWidth   = 1.5
            // Arm
            let arm = SKShapeNode(rectOf: CGSize(width: 4, height: 18), cornerRadius: 1)
            arm.fillColor   = SKColor(red: 0.5, green: 0.3, blue: 0.15, alpha: 1)
            arm.strokeColor = .clear
            arm.position    = CGPoint(x: 0, y: 11)
            arm.zRotation   = 0.25
            base.addChild(arm)
            // Boulder
            let boulder = SKShapeNode(circleOfRadius: 6)
            boulder.fillColor   = SKColor(red: 0.5, green: 0.48, blue: 0.45, alpha: 1)
            boulder.strokeColor = SKColor(white: 0.6, alpha: 0.7)
            boulder.lineWidth   = 1
            boulder.position    = CGPoint(x: -4, y: 21)
            base.addChild(boulder)
            return base

        case .sunMirror:
            // Hexagon base (gold) + bright center
            let r: CGFloat = 15
            let hexPath = CGMutablePath()
            for i in 0...6 {
                let angle = -CGFloat.pi / 2 + CGFloat(i) * (.pi / 3)
                let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
                if i == 0 { hexPath.move(to: pt) } else { hexPath.addLine(to: pt) }
            }
            hexPath.closeSubpath()
            let base = SKShapeNode(path: hexPath)
            base.fillColor   = SKColor(red: 0.85, green: 0.7, blue: 0.0, alpha: 1)
            base.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.9)
            base.lineWidth   = 2
            // Bright center
            let center = SKShapeNode(circleOfRadius: 5)
            center.fillColor   = SKColor(red: 1.0, green: 0.98, blue: 0.7, alpha: 1)
            center.strokeColor = SKColor(red: 1.0, green: 0.95, blue: 0.5, alpha: 0.9)
            center.lineWidth   = 2
            center.run(.repeatForever(.sequence([
                .scale(to: 1.25, duration: 0.5),
                .scale(to: 0.9, duration: 0.5)
            ])))
            base.addChild(center)
            return base

        case .obelisk:
            // Tall narrow rect (sandstone) + hieroglyph marks
            let base = SKShapeNode(rectOf: CGSize(width: 14, height: 34), cornerRadius: 2)
            base.fillColor   = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1)
            base.strokeColor = SKColor(red: 0.95, green: 0.85, blue: 0.65, alpha: 0.9)
            base.lineWidth   = 1.5
            // Hieroglyph marks (small horizontal lines)
            for i in 0..<3 {
                let mark = SKShapeNode(rectOf: CGSize(width: 8, height: 2), cornerRadius: 1)
                mark.fillColor   = SKColor(red: 0.4, green: 0.3, blue: 0.15, alpha: 0.8)
                mark.strokeColor = .clear
                mark.position    = CGPoint(x: 0, y: CGFloat(i - 1) * 7)
                base.addChild(mark)
            }
            return base

        case .venomPit:
            // Hexagon base (dark olive) + bubbling dots
            let r: CGFloat = 15
            let hexPath = CGMutablePath()
            for i in 0...6 {
                let angle = -CGFloat.pi / 2 + CGFloat(i) * (.pi / 3)
                let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
                if i == 0 { hexPath.move(to: pt) } else { hexPath.addLine(to: pt) }
            }
            hexPath.closeSubpath()
            let base = SKShapeNode(path: hexPath)
            base.fillColor   = SKColor(red: 0.25, green: 0.3, blue: 0.05, alpha: 1)
            base.strokeColor = SKColor(red: 0.45, green: 0.55, blue: 0.1, alpha: 0.9)
            base.lineWidth   = 1.5
            // Bubbling dots
            for i in 0..<4 {
                let bubble = SKShapeNode(circleOfRadius: 2)
                bubble.fillColor   = SKColor(red: 0.5, green: 0.75, blue: 0.1, alpha: 0.8)
                bubble.strokeColor = .clear
                bubble.position    = CGPoint(x: CGFloat(i - 1) * 5, y: -3)
                bubble.run(.repeatForever(.sequence([
                    .moveBy(x: 0, y: 8, duration: 0.7 + Double(i) * 0.18),
                    .fadeOut(withDuration: 0.15),
                    .move(to: CGPoint(x: CGFloat(i - 1) * 5, y: -3), duration: 0),
                    .fadeIn(withDuration: 0.1)
                ])))
                base.addChild(bubble)
            }
            return base

        case .warDrum:
            // Circle base (leather brown) + drum shape
            let base = SKShapeNode(circleOfRadius: 15)
            base.fillColor   = SKColor(red: 0.5, green: 0.3, blue: 0.15, alpha: 1)
            base.strokeColor = SKColor(red: 0.7, green: 0.5, blue: 0.25, alpha: 0.9)
            base.lineWidth   = 1.5
            // Drum body
            let drum = SKShapeNode(rectOf: CGSize(width: 16, height: 12), cornerRadius: 2)
            drum.fillColor   = SKColor(red: 0.65, green: 0.42, blue: 0.22, alpha: 1)
            drum.strokeColor = SKColor(red: 0.85, green: 0.65, blue: 0.35, alpha: 0.9)
            drum.lineWidth   = 1.5
            drum.position    = CGPoint(x: 0, y: 0)
            base.addChild(drum)
            // Top drumhead line
            let head = SKShapeNode(rectOf: CGSize(width: 16, height: 3), cornerRadius: 1)
            head.fillColor   = SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 0.9)
            head.strokeColor = .clear
            head.position    = CGPoint(x: 0, y: 6)
            base.addChild(head)
            return base

        case .scorpionBow:
            // Circle base (bronze) + crossbow arms + bolt
            let base = SKShapeNode(circleOfRadius: 14)
            base.fillColor   = SKColor(red: 0.55, green: 0.38, blue: 0.1, alpha: 1)
            base.strokeColor = SKColor(red: 0.8, green: 0.6, blue: 0.25, alpha: 0.9)
            base.lineWidth   = 1.5
            // Crossbow arms
            for xSign: CGFloat in [-1, 1] {
                let arm = SKShapeNode(rectOf: CGSize(width: 14, height: 3), cornerRadius: 1)
                arm.fillColor   = SKColor(red: 0.65, green: 0.45, blue: 0.15, alpha: 1)
                arm.strokeColor = .clear
                arm.position    = CGPoint(x: xSign * 7, y: 8)
                arm.zRotation   = xSign * 0.5
                base.addChild(arm)
            }
            // Bolt
            let bolt = SKShapeNode(rectOf: CGSize(width: 3, height: 20), cornerRadius: 1)
            bolt.fillColor   = SKColor(white: 0.82, alpha: 1)
            bolt.strokeColor = .clear
            bolt.position    = CGPoint(x: 0, y: 15)
            base.addChild(bolt)
            return base

        case .quicksand:
            // Circle base (sand) + swirl pattern
            let base = SKShapeNode(circleOfRadius: 15)
            base.fillColor   = SKColor(red: 0.82, green: 0.72, blue: 0.5, alpha: 1)
            base.strokeColor = SKColor(red: 0.95, green: 0.85, blue: 0.65, alpha: 0.9)
            base.lineWidth   = 1.5
            // Swirl rings
            for i in 1...3 {
                let ring = SKShapeNode(circleOfRadius: CGFloat(i) * 4)
                ring.strokeColor = SKColor(red: 0.65, green: 0.55, blue: 0.35, alpha: 0.7 - CGFloat(i) * 0.1)
                ring.lineWidth   = 1.5
                ring.fillColor   = .clear
                ring.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 2.0 + Double(i) * 0.5)))
                base.addChild(ring)
            }
            return base

        // MARK: Sky Towers

        case .windCannon:
            // Circle base (silver-blue) + barrel
            let base = SKShapeNode(circleOfRadius: 14)
            base.fillColor   = SKColor(red: 0.65, green: 0.75, blue: 0.85, alpha: 1)
            base.strokeColor = SKColor(red: 0.8, green: 0.88, blue: 0.96, alpha: 0.9)
            base.lineWidth   = 1.5
            // Barrel
            let barrel = SKShapeNode(rectOf: CGSize(width: 8, height: 20), cornerRadius: 2)
            barrel.fillColor   = SKColor(red: 0.55, green: 0.65, blue: 0.75, alpha: 1)
            barrel.strokeColor = .clear
            barrel.position    = CGPoint(x: 0, y: 16)
            base.addChild(barrel)
            return base

        case .thunderCloud:
            // Wide rect (dark gray) + lightning bolt shapes
            let base = SKShapeNode(rectOf: CGSize(width: 34, height: 20), cornerRadius: 6)
            base.fillColor   = SKColor(red: 0.28, green: 0.3, blue: 0.35, alpha: 1)
            base.strokeColor = SKColor(red: 0.85, green: 0.85, blue: 0.35, alpha: 0.9)
            base.lineWidth   = 1.5
            // Lightning bolt (zig-zag)
            let boltPath = CGMutablePath()
            boltPath.move(to: CGPoint(x: 3, y: 10))
            boltPath.addLine(to: CGPoint(x: -1, y: 2))
            boltPath.addLine(to: CGPoint(x: 2, y: 2))
            boltPath.addLine(to: CGPoint(x: -2, y: -8))
            let bolt1 = SKShapeNode(path: boltPath)
            bolt1.strokeColor = SKColor(red: 1.0, green: 0.95, blue: 0.3, alpha: 1)
            bolt1.lineWidth   = 2
            bolt1.fillColor   = .clear
            bolt1.position    = CGPoint(x: -5, y: 4)
            base.addChild(bolt1)
            // Second bolt
            let boltPath2 = CGMutablePath()
            boltPath2.move(to: CGPoint(x: 3, y: 8))
            boltPath2.addLine(to: CGPoint(x: -1, y: 1))
            boltPath2.addLine(to: CGPoint(x: 2, y: 1))
            boltPath2.addLine(to: CGPoint(x: -2, y: -7))
            let bolt2 = SKShapeNode(path: boltPath2)
            bolt2.strokeColor = SKColor(red: 1.0, green: 0.95, blue: 0.3, alpha: 0.7)
            bolt2.lineWidth   = 1.5
            bolt2.fillColor   = .clear
            bolt2.position    = CGPoint(x: 6, y: 4)
            base.addChild(bolt2)
            return base

        case .lightningRod:
            // Tall narrow rect (silver) + pointed tip + spark dots
            let base = SKShapeNode(rectOf: CGSize(width: 10, height: 30), cornerRadius: 2)
            base.fillColor   = SKColor(red: 0.72, green: 0.75, blue: 0.8, alpha: 1)
            base.strokeColor = SKColor(red: 0.88, green: 0.9, blue: 0.95, alpha: 0.9)
            base.lineWidth   = 1.5
            // Pointed tip
            let tipPath = CGMutablePath()
            tipPath.move(to: CGPoint(x: 0, y: 8))
            tipPath.addLine(to: CGPoint(x: -3, y: 0))
            tipPath.addLine(to: CGPoint(x: 3, y: 0))
            tipPath.closeSubpath()
            let tip = SKShapeNode(path: tipPath)
            tip.fillColor   = SKColor(red: 0.9, green: 0.92, blue: 0.98, alpha: 1)
            tip.strokeColor = .clear
            tip.position    = CGPoint(x: 0, y: 19)
            base.addChild(tip)
            // Spark dots
            for i in 0..<3 {
                let spark = SKShapeNode(circleOfRadius: 1.5)
                spark.fillColor   = SKColor(red: 0.9, green: 0.95, blue: 0.3, alpha: 0.9)
                spark.strokeColor = .clear
                let xPos = CGFloat(i - 1) * 6
                spark.position    = CGPoint(x: xPos, y: 25)
                spark.run(.repeatForever(.sequence([
                    .fadeOut(withDuration: 0.2 + Double(i) * 0.1),
                    .fadeIn(withDuration: 0.15)
                ])))
                base.addChild(spark)
            }
            return base

        case .skyShrine:
            // Diamond base (white/gold) + glow animation
            let r: CGFloat = 16
            let diamondPath = CGMutablePath()
            diamondPath.move(to: CGPoint(x: 0, y: r))
            diamondPath.addLine(to: CGPoint(x: r * 0.8, y: 0))
            diamondPath.addLine(to: CGPoint(x: 0, y: -r))
            diamondPath.addLine(to: CGPoint(x: -r * 0.8, y: 0))
            diamondPath.closeSubpath()
            let base = SKShapeNode(path: diamondPath)
            base.fillColor   = SKColor(red: 0.97, green: 0.95, blue: 0.88, alpha: 1)
            base.strokeColor = SKColor(red: 0.9, green: 0.75, blue: 0.3, alpha: 0.9)
            base.lineWidth   = 2
            // Glow center
            let glow = SKShapeNode(circleOfRadius: 5)
            glow.fillColor   = SKColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1)
            glow.strokeColor = SKColor(red: 0.95, green: 0.85, blue: 0.4, alpha: 0.8)
            glow.lineWidth   = 2
            glow.run(.repeatForever(.sequence([
                .scale(to: 1.3, duration: 1.0),
                .scale(to: 0.85, duration: 1.0)
            ])))
            base.addChild(glow)
            return base

        case .stormBrew:
            // Hexagon base (storm gray) + bubbling dots
            let r: CGFloat = 15
            let hexPath = CGMutablePath()
            for i in 0...6 {
                let angle = -CGFloat.pi / 2 + CGFloat(i) * (.pi / 3)
                let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
                if i == 0 { hexPath.move(to: pt) } else { hexPath.addLine(to: pt) }
            }
            hexPath.closeSubpath()
            let base = SKShapeNode(path: hexPath)
            base.fillColor   = SKColor(red: 0.35, green: 0.38, blue: 0.45, alpha: 1)
            base.strokeColor = SKColor(red: 0.55, green: 0.6, blue: 0.7, alpha: 0.9)
            base.lineWidth   = 1.5
            // Bubbling dots (lightning-tinted)
            for i in 0..<4 {
                let bubble = SKShapeNode(circleOfRadius: 2)
                bubble.fillColor   = SKColor(red: 0.85, green: 0.9, blue: 0.35, alpha: 0.8)
                bubble.strokeColor = .clear
                bubble.position    = CGPoint(x: CGFloat(i - 1) * 5, y: -3)
                bubble.run(.repeatForever(.sequence([
                    .moveBy(x: 0, y: 8, duration: 0.6 + Double(i) * 0.18),
                    .fadeOut(withDuration: 0.15),
                    .move(to: CGPoint(x: CGFloat(i - 1) * 5, y: -3), duration: 0),
                    .fadeIn(withDuration: 0.1)
                ])))
                base.addChild(bubble)
            }
            return base

        case .windChime:
            // Tall rect (light gray) + small hanging circles
            let base = SKShapeNode(rectOf: CGSize(width: 18, height: 28), cornerRadius: 3)
            base.fillColor   = SKColor(red: 0.75, green: 0.78, blue: 0.82, alpha: 1)
            base.strokeColor = SKColor(white: 0.9, alpha: 0.8)
            base.lineWidth   = 1.5
            // Hanging chime circles
            let chimeOffsets: [CGFloat] = [-6, -2, 2, 6]
            let chimeLengths: [CGFloat] = [14, 18, 16, 12]
            for (idx, xOff) in chimeOffsets.enumerated() {
                let length = chimeLengths[idx]
                let bar = SKShapeNode(rectOf: CGSize(width: 2, height: length), cornerRadius: 1)
                bar.fillColor   = SKColor(red: 0.6, green: 0.62, blue: 0.65, alpha: 1)
                bar.strokeColor = .clear
                bar.position    = CGPoint(x: xOff, y: -(length / 2 + 2))
                base.addChild(bar)
                let chime = SKShapeNode(circleOfRadius: 2.5)
                chime.fillColor   = SKColor(red: 0.85, green: 0.88, blue: 0.92, alpha: 1)
                chime.strokeColor = SKColor(white: 1, alpha: 0.7)
                chime.lineWidth   = 1
                chime.position    = CGPoint(x: xOff, y: -(length + 6))
                chime.run(.repeatForever(.sequence([
                    .moveBy(x: 2, y: 0, duration: 0.4 + Double(idx) * 0.1),
                    .moveBy(x: -2, y: 0, duration: 0.4 + Double(idx) * 0.1)
                ])))
                base.addChild(chime)
            }
            return base

        case .galeForce:
            // Circle base (steel) + wide barrel
            let base = SKShapeNode(circleOfRadius: 15)
            base.fillColor   = SKColor(red: 0.45, green: 0.5, blue: 0.58, alpha: 1)
            base.strokeColor = SKColor(red: 0.65, green: 0.72, blue: 0.8, alpha: 0.9)
            base.lineWidth   = 1.5
            // Wide barrel
            let barrel = SKShapeNode(rectOf: CGSize(width: 12, height: 18), cornerRadius: 2)
            barrel.fillColor   = SKColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
            barrel.strokeColor = .clear
            barrel.position    = CGPoint(x: 0, y: 18)
            base.addChild(barrel)
            return base

        case .cloudTrap:
            // Circle base (white/gray) + cloud puff shapes
            let base = SKShapeNode(circleOfRadius: 15)
            base.fillColor   = SKColor(red: 0.88, green: 0.9, blue: 0.93, alpha: 1)
            base.strokeColor = SKColor(red: 0.7, green: 0.75, blue: 0.82, alpha: 0.9)
            base.lineWidth   = 1.5
            // Cloud puffs (overlapping circles)
            let puffPositions: [CGPoint] = [
                CGPoint(x: -5, y: 6),
                CGPoint(x: 5, y: 6),
                CGPoint(x: 0, y: 10),
                CGPoint(x: -8, y: 3),
                CGPoint(x: 8, y: 3)
            ]
            let puffRadii: [CGFloat] = [5, 5, 5, 4, 4]
            for (idx, pos) in puffPositions.enumerated() {
                let puff = SKShapeNode(circleOfRadius: puffRadii[idx])
                puff.fillColor   = SKColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 0.85)
                puff.strokeColor = SKColor(red: 0.75, green: 0.8, blue: 0.88, alpha: 0.6)
                puff.lineWidth   = 1
                puff.position    = pos
                base.addChild(puff)
            }
            return base
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
