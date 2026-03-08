import SwiftUI

struct HUDView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var appState: AppState
    @ObservedObject private var sound = SoundSystem.shared

    var body: some View {
        HStack(spacing: 4) {
            // Lives
            hudPill(icon: "heart.fill", value: "\(gameState.lives)", color: .tdDanger)

            // Wave
            hudPill(icon: nil, value: "Siege \(gameState.wave)/100", color: .tdTextPrimary)

            Spacer()

            // Gold
            hudPill(icon: "circle.fill", value: "\(gameState.gold)", color: .tdAccentAmber)

            // Gems
            hudPill(icon: "diamond.fill", value: "\(gameState.gems)", color: .cyan)

            // Mute button
            Button {
                sound.isMuted.toggle()
                HapticManager.towerSelected()
            } label: {
                Image(systemName: sound.isMuted ? "speaker.slash.fill" : "speaker.2.fill")
                    .foregroundColor(.tdTextSecondary)
                    .font(.caption)
                    .frame(width: 32, height: 32)
                    .background(Color.tdElevated)
                    .cornerRadius(8)
            }
            .padding(.leading, 2)

            // Pause button
            Button {
                appState.isPaused = true
                SoundSystem.shared.pauseEngine()
            } label: {
                Image(systemName: "pause.fill")
                    .foregroundColor(.tdTextSecondary)
                    .font(.caption)
                    .frame(width: 32, height: 32)
                    .background(Color.tdElevated)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(Color.tdSurface.opacity(0.95).ignoresSafeArea(edges: .horizontal))
    }

    private func hudPill(icon: String?, value: String, color: Color) -> some View {
        HStack(spacing: 3) {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption2)
            }
            Text(value)
                .font(.caption.bold())
                .foregroundColor(.tdTextPrimary)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(Color.tdElevated)
        .cornerRadius(8)
    }
}
