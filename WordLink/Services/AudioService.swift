import AVFoundation
import UIKit

// MARK: - Audio Service (synthesized SFX, no audio files required)
//
// A small additive synth: each cue is a set of `Voice`s mixed into one buffer.
// A voice can glide in pitch, carry overtones (harmonics) for body, and add a
// little vibrato shimmer. The mix is soft-clipped through `tanh`, which both
// guards against hard clipping and adds a touch of analog-style saturation —
// the difference between a thin beep and something that feels "juicy".
final class AudioService {
    static let shared = AudioService()
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private let sampleRate = 44100.0

    private init() {
        setupEngine()
    }

    private func setupEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        guard let engine = audioEngine, let player = playerNode else { return }
        engine.attach(player)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
        try? engine.start()
    }

    // MARK: Voice + synth core

    /// One sine-plus-harmonics tone with a pitch glide, AR envelope and optional
    /// vibrato. Property order matters: it drives the memberwise initializer.
    private struct Voice {
        var start: Double            // start frequency (Hz)
        var end: Double              // end frequency — set == start for no glide
        var delay: Double = 0        // start offset within the cue (s)
        var duration: Double
        var volume: Float
        var harmonics: [Float] = [1] // amplitude of 1st, 2nd, 3rd… partials
        var attack: Double = 0.004
        var release: Double = 0.05
        var vibratoHz: Double = 0
        var vibratoDepth: Double = 0 // fraction of the frequency
    }

    /// Linear attack/sustain/release envelope in [0, 1].
    private func envelope(t: Double, duration: Double, attack: Double, release: Double) -> Double {
        if attack > 0, t < attack { return t / attack }
        let releaseStart = duration - release
        if release > 0, t > releaseStart { return max(0, (duration - t) / release) }
        return 1
    }

    /// Render the voices off the main thread, then schedule playback on it.
    private func play(_ voices: [Voice]) {
        guard let engine = audioEngine, let player = playerNode else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self, let buffer = self.makeBuffer(voices) else { return }
            DispatchQueue.main.async {
                if !engine.isRunning { try? engine.start() }
                player.scheduleBuffer(buffer, completionHandler: nil)
                if !player.isPlaying { player.play() }
            }
        }
    }

    private func makeBuffer(_ voices: [Voice]) -> AVAudioPCMBuffer? {
        let total = voices.map { $0.delay + $0.duration }.max() ?? 0
        guard total > 0,
              let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return nil }
        let frameCount = AVAudioFrameCount(sampleRate * (total + 0.02))
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        let data = buffer.floatChannelData![0]
        let count = Int(frameCount)
        for i in 0..<count { data[i] = 0 }

        for v in voices {
            let startFrame = Int(v.delay * sampleRate)
            let voiceFrames = Int(v.duration * sampleRate)
            var phase = 0.0
            for n in 0..<voiceFrames {
                let i = startFrame + n
                if i >= count { break }
                let t = Double(n) / sampleRate
                let prog = v.duration > 0 ? t / v.duration : 0
                var f = v.start + (v.end - v.start) * prog
                if v.vibratoHz > 0 {
                    f *= 1 + v.vibratoDepth * sin(2 * .pi * v.vibratoHz * t)
                }
                phase += 2 * .pi * f / sampleRate
                var sample = 0.0
                for (h, amp) in v.harmonics.enumerated() {
                    sample += Double(amp) * sin(Double(h + 1) * phase)
                }
                let env = envelope(t: t, duration: v.duration, attack: v.attack, release: v.release)
                data[i] += Float(sample * Double(v.volume) * env)
            }
        }

        // Soft clip: keeps the signal in range and warms it with gentle saturation.
        for i in 0..<count { data[i] = Float(tanh(Double(data[i]) * 1.5)) }
        return buffer
    }

    // MARK: Cues

    /// Soft, crisp click when a letter is tapped.
    func playTap() {
        play([Voice(start: 1300, end: 950, duration: 0.045, volume: 0.22,
                    harmonics: [1, 0.25], attack: 0.001, release: 0.04)])
    }

    /// The signature link-snap: a punchy rising body plus a high transient click.
    func playSnap() {
        play([
            Voice(start: 320, end: 760, duration: 0.10, volume: 0.5,
                  harmonics: [1, 0.55, 0.3, 0.12], attack: 0.001, release: 0.085),
            Voice(start: 1800, end: 1500, duration: 0.028, volume: 0.28,
                  harmonics: [1, 0.4], attack: 0.0005, release: 0.026)
        ])
    }

    /// Rewarding ascending triad (C–E–G) with a high shimmer on top.
    func playCorrect() {
        let rich: [Float] = [1, 0.5, 0.28, 0.14]
        play([
            Voice(start: 523.25, end: 523.25, duration: 0.14, volume: 0.38,
                  harmonics: rich, attack: 0.003, release: 0.11),
            Voice(start: 659.25, end: 659.25, delay: 0.07, duration: 0.14, volume: 0.38,
                  harmonics: rich, attack: 0.003, release: 0.11),
            Voice(start: 783.99, end: 783.99, delay: 0.14, duration: 0.24, volume: 0.44,
                  harmonics: rich, attack: 0.003, release: 0.17),
            Voice(start: 1567.98, end: 1567.98, delay: 0.14, duration: 0.24, volume: 0.12,
                  harmonics: [1, 0.3], attack: 0.004, release: 0.2, vibratoHz: 14, vibratoDepth: 0.01)
        ])
    }

    /// Soft descending "thunk" with a detuned partner for grit — wrong, not harsh.
    func playWrong() {
        play([
            Voice(start: 233, end: 150, duration: 0.24, volume: 0.32,
                  harmonics: [1, 0.6, 0.45, 0.2], attack: 0.002, release: 0.14),
            Voice(start: 240, end: 154, duration: 0.24, volume: 0.2,
                  harmonics: [1, 0.5], attack: 0.002, release: 0.14)
        ])
    }

    /// Gentle rising sparkle with an octave shimmer.
    func playHint() {
        play([
            Voice(start: 880, end: 1245, duration: 0.13, volume: 0.3,
                  harmonics: [1, 0.35, 0.15], attack: 0.003, release: 0.1),
            Voice(start: 1760, end: 2490, duration: 0.13, volume: 0.08,
                  harmonics: [1], attack: 0.004, release: 0.11)
        ])
    }

    /// Triumphant ~1s fanfare: three rising chords, a bass root and a sparkle tail.
    func playCompletion() {
        let rich: [Float] = [1, 0.5, 0.3, 0.16]
        func chord(_ freqs: [Double], delay: Double, dur: Double, vol: Float) -> [Voice] {
            freqs.map {
                Voice(start: $0, end: $0, delay: delay, duration: dur, volume: vol,
                      harmonics: rich, attack: 0.004, release: dur * 0.5)
            }
        }
        var voices: [Voice] = []
        voices += chord([523.25, 659.25, 783.99], delay: 0.0, dur: 0.28, vol: 0.3)    // C  E  G
        voices += chord([587.33, 739.99, 880.0],  delay: 0.22, dur: 0.28, vol: 0.3)   // D  F# A
        voices += chord([783.99, 987.77, 1174.66], delay: 0.46, dur: 0.5, vol: 0.34)  // G  B  D (bright)
        voices.append(Voice(start: 130.81, end: 130.81, delay: 0.46, duration: 0.6, volume: 0.28,
                            harmonics: [1, 0.4, 0.2], attack: 0.004, release: 0.4))    // C3 bass
        voices.append(Voice(start: 1567.98, end: 1567.98, delay: 0.5, duration: 0.6, volume: 0.12,
                            harmonics: [1, 0.3], attack: 0.005, release: 0.4, vibratoHz: 12, vibratoDepth: 0.012))
        play(voices)
    }

    /// Synthesized fallback used by `SoundManager` when no bundled `.wav` exists
    /// for a juice cue. Maps cue names to the generators above.
    func playFallback(_ name: String) {
        switch name {
        case "tap":            playTap()
        case "snap":           playSnap()
        case "success":        playCorrect()
        case "level_complete": playCompletion()
        case "wrong":          playWrong()
        case "hint":           playHint()
        default:               break
        }
    }
}

// MARK: - Haptics Service
final class HapticsService {
    static let shared = HapticsService()
    private init() {}

    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}

// MARK: - Speech Service (TTS)
final class SpeechService {
    static let shared = SpeechService()
    private let synthesizer = AVSpeechSynthesizer()
    private init() {}

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text.lowercased())
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.1
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
}
