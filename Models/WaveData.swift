import Foundation

enum WaveData {
    static let all: [WaveConfig] = (1...100).map { wave in
        let tier      = (wave - 1) / 10
        // Enemies start weak and ramp up: wave 1 ≈ 0.4×, wave 10 ≈ 1.1×, wave 50 ≈ 5.0×, wave 100 ≈ 8.4×
        let hpScale   = Float(0.3 + Double(wave) * 0.0735 + Double(wave * wave) * 0.00042)
        let spdScale  = Float(1.0 + Double(wave) * 0.04)
        let isBoss    = wave % 10 == 0
        let goldBonus = 20 + wave * 3 + (isBoss ? 80 : 0)

        // Enemy pool unlocks progressively based on wave number
        let pool: [EnemyType] = {
            var t: [EnemyType] = [.goblin]
            if wave >= 11 { t.append(.orc) }            // orc — heavy armor
            if wave >= 18 { t.append(.darkKnight) }     // dark knight — arrow immune, magic vulnerable
            if wave >= 21 { t.append(.skeleton) }       // skeleton — fast, numerous
            if wave >= 25 { t.append(.troll) }          // troll — regen, armored
            if wave >= 28 { t.append(.bandit) }         // bandit — dodge chance
            if wave >= 31 { t.append(.necromancer) }    // necromancer — splits into skeletons
            if wave >= 35 { t.append(.skeletonSwarm) }  // skeleton swarm — tiny, fast, splits
            if wave >= 41 { t.append(.siegeRam) }       // siege ram — massive HP, armored
            if wave >= 45 { t.append(.warlock) }        // warlock — shield + regen
            if wave >= 55 { t.append(.harpy) }          // harpy — flying
            if wave >= 65 { t.append(.wraith) }         // wraith — fastest, slow immune, dodge
            return t
        }()

        let baseCount     = 5 + wave * 2
        let spawnInterval = max(0.32, 1.5 - Double(tier) * 0.12) as TimeInterval

        var spawns: [EnemySpawn] = (0..<baseCount).map { i in
            EnemySpawn(
                type:       pool[i % pool.count],
                hpScale:    hpScale,
                speedScale: spdScale,
                delay:      TimeInterval(i) * spawnInterval
            )
        }

        let bossDelay = TimeInterval(baseCount) * spawnInterval + 1.0

        // Dragon Lord appears every boss wave (every 10 waves)
        if isBoss {
            spawns.append(EnemySpawn(
                type:       .dragonLord,
                hpScale:    hpScale * 1.5,
                speedScale: spdScale * 0.8,
                delay:      bossDelay
            ))
        }

        // Necro King joins boss waves from wave 50 onward
        if isBoss && wave >= 50 {
            spawns.append(EnemySpawn(
                type:       .necroKing,
                hpScale:    hpScale * 1.2,
                speedScale: spdScale * 0.7,
                delay:      bossDelay + 3.0
            ))
        }

        return WaveConfig(
            waveNumber: wave,
            spawns:     spawns,
            goldBonus:  goldBonus,
            isBossWave: isBoss
        )
    }
}
