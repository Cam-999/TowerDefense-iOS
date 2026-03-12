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
        case .ocean:
            edgeColor  = SKColor(red: 0.10, green: 0.20, blue: 0.35, alpha: 1)
            mainColor  = SKColor(red: 0.15, green: 0.30, blue: 0.50, alpha: 1)
            centerColor = SKColor(red: 0.20, green: 0.38, blue: 0.58, alpha: 1)
        case .space:
            edgeColor  = SKColor(red: 0.15, green: 0.12, blue: 0.22, alpha: 1)
            mainColor  = SKColor(red: 0.25, green: 0.20, blue: 0.35, alpha: 1)
            centerColor = SKColor(red: 0.32, green: 0.28, blue: 0.42, alpha: 1)
        case .desert:
            edgeColor  = SKColor(red: 0.45, green: 0.35, blue: 0.20, alpha: 1)
            mainColor  = SKColor(red: 0.60, green: 0.48, blue: 0.28, alpha: 1)
            centerColor = SKColor(red: 0.68, green: 0.55, blue: 0.35, alpha: 1)
        case .sky:
            edgeColor  = SKColor(red: 0.60, green: 0.65, blue: 0.75, alpha: 1)
            mainColor  = SKColor(red: 0.72, green: 0.78, blue: 0.88, alpha: 1)
            centerColor = SKColor(red: 0.82, green: 0.86, blue: 0.92, alpha: 1)
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

        // Path decorations
        addPebbles(along: waypoints, mapType: mapType)
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
                switch mapType {
                case .forest:
                    pebble.fillColor = SKColor(red: 0.18 + shade, green: 0.22 + shade, blue: 0.12, alpha: 0.25)
                case .ocean:
                    pebble.fillColor = SKColor(red: 0.10, green: 0.18 + shade, blue: 0.30 + shade, alpha: 0.25)
                case .space:
                    pebble.fillColor = SKColor(red: 0.20 + shade, green: 0.15 + shade, blue: 0.30, alpha: 0.2)
                case .desert:
                    pebble.fillColor = SKColor(red: 0.50 + shade, green: 0.40 + shade, blue: 0.25, alpha: 0.3)
                case .sky:
                    pebble.fillColor = SKColor(red: 0.70 + shade, green: 0.72 + shade, blue: 0.78, alpha: 0.2)
                }
                pebble.strokeColor = .clear
                pebble.position = CGPoint(x: px, y: py)
                pebble.zPosition = 0
                addChild(pebble)
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
