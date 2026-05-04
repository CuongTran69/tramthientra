## ADDED Requirements

### Requirement: Kinh Tung tab displays six-section repentance sutra
The system SHALL display the Sam Hoi Sau Can (Six-Sense Repentance) sutra in a scrollable view when the Kinh Tung tab is selected. The content SHALL be organized into six sections corresponding to the six sense organs: Nhan Can (Mat), Nhi Can (Tai), Ty Can (Mui), Thiet Can (Luoi), Than Can (Than), and Y Can (Tam).

#### Scenario: User switches to Kinh Tung tab
- **WHEN** user selects the "Kinh tung" tab via the segmented Picker
- **THEN** the system SHALL display a ScrollView containing the sutra title "Sam Hoi Sau Can", attribution text "Theo truyen thong Phat giao Viet Nam", and all six sutra sections

#### Scenario: User scrolls through sutra content
- **WHEN** user scrolls the Kinh Tung tab content
- **THEN** all six sections SHALL be accessible via vertical scrolling with smooth scroll behavior

### Requirement: Each sutra section has header and poetic text
Each of the six sutra sections SHALL display a section header (e.g., "Nhan Can -- Mat") in headline font and the corresponding sutra text in body font. The section headers SHALL use primary text color and the sutra text SHALL use secondary text color, both adapting to the current time period via ThoiGianViewModel.

#### Scenario: Section header styling
- **WHEN** the Kinh Tung tab is displayed
- **THEN** each section header SHALL use ZenFont.headline() with the current time period's textPrimary color

#### Scenario: Sutra text styling
- **WHEN** the Kinh Tung tab is displayed
- **THEN** each sutra text block SHALL use ZenFont.body() with the current time period's textSecondary color

### Requirement: Sutra content is complete and accurate
The system SHALL display the complete Sam Hoi Sau Can text in Vietnamese for all six sections. Each section SHALL contain a six-line poetic verse following the traditional repentance structure: acknowledgment of past transgressions through that sense organ, followed by a vow of repentance.

#### Scenario: All six sections present
- **WHEN** the Kinh Tung tab is fully scrolled
- **THEN** the user SHALL see all six sections: Nhan Can (Mat), Nhi Can (Tai), Ty Can (Mui), Thiet Can (Luoi), Than Can (Than), Y Can (Tam)

#### Scenario: Each section has complete verse
- **WHEN** any sutra section is displayed
- **THEN** it SHALL contain the complete six-line verse for that sense organ

### Requirement: Time-adaptive colors for sutra reading
The sutra reading view SHALL use time-adaptive colors from ThoiGianViewModel for all text elements, backgrounds, and decorative elements. Colors SHALL transition smoothly when the time period changes.

#### Scenario: Time period changes while reading
- **WHEN** the time period changes while the user is on the Kinh Tung tab
- **THEN** all text colors and background elements SHALL animate smoothly to the new time period's colors using easeInOut duration of 2.0 seconds

### Requirement: Accessibility support for Kinh Tung tab
The system SHALL ensure the sutra content is fully accessible via VoiceOver. Section headers SHALL be marked as headers. The entire sutra content SHALL be navigable via VoiceOver gestures.

#### Scenario: VoiceOver reads sutra sections
- **WHEN** VoiceOver is enabled and user navigates the Kinh Tung tab
- **THEN** section headers SHALL be announced as headers
- **THEN** sutra text SHALL be readable as static text elements

### Requirement: Tab switching preserves no state
The system SHALL NOT preserve any state when switching between the Sam Hoi and Kinh Tung tabs. The Kinh Tung tab scroll position MAY reset when switching away and back. Text entered in the Sam Hoi tab SHALL be preserved while switching tabs within the same session but SHALL NOT be persisted across screen dismissals.

#### Scenario: Switch from Sam Hoi to Kinh Tung and back
- **WHEN** user writes text in Sam Hoi tab, switches to Kinh Tung, then switches back
- **THEN** the repentance text SHALL still be present in the Sam Hoi tab

#### Scenario: Dismiss and reopen screen
- **WHEN** user dismisses the Phong Sam Hoi screen and reopens it
- **THEN** all text fields SHALL be empty and the Sam Hoi tab SHALL be selected by default
