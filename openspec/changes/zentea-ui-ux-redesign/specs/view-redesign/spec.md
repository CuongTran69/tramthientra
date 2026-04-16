## ADDED Requirements

### Requirement: TraThatView header
TraThatView SHALL display the app title "Trạm Thiền Trà" using `ZenFont.display()` at the top of the screen. The teapot illustration SHALL be scaled to 240×240 pt and SHALL have a gold drop shadow (`zenGold.opacity(0.35)`, radius 20) to create a soft glow effect.

#### Scenario: Title visible on launch
- **WHEN** the user opens the app
- **THEN** "Trạm Thiền Trà" is displayed in display-weight serif font above the teapot

#### Scenario: Teapot glow present
- **WHEN** TraThatView is rendered
- **THEN** the teapot has a visible warm gold shadow glow behind it

### Requirement: TraThatView action buttons
The primary action buttons on TraThatView (Tích Lũy and Buông Bỏ) SHALL use the `ZenButton` primary variant with gradient fill. The streak summary row SHALL be wrapped in a `ZenCard`.

#### Scenario: Primary buttons use ZenButton
- **WHEN** TraThatView is rendered
- **THEN** both ritual action buttons display with the zenBrown gradient fill and scale animation

#### Scenario: Streak card uses ZenCard
- **WHEN** the streak summary is visible
- **THEN** it is contained within a glassmorphism ZenCard overlay

### Requirement: OnboardingView illustration and animation
Each onboarding page SHALL display its illustration at 160×160 pt. Text content SHALL fade in with a 0.4 s opacity animation when a page becomes active. The page progress indicator SHALL be a thin horizontal bar (not dots), filling from left to right as pages advance.

#### Scenario: Illustration sizing
- **WHEN** any onboarding page is shown
- **THEN** the central illustration renders at 160×160 pt

#### Scenario: Text fade-in
- **WHEN** the user swipes to a new onboarding page
- **THEN** the page title and body text fade in over 0.4 seconds

#### Scenario: Progress bar replaces dots
- **WHEN** the onboarding flow is displayed
- **THEN** a thin horizontal bar shows proportional progress instead of discrete dots

### Requirement: OnboardingView start button
The "Bắt đầu" button on the final onboarding page SHALL use `ZenButton` primary variant.

#### Scenario: Start button styling
- **WHEN** the user reaches the last onboarding page
- **THEN** the "Bắt đầu" button uses the ZenButton primary gradient style

### Requirement: TichLuyView form styling
TichLuyView text input fields SHALL use `ZenTextField` (ZenCard container + focus ring). The character counter SHALL be rendered inline inside the field using `ZenFont.caption2()`. The section header SHALL include a 1 pt `zenSage.opacity(0.4)` horizontal decoration line below the header text.

#### Scenario: Input field focus ring
- **WHEN** the user taps a gratitude text field
- **THEN** a 1 pt zenSage focus ring appears around the ZenCard container

#### Scenario: Inline character counter
- **WHEN** the user types in a TichLuy field with a character limit
- **THEN** the counter appears inside the field bottom-right, not below it

### Requirement: BuongBoView text area and button
BuongBoView SHALL render its release text area as a full-width `ZenCard` with `.ultraThinMaterial`. The "Buông" confirmation button SHALL display a smoke/dissolve icon animation lasting 0.6 s when tapped, before dismissing.

#### Scenario: Full-width glassmorphism text area
- **WHEN** BuongBoView is rendered
- **THEN** the text area occupies full available width within a ZenCard container

#### Scenario: Smoke icon animation on confirm
- **WHEN** the user taps "Buông"
- **THEN** a smoke/dissolve animation plays on the button icon for 0.6 s before the view dismisses

### Requirement: HistoryView list design
Each history list row SHALL be wrapped in a `ZenCard`. On view appear, rows SHALL animate in with a staggered vertical offset (20 pt down, fading from 0 opacity) with 0.05 s delay between each row. The empty state SHALL show a custom empty-teacup illustration with a message. Date section headers SHALL be sticky.

#### Scenario: Stagger animation on appear
- **WHEN** HistoryView appears with existing entries
- **THEN** each row animates in sequentially with a 0.05 s stagger delay

#### Scenario: Empty state illustration
- **WHEN** there are no history entries
- **THEN** an empty-teacup illustration and message are shown instead of an empty list

#### Scenario: Sticky date headers
- **WHEN** the user scrolls the history list
- **THEN** the date section header sticks to the top of the visible area until the next section scrolls into view

### Requirement: SettingsView section styling
SettingsView section headers SHALL render in uppercase with 1.5 pt letter spacing using `ZenFont.caption()`. Setting row icons SHALL be consistently sized at 22×22 pt and use `zenSage` tint. The system `Toggle` control SHALL use `zenSage` as its tint color.

#### Scenario: Uppercase headers with tracking
- **WHEN** SettingsView is rendered
- **THEN** section headers display in uppercase with visible letter spacing

#### Scenario: Consistent icon sizing
- **WHEN** any settings row with an icon is displayed
- **THEN** the icon is exactly 22×22 pt with zenSage tint
