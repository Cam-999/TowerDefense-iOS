import Foundation

enum MapType: String, CaseIterable, Identifiable {
    case forest
    case ocean
    case space
    case desert
    case sky

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .forest:  "Dark Forest"
        case .ocean:   "Sunken Depths"
        case .space:   "Cosmic Void"
        case .desert:  "Scorching Sands"
        case .sky:     "Cloud Kingdom"
        }
    }

    var description: String {
        switch self {
        case .forest:  "A winding path through ancient woods"
        case .ocean:   "Navigate the treacherous ocean floor"
        case .space:   "Defend the space station perimeter"
        case .desert:  "Cross the endless burning dunes"
        case .sky:     "Battle above the clouds"
        }
    }

    var icon: String {
        switch self {
        case .forest:  "tree.fill"
        case .ocean:   "water.waves"
        case .space:   "sparkles"
        case .desert:  "sun.max.fill"
        case .sky:     "cloud.fill"
        }
    }
}
