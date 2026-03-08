import SpriteKit

enum ProjectileSystem {
    /// Fire a projectile from `tower` toward `target`.
    /// Returns the projectile node added to `scene`.
    @discardableResult
    static func fire(
        from tower: TowerNode,
        at target: EnemyNode,
        in scene: SKScene,
        gameState: GameState,
        allEnemies: [EnemyNode],
        onHit: @escaping (EnemyNode, CGFloat) -> Void
    ) -> ProjectileNode {
        let proj = ProjectileNode(towerType: tower.towerType, startPosition: tower.position, target: target)
        scene.addChild(proj)

        let baseDamage = tower.effectiveDamage
        let finalDamage = applyCrit(damage: baseDamage, gameState: gameState)

        let towerType      = tower.towerType
        let splashRadius   = towerType.splashRadius * CGFloat(gameState.splashMultiplier) * tower.upgradeSplashMult

        proj.onReachTarget = { [weak scene] hitPoint in
            guard let scene else { return }

            SoundSystem.shared.play(.hit)

            // Arrow immunity check — archer arrows bounce off arrow-immune enemies
            if towerType == .archer && target.enemyType.arrowImmune {
                showArrowBounce(at: hitPoint, in: scene)
                proj.removeFromParent()
                return
            }

            // Magic vulnerability multiplier (wizard deals bonus damage to magic-vulnerable enemies)
            let magicMult: CGFloat = towerType == .wizard ? target.enemyType.magicVulnerability : 1.0
            let adjustedDamage = finalDamage * magicMult

            // AoE splash (catapult, alchemist)
            if splashRadius > 0 {
                let victims = TargetingSystem.allInRange(allEnemies, from: hitPoint, radius: splashRadius)
                for v in victims {
                    let vMagicMult: CGFloat = towerType == .wizard ? v.enemyType.magicVulnerability : 1.0
                    onHit(v, finalDamage * vMagicMult)
                    v.applyHitEffect(from: towerType)
                }
            } else {
                onHit(target, adjustedDamage)
                target.applyHitEffect(from: towerType)
            }

            // Moat slow — uses tiered values + tower upgrade bonus
            if towerType == .moat && !target.enemyType.slowImmune {
                let slowFactor = max(0.1, gameState.cryoFactor - Double(tower.extraSlowFactor))
                target.applySlowEffect(
                    factor: CGFloat(slowFactor),
                    duration: gameState.cryoDuration
                )
            }

            proj.removeFromParent()
        }

        return proj
    }

    private static func applyCrit(damage: CGFloat, gameState: GameState) -> CGFloat {
        guard gameState.critChance > 0 else { return damage }
        if Double.random(in: 0...1) < gameState.critChance {
            return damage * CGFloat(gameState.critMultiplier)
        }
        return damage
    }

    /// Visual effect when an arrow bounces off an arrow-immune enemy
    private static func showArrowBounce(at point: CGPoint, in scene: SKScene) {
        let spark = SKShapeNode(circleOfRadius: 4)
        spark.fillColor   = SKColor(white: 0.8, alpha: 0.8)
        spark.strokeColor = .clear
        spark.position    = point
        scene.addChild(spark)
        spark.run(.sequence([
            .group([
                .scale(to: 0.3, duration: 0.2),
                .fadeOut(withDuration: 0.2),
                .moveBy(x: CGFloat.random(in: -8...8), y: 8, duration: 0.2)
            ]),
            .removeFromParent()
        ]))
    }
}
