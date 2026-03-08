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
        if !gameState.shopIsOpen {
            placeTower(at: touch.location(in: self))
        }
        hideGhost()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideGhost()
    }
}
