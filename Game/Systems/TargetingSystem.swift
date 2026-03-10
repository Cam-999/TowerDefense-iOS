import SpriteKit

enum TargetingSystem {
    /// Returns the enemy node closest to exit (highest waypointIndex) within range.
    /// Filters out flying enemies for towers that can't target them.
    static func target(for tower: TowerNode, enemies: [EnemyNode], canTargetFlyingGlobal: Bool = false) -> EnemyNode? {
        let range = tower.effectiveRange
        let rangeSq = range * range
        let pos = tower.position
        let canHitFlying = tower.towerType.canTargetFlying || canTargetFlyingGlobal

        return enemies
            .filter { $0.parent != nil && !$0.isDead }
            .filter { !$0.enemyType.isFlying || canHitFlying }
            .filter { pos.distanceSquared(to: $0.position) <= rangeSq }
            .max(by: { $0.waypointIndex < $1.waypointIndex })
    }

    /// All enemies within range of tower (for AoE / chain)
    static func allInRange(_ enemies: [EnemyNode], from point: CGPoint, radius: CGFloat) -> [EnemyNode] {
        let radiusSq = radius * radius
        return enemies.filter { $0.parent != nil && !$0.isDead && point.distanceSquared(to: $0.position) <= radiusSq }
    }
}
