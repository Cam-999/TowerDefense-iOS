import SpriteKit

extension SKNode {
    func children<T: SKNode>(ofType type: T.Type) -> [T] {
        children.compactMap { $0 as? T }
    }

    func removeAllChildren<T: SKNode>(ofType type: T.Type) {
        children.compactMap { $0 as? T }.forEach { $0.removeFromParent() }
    }

    func run(_ action: SKAction, withKey key: String, completion: (() -> Void)? = nil) {
        if let completion {
            run(SKAction.sequence([action, SKAction.run(completion)]), withKey: key)
        } else {
            run(action, withKey: key)
        }
    }
}

extension SKScene {
    var safeFrame: CGRect { frame }
}
