import AVFoundation
import Combine

/// Plays looping background music per map. Replaces the old procedural sound system.
final class MusicPlayer: ObservableObject {
    static let shared = MusicPlayer()

    @Published var isMuted: Bool {
        didSet { UserDefaults.standard.set(isMuted, forKey: "soundMuted")
            player?.volume = isMuted ? 0 : 1
        }
    }

    private var player: AVAudioPlayer?

    private init() {
        isMuted = UserDefaults.standard.bool(forKey: "soundMuted")
        configureAudioSession()
    }

    private func configureAudioSession() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
    }

    func play(for map: MapType) {
        // Use the single bundled music file for all maps
        guard let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1  // loop forever
            player?.volume = isMuted ? 0 : 1
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("MusicPlayer: failed to load \(url.lastPathComponent): \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }

    func pauseEngine() {
        player?.pause()
    }

    func resumeEngine() {
        player?.play()
    }
}

// MARK: - Legacy compatibility shim
// ProjectileSystem and GameScene reference SoundSystem.shared.play(.hit) — redirect to no-op
enum SoundType: CaseIterable {
    case archer, catapult, wizard, blacksmith, alchemist, ballista, moat, hit

    init(towerType: TowerType) {
        switch towerType {
        case .archer:     self = .archer
        case .catapult:   self = .catapult
        case .wizard:     self = .wizard
        case .blacksmith: self = .hit
        case .alchemist:  self = .alchemist
        case .bellTower:  self = .hit
        case .ballista:   self = .ballista
        case .moat:       self = .moat
        default:          self = .hit
        }
    }
}

final class SoundSystem: ObservableObject {
    static let shared = SoundSystem()
    @Published var isMuted: Bool = true
    private init() {}
    func play(_ type: SoundType) { /* no-op — replaced by MusicPlayer */ }
    func pauseEngine() {}
    func resumeEngine() {}
}
