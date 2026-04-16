import Foundation
import SwiftUI

// MARK: - SPEC §3.3 ViewModel — Main screen state

@MainActor
final class TraThatViewModel: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    @Published var currentStreak: Int = 0

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(
            forKey: Constants.hasCompletedOnboardingKey
        )
    }

    func refreshOnboardingState() {
        hasCompletedOnboarding = UserDefaults.standard.bool(
            forKey: Constants.hasCompletedOnboardingKey
        )
    }
}