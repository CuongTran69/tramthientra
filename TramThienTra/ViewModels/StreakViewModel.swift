import Foundation
import SwiftUI

// MARK: - SPEC §3.3 ViewModel — Streak calculation and phase mapping

@MainActor
final class StreakViewModel: ObservableObject {
    @Published var streak: Int = 0
    @Published var stage: LeafStage = .hatTra

    enum LeafStage: Int, CaseIterable {
        case hatTra = 0
        case mamTra = 1
        case bupNon = 2
        case laNon = 3
        case laXanh = 4
        case traChin = 5

        var title: String {
            switch self {
            case .hatTra: return "Hạt Trà"
            case .mamTra: return "Mầm Trà"
            case .bupNon: return "Búp Non"
            case .laNon: return "Lá Non"
            case .laXanh: return "Lá Xanh"
            case .traChin: return "Trà Chín"
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
        case 0: stage = .hatTra
        case 1...3: stage = .mamTra
        case 4...7: stage = .bupNon
        case 8...14: stage = .laNon
        case 15...29: stage = .laXanh
        default: stage = streak >= 30 ? .traChin : .hatTra
        }
    }
}