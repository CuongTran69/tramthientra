## ADDED Requirements

### Requirement: Default notification state is OFF
The daily reminder toggle in Settings SHALL default to `false` (OFF) so that notifications are opt-in only.

#### Scenario: Fresh install default state
- **WHEN** a user launches the app for the first time without completing onboarding notification step
- **THEN** the `dailyReminderEnabled` AppStorage value defaults to `false`
- **AND** the Settings toggle shows as OFF

### Requirement: Time picker for daily reminder
The Settings view SHALL display a time picker (hour and minute) below the daily reminder toggle when the toggle is enabled, allowing users to choose when they receive their daily reminder.

#### Scenario: Time picker visibility when toggle is ON
- **WHEN** `dailyReminderEnabled` is `true`
- **THEN** a DatePicker in `.hourAndMinute` display mode is visible below the toggle

#### Scenario: Time picker hidden when toggle is OFF
- **WHEN** `dailyReminderEnabled` is `false`
- **THEN** the time picker is NOT visible

### Requirement: Notification time persistence
The selected reminder time SHALL be stored as separate `notificationHour` and `notificationMinute` integer values in UserDefaults.

#### Scenario: User changes reminder time
- **WHEN** user selects a new time using the time picker
- **THEN** the system stores the selected hour in `notificationHour` UserDefaults key
- **AND** the system stores the selected minute in `notificationMinute` UserDefaults key

#### Scenario: Default time values
- **WHEN** no custom time has been set by the user
- **THEN** `notificationHour` defaults to `21` (9 PM)
- **AND** `notificationMinute` defaults to `0`

### Requirement: Reschedule notification on time change
The system SHALL reschedule the daily reminder notification whenever the user changes the reminder time.

#### Scenario: Time change triggers reschedule
- **WHEN** user changes the reminder time via the time picker
- **THEN** the system calls `NotificationService.shared.scheduleDailyReminder(hour:minute:)` with the new hour and minute values
- **AND** the previously scheduled notification is replaced

### Requirement: NotificationService supports custom time
`NotificationService.scheduleDailyReminder()` SHALL accept optional `hour` and `minute` parameters, defaulting to the values stored in UserDefaults, which in turn fall back to `Constants.notificationHour` and `Constants.notificationMinute`.

#### Scenario: Schedule with explicit time
- **WHEN** `scheduleDailyReminder(hour: 8, minute: 30)` is called
- **THEN** the system schedules a daily local notification at 08:30

#### Scenario: Schedule with UserDefaults time
- **WHEN** `scheduleDailyReminder()` is called without parameters
- **AND** UserDefaults contains `notificationHour = 7` and `notificationMinute = 15`
- **THEN** the system schedules a daily local notification at 07:15

#### Scenario: Schedule with fallback to Constants
- **WHEN** `scheduleDailyReminder()` is called without parameters
- **AND** UserDefaults has no stored notification time values
- **THEN** the system schedules a daily local notification at the time defined in `Constants.notificationHour` and `Constants.notificationMinute`

### Requirement: Authorization status check without prompting
`NotificationService` SHALL provide a `checkCurrentAuthorizationStatus() async -> Bool` method that queries the current notification authorization status without triggering a new system permission prompt.

#### Scenario: Check when authorized
- **WHEN** `checkCurrentAuthorizationStatus()` is called
- **AND** the user has previously granted notification permission
- **THEN** the method returns `true`

#### Scenario: Check when not authorized
- **WHEN** `checkCurrentAuthorizationStatus()` is called
- **AND** the user has not granted notification permission (denied or not determined)
- **THEN** the method returns `false`
- **AND** no iOS system permission dialog is shown
