## 1. Constants and Foundation

- [x] 1.1 Add new UserDefaults keys to `Constants.swift`: `notificationHour`, `notificationMinute`, `lastNotificationPromptDate`, `notificationPromptDismissCount`
- [x] 1.2 Verify existing `Constants.notificationHour` and `Constants.notificationMinute` values are 21 and 0 respectively (these become the fallback defaults)

## 2. Clean Up AppDelegate

- [x] 2.1 Remove `UIApplication.shared.registerForRemoteNotifications()` call from `didFinishLaunchingWithOptions` in `AppDelegate.swift`
- [x] 2.2 Remove `didRegisterForRemoteNotificationsWithDeviceToken` delegate method from `AppDelegate.swift`
- [x] 2.3 Remove `didFailToRegisterForRemoteNotificationsWithError` delegate method from `AppDelegate.swift` <- (verify: AppDelegate compiles cleanly, no APNs references remain)

## 3. Update NotificationService

- [x] 3.1 Modify `scheduleDailyReminder()` in `NotificationService.swift` to accept optional `hour: Int?` and `minute: Int?` parameters
- [x] 3.2 Implement fallback logic: use provided params, then UserDefaults `notificationHour`/`notificationMinute`, then `Constants.notificationHour`/`Constants.notificationMinute`
- [x] 3.3 Add `checkCurrentAuthorizationStatus() async -> Bool` method that queries `UNUserNotificationCenter.current().notificationSettings()` and returns `true` only if `authorizationStatus == .authorized` <- (verify: method returns correct status without triggering permission prompt, scheduleDailyReminder respects all three fallback levels)

## 4. Fix Settings View

- [x] 4.1 Change `@AppStorage("dailyReminderEnabled")` default from `true` to `false` in `SettingsView.swift`
- [x] 4.2 Add `@AppStorage("notificationHour")` and `@AppStorage("notificationMinute")` properties with defaults of 21 and 0
- [x] 4.3 Add a `DatePicker` in `.hourAndMinute` display mode below the daily reminder toggle, visible only when toggle is ON
- [x] 4.4 Bind the DatePicker to a computed `Date` from the stored hour/minute values
- [x] 4.5 Add `onChange` handler for the time picker that stores the new hour/minute and calls `NotificationService.shared.scheduleDailyReminder(hour:minute:)` <- (verify: toggle defaults to OFF on fresh install, time picker shows/hides correctly, changing time reschedules notification)

## 5. Create NotificationPromptView Component

- [x] 5.1 Create `TramThienTra/Views/Components/NotificationPromptView.swift` as a reusable SwiftUI view
- [x] 5.2 Implement the view with bell icon, title "Bat nhac nho?", body text, ZenButton "Bat thong bao" (accept), and text button "De sau" (dismiss)
- [x] 5.3 Accept `onAccept` and `onDismiss` closures as parameters for action handling
- [x] 5.4 Use `NenDongView` background, `ZenCard`, `ZenButton(.primary)`, `ZenFont`, and `ZenColor` for visual consistency <- (verify: view renders correctly with all design system components, both action closures are invoked properly)

## 6. Add Notification Onboarding Page

- [x] 6.1 Add a 4th page to the onboarding `TabView` in `OnboardingView.swift` with title "Nhac nho hang ngay" and subtitle explaining daily gratitude reminders
- [x] 6.2 Add a `ZenButton` "Bat thong bao" that calls `NotificationService.shared.requestAuthorization()` and sets `dailyReminderEnabled` based on the result
- [x] 6.3 Add a "Bo qua" text button that sets `dailyReminderEnabled = false` and completes onboarding
- [x] 6.4 If permission is granted, schedule default 21:00 reminder via `NotificationService.shared.scheduleDailyReminder()`
- [x] 6.5 Use existing `NenDongView`, `ZenCard`, `ZenButton`, `ZenFont`, `ZenColor` components and existing `IllustrationType` pattern (use `.teaPot` or add `.bell`) <- (verify: onboarding flows correctly through all 4 pages, accept path requests permission and schedules notification, skip path sets dailyReminderEnabled to false, both paths complete onboarding)

## 7. Create NotificationReminderService

- [x] 7.1 Create `TramThienTra/Services/NotificationReminderService.swift` as an `ObservableObject` with `@Published var shouldShowPrompt: Bool`
- [x] 7.2 Implement `checkAndUpdatePromptStatus()` method that checks: `dailyReminderEnabled == false`, `hasCompletedOnboarding == true`, `lastNotificationPromptDate` older than 24 hours (or nil), and `notificationPromptDismissCount < 3`
- [x] 7.3 Implement `dismissPrompt()` that increments `notificationPromptDismissCount` and stores current date as `lastNotificationPromptDate`
- [x] 7.4 Implement `acceptPrompt()` that calls `NotificationService.shared.requestAuthorization()`, sets `dailyReminderEnabled = true` on success, and schedules the daily reminder <- (verify: service correctly evaluates all four conditions, dismiss increments count and sets cooldown date, accept requests permission and enables reminders, prompt stops after 3 dismissals)

## 8. Wire Notification Reminder into ContentView

- [x] 8.1 Add `@Environment(\.scenePhase)` to `ContentView` in `TramThienTraApp.swift`
- [x] 8.2 Create and inject `NotificationReminderService` as a `@StateObject`
- [x] 8.3 Add `onChange(of: scenePhase)` handler that calls `notificationReminderService.checkAndUpdatePromptStatus()` when phase is `.active`
- [x] 8.4 Add `.sheet(isPresented: $notificationReminderService.shouldShowPrompt)` presenting `NotificationPromptView` with accept/dismiss wired to the service methods <- (verify: sheet appears on foreground when all conditions met, does not appear when notifications enabled or onboarding incomplete, cooldown and max-dismissal logic works end-to-end)
