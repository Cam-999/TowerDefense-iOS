import SpriteKit

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !gameState.shopIsOpen else { return }
        updateGhost(at: touch.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updateGhost(at: touch.location(in: self))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if !gameState.shopIsOpen {
            // Check if an enemy was tapped
            if let enemy = closestEnemy(to: location, maxDistance: 25) {
                let info = EnemyStatsInfo(
                    type: enemy.enemyType,
                    currentHP: enemy.currentHP,
                    maxHP: enemy.maxHP,
                    remainingShield: enemy.remainingShield,
                    moveSpeed: enemy.moveSpeed
                )
                gameState.selectedEnemy = info
            } else {
                placeTower(at: location)
            }
        }
        hideGhost()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideGhost()
    }

    /// Find the closest enemy node to a point within a max distance
    private func closestEnemy(to point: CGPoint, maxDistance: CGFloat) -> EnemyNode? {
        var best: EnemyNode?
        var bestDist: CGFloat = maxDistance

        // nodes(at:) returns all nodes at that exact point; we need a broader search
        // Scan a rect around the tap point
        let searchRect = CGRect(
            x: point.x - maxDistance,
            y: point.y - maxDistance,
            width: maxDistance * 2,
            height: maxDistance * 2
        )

        for node in nodes(at: point) {
            if let enemy = findEnemyNode(node), !enemy.isDead {
                let dist = point.distance(to: enemy.position)
                if dist < bestDist {
                    bestDist = dist
                    best = enemy
                }
            }
        }

        // Also check nearby nodes that might not be exactly at the tap point
        // by checking physics bodies in the area
        physicsWorld.enumerateBodies(in: searchRect) { body, _ in
            if let enemy = body.node as? EnemyNode, !enemy.isDead {
                let dist = point.distance(to: enemy.position)
                if dist < bestDist {
                    bestDist = dist
                    best = enemy
                }
            }
        }

        return best
    }

    /// Walk up the node tree to find an EnemyNode ancestor
    private func findEnemyNode(_ node: SKNode) -> EnemyNode? {
        var current: SKNode? = node
        while let n = current {
            if let enemy = n as? EnemyNode { return enemy }
            current = n.parent
        }
        return nil
    }
}
