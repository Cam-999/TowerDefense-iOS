import Foundation

enum CellState {
    case empty
    case path
    case tower(TowerType)
    case blocked
}

struct GridCell {
    let column: Int
    let row: Int
    var state: CellState = .empty

    var isPlaceable: Bool {
        if case .empty = state { return true }
        return false
    }

    var isPathPlaceable: Bool {
        if case .path = state { return true }
        return false
    }
}
