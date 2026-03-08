import AVFoundation
import Combine

enum SoundType: CaseIterable {
    case archer, catapult, wizard, barracks, alchemist, ballista, moat, hit

    init(towerType: TowerType) {
        switch towerType {
        case .archer:    self = .archer
        case .catapult:  self = .catapult
        case .wizard:    self = .wizard
        case .barracks:  self = .barracks
        case .alchemist: self = .alchemist
        case .bellTower: self = .hit   // support tower doesn't fire
        case .ballista:  self = .ballista
        case .moat:      self = .moat
        }
    }
}

/// Synthesizes short procedural sounds via AVAudioEngine (no audio files needed).
/// Buffers are pre-generated at init for zero per-shot allocation.
final class SoundSystem: ObservableObject {
    static let shared = SoundSystem()

    @Published var isMuted: Bool {
        didSet { UserDefaults.standard.set(isMuted, forKey: "soundMuted") }
    }

    private let engine = AVAudioMixerNode()
    private let avEngine = AVAudioEngine()
    private var cachedBuffers: [SoundType: AVAudioPCMBuffer] = [:]
    private var playerPool: [AVAudioPlayerNode] = []
    private let poolSize = 8

    private let bufferFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!

    private init() {
        isMuted = UserDefaults.standard.bool(forKey: "soundMuted")

        avEngine.attach(engine)
        avEngine.connect(engine, to: avEngine.mainMixerNode, format: nil)
        try? avEngine.start()

        // Pre-create player node pool with explicit mono format
        for _ in 0..<poolSize {
            let player = AVAudioPlayerNode()
            avEngine.attach(player)
            avEngine.connect(player, to: engine, format: bufferFormat)
            playerPool.append(player)
        }

        // Pre-synthesize all sound buffers at init
        for type in SoundType.allCases {
            let params = soundParams(for: type)
            if let buffer = makeBuffer(params) {
                cachedBuffers[type] = buffer
            }
        }
    }

    private var nextPlayerIndex = 0

    func play(_ type: SoundType) {
        guard !isMuted, let buffer = cachedBuffers[type] else { return }

        let player = playerPool[nextPlayerIndex % poolSize]
        nextPlayerIndex += 1

        player.stop()
        player.play()
        player.scheduleBuffer(buffer, completionHandler: nil)
    }

    func pauseEngine() {
        avEngine.pause()
    }

    func resumeEngine() {
        try? avEngine.start()
    }

    // MARK: - Buffer synthesis

    private struct Params {
        let oscType: OscType
        let startFreq: Double
        let endFreq: Double
        let duration: Double
        let volume: Float
    }

    private enum OscType { case sine, sawtooth, square, triangle }

    private func soundParams(for type: SoundType) -> Params {
        switch type {
        case .archer:    return Params(oscType: .sawtooth,  startFreq: 800,  endFreq: 200,  duration: 0.10, volume: 0.16)
        case .catapult:  return Params(oscType: .sine,      startFreq: 80,   endFreq: 30,   duration: 0.25, volume: 0.18)
        case .wizard:    return Params(oscType: .sine,      startFreq: 500,  endFreq: 800,  duration: 0.18, volume: 0.14)
        case .barracks:  return Params(oscType: .square,    startFreq: 300,  endFreq: 150,  duration: 0.15, volume: 0.12)
        case .alchemist: return Params(oscType: .triangle,  startFreq: 400,  endFreq: 600,  duration: 0.12, volume: 0.12)
        case .ballista:  return Params(oscType: .sawtooth,  startFreq: 600,  endFreq: 100,  duration: 0.14, volume: 0.16)
        case .moat:      return Params(oscType: .sine,      startFreq: 200,  endFreq: 400,  duration: 0.20, volume: 0.12)
        case .hit:       return Params(oscType: .sine,      startFreq: 1200, endFreq: 800,  duration: 0.08, volume: 0.10)
        }
    }

    private func makeBuffer(_ params: Params) -> AVAudioPCMBuffer? {
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(sampleRate * params.duration)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        buffer.frameLength = frameCount

        let data = buffer.floatChannelData![0]
        let twoPi = 2.0 * Double.pi
        var phase = 0.0

        for i in 0..<Int(frameCount) {
            let t        = Double(i) / sampleRate
            let progress = t / params.duration
            let freq     = params.startFreq + (params.endFreq - params.startFreq) * progress
            let envelope = Float(max(0.0, 1.0 - progress))

            phase += twoPi * freq / sampleRate
            if phase > twoPi { phase -= twoPi }

            var sample: Float
            switch params.oscType {
            case .sine:
                sample = Float(sin(phase))
            case .sawtooth:
                sample = Float(phase / Double.pi - 1.0)   // -1 ... 1
            case .square:
                sample = sin(phase) >= 0 ? 1.0 : -1.0
            case .triangle:
                let norm = phase / twoPi
                sample = Float(abs(4.0 * norm - 2.0) - 1.0)
            }

            data[i] = sample * envelope * params.volume
        }

        return buffer
    }
}
