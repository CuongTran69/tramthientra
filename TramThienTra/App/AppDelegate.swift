import UIKit

// MARK: - SPEC §1 App Delegate for APNs registration
// TODO: Implement APNs token registration (SPEC §3.4)

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Register for remote notifications to receive APNs token
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // TODO: Pass token to NotificationService for APNs setup (SPEC §3.4)
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("[APNs] Token received: \(token)")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[APNs] Registration failed: \(error.localizedDescription)")
    }
}