## ADDED Requirements

### Requirement: Time-contextual greeting is displayed on the Home screen
The system SHALL display a greeting phrase derived from the current `ThoiGian` period at the top of TraThatView. The phrase SHALL be rendered in ZenFont.title() (28pt serif) and SHALL update automatically when `ThoiGian.current` changes.

#### Scenario: Greeting shows correct phrase for each period
- **WHEN** the app is launched during a specific time period
- **THEN** the greeting text displayed SHALL match the `greetingPhrase` value for that period: "Buổi sáng an lành" (suongSom), "Trà chiều tĩnh lặng" (banNgay), "Hoàng hôn nhẹ nhàng" (hoangHon), or "Đêm trà thư giãn" (traDenDem)

#### Scenario: Greeting is accessible
- **WHEN** VoiceOver is active
- **THEN** the greeting text SHALL be readable by VoiceOver as a static text element with its Vietnamese content

### Requirement: Teapot is visually grounded with a surface shadow
The system SHALL render an elliptical blurred shadow beneath the teapot body in TraXongView. The shadow SHALL appear after the teapot body is drawn and before smoke particles in the Canvas draw order.

#### Scenario: Shadow renders beneath the teapot body
- **WHEN** TraXongView is displayed
- **THEN** an ellipse at approximately `(centerX - 38, centerY + 38, width: 76, height: 16)` SHALL be drawn with `zenBrownDark.opacity(0.18)` fill and blur radius 8, making the teapot appear to rest on a surface

#### Scenario: Shadow does not obscure smoke particles
- **WHEN** the teapot smoke animation is active
- **THEN** smoke particles SHALL render on top of the shadow ellipse, not beneath it

### Requirement: Home screen uses a Tea Table Scene layout
The system SHALL replace the existing VStack layout in TraThatView with a layered "Tea Table Scene" structure. The layout top-to-bottom SHALL be: nav strip, time greeting, app name, flexible spacer, teapot (220×220pt), 20pt spacer, streak card, 16pt spacer, bottom action dock, 32pt bottom safe area padding.

#### Scenario: Layout renders all components in correct vertical order
- **WHEN** the Home screen is displayed
- **THEN** the nav strip SHALL appear at the top, the teapot SHALL be centered in the mid-section, the streak card SHALL appear between the teapot and the bottom dock, and the bottom dock SHALL be anchored at the bottom edge

#### Scenario: All sheet and fullScreenCover navigation remains functional
- **WHEN** any action button in the bottom dock is tapped
- **THEN** the corresponding sheet or fullScreenCover SHALL present exactly as before the redesign

#### Scenario: All @State variables are preserved
- **WHEN** the view is compiled
- **THEN** all existing @State variables for sheet presentation SHALL be present and unmodified

### Requirement: Bottom action dock uses glassmorphism styling
The system SHALL render the bottom action dock with `.ultraThinMaterial` background, `Color.white.opacity(0.40)` overlay, a white stroke border, corner radius 24pt, inner padding 16pt, and shadow `zenBrown.opacity(0.10)` with radius 20 and y-offset 8.

#### Scenario: Dock adapts to night period
- **WHEN** `ThoiGian.current == .traDenDem`
- **THEN** the white overlay on the dock SHALL reduce to `Color.white.opacity(0.08)` to preserve night-time ambiance

#### Scenario: Dock contains correct button layout
- **WHEN** the Home screen is displayed
- **THEN** the dock SHALL contain one full-width primary button ("Tích luỹ", icon: "drop.fill") above an HStack with two equal-width secondary buttons ("Buông bỏ" and "Thiền Thở", icon: "wind"), with 10pt spacing between the secondary buttons

### Requirement: Nav icon button uses lighter visual style with preserved touch target
The system SHALL render nav icon buttons with a 36pt visual frame Circle filled with `Color.white.opacity(0.25)`. The touch target SHALL remain 44pt via `.contentShape(Circle())`. The `.ultraThinMaterial` and additional white overlay layers SHALL be removed.

#### Scenario: Nav icon button meets WCAG minimum touch target
- **WHEN** a nav icon button is rendered
- **THEN** the tappable area SHALL be at least 44×44pt regardless of the visible circle size

#### Scenario: Nav icon button accessibility labels are preserved
- **WHEN** VoiceOver is active and a nav icon button is focused
- **THEN** the button SHALL announce its existing accessibility label and hint unchanged

### Requirement: CayThienView uses reduced internal padding
The system SHALL render CayThienView with 16pt horizontal padding and 12pt vertical padding (reduced from 20pt and 16pt respectively) when displayed inside the streak card between the teapot and the bottom dock.

#### Scenario: Streak card fits comfortably in mid-screen position
- **WHEN** the Home screen is displayed with the Tea Table Scene layout
- **THEN** the streak card SHALL not clip or overflow its available vertical space between the teapot and the bottom dock
