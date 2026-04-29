## Context

TramThienTra (Zen Tea) is a SwiftUI-based iOS gratitude practice app. It currently has a daily reminder notification feature that is fundamentally broken: the Settings toggle defaults to ON without requesting system permission, and `AppDelegate` registers for remote notifications (APNs) even though the app only uses local notifications. There is no onboarding step for notifications and no way for users to customize the reminder time (hardcoded to 21:00).

The app follows established patterns: `NenDongView` for backgrounds, `ZenButton`/`ZenCard`/`ZenFont`/`ZenColor` for UI, `@AppStorage` for UserDefaults persistence, and `@EnvironmentObject` for view model injection. The onboarding flow currently has 3 pages managed by `OnboardingView`.

## Goals / Non-Goals

**Goals:**
- Make notification permission explicitly opt-in with proper iOS authorization flow
- Remove dead APNs registration code from AppDelegate
- Let users choose their daily reminder time via a time picker in Settings
- Introduce a notification permission step in the onboarding flow
- Provide a gentle re-prompt mechanism for users who skip/decline notifications (max 3 attempts, 24h cooldown)

**Non-Goals:**
- Push notification / APNs integration (the app is local-only)
- Notification categories, actions, or rich notifications
- Multiple reminders per day or per-feature notification channels
- Localization beyond Vietnamese (the app is Vietnamese-only)
- Migrating existing users who already have `dailyReminderEnabled = true` (they keep their current state)

## Decisions

### 1. Default notification state: OFF instead of ON

The `@AppStorage("dailyReminderEnabled")` default changes from `true` to `false`. This is a correctness fix -- the current default of `true` means the UI shows the toggle as enabled without ever requesting system permission, so notifications are never actually delivered.

**Why not migrate existing users?** Users who already launched the app have a stored value in UserDefaults. Changing the code-level default only affects fresh installs. Existing users with `dailyReminderEnabled = true` will keep their toggle ON, and the `onChange` handler will still trigger permission requests when they interact with it. No migration needed.

### 2. Time storage as separate hour/minute integers in UserDefaults

Store `notificationHour` (Int) and `notificationMinute` (Int) via `@AppStorage` rather than a `Date` or formatted string. This avoids timezone/calendar serialization issues and maps directly to `DateComponents` used by `UNCalendarNotificationTrigger`.

**Alternative considered:** Storing a `Date` object. Rejected because `Date` includes a full timestamp that would need parsing, and timezone changes could shift the intended time.

### 3. Onboarding notification page as the 4th (final) page

The notification permission page is added as page 4 of the onboarding `TabView`, after the existing 3 content pages. This follows iOS convention of requesting permissions late in onboarding after establishing value.

**Alternative considered:** A modal sheet after onboarding completes. Rejected because it creates a jarring context switch and the onboarding `TabView` already supports paged navigation.

### 4. NotificationReminderService as a standalone ObservableObject

The reminder logic (cooldown tracking, dismissal counting, foreground checks) lives in a dedicated `NotificationReminderService` class conforming to `ObservableObject` with a `@Published var shouldShowPrompt: Bool`. This keeps the logic testable and separated from `ContentView`.

**Alternative considered:** Inline logic in `ContentView` or `TramThienTraApp`. Rejected because the logic involves multiple UserDefaults reads, date comparisons, and async permission checks that would clutter the view layer.

### 5. Reusable NotificationPromptView component

The notification permission prompt UI (`NotificationPromptView`) is a standalone SwiftUI view used in both the onboarding page and the reminder sheet. It accepts closures for accept/skip actions, enabling different behavior depending on context (onboarding vs. in-app reminder).

### 6. Remove APNs registration entirely

`UIApplication.shared.registerForRemoteNotifications()` and the associated delegate methods are removed from `AppDelegate`. The app has no APNs certificate, no server-side push infrastructure, and only schedules local notifications via `UNUserNotificationCenter`. The remote registration call is dead code.

## Risks / Trade-offs

- **[Existing users with toggle ON but no permission]** Users who installed the app before this fix have `dailyReminderEnabled = true` in UserDefaults but may never have granted notification permission. **Mitigation:** On Settings view load, check actual authorization status via `NotificationService.checkCurrentAuthorizationStatus()`. If permission is denied/not-determined but toggle is ON, the `onChange` handler will fire when they interact with it, prompting for permission. A future enhancement could proactively detect and fix this mismatch.

- **[Reminder prompt fatigue]** Showing notification prompts on every foreground could annoy users. **Mitigation:** 24-hour cooldown between prompts and hard cap of 3 total dismissals. After 3 dismissals, the prompt is never shown again.

- **[Onboarding page count increase]** Going from 3 to 4 pages may reduce onboarding completion rate. **Mitigation:** The notification page has a prominent "Skip" button and is the last page, so users can complete it quickly. The page provides clear value proposition before asking for permission.

- **[Time picker UX]** SwiftUI's `DatePicker` in `.hourAndMinute` mode uses a wheel/compact picker that may not match the app's zen aesthetic. **Mitigation:** Wrap it in a `ZenCard` for visual consistency. Custom time picker is a non-goal for this change.
