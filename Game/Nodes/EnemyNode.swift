import SpriteKit

final class EnemyNode: SKNode {
    let enemyType: EnemyType
    private(set) var maxHP: CGFloat
    private(set) var currentHP: CGFloat
    private(set) var remainingShield: CGFloat
    let moveSpeed: CGFloat
    private(set) var isDead = false
    var waypointIndex: Int = 0

    var onDeath: ((EnemyNode) -> Void)?
    var onReachEnd: ((EnemyNode) -> Void)?

    private let bodyNode: SKShapeNode
    private let hpBarBg: SKShapeNode
    private let hpBarFill: SKShapeNode
    private var shieldNode: SKShapeNode?

    private var isSlowed     = false
    private var hasBerserked = false

    // MARK: - Init

    init(type: EnemyType, hpScale: Float, speedScale: Float) {
        self.enemyType       = type
        self.maxHP           = type.baseHP    * CGFloat(hpScale)
        self.currentHP       = maxHP
        self.remainingShield = type.shieldHP
        self.moveSpeed       = type.baseSpeed * CGFloat(speedScale)

        let sz = type.size

        // Body shape — distinct per enemy type
        let body = EnemyNode.makeBody(type: type, size: sz)
        body.fillColor   = type.color
        body.strokeColor = .clear
        self.bodyNode = body

        // HP bar
        let barW = sz.width
        let bg   = SKShapeNode(rectOf: CGSize(width: barW, height: 4))
        bg.fillColor   = SKColor(white: 0.15, alpha: 0.85)
        bg.strokeColor = .clear
        bg.position    = CGPoint(x: 0, y: sz.height / 2 + 6)
        self.hpBarBg = bg

        let fill = SKShapeNode(rectOf: CGSize(width: barW, height: 4))
        fill.fillColor   = SKColor(red: 0.2, green: 0.9, blue: 0.2, alpha: 1)
        fill.strokeColor = .clear
        fill.position    = CGPoint(x: 0, y: sz.height / 2 + 6)
        self.hpBarFill = fill

        super.init()
        addChild(body)
        addChild(bg)
        addChild(fill)

        physicsBody = type.isBoss
            ? SKPhysicsBody(rectangleOf: sz)
            : SKPhysicsBody(circleOfRadius: sz.width / 2)
        physicsBody?.categoryBitMask    = PhysicsCategories.enemy
        physicsBody?.contactTestBitMask = PhysicsCategories.none
        physicsBody?.collisionBitMask   = PhysicsCategories.none
        physicsBody?.isDynamic = false

        applyTypeVisuals()
        applySprite(size: sz)

        if type.regenPerSecond > 0 {
            let tick: TimeInterval = 0.5
            let amt = type.regenPerSecond * CGFloat(tick)
            run(.repeatForever(.sequence([
                .wait(forDuration: tick),
                .run { [weak self] in self?.heal(amt) }
            ])), withKey: "regen")
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Shape factory

    private static func makeBody(type: EnemyType, size: CGSize) -> SKShapeNode {
        let r = size.width / 2
        switch type {

        // ── Fantasy (original) ───────────────────────────────────────────

        // Bosses: rounded rectangles
        case .dragonLord:
            return SKShapeNode(rectOf: size, cornerRadius: 6)
        case .necroKing:
            return SKShapeNode(rectOf: size, cornerRadius: 5)

        // Orc: hexagon (sturdy)
        case .orc:
            return SKShapeNode(path: polygonPath(sides: 6, radius: r))

        // Dark Knight: pentagon (armored)
        case .darkKnight:
            return SKShapeNode(path: polygonPath(sides: 5, radius: r))

        // Skeleton: 4-point star (bony)
        case .skeleton:
            return SKShapeNode(path: starPath(points: 4, outerRadius: r, innerRadius: r * 0.45))

        // Troll: large circle
        case .troll:
            return SKShapeNode(circleOfRadius: r)

        // Bandit: diamond (sleek)
        case .bandit:
            return SKShapeNode(path: diamondPath(radius: r))

        // Necromancer: circle (with skull cross added in applyTypeVisuals)
        case .necromancer:
            return SKShapeNode(circleOfRadius: r)

        // Siege Ram: wide rectangle
        case .siegeRam:
            return SKShapeNode(rectOf: size, cornerRadius: 3)

        // Warlock: octagon
        case .warlock:
            return SKShapeNode(path: polygonPath(sides: 8, radius: r))

        // Harpy: triangle (flying)
        case .harpy:
            return SKShapeNode(path: polygonPath(sides: 3, radius: r))

        // Wraith: transparent circle
        case .wraith:
            return SKShapeNode(circleOfRadius: r)

        // ── Ocean ────────────────────────────────────────────────────────

        // Basic
        case .crab:
            return SKShapeNode(circleOfRadius: r)

        // Armored
        case .pirate:
            return SKShapeNode(path: polygonPath(sides: 6, radius: r))

        // Fast
        case .jellyfish:
            return SKShapeNode(path: starPath(points: 4, outerRadius: r, innerRadius: r * 0.45))

        // Dodge
        case .siren:
            return SKShapeNode(path: diamondPath(radius: r))

        // Regen
        case .seaSerpent:
            return SKShapeNode(circleOfRadius: r)

        // Summoner
        case .anglerFish:
            return SKShapeNode(circleOfRadius: r)

        // Swarm
        case .sharkSwarm:
            return SKShapeNode(circleOfRadius: r)

        // Heavy
        case .turtleTank:
            return SKShapeNode(rectOf: size, cornerRadius: 3)

        // Shield
        case .stormCaster:
            return SKShapeNode(path: polygonPath(sides: 8, radius: r))

        // Flying
        case .flyingFish:
            return SKShapeNode(path: polygonPath(sides: 3, radius: r))

        // Elite
        case .ghostShip:
            return SKShapeNode(circleOfRadius: r)

        // Boss 1
        case .tidalLord:
            return SKShapeNode(rectOf: size, cornerRadius: 5)

        // Boss 2
        case .kraken:
            return SKShapeNode(rectOf: size, cornerRadius: 6)

        // ── Space ────────────────────────────────────────────────────────

        // Basic
        case .alienDrone:
            return SKShapeNode(circleOfRadius: r)

        // Armored
        case .mechSoldier:
            return SKShapeNode(path: polygonPath(sides: 6, radius: r))

        // Fast
        case .speedster:
            return SKShapeNode(path: starPath(points: 4, outerRadius: r, innerRadius: r * 0.45))

        // Dodge
        case .phaseShifter:
            return SKShapeNode(path: diamondPath(radius: r))

        // Regen
        case .plasmaGolem:
            return SKShapeNode(circleOfRadius: r)

        // Summoner
        case .hiveMind:
            return SKShapeNode(circleOfRadius: r)

        // Swarm
        case .naniteSwarm:
            return SKShapeNode(circleOfRadius: r)

        // Heavy
        case .battleCruiser:
            return SKShapeNode(rectOf: size, cornerRadius: 3)

        // Shield
        case .voidCaster:
            return SKShapeNode(path: polygonPath(sides: 8, radius: r))

        // Flying
        case .starfighter:
            return SKShapeNode(path: polygonPath(sides: 3, radius: r))

        // Elite
        case .darkMatter:
            return SKShapeNode(circleOfRadius: r)

        // Boss 1
        case .admiralZyx:
            return SKShapeNode(rectOf: size, cornerRadius: 5)

        // Boss 2
        case .mothershipOmega:
            return SKShapeNode(rectOf: size, cornerRadius: 6)

        // ── Desert ──────────────────────────────────────────────────────

        // Basic
        case .scarab:
            return SKShapeNode(circleOfRadius: r)

        // Armored
        case .sandGolem:
            return SKShapeNode(path: polygonPath(sides: 6, radius: r))

        // Fast
        case .dustDevil:
            return SKShapeNode(path: starPath(points: 4, outerRadius: r, innerRadius: r * 0.45))

        // Dodge
        case .mirage:
            return SKShapeNode(path: diamondPath(radius: r))

        // Regen
        case .sandWorm:
            return SKShapeNode(circleOfRadius: r)

        // Summoner
        case .mummy:
            return SKShapeNode(circleOfRadius: r)

        // Swarm
        case .scorpionPack:
            return SKShapeNode(circleOfRadius: r)

        // Heavy
        case .siegeElephant:
            return SKShapeNode(rectOf: size, cornerRadius: 3)

        // Shield
        case .sandSorcerer:
            return SKShapeNode(path: polygonPath(sides: 8, radius: r))

        // Flying
        case .desertHawk:
            return SKShapeNode(path: polygonPath(sides: 3, radius: r))

        // Elite
        case .sphinxWraith:
            return SKShapeNode(circleOfRadius: r)

        // Boss 1
        case .pharaohKing:
            return SKShapeNode(rectOf: size, cornerRadius: 5)

        // Boss 2
        case .ancientColossus:
            return SKShapeNode(rectOf: size, cornerRadius: 6)

        // ── Sky ──────────────────────────────────────────────────────────

        // Basic
        case .cloudWisp:
            return SKShapeNode(circleOfRadius: r)

        // Armored
        case .stormKnight:
            return SKShapeNode(path: polygonPath(sides: 6, radius: r))

        // Fast
        case .windSprite:
            return SKShapeNode(path: starPath(points: 4, outerRadius: r, innerRadius: r * 0.45))

        // Dodge
        case .fogPhantom:
            return SKShapeNode(path: diamondPath(radius: r))

        // Regen
        case .thunderBeast:
            return SKShapeNode(circleOfRadius: r)

        // Summoner
        case .cloudWeaver:
            return SKShapeNode(circleOfRadius: r)

        // Swarm
        case .featherSwarm:
            return SKShapeNode(circleOfRadius: r)

        // Heavy
        case .skyFortress:
            return SKShapeNode(rectOf: size, cornerRadius: 3)

        // Shield
        case .galeWizard:
            return SKShapeNode(path: polygonPath(sides: 8, radius: r))

        // Flying
        case .stormEagle:
            return SKShapeNode(path: polygonPath(sides: 3, radius: r))

        // Elite
        case .voidZephyr:
            return SKShapeNode(circleOfRadius: r)

        // Boss 1
        case .skylordAres:
            return SKShapeNode(rectOf: size, cornerRadius: 5)

        // Boss 2
        case .thunderDragon:
            return SKShapeNode(rectOf: size, cornerRadius: 6)

        // Default circle for goblin, skeletonSwarm, and any unlisted type
        default:
            return SKShapeNode(circleOfRadius: r)
        }
    }

    private static func polygonPath(sides: Int, radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let angleStep = (2 * CGFloat.pi) / CGFloat(sides)
        let startAngle = -CGFloat.pi / 2
        for i in 0...sides {
            let angle = startAngle + angleStep * CGFloat(i)
            let pt = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }

    private static func diamondPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let stretch: CGFloat = 1.3 // elongated vertically
        path.move(to: CGPoint(x: 0, y: radius * stretch))
        path.addLine(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -radius * stretch))
        path.addLine(to: CGPoint(x: -radius, y: 0))
        path.closeSubpath()
        return path
    }

    private static func starPath(points: Int, outerRadius: CGFloat, innerRadius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let totalPoints = points * 2
        let angleStep = (2 * CGFloat.pi) / CGFloat(totalPoints)
        let startAngle = -CGFloat.pi / 2
        for i in 0..<totalPoints {
            let angle = startAngle + angleStep * CGFloat(i)
            let r = (i % 2 == 0) ? outerRadius : innerRadius
            let pt = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }

    // MARK: - Type-specific visuals

    private func applyTypeVisuals() {
        switch enemyType {

        // ── Fantasy (original) ───────────────────────────────────────────

        case .wraith:
            // Ghostly near-transparent white
            bodyNode.alpha       = 0.55
            bodyNode.strokeColor = SKColor(white: 1, alpha: 0.6)
            bodyNode.lineWidth   = 1.5

        case .warlock:
            // Dark purple with animated shield ring
            bodyNode.strokeColor = SKColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 0.9)
            bodyNode.lineWidth   = 2
            let shield = SKShapeNode(circleOfRadius: 15)
            shield.fillColor   = SKColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 0.15)
            shield.strokeColor = SKColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 0.95)
            shield.lineWidth   = 2.5
            shield.run(.repeatForever(.sequence([
                .scale(to: 1.12, duration: 0.55),
                .scale(to: 1.00, duration: 0.55)
            ])))
            addChild(shield)
            shieldNode = shield

        case .darkKnight:
            // Dark steel with metallic outline
            bodyNode.strokeColor = SKColor(white: 0.6, alpha: 0.9)
            bodyNode.lineWidth   = 2

        case .troll:
            // Mossy green with thick border
            bodyNode.strokeColor = SKColor(red: 0.35, green: 0.45, blue: 0.20, alpha: 0.8)
            bodyNode.lineWidth   = 2.5

        case .bandit:
            // Brown with subtle outline
            bodyNode.strokeColor = SKColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 0.7)
            bodyNode.lineWidth   = 1.5

        case .necromancer:
            // Dark purple with skull cross overlay
            bodyNode.strokeColor = SKColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 0.8)
            bodyNode.lineWidth   = 2
            addCrossOverlay()

        case .siegeRam:
            // Dark wood with golden trim
            bodyNode.strokeColor = SKColor(red: 0.83, green: 0.63, blue: 0.09, alpha: 0.9)
            bodyNode.lineWidth   = 2.5

        case .harpy:
            // Flying — shadow underneath + bobbing animation
            bodyNode.strokeColor = SKColor(red: 0.7, green: 0.6, blue: 0.85, alpha: 0.8)
            bodyNode.lineWidth   = 1.5
            addFlyingShadow()
            addBobAnimation()

        case .dragonLord:
            // Blood red with bright red rim
            bodyNode.strokeColor = SKColor(red: 1.0, green: 0.25, blue: 0.25, alpha: 0.9)
            bodyNode.lineWidth   = 2.5

        case .necroKing:
            // Royal purple with golden border
            bodyNode.strokeColor = SKColor(red: 0.85, green: 0.60, blue: 0.10, alpha: 0.9)
            bodyNode.lineWidth   = 3

        case .orc:
            // Green with thick outline
            bodyNode.strokeColor = SKColor(red: 0.25, green: 0.40, blue: 0.15, alpha: 0.8)
            bodyNode.lineWidth   = 2

        case .skeleton:
            // Bone with subtle outline
            bodyNode.strokeColor = SKColor(white: 0.6, alpha: 0.5)
            bodyNode.lineWidth   = 1

        case .skeletonSwarm:
            break // Tiny bone dot — no extra visuals

        // ── Ocean ────────────────────────────────────────────────────────

        // Armored: thick stroke matching ocean blue
        case .pirate:
            bodyNode.strokeColor = SKColor(red: 0.0, green: 0.35, blue: 0.65, alpha: 0.85)
            bodyNode.lineWidth   = 2

        // Regen: thick border
        case .seaSerpent:
            bodyNode.strokeColor = SKColor(red: 0.0, green: 0.50, blue: 0.55, alpha: 0.85)
            bodyNode.lineWidth   = 2.5

        // Summoner: cross overlay
        case .anglerFish:
            bodyNode.strokeColor = SKColor(red: 0.0, green: 0.30, blue: 0.50, alpha: 0.8)
            bodyNode.lineWidth   = 2
            addCrossOverlay()

        // Shield: animated shield ring
        case .stormCaster:
            bodyNode.strokeColor = SKColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 0.9)
            bodyNode.lineWidth   = 2
            addShieldRing(color: SKColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 0.95))

        // Flying: shadow + bob
        case .flyingFish:
            bodyNode.strokeColor = SKColor(red: 0.1, green: 0.6, blue: 0.85, alpha: 0.8)
            bodyNode.lineWidth   = 1.5
            addFlyingShadow()
            addBobAnimation()

        // Elite: ghostly alpha + glow stroke
        case .ghostShip:
            bodyNode.alpha       = 0.55
            bodyNode.strokeColor = SKColor(white: 1, alpha: 0.6)
            bodyNode.lineWidth   = 1.5

        // Heavy: golden trim
        case .turtleTank:
            bodyNode.strokeColor = SKColor(red: 0.83, green: 0.63, blue: 0.09, alpha: 0.9)
            bodyNode.lineWidth   = 2.5

        // Dodge: subtle outline
        case .siren:
            bodyNode.strokeColor = SKColor(red: 0.4, green: 0.7, blue: 0.9, alpha: 0.7)
            bodyNode.lineWidth   = 1.5

        // Boss 1
        case .tidalLord:
            bodyNode.strokeColor = SKColor(red: 0.0, green: 0.55, blue: 1.0, alpha: 0.9)
            bodyNode.lineWidth   = 3

        // Boss 2
        case .kraken:
            bodyNode.strokeColor = SKColor(red: 0.0, green: 0.30, blue: 0.70, alpha: 0.9)
            bodyNode.lineWidth   = 3

        // ── Space ────────────────────────────────────────────────────────

        // Armored: thick stroke matching space purple/grey
        case .mechSoldier:
            bodyNode.strokeColor = SKColor(red: 0.35, green: 0.35, blue: 0.55, alpha: 0.85)
            bodyNode.lineWidth   = 2

        // Regen: thick border
        case .plasmaGolem:
            bodyNode.strokeColor = SKColor(red: 0.4, green: 0.2, blue: 0.7, alpha: 0.85)
            bodyNode.lineWidth   = 2.5

        // Summoner: cross overlay
        case .hiveMind:
            bodyNode.strokeColor = SKColor(red: 0.3, green: 0.15, blue: 0.55, alpha: 0.8)
            bodyNode.lineWidth   = 2
            addCrossOverlay()

        // Shield: animated shield ring
        case .voidCaster:
            bodyNode.strokeColor = SKColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 0.9)
            bodyNode.lineWidth   = 2
            addShieldRing(color: SKColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 0.95))

        // Flying: shadow + bob
        case .starfighter:
            bodyNode.strokeColor = SKColor(red: 0.6, green: 0.6, blue: 0.9, alpha: 0.8)
            bodyNode.lineWidth   = 1.5
            addFlyingShadow()
            addBobAnimation()

        // Elite: ghostly alpha + glow stroke
        case .darkMatter:
            bodyNode.alpha       = 0.55
            bodyNode.strokeColor = SKColor(white: 1, alpha: 0.6)
            bodyNode.lineWidth   = 1.5

        // Heavy: golden trim
        case .battleCruiser:
            bodyNode.strokeColor = SKColor(red: 0.83, green: 0.63, blue: 0.09, alpha: 0.9)
            bodyNode.lineWidth   = 2.5

        // Dodge: subtle outline
        case .phaseShifter:
            bodyNode.strokeColor = SKColor(red: 0.6, green: 0.5, blue: 0.9, alpha: 0.7)
            bodyNode.lineWidth   = 1.5

        // Boss 1
        case .admiralZyx:
            bodyNode.strokeColor = SKColor(red: 0.55, green: 0.25, blue: 1.0, alpha: 0.9)
            bodyNode.lineWidth   = 3

        // Boss 2
        case .mothershipOmega:
            bodyNode.strokeColor = SKColor(red: 0.35, green: 0.10, blue: 0.75, alpha: 0.9)
            bodyNode.lineWidth   = 3

        // ── Desert ──────────────────────────────────────────────────────

        // Armored: thick stroke matching desert tan/brown
        case .sandGolem:
            bodyNode.strokeColor = SKColor(red: 0.55, green: 0.38, blue: 0.15, alpha: 0.85)
            bodyNode.lineWidth   = 2

        // Regen: thick border
        case .sandWorm:
            bodyNode.strokeColor = SKColor(red: 0.60, green: 0.42, blue: 0.10, alpha: 0.85)
            bodyNode.lineWidth   = 2.5

        // Summoner: cross overlay
        case .mummy:
            bodyNode.strokeColor = SKColor(red: 0.65, green: 0.55, blue: 0.35, alpha: 0.8)
            bodyNode.lineWidth   = 2
            addCrossOverlay()

        // Shield: animated shield ring
        case .sandSorcerer:
            bodyNode.strokeColor = SKColor(red: 0.85, green: 0.65, blue: 0.20, alpha: 0.9)
            bodyNode.lineWidth   = 2
            addShieldRing(color: SKColor(red: 0.85, green: 0.65, blue: 0.20, alpha: 0.95))

        // Flying: shadow + bob
        case .desertHawk:
            bodyNode.strokeColor = SKColor(red: 0.75, green: 0.55, blue: 0.25, alpha: 0.8)
            bodyNode.lineWidth   = 1.5
            addFlyingShadow()
            addBobAnimation()

        // Elite: ghostly alpha + glow stroke
        case .sphinxWraith:
            bodyNode.alpha       = 0.55
            bodyNode.strokeColor = SKColor(white: 1, alpha: 0.6)
            bodyNode.lineWidth   = 1.5

        // Heavy: golden trim
        case .siegeElephant:
            bodyNode.strokeColor = SKColor(red: 0.83, green: 0.63, blue: 0.09, alpha: 0.9)
            bodyNode.lineWidth   = 2.5

        // Dodge: subtle outline
        case .mirage:
            bodyNode.strokeColor = SKColor(red: 0.85, green: 0.75, blue: 0.50, alpha: 0.7)
            bodyNode.lineWidth   = 1.5

        // Boss 1
        case .pharaohKing:
            bodyNode.strokeColor = SKColor(red: 0.90, green: 0.70, blue: 0.10, alpha: 0.9)
            bodyNode.lineWidth   = 3

        // Boss 2
        case .ancientColossus:
            bodyNode.strokeColor = SKColor(red: 0.70, green: 0.45, blue: 0.10, alpha: 0.9)
            bodyNode.lineWidth   = 3

        // ── Sky ──────────────────────────────────────────────────────────

        // Armored: thick stroke matching sky blue/grey
        case .stormKnight:
            bodyNode.strokeColor = SKColor(red: 0.35, green: 0.50, blue: 0.65, alpha: 0.85)
            bodyNode.lineWidth   = 2

        // Regen: thick border
        case .thunderBeast:
            bodyNode.strokeColor = SKColor(red: 0.40, green: 0.55, blue: 0.20, alpha: 0.85)
            bodyNode.lineWidth   = 2.5

        // Summoner: cross overlay
        case .cloudWeaver:
            bodyNode.strokeColor = SKColor(red: 0.55, green: 0.70, blue: 0.85, alpha: 0.8)
            bodyNode.lineWidth   = 2
            addCrossOverlay()

        // Shield: animated shield ring
        case .galeWizard:
            bodyNode.strokeColor = SKColor(red: 0.50, green: 0.75, blue: 0.95, alpha: 0.9)
            bodyNode.lineWidth   = 2
            addShieldRing(color: SKColor(red: 0.50, green: 0.75, blue: 0.95, alpha: 0.95))

        // Flying: shadow + bob
        case .stormEagle:
            bodyNode.strokeColor = SKColor(red: 0.60, green: 0.65, blue: 0.80, alpha: 0.8)
            bodyNode.lineWidth   = 1.5
            addFlyingShadow()
            addBobAnimation()

        // Elite: ghostly alpha + glow stroke
        case .voidZephyr:
            bodyNode.alpha       = 0.55
            bodyNode.strokeColor = SKColor(white: 1, alpha: 0.6)
            bodyNode.lineWidth   = 1.5

        // Heavy: golden trim
        case .skyFortress:
            bodyNode.strokeColor = SKColor(red: 0.83, green: 0.63, blue: 0.09, alpha: 0.9)
            bodyNode.lineWidth   = 2.5

        // Dodge: subtle outline
        case .fogPhantom:
            bodyNode.strokeColor = SKColor(red: 0.70, green: 0.75, blue: 0.85, alpha: 0.7)
            bodyNode.lineWidth   = 1.5

        // Boss 1
        case .skylordAres:
            bodyNode.strokeColor = SKColor(red: 0.30, green: 0.65, blue: 1.0, alpha: 0.9)
            bodyNode.lineWidth   = 3

        // Boss 2
        case .thunderDragon:
            bodyNode.strokeColor = SKColor(red: 0.55, green: 0.30, blue: 0.90, alpha: 0.9)
            bodyNode.lineWidth   = 3

        default:
            break
        }
    }

    // MARK: - Visual helpers

    private func addCrossOverlay() {
        let crossSize: CGFloat = 6
        let crossThick: CGFloat = 2.5
        let vBar = SKShapeNode(rectOf: CGSize(width: crossThick, height: crossSize))
        vBar.fillColor   = SKColor(white: 0.85, alpha: 0.85)
        vBar.strokeColor = .clear
        let hBar = SKShapeNode(rectOf: CGSize(width: crossSize, height: crossThick))
        hBar.fillColor   = SKColor(white: 0.85, alpha: 0.85)
        hBar.strokeColor = .clear
        bodyNode.addChild(vBar)
        bodyNode.addChild(hBar)
    }

    private func addShieldRing(color: SKColor) {
        let shield = SKShapeNode(circleOfRadius: 15)
        shield.fillColor   = color.withAlphaComponent(0.15)
        shield.strokeColor = color
        shield.lineWidth   = 2.5
        shield.run(.repeatForever(.sequence([
            .scale(to: 1.12, duration: 0.55),
            .scale(to: 1.00, duration: 0.55)
        ])))
        addChild(shield)
        shieldNode = shield
    }

    private func addFlyingShadow() {
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 16, height: 6))
        shadow.fillColor   = SKColor(white: 0, alpha: 0.25)
        shadow.strokeColor = .clear
        shadow.position    = CGPoint(x: 0, y: -16)
        shadow.zPosition   = -1
        addChild(shadow)
    }

    private func addBobAnimation() {
        bodyNode.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 4, duration: 0.5),
            .moveBy(x: 0, y: -4, duration: 0.5)
        ])))
    }

    // MARK: - Sprite overlay

    private var spriteNode: SKSpriteNode?
    private var sideWalkFrames: [SKTexture] = []
    private var frontWalkFrames: [SKTexture] = []
    private var currentAnim: SpriteAnim = .side

    private enum SpriteAnim { case side, front }

    private func applySprite(size sz: CGSize) {
        switch enemyType {
        case .goblin:
            setupWalkSprite(
                sidePrefix: "goblin_walk", sideCount: 21,
                frontPrefix: "goblin_front", frontCount: 30,
                size: sz, scale: 1.4
            )

        case .orc:
            setupWalkSprite(
                sidePrefix: "orc_walk", sideCount: 30,
                frontPrefix: "orc_front", frontCount: 30,
                size: sz, scale: 1.4
            )

        default:
            break
        }
    }

    private func setupWalkSprite(sidePrefix: String, sideCount: Int, frontPrefix: String, frontCount: Int, size sz: CGSize, scale: CGFloat) {
        sideWalkFrames = (0..<sideCount).map {
            let tex = SKTexture(imageNamed: String(format: "%@_%02d", sidePrefix, $0))
            tex.filteringMode = .nearest
            return tex
        }
        frontWalkFrames = (0..<frontCount).map {
            let tex = SKTexture(imageNamed: String(format: "%@_%02d", frontPrefix, $0))
            tex.filteringMode = .nearest
            return tex
        }
        guard !sideWalkFrames.isEmpty else { return }
        let sprite = SKSpriteNode(texture: sideWalkFrames[0])
        sprite.size = CGSize(width: sz.width * scale, height: sz.height * scale)
        sprite.zPosition = 1
        sprite.run(.repeatForever(.animate(with: sideWalkFrames, timePerFrame: 0.07)), withKey: "anim")
        addChild(sprite)
        spriteNode = sprite
        currentAnim = .side
        bodyNode.isHidden = true
    }

    /// Switch animation and flip sprite based on movement direction
    func updateSpriteDirection(dx: CGFloat, dy: CGFloat) {
        guard let sprite = spriteNode else { return }
        let isVertical = abs(dy) > abs(dx)

        if isVertical && !frontWalkFrames.isEmpty && currentAnim != .front {
            sprite.removeAction(forKey: "anim")
            sprite.run(.repeatForever(.animate(with: frontWalkFrames, timePerFrame: 0.07)), withKey: "anim")
            sprite.xScale = abs(sprite.xScale)
            currentAnim = .front
        } else if !isVertical && !sideWalkFrames.isEmpty && currentAnim != .side {
            sprite.removeAction(forKey: "anim")
            sprite.run(.repeatForever(.animate(with: sideWalkFrames, timePerFrame: 0.07)), withKey: "anim")
            currentAnim = .side
        }

        if !isVertical && dx != 0 {
            if dx > 0 {
                sprite.xScale = abs(sprite.xScale)
            } else {
                sprite.xScale = -abs(sprite.xScale)
            }
        }
    }

    // MARK: - Movement

    func startMoving(fromWaypoint index: Int = 1) {
        waypointIndex = max(index, 1)
        let waypoints = PathSystem.waypoints
        guard waypointIndex < waypoints.count else { return }

        var actions: [SKAction] = []
        var prevPt = waypoints[waypointIndex - 1]

        for i in waypointIndex..<waypoints.count {
            let wp       = waypoints[i]
            let dist     = prevPt.distance(to: wp)
            let duration = TimeInterval(dist / moveSpeed)
            let captured = i
            let dx = wp.x - prevPt.x
            let dy = wp.y - prevPt.y
            actions.append(.run { [weak self] in self?.updateSpriteDirection(dx: dx, dy: dy) })
            actions.append(.move(to: wp, duration: duration))
            actions.append(.run { [weak self] in self?.waypointIndex = captured })
            prevPt = wp
        }

        actions.append(.run { [weak self] in
            guard let self, !self.isDead else { return }
            self.isDead = true
            self.removeFromParent()
            self.onReachEnd?(self)
            self.onReachEnd = nil
            self.onDeath = nil
        })

        run(.sequence(actions), withKey: "move")
    }

    // MARK: - Damage / Heal

    func takeDamage(_ rawDamage: CGFloat, ignoresArmor: Bool = false) {
        guard !isDead else { return }

        // Dodge check (bandit / wraith)
        if enemyType.dodgeChance > 0, Double.random(in: 0...1) < enemyType.dodgeChance {
            showDodgeFlash()
            return
        }

        var dmg = rawDamage
        if !ignoresArmor { dmg *= enemyType.damageReduction }

        // Shield absorbs first
        if remainingShield > 0 {
            if dmg <= remainingShield {
                remainingShield -= dmg
                shieldNode?.run(.sequence([
                    .colorize(with: .white, colorBlendFactor: 0.8, duration: 0.04),
                    .colorize(withColorBlendFactor: 0, duration: 0.12)
                ]))
                return
            } else {
                dmg -= remainingShield
                remainingShield = 0
                shieldNode?.run(.sequence([
                    .scale(to: 1.4, duration: 0.08),
                    .fadeOut(withDuration: 0.1),
                    .removeFromParent()
                ]))
                shieldNode = nil
            }
        }

        currentHP -= dmg
        updateHPBar()

        if currentHP <= 0 { die() }
    }

    private func heal(_ amount: CGFloat) {
        guard !isDead else { return }
        currentHP = min(maxHP, currentHP + amount)
        updateHPBar()
    }

    func die() {
        guard !isDead else { return }
        isDead = true
        removeAction(forKey: "move")
        removeAction(forKey: "regen")
        run(.sequence([.fadeAlpha(to: 0, duration: 0.12), .removeFromParent()]))
        onDeath?(self)
        onDeath = nil
        onReachEnd = nil
    }

    // MARK: - Slow

    func applySlowEffect(factor: CGFloat = 0.5, duration: TimeInterval = 2.0) {
        guard !enemyType.slowImmune, !isSlowed else { return }
        isSlowed = true
        self.speed = factor
        // Teal tint via colorize so it layers cleanly over any existing fill
        bodyNode.run(.colorize(with: .tdAccentTeal, colorBlendFactor: 0.85, duration: 0.1))
        removeAction(forKey: "slowTimer")
        run(.sequence([
            .wait(forDuration: duration),
            .run { [weak self] in self?.removeSlow() }
        ]), withKey: "slowTimer")
    }

    private func removeSlow() {
        isSlowed = false
        self.speed = 1.0
        bodyNode.run(.colorize(withColorBlendFactor: 0, duration: 0.15))
    }

    // MARK: - Special effects

    private func showDodgeFlash() {
        bodyNode.run(.sequence([
            .colorize(with: .white, colorBlendFactor: 1.0, duration: 0.04),
            .colorize(withColorBlendFactor: 0, duration: 0.12)
        ]))
    }

    // MARK: - Tower hit effects

    func applyHitEffect(from towerType: TowerType) {
        guard !isDead else { return }
        switch towerType {

        // ── Yellow flash (archer-class) ───────────────────────────────────
        case .archer,
             .harpoonGun, .laserTurret, .spearThrower, .windCannon:
            bodyNode.run(.sequence([
                .colorize(with: SKColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1),
                          colorBlendFactor: 0.6, duration: 0.03),
                .colorize(withColorBlendFactor: 0, duration: 0.1)
            ]))

        // ── Orange flash + shake (catapult-class) ────────────────────────
        case .catapult,
             .depthCharge, .missilePod, .boulderSling, .thunderCloud:
            bodyNode.run(.sequence([
                .colorize(with: SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1),
                          colorBlendFactor: 0.7, duration: 0.04),
                .group([
                    .sequence([
                        .moveBy(x: 3, y: 0, duration: 0.03),
                        .moveBy(x: -6, y: 0, duration: 0.03),
                        .moveBy(x: 3, y: 0, duration: 0.03)
                    ]),
                    .colorize(withColorBlendFactor: 0, duration: 0.15)
                ])
            ]))

        // ── Purple flash + squish (wizard-class) ─────────────────────────
        case .wizard,
             .coralMage, .plasmaBeam, .sunMirror, .lightningRod:
            bodyNode.run(.sequence([
                .colorize(with: SKColor(red: 0.6, green: 0.3, blue: 1.0, alpha: 1),
                          colorBlendFactor: 0.8, duration: 0.03),
                .group([
                    .sequence([
                        .scale(to: 0.85, duration: 0.05),
                        .scale(to: 1.0, duration: 0.1)
                    ]),
                    .colorize(withColorBlendFactor: 0, duration: 0.12)
                ])
            ]))

        // ── Support towers — no hit effect ───────────────────────────────
        case .blacksmith,
             .pearlShrine, .shieldGen, .obelisk, .skyShrine,
             .fogHorn, .commsArray, .warDrum, .windChime:
            break

        // ── Green flash + expand (alchemist-class) ───────────────────────
        case .alchemist,
             .toxicReef, .acidSprayer, .venomPit, .stormBrew:
            bodyNode.run(.sequence([
                .colorize(with: SKColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1),
                          colorBlendFactor: 0.7, duration: 0.04),
                .group([
                    .sequence([
                        .scale(to: 1.15, duration: 0.06),
                        .scale(to: 1.0, duration: 0.1)
                    ]),
                    .colorize(withColorBlendFactor: 0, duration: 0.18)
                ])
            ]))

        // ── Red flash + squish (ballista-class) ──────────────────────────
        case .ballista,
             .tridentTower, .railgun, .scorpionBow, .galeForce:
            bodyNode.run(.sequence([
                .colorize(with: SKColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 1),
                          colorBlendFactor: 0.85, duration: 0.02),
                .group([
                    .sequence([
                        .scale(to: 0.75, duration: 0.05),
                        .scale(to: 1.0, duration: 0.1)
                    ]),
                    .colorize(withColorBlendFactor: 0, duration: 0.12)
                ])
            ]))

        // ── Blue flash (moat-class) ───────────────────────────────────────
        case .moat,
             .whirlpool, .gravityWell, .quicksand, .cloudTrap:
            bodyNode.run(.sequence([
                .colorize(with: SKColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1),
                          colorBlendFactor: 0.6, duration: 0.04),
                .colorize(withColorBlendFactor: 0, duration: 0.2)
            ]))

        case .bellTower:
            break
        }
    }

    // MARK: - HP bar

    private func updateHPBar() {
        let fraction = max(0, currentHP / maxHP)
        let fullW    = enemyType.size.width
        hpBarFill.xScale     = fraction
        hpBarFill.position.x = -(fullW / 2) * (1 - fraction)
        hpBarFill.fillColor  = fraction > 0.5
            ? SKColor(red: 0.2, green: 0.9, blue: 0.2, alpha: 1)
            : fraction > 0.25
                ? SKColor(red: 0.9, green: 0.72, blue: 0.1, alpha: 1)
                : SKColor(red: 0.9, green: 0.2, blue: 0.1, alpha: 1)
    }
}
