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
