import SpriteKit

final class GameScene: SKScene {
    // MARK: - State (set before didMove)
    unowned let gameState: GameState
    unowned let appState: AppState

    // MARK: - Systems
    private(set) var waveSystem: WaveSystem!

    // MARK: - Grid
    static let cols = 9
    static let rows = 18
    var grid: [[GridCell]] = []

    // MARK: - Node layers
    private let towerLayer      = SKNode()
    private let enemyLayer      = SKNode()
    private let projectileLayer = SKNode()

    var placedTowers: [TowerNode]           = []
    var activeProjectiles: [ProjectileNode] = []
    var poisonZones: [PoisonZoneNode]       = []

    private var lastUpdateTime: TimeInterval?
    private var moatTowerCache: [TowerNode] = []
    private var moatTickCounter: Int = 0
    private lazy var cullRect: CGRect = {
        CGRect(origin: .zero, size: size).insetBy(dx: -40, dy: -40)
    }()
    private var ghostContainer: SKNode?
    private var ghostBody: SKShapeNode?
    private var ghostRing: SKShapeNode?
    private var ghostCurrentCell: GridCoord?
    private var ghostCurrentType: TowerType?

    // MARK: - Init

    init(gameState: GameState, appState: AppState) {
        self.gameState = gameState
        self.appState  = appState
        let cs = 390.0 / CGFloat(GameScene.cols)
        super.init(size: CGSize(width: 390, height: cs * CGFloat(GameScene.rows)))
    }

    required init?(coder: NSCoder) { fatalError() }

    deinit {
        cleanup()
    }

    func cleanup() {
        // Detach scene from SKView immediately to release SpriteView→SKScene connection
        view?.presentScene(nil)
        removeAllActions()
        // Nil wave system callbacks to break cycles
        waveSystem?.onWaveComplete = nil
        waveSystem?.onEnemyReachedEnd = nil
        // Nil closures on active projectiles
        for proj in activeProjectiles {
            proj.onReachTarget = nil
            proj.onPierceHit = nil
        }
        // Nil closures on active enemies
        for enemy in (waveSystem?.activeEnemies ?? []) {
            enemy.onDeath = nil
            enemy.onReachEnd = nil
            enemy.removeAllActions()
        }
        activeProjectiles.removeAll()
        poisonZones.removeAll()
        placedTowers.removeAll()
        removeAllChildren()
        waveSystem = nil
    }

    // MARK: - didMove

    override func didMove(to view: SKView) {
        backgroundColor = .tdBackground
        physicsWorld.gravity  = .zero
        physicsWorld.contactDelegate = self
        view.preferredFramesPerSecond = 60
        view.clipsToBounds = true

        // Set actual scene width so grid/path fill the screen
        TowerPlacementSystem.sceneWidth = size.width

        // Set map before generating path/grid
        PathSystem.currentMap = gameState.selectedMap

        setupBackground()

        towerLayer.zPosition = 2
        enemyLayer.zPosition = 3
        projectileLayer.zPosition = 4
        addChild(towerLayer)
        addChild(enemyLayer)
        addChild(projectileLayer)

        setupGrid()
        addChild(PathNode(waypoints: PathSystem.waypoints, roadWidth: 36, mapType: gameState.selectedMap))

        waveSystem = WaveSystem(scene: self, gameState: gameState)
        waveSystem.onWaveComplete    = { [weak self] in self?.handleWaveComplete() }
        waveSystem.onEnemyReachedEnd = { [weak self] in self?.handleEnemyReachedEnd() }

    }

    // MARK: - Outdoor background

    private func setupBackground() {
        let bgLayer = SKNode()
        bgLayer.zPosition = -10

        let cs = TowerPlacementSystem.cellSize
        var rng = BackgroundRNG(seed: 99)
        let map = gameState.selectedMap

        // Ground tiles — color varies by map
        let blockedMinRow = GameScene.rows - 4
        for row in 0..<GameScene.rows {
            for col in 0..<GameScene.cols {
                let coord = GridCoord(col: col, row: row)
                let isPath = PathSystem.pathCells.contains(coord)
                guard !isPath else { continue }

                let cx = CGFloat(col) * cs + cs / 2
                let cy = CGFloat(row) * cs + cs / 2

                let patch = SKShapeNode(rectOf: CGSize(width: cs + 1, height: cs + 1))
                if row >= blockedMinRow {
                    patch.fillColor = SKColor(red: 0.102, green: 0.071, blue: 0.031, alpha: 0.95)
                } else {
                    let shade = CGFloat(rng.next() % 20) / 100.0 - 0.1
                    switch map {
                    case .forest:
                        patch.fillColor = SKColor(
                            red: 0.08 + shade * 0.2,
                            green: 0.14 + shade * 0.6,
                            blue: 0.06 + shade * 0.15, alpha: 1)
                    case .courtyard:
                        patch.fillColor = SKColor(
                            red: 0.42 + shade * 0.3,
                            green: 0.40 + shade * 0.3,
                            blue: 0.36 + shade * 0.3, alpha: 1)
                    case .mountain:
                        patch.fillColor = SKColor(
                            red: 0.35 + shade * 0.3,
                            green: 0.32 + shade * 0.2,
                            blue: 0.28 + shade * 0.2, alpha: 1)
                    }
                }
                patch.strokeColor = .clear
                patch.position = CGPoint(x: cx, y: cy)
                bgLayer.addChild(patch)
            }
        }

        let w = size.width

        // Map-specific decorations
        switch map {
        case .forest:
            // Dark grass clusters
            for _ in 0..<80 {
                let x = CGFloat(rng.next() % UInt64(w - 10)) + 5
                let row = Int(rng.next() % UInt64(GameScene.rows - 4))
                let y = CGFloat(row) * cs + CGFloat(rng.next() % UInt64(cs))
                let coord = GridCoord(col: Int(x / cs), row: Int(y / cs))
                if PathSystem.pathCells.contains(coord) { continue }
                let tuft = darkGrassTuft(rng: &rng)
                tuft.position = CGPoint(x: x, y: y)
                bgLayer.addChild(tuft)
            }
            // Dark trees — randomly placed, avoiding path by pixel distance
            let maxTreeY = CGFloat(blockedMinRow) * cs - 40
            let wps = PathSystem.waypoints
            let minPathDist: CGFloat = 55  // min px from path centerline
            let minTreeDist: CGFloat = 45  // min px between tree centers
            var placedTreePts: [CGPoint] = []
            let treeTarget = 25
            for _ in 0..<120 {  // up to 120 candidates
                if placedTreePts.count >= treeTarget { break }
                let tx = CGFloat(rng.next() % UInt64(w - 30)) + 15
                let ty = CGFloat(rng.next() % UInt64(max(Int(maxTreeY) - 20, 1))) + 10
                let coord = GridCoord(col: Int(tx / cs), row: Int(ty / cs))
                if coord.row >= blockedMinRow { continue }
                // Check pixel distance to every path segment
                let pt = CGPoint(x: tx, y: ty)
                var tooClose = false
                for i in 0..<(wps.count - 1) {
                    let d = pt.distanceToSegment(a: wps[i], b: wps[i + 1])
                    if d < minPathDist { tooClose = true; break }
                }
                if tooClose { continue }
                // Check distance to already-placed trees
                for prev in placedTreePts {
                    let dx = pt.x - prev.x, dy = pt.y - prev.y
                    if dx * dx + dy * dy < minTreeDist * minTreeDist {
                        tooClose = true; break
                    }
                }
                if tooClose { continue }
                placedTreePts.append(pt)
                let tree = buildDarkTree(rng: &rng)
                let s = 1.3 + CGFloat(rng.next() % 50) / 100.0
                tree.xScale = s
                tree.yScale = s
                tree.position = pt
                bgLayer.addChild(tree)
            }
            // Glowing mushrooms
            for _ in 0..<25 {
                let x = CGFloat(rng.next() % UInt64(w - 20)) + 10
                let row = Int(rng.next() % UInt64(GameScene.rows - 4))
                let y = CGFloat(row) * cs + CGFloat(rng.next() % UInt64(cs))
                let coord = GridCoord(col: Int(x / cs), row: Int(y / cs))
                if PathSystem.pathCells.contains(coord) { continue }
                let mush = buildGlowingMushroom(rng: &rng)
                mush.position = CGPoint(x: x, y: y)
                bgLayer.addChild(mush)
            }
            // Dark ferns
            for _ in 0..<30 {
                let x = CGFloat(rng.next() % UInt64(w - 20)) + 10
                let row = Int(rng.next() % UInt64(GameScene.rows - 4))
                let y = CGFloat(row) * cs + CGFloat(rng.next() % UInt64(cs))
                let coord = GridCoord(col: Int(x / cs), row: Int(y / cs))
                if PathSystem.pathCells.contains(coord) { continue }
                let fern = buildDarkFern(rng: &rng)
                fern.position = CGPoint(x: x, y: y)
                bgLayer.addChild(fern)
            }
            // Fireflies
            for _ in 0..<20 {
                let x = CGFloat(rng.next() % UInt64(w - 20)) + 10
                let row = Int(rng.next() % UInt64(GameScene.rows - 4))
                let y = CGFloat(row) * cs + CGFloat(rng.next() % UInt64(cs))
                let fly = buildFirefly(rng: &rng)
                fly.position = CGPoint(x: x, y: y)
                bgLayer.addChild(fly)
            }
            // Fog patches
            for _ in 0..<15 {
                let x = CGFloat(rng.next() % UInt64(w - 20)) + 10
                let row = Int(rng.next() % UInt64(GameScene.rows - 4))
                let y = CGFloat(row) * cs + CGFloat(rng.next() % UInt64(cs))
                let fog = buildFogPatch(rng: &rng)
                fog.position = CGPoint(x: x, y: y)
                bgLayer.addChild(fog)
            }

        case .courtyard:
            // Stone wall sections along edges
            for row in stride(from: 0, to: GameScene.rows - 4, by: 3) {
                for col in [0, GameScene.cols - 1] {
                    let coord = GridCoord(col: col, row: row)
                    if PathSystem.pathCells.contains(coord) { continue }
                    let cx = CGFloat(col) * cs + cs / 2
                    let cy = CGFloat(row) * cs + cs / 2
                    let wall = SKShapeNode(rectOf: CGSize(width: cs - 2, height: cs * 2), cornerRadius: 3)
                    wall.fillColor = SKColor(red: 0.50, green: 0.48, blue: 0.44, alpha: 0.7)
                    wall.strokeColor = SKColor(red: 0.40, green: 0.38, blue: 0.34, alpha: 0.5)
                    wall.lineWidth = 1
                    wall.position = CGPoint(x: cx, y: cy)
                    bgLayer.addChild(wall)
                }
            }
            // Torch sconces with flicker
            for row in stride(from: 2, to: GameScene.rows - 4, by: 4) {
                for col in [1, GameScene.cols - 2] {
                    let coord = GridCoord(col: col, row: row)
                    if PathSystem.pathCells.contains(coord) { continue }
                    let cx = CGFloat(col) * cs + cs / 2
                    let cy = CGFloat(row) * cs + cs / 2
                    let torch = SKShapeNode(circleOfRadius: 4)
                    torch.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 0.8)
                    torch.strokeColor = .clear
                    torch.position = CGPoint(x: cx, y: cy)
                    torch.run(.repeatForever(.sequence([
                        .fadeAlpha(to: 0.5, duration: 0.3),
                        .fadeAlpha(to: 1.0, duration: 0.3)
                    ])))
                    bgLayer.addChild(torch)
                }
            }

        case .mountain:
            // Boulders
            for _ in 0..<35 {
                let x = CGFloat(rng.next() % UInt64(w - 20)) + 10
                let row = Int(rng.next() % UInt64(GameScene.rows - 4))
                let y = CGFloat(row) * cs + CGFloat(rng.next() % UInt64(cs))
                let coord = GridCoord(col: Int(x / cs), row: Int(y / cs))
                if PathSystem.pathCells.contains(coord) { continue }
                let rock = buildRock(rng: &rng, mapType: map)
                rock.xScale = 1.5
                rock.yScale = 1.5
                rock.position = CGPoint(x: x, y: y)
                bgLayer.addChild(rock)
            }
            // Snow patches at top
            for _ in 0..<20 {
                let x = CGFloat(rng.next() % UInt64(w - 20)) + 10
                let row = Int(rng.next() % UInt64(4)) + GameScene.rows - 8
                if row >= blockedMinRow { continue }
                let y = CGFloat(row) * cs + CGFloat(rng.next() % UInt64(cs))
                let coord = GridCoord(col: Int(x / cs), row: Int(y / cs))
                if PathSystem.pathCells.contains(coord) { continue }
                let snow = SKShapeNode(circleOfRadius: CGFloat(4 + Int(rng.next() % 5)))
                snow.fillColor = SKColor(white: 0.92, alpha: 0.3)
                snow.strokeColor = .clear
                snow.position = CGPoint(x: x, y: y)
                bgLayer.addChild(snow)
            }
        }

        // Rocks on all maps
        for _ in 0..<25 {
            let x = CGFloat(rng.next() % UInt64(w - 20)) + 10
            let row = Int(rng.next() % UInt64(GameScene.rows - 4))
            let y = CGFloat(row) * cs + CGFloat(rng.next() % UInt64(cs))
            let coord = GridCoord(col: Int(x / cs), row: Int(y / cs))
            if PathSystem.pathCells.contains(coord) { continue }
            let rock = buildRock(rng: &rng, mapType: map)
            rock.position = CGPoint(x: x, y: y)
            bgLayer.addChild(rock)
        }

        addChild(bgLayer)

        // Subtle dark overlay for forest atmosphere
        if map == .forest {
            let overlay = SKShapeNode(rectOf: size)
            overlay.fillColor = SKColor(red: 0.0, green: 0.03, blue: 0.0, alpha: 0.08)
            overlay.strokeColor = .clear
            overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
            overlay.zPosition = 5
            addChild(overlay)
        }
    }

    private func grassTuft(rng: inout BackgroundRNG) -> SKNode {
        let node = SKNode()
        let count = 2 + Int(rng.next() % 3)
        for i in 0..<count {
            let h = CGFloat(6 + Int(rng.next() % 6))
            let blade = SKShapeNode(rectOf: CGSize(width: 1.5, height: h))
            blade.fillColor = SKColor(
                red: 0.2,
                green: 0.50 + CGFloat(rng.next() % 20) / 100.0,
                blue: 0.12,
                alpha: 0.7
            )
            blade.strokeColor = .clear
            blade.position = CGPoint(x: CGFloat(i) * 3 - 3, y: h / 2)
            blade.zRotation = CGFloat(Int(rng.next() % 30)) / 100.0 - 0.15
            node.addChild(blade)
        }
        return node
    }

    private func buildTree(rng: inout BackgroundRNG) -> SKNode {
        let node = SKNode()
        // Trunk
        let trunkH: CGFloat = 10 + CGFloat(rng.next() % 6)
        let trunk = SKShapeNode(rectOf: CGSize(width: 5, height: trunkH), cornerRadius: 1)
        trunk.fillColor = SKColor(red: 0.40, green: 0.28, blue: 0.14, alpha: 1)
        trunk.strokeColor = .clear
        trunk.position = CGPoint(x: 0, y: trunkH / 2)
        node.addChild(trunk)

        // Canopy — layered circles
        let canopyR: CGFloat = 10 + CGFloat(rng.next() % 5)
        let canopy = SKShapeNode(circleOfRadius: canopyR)
        canopy.fillColor = SKColor(
            red: 0.14 + CGFloat(rng.next() % 8) / 100.0,
            green: 0.40 + CGFloat(rng.next() % 15) / 100.0,
            blue: 0.10,
            alpha: 0.9
        )
        canopy.strokeColor = SKColor(red: 0.10, green: 0.30, blue: 0.08, alpha: 0.5)
        canopy.lineWidth = 1
        canopy.position = CGPoint(x: 0, y: trunkH + canopyR * 0.6)
        node.addChild(canopy)

        // Highlight on canopy
        let highlight = SKShapeNode(circleOfRadius: canopyR * 0.5)
        highlight.fillColor = SKColor(red: 0.22, green: 0.55, blue: 0.18, alpha: 0.5)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -canopyR * 0.2, y: canopyR * 0.25)
        canopy.addChild(highlight)

        return node
    }

    private func buildRock(rng: inout BackgroundRNG, mapType: MapType = .forest) -> SKNode {
        let w = CGFloat(6 + Int(rng.next() % 6))
        let h = CGFloat(4 + Int(rng.next() % 4))
        let rock = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: min(w, h) * 0.4)
        let shade = CGFloat(rng.next() % 15) / 100.0
        if mapType == .forest {
            rock.fillColor = SKColor(red: 0.28 + shade, green: 0.25 + shade, blue: 0.22 + shade, alpha: 0.6)
            rock.strokeColor = SKColor(red: 0.18, green: 0.16, blue: 0.14, alpha: 0.4)
        } else {
            rock.fillColor = SKColor(red: 0.45 + shade, green: 0.43 + shade, blue: 0.40 + shade, alpha: 0.8)
            rock.strokeColor = SKColor(red: 0.35, green: 0.33, blue: 0.30, alpha: 0.4)
        }
        rock.lineWidth = 0.5
        rock.zRotation = CGFloat(Int(rng.next() % 60)) / 100.0 - 0.3
        return rock
    }

    private func buildFlower(rng: inout BackgroundRNG) -> SKNode {
        let node = SKNode()
        // Stem
        let stem = SKShapeNode(rectOf: CGSize(width: 1, height: 5))
        stem.fillColor = SKColor(red: 0.2, green: 0.5, blue: 0.15, alpha: 0.8)
        stem.strokeColor = .clear
        stem.position = CGPoint(x: 0, y: 2.5)
        node.addChild(stem)

        // Petals
        let colors: [SKColor] = [
            SKColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 0.9),   // yellow
            SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 0.9),    // red
            SKColor(red: 0.9, green: 0.5, blue: 0.9, alpha: 0.9),    // pink
            SKColor(red: 0.6, green: 0.7, blue: 1.0, alpha: 0.9),    // blue
            SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9),    // white
        ]
        let color = colors[Int(rng.next() % UInt64(colors.count))]
        let petal = SKShapeNode(circleOfRadius: 2.5)
        petal.fillColor = color
        petal.strokeColor = .clear
        petal.position = CGPoint(x: 0, y: 6)
        node.addChild(petal)
        return node
    }

    // MARK: - Dark Forest Decorations

    private func darkGrassTuft(rng: inout BackgroundRNG) -> SKNode {
        let node = SKNode()
        let count = 2 + Int(rng.next() % 3)
        for i in 0..<count {
            let h = CGFloat(7 + Int(rng.next() % 7))
            let blade = SKShapeNode(rectOf: CGSize(width: 1.5, height: h))
            let isDead = rng.next() % 100 < 30
            if isDead {
                blade.fillColor = SKColor(red: 0.18, green: 0.12, blue: 0.06, alpha: 0.55)
            } else {
                let v = CGFloat(rng.next() % 10) / 100.0
                blade.fillColor = SKColor(red: 0.10, green: 0.22 + v, blue: 0.06, alpha: 0.65)
            }
            blade.strokeColor = .clear
            blade.position = CGPoint(x: CGFloat(i) * 3 - 3, y: h / 2)
            blade.zRotation = CGFloat(Int(rng.next() % 30)) / 100.0 - 0.15
            node.addChild(blade)
        }
        return node
    }

    private func buildDarkTree(rng: inout BackgroundRNG) -> SKNode {
        let node = SKNode()
        // Main trunk — wider and taller
        let trunkH: CGFloat = 14 + CGFloat(rng.next() % 8)
        let trunk = SKShapeNode(rectOf: CGSize(width: 7, height: trunkH), cornerRadius: 1)
        trunk.fillColor = SKColor(red: 0.20, green: 0.14, blue: 0.08, alpha: 1)
        trunk.strokeColor = .clear
        trunk.position = CGPoint(x: 0, y: trunkH / 2)
        node.addChild(trunk)

        // Second gnarled trunk piece
        let trunk2 = SKShapeNode(rectOf: CGSize(width: 4, height: trunkH * 0.7), cornerRadius: 1)
        trunk2.fillColor = SKColor(red: 0.16, green: 0.11, blue: 0.06, alpha: 0.8)
        trunk2.strokeColor = .clear
        trunk2.position = CGPoint(x: 3, y: trunkH * 0.3)
        trunk2.zRotation = 0.15
        node.addChild(trunk2)

        // Main canopy
        let canopyR: CGFloat = 14 + CGFloat(rng.next() % 6)
        let canopyVar = CGFloat(rng.next() % 8) / 100.0
        let canopy = SKShapeNode(circleOfRadius: canopyR)
        canopy.fillColor = SKColor(
            red: 0.08 + canopyVar,
            green: 0.20 + canopyVar,
            blue: 0.06,
            alpha: 0.85
        )
        canopy.strokeColor = SKColor(red: 0.05, green: 0.14, blue: 0.04, alpha: 0.5)
        canopy.lineWidth = 1
        canopy.position = CGPoint(x: 0, y: trunkH + canopyR * 0.6)
        node.addChild(canopy)

        // Second overlapping canopy for depth
        let canopy2R = canopyR * 0.75
        let canopy2 = SKShapeNode(circleOfRadius: canopy2R)
        canopy2.fillColor = SKColor(
            red: 0.06 + canopyVar,
            green: 0.16 + canopyVar,
            blue: 0.04,
            alpha: 0.7
        )
        canopy2.strokeColor = .clear
        canopy2.position = CGPoint(x: canopyR * 0.3, y: -canopyR * 0.15)
        canopy.addChild(canopy2)

        // Subtle dark highlight (no bright highlight)
        let highlight = SKShapeNode(circleOfRadius: canopyR * 0.3)
        highlight.fillColor = SKColor(red: 0.10, green: 0.22, blue: 0.08, alpha: 0.3)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -canopyR * 0.2, y: canopyR * 0.2)
        canopy.addChild(highlight)

        // 50% chance of hanging roots/branches
        if rng.next() % 2 == 0 {
            let rootCount = 2 + Int(rng.next() % 2)
            for r in 0..<rootCount {
                let rootLen = CGFloat(8 + Int(rng.next() % 6))
                let root = SKShapeNode(rectOf: CGSize(width: 1, height: rootLen))
                root.fillColor = SKColor(red: 0.14, green: 0.10, blue: 0.06, alpha: 0.5)
                root.strokeColor = .clear
                let xOff = CGFloat(r) * 6 - 4
                root.position = CGPoint(x: xOff, y: -canopyR - rootLen / 2 + 2)
                canopy.addChild(root)
            }
        }

        return node
    }

    private func buildGlowingMushroom(rng: inout BackgroundRNG) -> SKNode {
        let node = SKNode()
        // Stem
        let stem = SKShapeNode(rectOf: CGSize(width: 1.5, height: 4))
        stem.fillColor = SKColor(red: 0.15, green: 0.12, blue: 0.10, alpha: 0.8)
        stem.strokeColor = .clear
        stem.position = CGPoint(x: 0, y: 2)
        node.addChild(stem)

        // Cap
        let isTeal = rng.next() % 100 < 60
        let glowColor: SKColor
        if isTeal {
            glowColor = SKColor(red: 0.1, green: 0.7, blue: 0.5, alpha: 1)
        } else {
            glowColor = SKColor(red: 0.35, green: 0.2, blue: 0.8, alpha: 1)
        }
        let cap = SKShapeNode(circleOfRadius: 3)
        cap.fillColor = glowColor
        cap.strokeColor = .clear
        cap.position = CGPoint(x: 0, y: 5.5)
        node.addChild(cap)

        // Glow halo behind cap
        let halo = SKShapeNode(circleOfRadius: 6)
        if isTeal {
            halo.fillColor = SKColor(red: 0.1, green: 0.7, blue: 0.5, alpha: 0.15)
        } else {
            halo.fillColor = SKColor(red: 0.35, green: 0.2, blue: 0.8, alpha: 0.15)
        }
        halo.strokeColor = .clear
        halo.position = CGPoint(x: 0, y: 5.5)
        halo.zPosition = -0.1
        node.addChild(halo)

        // Pulse animation
        let delay = Double(rng.next() % 200) / 100.0
        let pulse = SKAction.sequence([
            .wait(forDuration: delay),
            .repeatForever(.sequence([
                .fadeAlpha(to: 0.4, duration: 1.5),
                .fadeAlpha(to: 0.8, duration: 1.5)
            ]))
        ])
        node.run(pulse)

        return node
    }

    private func buildDarkFern(rng: inout BackgroundRNG) -> SKNode {
        let node = SKNode()
        let bladeCount = 3 + Int(rng.next() % 3)
        for i in 0..<bladeCount {
            let h = CGFloat(8 + Int(rng.next() % 6))
            let blade = SKShapeNode(rectOf: CGSize(width: 2, height: h))
            let v = CGFloat(rng.next() % 10) / 100.0
            blade.fillColor = SKColor(red: 0.10, green: 0.25 + v, blue: 0.06, alpha: 0.7)
            blade.strokeColor = .clear
            let spread = -0.4 + 0.8 * CGFloat(i) / CGFloat(max(bladeCount - 1, 1))
            blade.position = CGPoint(x: 0, y: h / 2)
            blade.zRotation = spread
            node.addChild(blade)
        }
        return node
    }

    private func buildFirefly(rng: inout BackgroundRNG) -> SKNode {
        let node = SKNode()
        // Glow halo
        let halo = SKShapeNode(circleOfRadius: 4)
        halo.fillColor = SKColor(red: 0.5, green: 0.9, blue: 0.2, alpha: 0.12)
        halo.strokeColor = .clear
        node.addChild(halo)
        // Dot
        let dot = SKShapeNode(circleOfRadius: 1.5)
        dot.fillColor = SKColor(red: 0.5, green: 0.9, blue: 0.2, alpha: 1)
        dot.strokeColor = .clear
        node.addChild(dot)
        node.zPosition = 4

        // Blink animation
        let delay = Double(rng.next() % 400) / 100.0
        let blink = SKAction.sequence([
            .wait(forDuration: delay),
            .repeatForever(.sequence([
                .fadeAlpha(to: 0.0, duration: 2.0),
                .fadeAlpha(to: 1.0, duration: 2.0)
            ]))
        ])
        node.run(blink)

        // Gentle drift
        let dx = CGFloat(Int(rng.next() % 6)) - 3
        let dy = CGFloat(Int(rng.next() % 6)) - 3
        let drift = SKAction.repeatForever(.sequence([
            .moveBy(x: dx, y: dy, duration: 3.0),
            .moveBy(x: -dx, y: -dy, duration: 3.0)
        ]))
        node.run(drift)

        return node
    }

    private func buildFogPatch(rng: inout BackgroundRNG) -> SKNode {
        let fw = CGFloat(60 + Int(rng.next() % 40))
        let fh = CGFloat(25 + Int(rng.next() % 15))
        let fog = SKShapeNode(ellipseOf: CGSize(width: fw, height: fh))
        fog.fillColor = SKColor(white: 0.5, alpha: 0.04)
        fog.strokeColor = .clear
        fog.zRotation = CGFloat(Int(rng.next() % 314)) / 100.0
        fog.zPosition = 4

        // 50% get slow horizontal drift
        if rng.next() % 2 == 0 {
            let drift = SKAction.repeatForever(.sequence([
                .moveBy(x: 5, y: 0, duration: 8.0),
                .moveBy(x: -5, y: 0, duration: 8.0)
            ]))
            fog.run(drift)
        }

        return fog
    }

    // MARK: - Grid

    private func setupGrid() {
        grid = (0..<GameScene.rows).map { row in
            (0..<GameScene.cols).map { col in
                var cell = GridCell(column: col, row: row)
                if PathSystem.pathCells.contains(GridCoord(col: col, row: row)) {
                    cell.state = .path
                } else if row >= GameScene.rows - 4 {
                    cell.state = .blocked
                }
                return cell
            }
        }
    }

    // MARK: - Update

    private var wasPaused = false

    override func update(_ currentTime: TimeInterval) {
        if appState.isPaused {
            if !wasPaused {
                wasPaused = true
                self.speed = 0
            }
            lastUpdateTime = nil
            return
        } else if wasPaused {
            wasPaused = false
            self.speed = CGFloat(gameState.speedMultiplier)
        }

        // Keep scene speed in sync with game state
        let targetSpeed = CGFloat(gameState.speedMultiplier)
        if !appState.isPaused && abs(self.speed - targetSpeed) > 0.01 {
            self.speed = targetSpeed
        }

        let dt = currentTime - (lastUpdateTime ?? currentTime)
        lastUpdateTime = currentTime

        let cullRect = self.cullRect

        // Move projectiles & remove off-screen ones
        for proj in activeProjectiles {
            proj.update(deltaTime: dt)
            if !cullRect.contains(proj.position) {
                ProjectileSystem.release(proj)
            }
        }
        activeProjectiles.removeAll { $0.parent == nil }

        let enemies = waveSystem?.activeEnemies ?? []
        guard !enemies.isEmpty || !poisonZones.isEmpty else {
            // No enemies and no active zones — skip combat processing
            if supportBuffsDirty {
                recomputeSupportBuffs()
                supportBuffsDirty = false
            }
            return
        }

        // Filter to only alive, on-screen enemies for combat checks
        let aliveEnemies = enemies.filter { !$0.isDead && $0.parent != nil }

        // Check ballista pierce hits
        for proj in activeProjectiles where proj.towerType == .ballista && proj.piercesRemaining > 0 {
            proj.checkPierceHit(against: aliveEnemies)
        }

        // Tick poison zones
        for zone in poisonZones where !zone.isExpired {
            zone.update(deltaTime: dt, enemies: aliveEnemies) { [weak self] enemy, damage in
                guard let self else { return }
                enemy.takeDamage(damage, ignoresArmor: false)
                if enemy.isDead {
                    Task { @MainActor [weak self] in
                        self?.gameState.earnGold(enemy.enemyType.goldReward)
                    }
                }
            }
        }
        poisonZones.removeAll { $0.isExpired || $0.parent == nil }

        // Recompute support buffs only when tower count changed
        if supportBuffsDirty {
            recomputeSupportBuffs()
            supportBuffsDirty = false
        }

        // Fire towers (skip moat — it's passive)
        if !aliveEnemies.isEmpty {
            let canTargetFlying = gameState.hasUpgrade("s7")
            let speedMult = gameState.speedMultiplier
            for tower in placedTowers {
                guard !tower.towerType.placesOnPath else { continue }
                guard tower.canFire(at: currentTime, speedMultiplier: speedMult) else { continue }
                if let target = TargetingSystem.target(for: tower, enemies: aliveEnemies, canTargetFlyingGlobal: canTargetFlying) {
                    tower.aimAt(target: target)
                    tower.didFire(at: currentTime)
                    fireProjectile(from: tower, at: target, enemies: aliveEnemies)
                }
            }
        }

        // Moat towers: slow enemies that walk over them (throttled to every 3rd frame)
        moatTickCounter += 1
        if moatTickCounter >= 3 {
            moatTickCounter = 0
            let moatTowers = moatTowerCache
            if !moatTowers.isEmpty && !aliveEnemies.isEmpty {
                let cs = TowerPlacementSystem.cellSize
                let moatRadiusSq = (cs * 0.6) * (cs * 0.6)
                for tower in moatTowers {
                    for enemy in aliveEnemies {
                        guard !enemy.enemyType.slowImmune else { continue }
                        let distSq = tower.position.distanceSquared(to: enemy.position)
                        if distSq < moatRadiusSq {
                            let factor = max(0.1, gameState.cryoFactor - Double(tower.extraSlowFactor))
                            enemy.applySlowEffect(factor: CGFloat(factor), duration: CGFloat(gameState.cryoDuration))
                        }
                    }
                }
            }
        }
    }

    var supportBuffsDirty = true

    private func recomputeSupportBuffs() {
        moatTowerCache = placedTowers.filter { $0.towerType.placesOnPath }
        for tower in placedTowers {
            tower.supportDamageMult = 1.0
            tower.supportFireRateMult = 1.0
        }
        for support in placedTowers where support.towerType.isSupport {
            for tower in placedTowers where tower !== support && !tower.towerType.isSupport {
                if support.position.distance(to: tower.position) <= support.effectiveRange {
                    tower.supportDamageMult *= (support.towerType.auraDamageMult + support.upgradeAuraBonus)
                    let fireRateBonus = support.towerType == .bellTower ? support.upgradeAuraBonus : 0
                    tower.supportFireRateMult *= (support.towerType.auraFireRateMult - fireRateBonus)
                }
            }
        }
    }

    private func fireProjectile(from tower: TowerNode, at target: EnemyNode, enemies: [EnemyNode]) {
        SoundSystem.shared.play(SoundType(towerType: tower.towerType))

        let ignoresArmor = tower.towerType.ignoresArmor || gameState.hasUpgrade("d5")
        let supportMult = tower.supportDamageMult
        let towerType = tower.towerType
        let towerDamage = tower.effectiveDamage
        let splashMult = tower.upgradeSplashMult
        let splashMultiplier = gameState.splashMultiplier
        let towerSplashRadius = towerType.splashRadius

        let proj = ProjectileSystem.fire(
            from: tower,
            at: target,
            in: self,
            gameState: gameState,
            allEnemies: enemies
        ) { [weak self] enemy, damage in
            guard let self else { return }
            enemy.takeDamage(damage * supportMult, ignoresArmor: ignoresArmor)
            if enemy.isDead {
                Task { @MainActor [weak self] in
                    self?.gameState.earnGold(enemy.enemyType.goldReward)
                    if enemy.enemyType == .dragonLord {
                        self?.gameState.earnGems(5)
                    } else if enemy.enemyType == .necroKing {
                        self?.gameState.earnGems(3)
                    }
                }
            }

            // Alchemist: spawn poison zone on hit
            if towerType == .alchemist {
                let zoneDamage = towerDamage * 0.3 * supportMult
                let zoneRadius = towerSplashRadius * CGFloat(splashMultiplier) * splashMult
                let zone = PoisonZoneNode(at: enemy.position, damage: zoneDamage, radius: max(zoneRadius, 25))
                self.addChild(zone)
                self.poisonZones.append(zone)
            }
        }

        // Ballista: set up pierce (3 base, can be upgraded)
        if towerType == .ballista {
            proj.piercesRemaining = 3
            let pierceDmg = towerDamage * supportMult * 0.7
            proj.onPierceHit = { [weak self] enemy, hitPoint in
                guard self != nil else { return }
                enemy.takeDamage(pierceDmg, ignoresArmor: ignoresArmor)
                enemy.applyHitEffect(from: .ballista)
                if enemy.isDead {
                    Task { @MainActor [weak self] in
                        self?.gameState.earnGold(enemy.enemyType.goldReward)
                    }
                }
            }
        }

        activeProjectiles.append(proj)
    }

    // MARK: - Wave events

    private func handleWaveComplete() {
        Task { @MainActor in
            gameState.waveInProgress = false
            gameState.applyInterest()
            // Award gems every 10th wave: 3 at wave 10, +1 per milestone
            if gameState.wave % 10 == 0 {
                gameState.earnGems(2 + gameState.wave / 10)
            }
            if gameState.wave >= 100 {
                appState.phase = .gameOver
            } else if gameState.autoPlay {
                // Small delay then auto-start next wave
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.startWave((self?.gameState.wave ?? 0) + 1)
                }
            } else {
                gameState.shopIsOpen = true
            }
        }
    }

    private func handleEnemyReachedEnd() {
        Task { @MainActor in
            if gameState.shieldsRemaining > 0 {
                gameState.shieldsRemaining -= 1
            } else {
                gameState.loseLife()
                HapticManager.lifeLost()
                if gameState.lives <= 0 {
                    gameState.autoPlay = false
                    appState.phase = .gameOver
                    HapticManager.gameOver()
                }
            }
        }
    }

    // MARK: - Ghost placement preview (called from GameScene+Touches)

    func updateGhost(at scenePoint: CGPoint) {
        guard let type = gameState.selectedTowerType else {
            hideGhost()
            return
        }
        let cell = TowerPlacementSystem.cellFor(scenePoint: scenePoint)
        guard cell.row >= 0, cell.row < grid.count,
              cell.col >= 0, cell.col < grid[cell.row].count else { return }

        // Skip update if same cell and same tower type
        if cell == ghostCurrentCell && type == ghostCurrentType && ghostContainer != nil { return }
        ghostCurrentCell = cell
        ghostCurrentType = type

        let cellData = grid[cell.row][cell.col]
        let placeable = type.placesOnPath ? cellData.isPathPlaceable : cellData.isPlaceable
        let center = TowerPlacementSystem.sceneCenterFor(cell: cell)

        if let container = ghostContainer, let body = ghostBody, let ring = ghostRing {
            // Reuse existing nodes — just update position and colors
            container.position = center
            let fillOk    = SKColor(red: 0.2, green: 0.85, blue: 0.2, alpha: 0.5)
            let fillBad   = SKColor(red: 0.85, green: 0.2, blue: 0.2, alpha: 0.5)
            let strokeOk  = SKColor(red: 0.2, green: 1.0, blue: 0.2, alpha: 0.9)
            let strokeBad = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.9)
            body.fillColor   = placeable ? fillOk : fillBad
            body.strokeColor = placeable ? strokeOk : strokeBad
            ring.fillColor   = placeable ? SKColor(red: 0.2, green: 1.0, blue: 0.2, alpha: 0.06)
                                         : SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.06)
            ring.strokeColor = placeable ? SKColor(red: 0.2, green: 1.0, blue: 0.2, alpha: 0.45)
                                         : SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.45)
        } else {
            // First time — create ghost nodes
            ghostContainer?.removeFromParent()

            let container = SKNode()
            container.position  = center
            container.zPosition = 10

            let body: SKShapeNode
            if type.isSupport {
                let r: CGFloat = 16
                let path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: r))
                path.addLine(to: CGPoint(x: r, y: 0))
                path.addLine(to: CGPoint(x: 0, y: -r))
                path.addLine(to: CGPoint(x: -r, y: 0))
                path.closeSubpath()
                body = SKShapeNode(path: path)
            } else {
                body = SKShapeNode(circleOfRadius: 18)
            }
            body.fillColor   = placeable ? SKColor(red: 0.2, green: 0.85, blue: 0.2, alpha: 0.5)
                                         : SKColor(red: 0.85, green: 0.2, blue: 0.2, alpha: 0.5)
            body.strokeColor = placeable ? SKColor(red: 0.2, green: 1.0, blue: 0.2, alpha: 0.9)
                                         : SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.9)
            body.lineWidth   = 2
            container.addChild(body)

            let effectiveRange = type.range * CGFloat(gameState.globalRangeMultiplier)
            let ring = SKShapeNode(circleOfRadius: effectiveRange)
            ring.fillColor   = placeable ? SKColor(red: 0.2, green: 1.0, blue: 0.2, alpha: 0.06)
                                         : SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.06)
            ring.strokeColor = placeable ? SKColor(red: 0.2, green: 1.0, blue: 0.2, alpha: 0.45)
                                         : SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.45)
            ring.lineWidth   = 1.5
            container.addChild(ring)

            addChild(container)
            ghostContainer = container
            ghostBody = body
            ghostRing = ring
        }
    }

    func hideGhost() {
        ghostContainer?.removeFromParent()
        ghostContainer = nil
        ghostBody = nil
        ghostRing = nil
        ghostCurrentCell = nil
        ghostCurrentType = nil
    }

    // MARK: - Tower placement & selection (called from GameScene+Touches)

    func placeTower(at scenePoint: CGPoint) {
        let cell = TowerPlacementSystem.cellFor(scenePoint: scenePoint)
        guard cell.row >= 0, cell.row < grid.count,
              cell.col >= 0, cell.col < grid[cell.row].count else { return }

        // If tapped on an existing tower, select it
        if case .tower = grid[cell.row][cell.col].state {
            if let tapped = placedTowers.first(where: { $0.gridCoord.col == cell.col && $0.gridCoord.row == cell.row }) {
                Task { @MainActor in
                    // Deselect previous
                    gameState.selectedPlacedTower?.showRangeRing(false)
                    if gameState.selectedPlacedTower === tapped {
                        // Tap same tower again to deselect
                        gameState.selectedPlacedTower = nil
                    } else {
                        gameState.selectedPlacedTower = tapped
                        gameState.selectedTowerType = nil
                        tapped.showRangeRing(true)
                        HapticManager.towerSelected()
                    }
                }
            }
            return
        }

        // Otherwise, place a new tower
        guard let type = gameState.selectedTowerType else { return }
        let cellData = grid[cell.row][cell.col]
        if type.placesOnPath {
            guard cellData.isPathPlaceable else { return }
        } else {
            guard cellData.isPlaceable else { return }
        }

        Task { @MainActor in
            let cost = gameState.effectiveCost(for: type)
            guard gameState.purchase(tower: type) else { return }
            grid[cell.row][cell.col].state = .tower(type)
            let center = TowerPlacementSystem.sceneCenterFor(cell: cell)
            let tower  = TowerNode(type: type, gameState: gameState)
            tower.position  = center
            tower.paidCost      = cost
            tower.totalInvested = cost
            tower.gridCoord     = cell
            towerLayer.addChild(tower)
            placedTowers.append(tower)
            supportBuffsDirty = true
            HapticManager.towerPlaced()
            // Deselect any selected placed tower
            gameState.selectedPlacedTower?.showRangeRing(false)
            gameState.selectedPlacedTower = nil
        }
    }

    func upgradeSelectedTower() {
        guard let tower = gameState.selectedPlacedTower,
              let upgrade = tower.nextUpgrade,
              gameState.gold >= upgrade.cost else { return }
        Task { @MainActor in
            gameState.gold -= upgrade.cost
            tower.applyUpgrade(gameState: gameState)
            supportBuffsDirty = true
            HapticManager.towerUpgraded()
        }
    }

    func sellSelectedTower() {
        guard let tower = gameState.selectedPlacedTower else { return }
        let refund = gameState.sellRefund(for: tower)
        let coord = tower.gridCoord

        tower.showRangeRing(false)
        tower.removeFromParent()
        placedTowers.removeAll { $0 === tower }
        supportBuffsDirty = true
        HapticManager.towerSold()

        if coord.row >= 0, coord.row < grid.count,
           coord.col >= 0, coord.col < grid[coord.row].count {
            grid[coord.row][coord.col].state = tower.towerType.placesOnPath ? .path : .empty
        }

        Task { @MainActor in
            gameState.gold += refund
            gameState.selectedPlacedTower = nil
        }
    }
}

/// Simple deterministic RNG for reproducible background decoration placement.
private struct BackgroundRNG {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state >> 33
    }
}
