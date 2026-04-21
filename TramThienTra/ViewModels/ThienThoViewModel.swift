import Foundation
import Combine

// MARK: - Thiền Thở ViewModel
// Spec §1: Breathing exercise with 4-7-8 rhythm

enum BreathingPhase: String, CaseIterable {
    case inhale = "Hít vào"
    case hold = "Giữ hơi"
    case exhale = "Thở ra"
    case idle = "Sẵn sàng"
    
    var duration: TimeInterval {
        switch self {
        case .inhale: return 4.0
        case .hold: return 7.0
        case .exhale: return 8.0
        case .idle: return 0
        }
    }
    
    var accessibilityAnnouncement: String {
        switch self {
        case .inhale: return "Hít vào trong 4 giây"
        case .hold: return "Giữ hơi trong 7 giây"
        case .exhale: return "Thở ra trong 8 giây"
        case .idle: return "Sẵn sàng bắt đầu"
        }
    }
}

@MainActor
final class ThienThoViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentPhase: BreathingPhase = .idle
    @Published var isRunning: Bool = false
    @Published var currentCycle: Int = 0
    @Published var totalCycles: Int = 5
    @Published var phaseProgress: Double = 0.0
    @Published var secondsRemaining: Int = 0
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private var phaseStartTime: Date?
    
    // MARK: - Computed Properties
    var cycleText: String {
        guard currentCycle > 0 else { return "" }
        return "Chu kỳ: \(currentCycle)/\(totalCycles)"
    }
    
    var isComplete: Bool {
        currentCycle >= totalCycles && currentPhase == .idle && !isRunning
    }
    
    // MARK: - Public Methods
    func toggleSession() {
        if isRunning {
            pauseSession()
        } else {
            startSession()
        }
    }
    
    func startSession() {
        guard !isRunning else { return }
        
        isRunning = true
        if currentCycle == 0 {
            currentCycle = 1
        }
        
        HapticService.shared.playLight()
        startPhase(.inhale)
    }
    
    func pauseSession() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func resetSession() {
        pauseSession()
        currentPhase = .idle
        currentCycle = 0
        phaseProgress = 0.0
        secondsRemaining = 0
    }
    
    func setTotalCycles(_ cycles: Int) {
        totalCycles = max(1, min(10, cycles))
    }
    
    // MARK: - Private Methods
    private func startPhase(_ phase: BreathingPhase) {
        currentPhase = phase
        phaseProgress = 0.0
        phaseStartTime = Date()
        secondsRemaining = Int(phase.duration)
        
        if phase == .inhale || phase == .exhale {
            HapticService.shared.playLight()
        }
        
        timer?.cancel()
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateProgress()
            }
    }
    
    private func updateProgress() {
        guard let startTime = phaseStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let duration = currentPhase.duration
        
        phaseProgress = min(elapsed / duration, 1.0)
        secondsRemaining = max(0, Int(ceil(duration - elapsed)))
        
        if elapsed >= duration {
            advanceToNextPhase()
        }
    }
    
    private func advanceToNextPhase() {
        timer?.cancel()
        
        switch currentPhase {
        case .inhale:
            startPhase(.hold)
        case .hold:
            startPhase(.exhale)
        case .exhale:
            completeCycle()
        case .idle:
            break
        }
    }
    
    private func completeCycle() {
        HapticService.shared.playSuccess()
        
        if currentCycle >= totalCycles {
            // Session complete
            isRunning = false
            currentPhase = .idle
            phaseProgress = 0.0
        } else {
            // Start next cycle
            currentCycle += 1
            startPhase(.inhale)
        }
    }
}
