import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let masks = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        guard masks == (PhysicsCategories.projectile | PhysicsCategories.enemy) else { return }

        // Physics contact is a fallback — primary hit detection is velocity-based in ProjectileNode.update
        // so we don't double-apply damage here. Projectile removes itself via onReachTarget.
    }
}
