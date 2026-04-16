import Foundation
import UserNotifications

// MARK: - SPEC §3.4 Local notification scheduling — daily 21:00 reminder

final class NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let dailyReminderIdentifier = "com.tramthientra.dailyReminder"

    private init() {}

    /// Request notification authorization from the user.
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("[NotificationService] Auth error: \(error.localizedDescription)")
            }
            print("[NotificationService] Authorization granted: \(granted)")
        }
    }

    /// Schedule a daily reminder at 21:00.
    func scheduleDailyReminder() {
        cancelAllPendingNotifications()

        let content = UNMutableNotificationContent()
        content.title = "Trạm Thiền Trà"
        content.body = "Đã đến lúc thực hành tạ ơn cuộc sống."
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = Constants.notificationHour
        dateComponents.minute = Constants.notificationMinute

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