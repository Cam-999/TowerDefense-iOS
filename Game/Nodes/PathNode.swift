import SpriteKit

final class PathNode: SKNode {
    init(waypoints: [CGPoint], roadWidth: CGFloat = 40, mapType: MapType = .forest) {
        super.init()

        guard waypoints.count >= 2 else { return }

        let path = CGMutablePath()
        path.move(to: waypoints[0])
        for pt in waypoints.dropFirst() {
            path.addLine(to: pt)
        }

        // Road colors depend on map
        let edgeColor: SKColor
        let mainColor: SKColor
        let centerColor: SKColor

        switch mapType {
        case .forest:
            edgeColor  = SKColor(hex: 0x362A1E)
            mainColor  = SKColor(hex: 0x4A3D2D)
            centerColor = SKColor(hex: 0x584A38)
        case .courtyard:
            edgeColor  = SKColor(red: 0.35, green: 0.33, blue: 0.30, alpha: 1)
            mainColor  = SKColor(red: 0.55, green: 0.53, blue: 0.50, alpha: 1)
            centerColor = SKColor(red: 0.62, green: 0.60, blue: 0.57, alpha: 1)
        case .mountain:
            edgeColor  = SKColor(red: 0.30, green: 0.25, blue: 0.20, alpha: 1)
            mainColor  = SKColor(red: 0.45, green: 0.38, blue: 0.30, alpha: 1)
            centerColor = SKColor(red: 0.52, green: 0.45, blue: 0.35, alpha: 1)
        }

        // Road edge (slightly wider, darker border)
        let roadEdge = SKShapeNode(path: path)
        roadEdge.strokeColor = edgeColor
        roadEdge.lineWidth   = roadWidth + 4
        roadEdge.lineCap     = .round
        roadEdge.lineJoin    = .round
        roadEdge.zPosition   = -2
        addChild(roadEdge)

        // Main road
        let road = SKShapeNode(path: path)
        road.strokeColor = mainColor
        road.lineWidth   = roadWidth
        road.lineCap     = .round
        road.lineJoin    = .round
        road.zPosition   = -1
        addChild(road)

        // Lighter worn center track
        let center = SKShapeNode(path: path)
        center.strokeColor = centerColor
        center.lineWidth   = 8
        center.lineCap     = .round
        center.lineJoin    = .round
        center.zPosition   = 0
        addChild(center)

        // Pebbles (forest/mountain) or tile lines (courtyard)
        if mapType == .courtyard {
            addTileLines(along: waypoints)
        } else {
            addPebbles(along: waypoints, mapType: mapType)
        }
    }

    private func addPebbles(along waypoints: [CGPoint], mapType: MapType) {
        var rng = SeededRNG(seed: 42)
        for i in 0..<(waypoints.count - 1) {
            let a = waypoints[i], b = waypoints[i + 1]
            let dist = a.distance(to: b)
            let count = Int(dist / 18)
            for _ in 0..<count {
                let t = CGFloat(rng.next() % 1000) / 1000.0
                let cx = a.x + (b.x - a.x) * t
                let cy = a.y + (b.y - a.y) * t
                let dx = b.x - a.x, dy = b.y - a.y
                let len = sqrt(dx * dx + dy * dy)
                guard len > 0 else { continue }
                let nx = -dy / len, ny = dx / len
                let spread = CGFloat(Int(rng.next() % 28)) - 14
                let px = cx + nx * spread
                let py = cy + ny * spread

                let size = CGFloat(2 + Int(rng.next() % 3))
                let pebble = SKShapeNode(circleOfRadius: size)
                let shade = CGFloat(rng.next() % 10) / 100.0
                if mapType == .mountain {
                    pebble.fillColor = SKColor(red: 0.40 + shade, green: 0.35 + shade, blue: 0.28, alpha: 0.35)
                } else {
                    pebble.fillColor = SKColor(red: 0.18 + shade, green: 0.22 + shade, blue: 0.12, alpha: 0.25)
                }
                pebble.strokeColor = .clear
                pebble.position = CGPoint(x: px, y: py)
                pebble.zPosition = 0
                addChild(pebble)
            }
        }
    }

    private func addTileLines(along waypoints: [CGPoint]) {
        var rng = SeededRNG(seed: 42)
        for i in 0..<(waypoints.count - 1) {
            let a = waypoints[i], b = waypoints[i + 1]
            let dist = a.distance(to: b)
            let count = Int(dist / 30)
            let dx = b.x - a.x, dy = b.y - a.y
            let len = sqrt(dx * dx + dy * dy)
            guard len > 0 else { continue }
            let nx = -dy / len, ny = dx / len
            for j in 0..<count {
                let t = CGFloat(j) / CGFloat(max(count, 1))
                let cx = a.x + (b.x - a.x) * t
                let cy = a.y + (b.y - a.y) * t
                let tilePath = CGMutablePath()
                tilePath.move(to: CGPoint(x: cx + nx * 16, y: cy + ny * 16))
                tilePath.addLine(to: CGPoint(x: cx - nx * 16, y: cy - ny * 16))
                let tile = SKShapeNode(path: tilePath)
                tile.strokeColor = SKColor(white: 0.45, alpha: 0.25)
                tile.lineWidth = 1
                tile.zPosition = 0
                _ = rng.next() // consume for determinism
                addChild(tile)
            }
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}

/// Simple deterministic RNG for reproducible decoration placement.
private struct SeededRNG {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state >> 33
    }
}
