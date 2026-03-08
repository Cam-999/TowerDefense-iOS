import Foundation
import Combine

enum GamePhase {
    case menu
    case playing
    case betweenWaves
    case gameOver
}

final class AppState: ObservableObject {
    @Published var phase: GamePhase = .menu
    @Published var isPaused: Bool = false
}
