## Why

The app auto-enables daily reminder notifications without user consent. `AppDelegate` unconditionally registers for remote notifications on launch (unnecessary since the app only uses local notifications), and the Settings toggle defaults to ON (`dailyReminderEnabled = true`) without ever requesting notification permission. There is no onboarding step for notifications, no way to customize reminder time, and no mechanism to re-prompt users who decline. This violates iOS notification guidelines and creates a broken user experience where the toggle shows ON but no notifications are actually delivered.

## What Changes

- Remove unnecessary APNs remote notification registration from `AppDelegate` (the app only uses local notifications)
- Change the default value of `dailyReminderEnabled` from `true` to `false` so notifications are opt-in
- Add a date/time picker in Settings for users to choose their daily reminder time (currently hardcoded to 21:00)
- Add a 4th onboarding page that explains daily reminders and requests notification permission with explicit accept/skip actions
- Extend `NotificationService` to support custom reminder times and expose an authorization status check method
- Add a gentle in-app reminder system that periodically prompts users who have not enabled notifications (max 3 prompts, 24h cooldown)
- Add new reusable `NotificationPromptView` component for the reminder sheet
- Add new UserDefaults keys for notification time, prompt tracking, and dismissal count

## Capabilities

### New Capabilities
- `notification-onboarding`: Onboarding page that explains daily reminders and requests notification permission with accept/skip options
- `notification-time-picker`: User-facing time picker in Settings for choosing daily reminder hour and minute
- `notification-reminder`: In-app reminder system that gently prompts users to enable notifications (cooldown-based, max 3 dismissals)

### Modified Capabilities

None. No existing specs require requirement-level changes.

## Impact

- **Files modified**: `SettingsView.swift`, `AppDelegate.swift`, `OnboardingView.swift`, `NotificationService.swift`, `TramThienTraApp.swift`, `Constants.swift`
- **Files created**: `NotificationReminderService.swift`, `NotificationPromptView.swift`
- **UserDefaults**: New keys for `notificationHour`, `notificationMinute`, `lastNotificationPromptDate`, `notificationPromptDismissCount`
- **Onboarding flow**: Changes from 3 pages to 4 pages, existing users are not affected (only shown on first launch)
- **No backend/API impact**: All changes are client-side, local notifications only
- **No dependency changes**: Uses only built-in iOS frameworks (UserNotifications, SwiftUI)
