import Foundation

enum WaveData {
    /// Legacy accessor — returns forest waves
    static let all: [WaveConfig] = waves(for: .forest)

    static func waves(for map: MapType) -> [WaveConfig] {
        let pool = enemyPool(for: map)
        let bosses = pool.bosses

        return (1...100).map { wave in
            let tier      = (wave - 1) / 10
            let hpScale   = Float(0.3 + Double(wave) * 0.0735 + Double(wave * wave) * 0.00042)
            let spdScale  = Float(1.0 + Double(wave) * 0.04)
            let isBoss    = wave % 10 == 0
            let goldBonus = 20 + wave * 3 + (isBoss ? 80 : 0)

            let available: [EnemyType] = {
                var t: [EnemyType] = [pool.tier0]
                if wave >= 11 { t.append(pool.tier1) }
                if wave >= 18 { t.append(pool.tier2a) }
                if wave >= 21 { t.append(pool.tier2b) }
                if wave >= 25 { t.append(pool.tier3a) }
                if wave >= 28 { t.append(pool.tier3b) }
                if wave >= 31 { t.append(pool.tier3c) }
                if wave >= 35 { t.append(pool.tier4a) }
                if wave >= 41 { t.append(pool.tier4b) }
                if wave >= 45 { t.append(pool.tier5) }
                if wave >= 55 { t.append(pool.tier6) }
                if wave >= 65 { t.append(pool.tier7) }
                return t
            }()

            let baseCount     = 5 + wave * 2
            let spawnInterval = max(0.32, 1.5 - Double(tier) * 0.12) as TimeInterval

            var spawns: [EnemySpawn] = (0..<baseCount).map { i in
                EnemySpawn(
                    type:       available[i % available.count],
                    hpScale:    hpScale,
                    speedScale: spdScale,
                    delay:      TimeInterval(i) * spawnInterval
                )
            }

            let bossDelay = TimeInterval(baseCount) * spawnInterval + 1.0

            if isBoss {
                spawns.append(EnemySpawn(
                    type:       bosses.main,
                    hpScale:    hpScale * 1.5,
                    speedScale: spdScale * 0.8,
                    delay:      bossDelay
                ))
            }

            if isBoss && wave >= 50 {
                spawns.append(EnemySpawn(
                    type:       bosses.mini,
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

    // MARK: - Enemy pools per map

    private struct MapEnemyPool {
        let tier0: EnemyType   // basic
        let tier1: EnemyType   // armored
        let tier2a: EnemyType  // fast
        let tier2b: EnemyType  // dodge or extra
        let tier3a: EnemyType  // regen
        let tier3b: EnemyType  // dodge
        let tier3c: EnemyType  // summoner
        let tier4a: EnemyType  // swarm
        let tier4b: EnemyType  // heavy
        let tier5: EnemyType   // shield
        let tier6: EnemyType   // flying
        let tier7: EnemyType   // elite
        let bosses: (main: EnemyType, mini: EnemyType)
    }

    private static func enemyPool(for map: MapType) -> MapEnemyPool {
        switch map {
        case .forest:
            return MapEnemyPool(
                tier0: .goblin, tier1: .orc,
                tier2a: .darkKnight, tier2b: .skeleton,
                tier3a: .troll, tier3b: .bandit, tier3c: .necromancer,
                tier4a: .skeletonSwarm, tier4b: .siegeRam,
                tier5: .warlock, tier6: .harpy, tier7: .wraith,
                bosses: (main: .dragonLord, mini: .necroKing)
            )
        case .ocean:
            return MapEnemyPool(
                tier0: .crab, tier1: .pirate,
                tier2a: .jellyfish, tier2b: .siren,
                tier3a: .seaSerpent, tier3b: .siren, tier3c: .anglerFish,
                tier4a: .sharkSwarm, tier4b: .turtleTank,
                tier5: .stormCaster, tier6: .flyingFish, tier7: .ghostShip,
                bosses: (main: .kraken, mini: .tidalLord)
            )
        case .space:
            return MapEnemyPool(
                tier0: .alienDrone, tier1: .mechSoldier,
                tier2a: .speedster, tier2b: .phaseShifter,
                tier3a: .plasmaGolem, tier3b: .phaseShifter, tier3c: .hiveMind,
                tier4a: .naniteSwarm, tier4b: .battleCruiser,
                tier5: .voidCaster, tier6: .starfighter, tier7: .darkMatter,
                bosses: (main: .mothershipOmega, mini: .admiralZyx)
            )
        case .desert:
            return MapEnemyPool(
                tier0: .scarab, tier1: .sandGolem,
                tier2a: .dustDevil, tier2b: .mirage,
                tier3a: .sandWorm, tier3b: .mirage, tier3c: .mummy,
                tier4a: .scorpionPack, tier4b: .siegeElephant,
                tier5: .sandSorcerer, tier6: .desertHawk, tier7: .sphinxWraith,
                bosses: (main: .ancientColossus, mini: .pharaohKing)
            )
        case .sky:
            return MapEnemyPool(
                tier0: .cloudWisp, tier1: .stormKnight,
                tier2a: .windSprite, tier2b: .fogPhantom,
                tier3a: .thunderBeast, tier3b: .fogPhantom, tier3c: .cloudWeaver,
                tier4a: .featherSwarm, tier4b: .skyFortress,
                tier5: .galeWizard, tier6: .stormEagle, tier7: .voidZephyr,
                bosses: (main: .thunderDragon, mini: .skylordAres)
            )
        }
    }
}
