import SpriteKit

enum TowerPlacementSystem {
    /// Set once in GameScene.didMove to match actual screen width.
    static var sceneWidth: CGFloat = 390.0

    static var cellSize: CGFloat { sceneWidth / CGFloat(GameScene.cols) }

    static func cellFor(scenePoint p: CGPoint) -> GridCoord {
        GridCoord(col: Int(p.x / cellSize), row: Int(p.y / cellSize))
    }

    static func sceneCenterFor(cell: GridCoord) -> CGPoint {
        CGPoint(
            x: CGFloat(cell.col) * cellSize + cellSize / 2,
            y: CGFloat(cell.row) * cellSize + cellSize / 2
        )
    }

    static func canPlace(at cell: GridCoord, grid: [[GridCell]]) -> Bool {
        guard cell.row >= 0, cell.row < grid.count,
              cell.col >= 0, cell.col < grid[cell.row].count
        else { return false }
        return grid[cell.row][cell.col].isPlaceable
    }
}
