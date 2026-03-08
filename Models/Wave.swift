import Foundation

struct EnemySpawn {
    let type: EnemyType
    let hpScale: Float
    let speedScale: Float
    let delay: TimeInterval   // seconds after wave start to spawn this enemy
}

struct WaveConfig {
    let waveNumber: Int
    let spawns: [EnemySpawn]
    let goldBonus: Int
    let isBossWave: Bool
}
