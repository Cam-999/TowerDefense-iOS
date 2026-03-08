import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch appState.phase {
            case .menu:
                MainMenuView()
            case .playing, .betweenWaves:
                GameView()
            case .gameOver:
                GameOverView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.phase)
    }
}
