import Foundation
import SwiftUI

// MARK: - SPEC §3.3 ViewModel — Streak calculation and phase mapping

@MainActor
final class StreakViewModel: ObservableObject {
    @Published var streak: Int = 0
    @Published var stage: LeafStage = .seed

    enum LeafStage: Int, CaseIterable {
        case seed = 0
        case sprout = 1
        case young = 2
        case green = 3
        case lush = 4
        case greatTree = 5

        var title: String {
            switch self {
            case .seed: return "Hạt giống"
            case .sprout: return "Mầm non"
            case .young: return "Cây non"
            case .green: return "Cây xanh"
            case .lush: return "Cây tươi tốt"
            case .greatTree: return "Đại thụ"
            }
        }
    }

    init() {
        streak = UserDefaults.standard.integer(forKey: Constants.streakKey)
        checkStreak()
    }

    func incrementStreak() {
        streak += 1
        UserDefaults.standard.set(streak, forKey: Constants.streakKey)
        checkStreak()
    }

    func checkStreak() {
        switch streak {
        case 0: stage = .seed
        case 1...3: stage = .sprout
        case 4...7: stage = .young
        case 8...14: stage = .green
        case 15...29: stage = .lush
        default: stage = streak >= 30 ? .greatTree : .seed
        }
    }
}