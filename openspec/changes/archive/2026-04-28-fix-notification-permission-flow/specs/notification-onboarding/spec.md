## ADDED Requirements

### Requirement: Notification onboarding page exists
The onboarding flow SHALL include a notification permission page as the 4th (final) page in the onboarding TabView, displayed after the existing 3 content pages.

#### Scenario: User reaches notification page during onboarding
- **WHEN** user swipes to the 4th page during onboarding
- **THEN** the system displays a notification permission page with a title "Nhac nho hang ngay", a subtitle explaining the daily gratitude reminder feature, a primary "Bat thong bao" button, and a secondary "Bo qua" text button

### Requirement: Notification permission request on accept
The system SHALL request iOS notification authorization when the user taps the accept button on the onboarding notification page.

#### Scenario: User taps accept and grants permission
- **WHEN** user taps "Bat thong bao" on the onboarding notification page
- **AND** user grants notification permission in the iOS system dialog
- **THEN** the system sets `dailyReminderEnabled` to `true` in UserDefaults
- **AND** the system schedules a daily reminder at the default time (21:00)
- **AND** the system advances to complete onboarding

#### Scenario: User taps accept but denies permission
- **WHEN** user taps "Bat thong bao" on the onboarding notification page
- **AND** user denies notification permission in the iOS system dialog
- **THEN** the system sets `dailyReminderEnabled` to `false` in UserDefaults
- **AND** the system advances to complete onboarding

### Requirement: Skip notification permission
The system SHALL allow users to skip the notification permission step during onboarding without requesting system authorization.

#### Scenario: User taps skip
- **WHEN** user taps "Bo qua" on the onboarding notification page
- **THEN** the system sets `dailyReminderEnabled` to `false` in UserDefaults
- **AND** the system advances to complete onboarding
- **AND** no iOS notification permission dialog is shown

### Requirement: Onboarding notification page uses existing design system
The notification onboarding page SHALL use the app's existing visual components and patterns for consistency with the rest of the onboarding flow.

#### Scenario: Visual consistency
- **WHEN** the notification onboarding page is displayed
- **THEN** the page uses `NenDongView` as the background
- **AND** the page uses `ZenButton` with `.primary` variant for the accept action
- **AND** the page uses `ZenCard` for content layout
- **AND** the page uses `ZenFont` for typography and `ZenColor` for colors

### Requirement: Remove unnecessary APNs registration
The app SHALL NOT register for remote notifications on launch since only local notifications are used.

#### Scenario: App launch without APNs registration
- **WHEN** the app launches via `didFinishLaunchingWithOptions`
- **THEN** the system does NOT call `UIApplication.shared.registerForRemoteNotifications()`
- **AND** the `didRegisterForRemoteNotificationsWithDeviceToken` delegate method does not exist
- **AND** the `didFailToRegisterForRemoteNotificationsWithError` delegate method does not exist
