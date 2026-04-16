import UIKit
import AVFoundation

// MARK: - SPEC §3.4 Haptic & sound feedback

final class HapticService {
    static let shared = HapticService()

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private var audioPlayer: AVAudioPlayer?

    private init() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        notificationGenerator.prepare()
    }

    func playLight() {
        lightGenerator.impactOccurred()
    }

    func playMedium() {
        mediumGenerator.impactOccurred()
    }

    func playSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }

    func playWarning() {
        notificationGenerator.notificationOccurred(.warning)
    }

    func playError() {
        notificationGenerator.notificationOccurred(.error)
    }
}

// MARK: - Sound service for droplet.wav

final class SoundService {
    static let shared = SoundService()
    private var audioPlayer: AVAudioPlayer?

    private init() {}

    func playDroplet() {
        guard let url = Bundle.main.url(forResource: "droplet", withExtension: "wav") else {
            print("[Sound] droplet.wav not found in bundle")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("[Sound] Playback error: \(error.localizedDescription)")
        }
    }
}