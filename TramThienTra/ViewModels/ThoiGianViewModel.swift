import Foundation
import Combine

// MARK: - Shared time-slot view model
//
// Single source of truth for the current ThoiGian slot and intra-slot progress.
// Created as @StateObject at app root and injected via .environmentObject so that
// every view reads from one 30-second tick, eliminating timer drift between views.

final class ThoiGianViewModel: ObservableObject {

    /// The active time slot, updated every 30 seconds on the main thread.
    @Published var current: ThoiGian

    /// Fractional position within the current slot: 0.0 at slot start, 1.0 at slot end.
    @Published var progress: Double

    private var timer: Timer?

    init() {
        let slot = ThoiGian.current
        self.current = slot
        self.progress = ThoiGianViewModel.computeProgress(for: slot)
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Private helpers

    private func startTimer() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 30,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            let slot = ThoiGian.current
            self.current = slot
            self.progress = ThoiGianViewModel.computeProgress(for: slot)
        }
        // Allow firing while scroll views are tracking
        RunLoop.main.add(timer!, forMode: .common)
    }

    /// Returns the fractional position (0.0–1.0) within the given slot based on the current clock.
    private static func computeProgress(for slot: ThoiGian) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let hour = Double(calendar.component(.hour, from: now))
        let minute = Double(calendar.component(.minute, from: now))
        let second = Double(calendar.component(.second, from: now))
        let currentSeconds = hour * 3600 + minute * 60 + second

        // Slot boundaries in seconds from midnight (with 24-hour wraparound for traDenDem)
        let (startHour, endHour): (Double, Double)
        switch slot {
        case .suongSom:   startHour = 5;  endHour = 9
        case .buoiSang:   startHour = 9;  endHour = 12
        case .banNgay:    startHour = 12; endHour = 15
        case .chieuTa:    startHour = 15; endHour = 18
        case .hoangHon:   startHour = 18; endHour = 21
        case .traDenDem:  startHour = 21; endHour = 29   // 21:00 – 05:00 next day (29 = 24+5)
        }

        let startSeconds = startHour * 3600
        let totalSeconds = (endHour - startHour) * 3600

        // For traDenDem the current clock may be in 0–5h range; normalise
        var elapsed = currentSeconds - startSeconds
        if slot == .traDenDem && elapsed < 0 {
            elapsed += 24 * 3600
        }

        let raw = elapsed / totalSeconds
        return min(max(raw, 0.0), 1.0)
    }
}
