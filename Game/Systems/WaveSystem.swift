import SpriteKit

final class WaveSystem {
    private weak var scene: SKScene?
    private(set) var activeEnemies: [EnemyNode] = []

    private var totalCount:    Int = 0
    private var resolvedCount: Int = 0

    weak var gameState: GameState?
    var onWaveComplete:    (() -> Void)?
    var onEnemyReachedEnd: (() -> Void)?

    init(scene: SKScene, gameState: GameState) {
        self.scene     = scene
        self.gameState = gameState
    }

    func beginWave(_ config: WaveConfig) {
        guard let scene else { return }
        activeEnemies.removeAll()
        totalCount    = config.spawns.count
        resolvedCount = 0

        for spawn in config.spawns {
            scene.run(.sequence([
                .wait(forDuration: spawn.delay),
                .run { [weak self] in
                    guard let self, let scene = self.scene else { return }
                    self.spawnEnemy(spawn, in: scene)
                }
            ]))
        }
    }

    // MARK: - Spawning

    private func spawnEnemy(_ spawn: EnemySpawn, in scene: SKScene) {
        let node = EnemyNode(type: spawn.type, hpScale: spawn.hpScale, speedScale: spawn.speedScale)
        node.position   = PathSystem.waypoints[0]
        node.zPosition  = 3
        node.onDeath    = { [weak self] e in self?.handleEnemyDied(e) }
        node.onReachEnd = { [weak self] e in self?.handleEnemyReachedEnd(e) }
        scene.addChild(node)
        activeEnemies.append(node)
        node.startMoving()
    }

    private func spawnSplit(type: EnemyType, from parent: EnemyNode) {
        guard let scene else { return }
        let node = EnemyNode(type: type, hpScale: 1.0, speedScale: 1.0)
        node.position      = parent.position
        node.zPosition     = 3
        node.waypointIndex = parent.waypointIndex
        node.onDeath       = { [weak self] e in self?.handleEnemyDied(e) }
        node.onReachEnd    = { [weak self] e in self?.handleEnemyReachedEnd(e) }
        scene.addChild(node)
        activeEnemies.append(node)
        node.startMoving(fromWaypoint: parent.waypointIndex + 1)
    }

    // MARK: - Enemy events

    private func handleEnemyDied(_ enemy: EnemyNode) {
        activeEnemies.removeAll { $0 === enemy }

        // Split enemies (splitter → grunts, swarm → grunts, colossus → armored)
        if let split = enemy.enemyType.splitSpawn {
            totalCount += split.count
            for _ in 0..<split.count { spawnSplit(type: split.type, from: enemy) }
        }

        resolve()
    }

    private func handleEnemyReachedEnd(_ enemy: EnemyNode) {
        activeEnemies.removeAll { $0 === enemy }

        // Vampire drains 2 lives; all others drain 1
        // Each call to onEnemyReachedEnd lets GameScene handle shield/life logic
        let drains = enemy.enemyType.livesOnEscape
        for _ in 0..<drains { onEnemyReachedEnd?() }

        resolve()
    }

    // MARK: - Wave completion

    private func resolve() {
        resolvedCount += 1
        if resolvedCount >= totalCount && activeEnemies.isEmpty {
            onWaveComplete?()
        }
    }
}
