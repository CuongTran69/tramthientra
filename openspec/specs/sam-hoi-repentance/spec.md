## ADDED Requirements

### Requirement: Sam Hoi tab displays guided repentance writing interface
The system SHALL present a repentance writing interface as the default tab in the Phong Sam Hoi screen. The interface SHALL include a ZenScreenHeader with title "Phong Sam Hoi", a segmented Picker for tab switching between "Sam hoi" and "Kinh tung", helper text explaining the practice, rotating six-sense prompts, a main repentance text field, a transformation vow text field, and a submit button.

#### Scenario: User opens Phong Sam Hoi screen
- **WHEN** user taps the "Sam hoi" button on TraThatView
- **THEN** the system SHALL present SamHoiView as a full-screen cover with the Sam Hoi tab selected by default, ZenScreenHeader showing "Phong Sam Hoi", and a segmented Picker with two options

#### Scenario: User sees helper text
- **WHEN** the Sam Hoi tab is displayed
- **THEN** the system SHALL show the helper text "Lang long quan chieu sau can, thanh tam sam hoi nhung dieu da gay ton thuong." in caption style with secondary text color

### Requirement: Six-sense prompts rotate with fade animation
The system SHALL display one six-sense prompt at a time above the text field, cycling through all six prompts every 5 seconds with a fade transition. The six prompts SHALL be: "Mat da nhin thay gi gay ton thuong?", "Tai da nghe dieu gi bat thien?", "Mui da tham dam huong gi?", "Mieng da noi loi nao gay kho?", "Than da lam dieu gi bat an?", "Tam da nghi gi bat thien?"

#### Scenario: Prompts rotate automatically
- **WHEN** the Sam Hoi tab is visible for more than 5 seconds
- **THEN** the system SHALL transition to the next prompt with a fade animation
- **THEN** after the sixth prompt, the system SHALL cycle back to the first prompt

#### Scenario: Reduce motion is enabled
- **WHEN** the user has enabled Reduce Motion in accessibility settings
- **THEN** the system SHALL still rotate prompts but without fade animation (instant switch)

### Requirement: Repentance text input with no character limit
The system SHALL provide a multiline ZenTextField inside a ZenCard for writing repentance text. The text field SHALL have placeholder text, minHeight of 180, maxHeight of 300, and no character limit. The text field SHALL NOT persist any data.

#### Scenario: User writes repentance text
- **WHEN** user taps the repentance text field and types text
- **THEN** the system SHALL accept the input with no character limit and the text field SHALL expand vertically between 180pt and 300pt as needed

#### Scenario: Text field is empty
- **WHEN** the repentance text field contains no text
- **THEN** the submit button SHALL be disabled

### Requirement: Transformation vow input field
The system SHALL provide a second, smaller ZenTextField below the main repentance text with the prompt "Nguyen chuyen hoa: Ban se lam khac the nao?" The field SHALL have minHeight of 60 and maxHeight of 120.

#### Scenario: User enters transformation vow
- **WHEN** user taps the transformation vow field and types text
- **THEN** the system SHALL accept the input in a smaller text area below the main repentance text

### Requirement: Submit triggers smoke animation and quote display
The system SHALL provide a NutGiotNuocView button with icon "hands.sparkles.fill" and label "Sam hoi". When tapped, the system SHALL execute the celebration animation sequence: button fades out, form fades out, KhoiTanView smoke animation plays, a random quote fades in, holds for 3 seconds, fades out, then the form and button fade back in with cleared text fields.

#### Scenario: User submits repentance
- **WHEN** user taps the "Sam hoi" button with non-empty repentance text
- **THEN** the system SHALL execute the animation sequence: button fade out (0.3s), form fade out (0.5s), smoke animation (~2.5s), quote fade in (0.7s), quote hold (3.0s), quote fade out (0.7s), form and button fade back in (0.7s)
- **THEN** both text fields SHALL be cleared after the animation

#### Scenario: Submit with reduce motion enabled
- **WHEN** user taps submit with Reduce Motion enabled
- **THEN** the system SHALL use shortened animation timings while still showing the quote

#### Scenario: Submit button disabled during animation
- **WHEN** the celebration animation is in progress
- **THEN** the submit button SHALL be disabled and not respond to taps

### Requirement: Fifteen repentance quotes displayed randomly
The system SHALL maintain a collection of 15 Vietnamese repentance quotes. After each submission, the system SHALL display one quote selected at random from the collection.

#### Scenario: Quote is displayed after submission
- **WHEN** the smoke animation completes after a submission
- **THEN** the system SHALL display a randomly selected quote centered on screen with title font and primary text color

### Requirement: Privacy by design with no data persistence
The system SHALL NOT persist any repentance text, transformation vow text, or submission history. All text SHALL be cleared after the animation sequence completes. Dismissing the screen SHALL also discard all text.

#### Scenario: User dismisses screen after writing
- **WHEN** user dismisses the Phong Sam Hoi screen after writing text without submitting
- **THEN** all text SHALL be discarded with no data saved anywhere

#### Scenario: Text cleared after animation
- **WHEN** the celebration animation sequence completes
- **THEN** both the repentance text field and transformation vow field SHALL be empty

### Requirement: Accessibility support for Sam Hoi tab
The system SHALL provide VoiceOver labels on all interactive elements, maintain 44pt minimum touch targets, and support Reduce Motion for all animations.

#### Scenario: VoiceOver navigation
- **WHEN** VoiceOver is enabled
- **THEN** the submit button SHALL announce its label "Sam hoi" and hint describing the action
- **THEN** the text fields SHALL have accessibility labels describing their purpose
- **THEN** the rotating prompts SHALL be announced when they change

### Requirement: Navigation from TraThatView
The system SHALL add a "Sam hoi" button to the TraThatView bottom dock as a full-width secondary ZenButton with icon "hands.sparkles.fill" in a new row below the existing Buong Bo and Thien Tho buttons. Tapping it SHALL present SamHoiView as a fullScreenCover.

#### Scenario: User navigates to Phong Sam Hoi
- **WHEN** user taps the "Sam hoi" button on the TraThatView dock
- **THEN** the system SHALL present SamHoiView as a full-screen cover with ThoiGianViewModel passed as environment object
