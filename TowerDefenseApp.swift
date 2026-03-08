import SwiftUI

@main
struct TowerDefenseApp: App {
    @StateObject private var appState   = AppState()
    @StateObject private var gameState  = GameState()
    @StateObject private var shopState  = ShopState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(gameState)
                .environmentObject(shopState)
                .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                if appState.isPaused {
                    appState.isPaused = false
                    SoundSystem.shared.resumeEngine()
                }
            case .inactive, .background:
                if appState.phase == .playing || appState.phase == .betweenWaves {
                    appState.isPaused = true
                    SoundSystem.shared.pauseEngine()
                }
            @unknown default:
                break
            }
        }
    }
}
