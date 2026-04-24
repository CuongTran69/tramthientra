## ADDED Requirements

### Requirement: ThienThoView screen exists and is navigable
The system SHALL provide a ThienThoView screen that wraps BreathingCircleView with ThienThoViewModel and is reachable from TraThatView via a dedicated "Thiền Thở" button.

#### Scenario: User taps Thiền Thở button on TraThatView
- **WHEN** the user taps the "Thiền Thở" button on TraThatView
- **THEN** ThienThoView is presented as a full-screen cover with NenDongView background, a dismiss button (xmark), and BreathingCircleView centered in the content area

#### Scenario: User dismisses ThienThoView
- **WHEN** the user taps the xmark dismiss button in ThienThoView
- **THEN** ThienThoView is dismissed and the user returns to TraThatView

### Requirement: ThienThoView follows app visual and accessibility conventions
ThienThoView SHALL use NenDongView as the full-bleed background, ZenFont for all text, ZenColor for colors, and provide accessibility labels on all interactive controls.

#### Scenario: Screen renders with standard app background
- **WHEN** ThienThoView appears
- **THEN** NenDongView fills the entire screen behind all content, ignoring safe area edges

#### Scenario: Dismiss button has accessibility label
- **WHEN** VoiceOver focuses on the dismiss button
- **THEN** the accessibility label reads "Đóng" and the hint reads "Đóng màn hình thiền thở"

### Requirement: BreathingCircleView is controlled by ThienThoViewModel
ThienThoView SHALL instantiate ThienThoViewModel as a @StateObject and pass its published phase, progress, and isRunning properties to BreathingCircleView.

#### Scenario: Breathing session starts when user taps start
- **WHEN** the user taps the start/pause control in ThienThoView
- **THEN** ThienThoViewModel.toggleSession() is called and BreathingCircleView animates to reflect the current BreathingPhase

#### Scenario: Cycle counter reflects current progress
- **WHEN** a breathing cycle completes
- **THEN** the cycle counter displayed in the UI matches ThienThoViewModel.cycleText

### Requirement: Thiền Thở button is visually consistent with existing action buttons
The "Thiền Thở" button in TraThatView SHALL use ZenButton with the .secondary variant and include an appropriate SF Symbols icon and accessibility label.

#### Scenario: Button renders alongside existing action buttons
- **WHEN** TraThatView renders its action button section
- **THEN** "Tích luỹ", "Buông bỏ", and "Thiền Thở" buttons appear stacked vertically in that order with consistent spacing
