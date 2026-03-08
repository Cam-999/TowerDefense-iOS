import SpriteKit

enum TargetingSystem {
    /// Returns the enemy node closest to exit (highest waypointIndex) within range.
    /// Filters out flying enemies for towers that can't target them.
    static func target(for tower: TowerNode, enemies: [EnemyNode], canTargetFlyingGlobal: Bool = false) -> EnemyNode? {
        let range = tower.effectiveRange
        let pos = tower.position
        let canHitFlying = tower.towerType.canTargetFlying || canTargetFlyingGlobal

        return enemies
            .filter { $0.parent != nil && !$0.isDead }
            .filter { !$0.enemyType.isFlying || canHitFlying }
            .filter { pos.distance(to: $0.position) <= range }
            .max(by: { $0.waypointIndex < $1.waypointIndex })
    }

    /// All enemies within range of tower (for AoE / chain)
    static func allInRange(_ enemies: [EnemyNode], from point: CGPoint, radius: CGFloat) -> [EnemyNode] {
        enemies.filter { $0.parent != nil && !$0.isDead && point.distance(to: $0.position) <= radius }
    }
}
