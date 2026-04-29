import Foundation
import UserNotifications

// MARK: - SPEC §3.4 Local notification scheduling — daily reminder with custom time

final class NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let dailyReminderIdentifier = "com.tramthientra.dailyReminder"

    private init() {}

    /// Request notification authorization from the user.
    /// Returns true if authorization was granted.
    @discardableResult
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("[NotificationService] Auth error: \(error.localizedDescription)")
                }
                print("[NotificationService] Authorization granted: \(granted)")
                continuation.resume(returning: granted)
            }
        }
    }

    // MARK: - SPEC: Authorization status check without prompting

    /// Query the current notification authorization status without triggering a new system permission prompt.
    /// Returns `true` only if `authorizationStatus == .authorized`.
    func checkCurrentAuthorizationStatus() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    // MARK: - SPEC: Schedule daily reminder with configurable time

    /// Schedule a daily reminder notification.
    ///
    /// Fallback priority for hour/minute:
    /// 1. Provided parameters (if non-nil)
    /// 2. UserDefaults values (`notificationHour` / `notificationMinute`)
    /// 3. Constants defaults (`Constants.notificationHour` / `Constants.notificationMinute`)
    func scheduleDailyReminder(hour: Int? = nil, minute: Int? = nil) {
        cancelAllPendingNotifications()

        let defaults = UserDefaults.standard
        let resolvedHour: Int
        let resolvedMinute: Int

        if let hour = hour {
            resolvedHour = hour
        } else if defaults.object(forKey: Constants.notificationHourKey) != nil {
            resolvedHour = defaults.integer(forKey: Constants.notificationHourKey)
        } else {
            resolvedHour = Constants.notificationHour
        }

        if let minute = minute {
            resolvedMinute = minute
        } else if defaults.object(forKey: Constants.notificationMinuteKey) != nil {
            resolvedMinute = defaults.integer(forKey: Constants.notificationMinuteKey)
        } else {
            resolvedMinute = Constants.notificationMinute
        }

        let content = UNMutableNotificationContent()
        content.title = "Trạm Thiền Trà"
        content.body = "Đã đến lúc thực hành tạ ơn cuộc sống."
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = resolvedHour
        dateComponents.minute = resolvedMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("[NotificationService] Schedule error: \(error.localizedDescription)")
            }
        }
    }

    /// Remove all pending (and delivered) notifications.
    func cancelAllPendingNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}
