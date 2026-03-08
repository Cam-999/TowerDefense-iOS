import Foundation

enum MapType: String, CaseIterable, Identifiable {
    case forest
    case courtyard
    case mountain

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .forest:    "Dark Forest"
        case .courtyard: "Castle Courtyard"
        case .mountain:  "Mountain Pass"
        }
    }

    var description: String {
        switch self {
        case .forest:    "A winding path through ancient woods"
        case .courtyard: "Defend the inner castle grounds"
        case .mountain:  "A narrow pass through the peaks"
        }
    }

    var icon: String {
        switch self {
        case .forest:    "tree.fill"
        case .courtyard: "building.columns.fill"
        case .mountain:  "mountain.2.fill"
        }
    }
}
