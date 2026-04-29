## ADDED Requirements

### Requirement: Foreground notification reminder check
The system SHALL check whether to show a notification reminder prompt each time the app enters the foreground (active scene phase).

#### Scenario: Conditions met for showing prompt
- **WHEN** the app enters the foreground
- **AND** `dailyReminderEnabled` is `false`
- **AND** `hasCompletedOnboarding` is `true`
- **AND** `lastNotificationPromptDate` is either nil or more than 24 hours ago
- **AND** `notificationPromptDismissCount` is less than 3
- **THEN** the system shows the notification reminder prompt as a sheet

#### Scenario: Notifications already enabled
- **WHEN** the app enters the foreground
- **AND** `dailyReminderEnabled` is `true`
- **THEN** the system does NOT show the notification reminder prompt

#### Scenario: Onboarding not completed
- **WHEN** the app enters the foreground
- **AND** `hasCompletedOnboarding` is `false`
- **THEN** the system does NOT show the notification reminder prompt

### Requirement: 24-hour cooldown between prompts
The system SHALL NOT show the notification reminder prompt more than once within a 24-hour period.

#### Scenario: Prompt shown within 24 hours
- **WHEN** the app enters the foreground
- **AND** `lastNotificationPromptDate` was set less than 24 hours ago
- **THEN** the system does NOT show the notification reminder prompt

#### Scenario: Prompt shown after 24 hours
- **WHEN** the app enters the foreground
- **AND** `lastNotificationPromptDate` was set more than 24 hours ago
- **AND** all other conditions are met
- **THEN** the system shows the notification reminder prompt

### Requirement: Maximum 3 dismissals
The system SHALL stop showing the notification reminder prompt after the user has dismissed it 3 times.

#### Scenario: User has dismissed 3 times
- **WHEN** the app enters the foreground
- **AND** `notificationPromptDismissCount` equals 3
- **THEN** the system does NOT show the notification reminder prompt regardless of other conditions

#### Scenario: User has dismissed fewer than 3 times
- **WHEN** the app enters the foreground
- **AND** `notificationPromptDismissCount` is less than 3
- **AND** all other conditions are met
- **THEN** the system shows the notification reminder prompt

### Requirement: Reminder prompt accept action
When the user accepts the notification reminder prompt, the system SHALL request notification permission, enable daily reminders, and schedule the notification.

#### Scenario: User accepts and grants permission
- **WHEN** user taps "Bat thong bao" on the notification reminder prompt
- **AND** user grants notification permission
- **THEN** the system sets `dailyReminderEnabled` to `true`
- **AND** the system schedules a daily reminder at the stored time (or default 21:00)
- **AND** the prompt sheet is dismissed

#### Scenario: User accepts but denies permission
- **WHEN** user taps "Bat thong bao" on the notification reminder prompt
- **AND** user denies notification permission
- **THEN** `dailyReminderEnabled` remains `false`
- **AND** the prompt sheet is dismissed

### Requirement: Reminder prompt dismiss action
When the user dismisses the notification reminder prompt, the system SHALL record the dismissal for cooldown and count tracking.

#### Scenario: User taps dismiss
- **WHEN** user taps "De sau" on the notification reminder prompt
- **THEN** the system stores the current date as `lastNotificationPromptDate` in UserDefaults
- **AND** the system increments `notificationPromptDismissCount` by 1
- **AND** the prompt sheet is dismissed

### Requirement: Notification prompt view content
The notification reminder prompt SHALL display specific content following the app's design system.

#### Scenario: Prompt content and styling
- **WHEN** the notification reminder prompt is displayed
- **THEN** it shows a bell icon
- **AND** title text "Bat nhac nho?"
- **AND** body text "Tram Thien Tra co the nhac ban moi ngay de thuc hanh ta on cuoc song."
- **AND** a `ZenButton` with "Bat thong bao" as the accept action
- **AND** a text button "De sau" as the dismiss action

### Requirement: NotificationReminderService as ObservableObject
The reminder logic SHALL be encapsulated in a `NotificationReminderService` class conforming to `ObservableObject` with a published property indicating whether to show the prompt.

#### Scenario: Service publishes show state
- **WHEN** `NotificationReminderService.checkAndUpdatePromptStatus()` is called
- **AND** all conditions for showing the prompt are met
- **THEN** `shouldShowPrompt` is set to `true`

#### Scenario: Service publishes hide state
- **WHEN** `NotificationReminderService.checkAndUpdatePromptStatus()` is called
- **AND** any condition for showing the prompt is NOT met
- **THEN** `shouldShowPrompt` is set to `false`

### Requirement: ContentView integration
The notification reminder prompt SHALL be wired into the main content view via scene phase observation and presented as a sheet.

#### Scenario: Scene phase triggers check
- **WHEN** scene phase changes to `.active`
- **THEN** the system calls `NotificationReminderService.checkAndUpdatePromptStatus()`

#### Scenario: Sheet presentation
- **WHEN** `NotificationReminderService.shouldShowPrompt` is `true`
- **THEN** a `.sheet` presenting `NotificationPromptView` is shown in `ContentView`
