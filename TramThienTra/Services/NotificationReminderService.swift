import Foundation
import SwiftUI

// MARK: - SPEC: Notification reminder service
//
// Manages the in-app notification prompt that gently reminds users
// to enable daily notifications. Conditions for showing the prompt:
// 1. dailyReminderEnabled == false
// 2. hasCompletedOnboarding == true
// 3. lastNotificationPromptDate is nil or older than 24 hours
// 4. notificationPromptDismissCount < 3

final class NotificationReminderService: ObservableObject {
    @Published var shouldShowPrompt: Bool = false

    // MARK: - Check and update prompt visibility

    /// Evaluates all four conditions and sets `shouldShowPrompt` accordingly.
    /// Call this when the app enters the foreground (scene phase becomes `.active`).
    func checkAndUpdatePromptStatus() {
        let defaults = UserDefaults.standard

        // Condition 1: Notifications must be disabled
        let dailyReminderEnabled = defaults.bool(forKey: Constants.dailyReminderEnabledKey)
        guard !dailyReminderEnabled else {
            shouldShowPrompt = false
            return
        }

        // Condition 2: Onboarding must be completed
        let hasCompletedOnboarding = defaults.bool(forKey: Constants.hasCompletedOnboardingKey)
        guard hasCompletedOnboarding else {
            shouldShowPrompt = false
            return
        }

        // Condition 3: 24-hour cooldown since last prompt
        if let lastPromptDate = defaults.object(forKey: Constants.lastNotificationPromptDateKey) as? Date {
            let hoursSinceLastPrompt = Date().timeIntervalSince(lastPromptDate) / 3600
            guard hoursSinceLastPrompt >= 24 else {
                shouldShowPrompt = false
                return
            }
        }

        // Condition 4: Fewer than 3 dismissals
        let dismissCount = defaults.integer(forKey: Constants.notificationPromptDismissCountKey)
        guard dismissCount < 3 else {
            shouldShowPrompt = false
            return
        }

        // All conditions met
        shouldShowPrompt = true
    }

    // MARK: - Dismiss prompt

    /// Records the dismissal: increments the dismiss count and stores the current date
    /// as the last prompt date for cooldown tracking.
    func dismissPrompt() {
        let defaults = UserDefaults.standard
        let currentCount = defaults.integer(forKey: Constants.notificationPromptDismissCountKey)
        defaults.set(currentCount + 1, forKey: Constants.notificationPromptDismissCountKey)
        defaults.set(Date(), forKey: Constants.lastNotificationPromptDateKey)
        shouldShowPrompt = false
    }

    // MARK: - Accept prompt

    /// Requests notification permission, enables daily reminders on success,
    /// and schedules the daily reminder at the stored (or default) time.
    func acceptPrompt() {
        Task {
            let granted = await NotificationService.shared.requestAuthorization()
            await MainActor.run {
                if granted {
                    UserDefaults.standard.set(true, forKey: Constants.dailyReminderEnabledKey)
                    NotificationService.shared.scheduleDailyReminder()
                }
                shouldShowPrompt = false
            }
        }
    }
}
