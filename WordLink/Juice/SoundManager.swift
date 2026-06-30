import AVFoundation

/// Central sound front-door for the game's "juice" layer.
///
/// Plays short `.wav` SFX when the founder supplies them in the app bundle
/// (`tap.wav`, `snap.wav`, `success.wav`, `level_complete.wav`, and optionally
/// `wrong.wav` / `hint.wav`). For any cue without a bundled file it falls back
/// to the synthesized tones in `AudioService`, so the game always has sound.
///
/// A single persisted `isMuted` flag gates every cue, so the Settings toggle
/// silences both the file-based and synthesized paths and survives relaunch.
@MainActor
final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    @Published var isMuted: Bool {
        didSet { UserDefaults.standard.set(isMuted, forKey: "soundMuted") }
    }

    private var players: [String: AVAudioPlayer] = [:]

    private init() {
        isMuted = UserDefaults.standard.bool(forKey: "soundMuted")
        configureSession()
        // Founder-supplied assets; any that are missing fall back to synth tones.
        preload(["tap", "snap", "success", "level_complete", "wrong", "hint"])
    }

    private func configureSession() {
        // .ambient respects the physical silent switch and mixes with music apps.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func preload(_ names: [String]) {
        for name in names {
            // Look in the bundled `Sounds/` folder first, then the bundle root.
            guard let url = Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Sounds")
                    ?? Bundle.main.url(forResource: name, withExtension: "wav"),
                  let player = try? AVAudioPlayer(contentsOf: url) else { continue }
            player.prepareToPlay()
            players[name] = player
        }
    }

    func play(_ name: String) {
        guard !isMuted else { return }
        if let player = players[name] {
            player.currentTime = 0
            player.play()
        } else {
            // No bundled .wav for this cue yet — use the synthesized fallback.
            AudioService.shared.playFallback(name)
        }
    }
}
