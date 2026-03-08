import SpriteKit

extension GameScene {
    func startWave(_ waveNumber: Int) {
        guard waveNumber >= 1, waveNumber <= 100 else { return }
        let config = WaveData.all[waveNumber - 1]
        Task { @MainActor in
            gameState.wave = waveNumber
            gameState.waveInProgress = true
            if gameState.interestRate > 0 {
                gameState.gold += config.goldBonus
            }
            gameState.resetShields()
        }
        waveSystem.beginWave(config)
        HapticManager.waveStarted()
    }
}
