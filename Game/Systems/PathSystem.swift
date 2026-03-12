import SpriteKit

enum PathSystem {
    /// Current map — set before scene loads
    static var currentMap: MapType = .forest

    private static var cs: CGFloat { TowerPlacementSystem.cellSize }

    /// Waypoints for the current map.
    static var waypoints: [CGPoint] {
        switch currentMap {
        case .forest:  return forestWaypoints
        case .ocean:   return oceanWaypoints
        case .space:   return spaceWaypoints
        case .desert:  return desertWaypoints
        case .sky:     return skyWaypoints
        }
    }

    /// Grid cells the path occupies.
    static var pathCells: Set<GridCoord> {
        let cs = cs
        let wps = waypoints
        var cells = Set<GridCoord>()
        for i in 0..<(wps.count - 1) {
            let a = wps[i]
            let b = wps[i + 1]
            let steps = Int(a.distance(to: b) / cs) + 2
            for s in 0...steps {
                let t = steps == 0 ? 0.0 : CGFloat(s) / CGFloat(steps)
                let pt = CGPoint(x: a.x + (b.x - a.x) * t,
                                 y: a.y + (b.y - a.y) * t)
                cells.insert(GridCoord(col: Int(pt.x / cs),
                                       row: Int(pt.y / cs)))
            }
        }
        return cells
    }

    static func moveActions(speed: CGFloat) -> [SKAction] {
        let wps = waypoints
        var actions: [SKAction] = []
        for i in 0..<(wps.count - 1) {
            let dist     = wps[i].distance(to: wps[i + 1])
            let duration = TimeInterval(dist / speed)
            actions.append(.move(to: wps[i + 1], duration: duration))
        }
        return actions
    }

    // MARK: - Forest (original zigzag)
    // Entry left row 13 → zigzag cols 2/6 → exit right row 1

    private static var forestWaypoints: [CGPoint] {
        let cs = cs
        let w = TowerPlacementSystem.sceneWidth
        return [
            CGPoint(x:     0,              y: 13 * cs + cs / 2),
            CGPoint(x: 6 * cs + cs / 2,    y: 13 * cs + cs / 2),
            CGPoint(x: 6 * cs + cs / 2,    y: 10 * cs + cs / 2),
            CGPoint(x: 2 * cs + cs / 2,    y: 10 * cs + cs / 2),
            CGPoint(x: 2 * cs + cs / 2,    y:  7 * cs + cs / 2),
            CGPoint(x: 6 * cs + cs / 2,    y:  7 * cs + cs / 2),
            CGPoint(x: 6 * cs + cs / 2,    y:  4 * cs + cs / 2),
            CGPoint(x: 2 * cs + cs / 2,    y:  4 * cs + cs / 2),
            CGPoint(x: 2 * cs + cs / 2,    y:  1 * cs + cs / 2),
            CGPoint(x: w,                   y:  1 * cs + cs / 2),
        ]
    }

    // MARK: - Ocean (Sunken Depths)
    // Entry bottom-left, snaking upward (like rising through water)

    private static var oceanWaypoints: [CGPoint] {
        let cs = cs
        let w = TowerPlacementSystem.sceneWidth
        return [
            CGPoint(x: 0,                 y:  1 * cs + cs / 2),     // entry left, row 1
            CGPoint(x: 2 * cs + cs / 2,   y:  1 * cs + cs / 2),     // right to col 2
            CGPoint(x: 2 * cs + cs / 2,   y:  4 * cs + cs / 2),     // up to row 4
            CGPoint(x: 6 * cs + cs / 2,   y:  4 * cs + cs / 2),     // right to col 6
            CGPoint(x: 6 * cs + cs / 2,   y:  7 * cs + cs / 2),     // up to row 7
            CGPoint(x: 2 * cs + cs / 2,   y:  7 * cs + cs / 2),     // left to col 2
            CGPoint(x: 2 * cs + cs / 2,   y: 10 * cs + cs / 2),     // up to row 10
            CGPoint(x: 7 * cs + cs / 2,   y: 10 * cs + cs / 2),     // right to col 7
            CGPoint(x: 7 * cs + cs / 2,   y: 13 * cs + cs / 2),     // up to row 13
            CGPoint(x: w,                  y: 13 * cs + cs / 2),     // exit right, row 13
        ]
    }

    // MARK: - Space (Cosmic Void)
    // Entry top-left, spiraling inward then exiting right

    private static var spaceWaypoints: [CGPoint] {
        let cs = cs
        let w = TowerPlacementSystem.sceneWidth
        return [
            CGPoint(x: 0,                 y: 13 * cs + cs / 2),     // entry left, row 13
            CGPoint(x: 7 * cs + cs / 2,   y: 13 * cs + cs / 2),     // right to col 7
            CGPoint(x: 7 * cs + cs / 2,   y:  2 * cs + cs / 2),     // down to row 2
            CGPoint(x: 2 * cs + cs / 2,   y:  2 * cs + cs / 2),     // left to col 2
            CGPoint(x: 2 * cs + cs / 2,   y: 11 * cs + cs / 2),     // up to row 11
            CGPoint(x: 5 * cs + cs / 2,   y: 11 * cs + cs / 2),     // right to col 5
            CGPoint(x: 5 * cs + cs / 2,   y:  5 * cs + cs / 2),     // down to row 5
            CGPoint(x: 4 * cs + cs / 2,   y:  5 * cs + cs / 2),     // left to col 4
            CGPoint(x: 4 * cs + cs / 2,   y:  8 * cs + cs / 2),     // up to row 8
            CGPoint(x: w,                  y:  8 * cs + cs / 2),     // exit right, row 8
        ]
    }

    // MARK: - Desert (Scorching Sands)
    // Entry left middle, long horizontal zigzags (wide desert feel)

    private static var desertWaypoints: [CGPoint] {
        let cs = cs
        let w = TowerPlacementSystem.sceneWidth
        return [
            CGPoint(x: 0,                 y:  7 * cs + cs / 2),     // entry left, row 7
            CGPoint(x: 7 * cs + cs / 2,   y:  7 * cs + cs / 2),     // long right to col 7
            CGPoint(x: 7 * cs + cs / 2,   y:  5 * cs + cs / 2),     // down to row 5
            CGPoint(x: 1 * cs + cs / 2,   y:  5 * cs + cs / 2),     // long left to col 1
            CGPoint(x: 1 * cs + cs / 2,   y:  3 * cs + cs / 2),     // down to row 3
            CGPoint(x: 7 * cs + cs / 2,   y:  3 * cs + cs / 2),     // long right to col 7
            CGPoint(x: 7 * cs + cs / 2,   y: 10 * cs + cs / 2),     // up to row 10
            CGPoint(x: 1 * cs + cs / 2,   y: 10 * cs + cs / 2),     // long left to col 1
            CGPoint(x: 1 * cs + cs / 2,   y: 12 * cs + cs / 2),     // up to row 12
            CGPoint(x: w,                  y: 12 * cs + cs / 2),     // exit right, row 12
        ]
    }

    // MARK: - Sky (Cloud Kingdom)
    // Entry top-right, descending zigzag pattern

    private static var skyWaypoints: [CGPoint] {
        let cs = cs
        let w = TowerPlacementSystem.sceneWidth
        return [
            CGPoint(x: w,                  y: 13 * cs + cs / 2),     // entry right, row 13
            CGPoint(x: 2 * cs + cs / 2,    y: 13 * cs + cs / 2),     // left to col 2
            CGPoint(x: 2 * cs + cs / 2,    y: 11 * cs + cs / 2),     // down to row 11
            CGPoint(x: 6 * cs + cs / 2,    y: 11 * cs + cs / 2),     // right to col 6
            CGPoint(x: 6 * cs + cs / 2,    y:  8 * cs + cs / 2),     // down to row 8
            CGPoint(x: 1 * cs + cs / 2,    y:  8 * cs + cs / 2),     // left to col 1
            CGPoint(x: 1 * cs + cs / 2,    y:  5 * cs + cs / 2),     // down to row 5
            CGPoint(x: 7 * cs + cs / 2,    y:  5 * cs + cs / 2),     // right to col 7
            CGPoint(x: 7 * cs + cs / 2,    y:  2 * cs + cs / 2),     // down to row 2
            CGPoint(x: 0,                   y:  2 * cs + cs / 2),     // exit left, row 2
        ]
    }
}

struct GridCoord: Hashable {
    let col: Int
    let row: Int
}
