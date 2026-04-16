## ADDED Requirements

### Requirement: Color token system
The app SHALL define all color values as named static properties in a `ZenColor` namespace inside `Constants.swift`. No view file SHALL contain a hardcoded hex string or inline `Color(hex:)` call. The palette SHALL include: `zenBrown`, `zenBrownDark`, `zenSage`, `zenSageLight`, `zenGold`, `zenCream`, plus the deprecated alias `zenAccent = zenSage`.

#### Scenario: Token used in a view
- **WHEN** a SwiftUI view needs a brand color
- **THEN** it references a named token (e.g. `ZenColor.zenSage`) rather than an inline hex value

#### Scenario: Alias deprecation
- **WHEN** `ZenColor.zenAccent` is referenced
- **THEN** it resolves to the same value as `ZenColor.zenSage` until the alias is removed

### Requirement: Typography scale
`Constants.swift` SHALL expose a `ZenFont` namespace with at minimum these levels: `display` (40 pt serif bold), `title` (28 pt serif semibold), `headline` (17 pt default semibold), `subheadline` (15 pt default medium), `body` (16 pt default regular), `caption` (13 pt default regular), `caption2` (11 pt default regular). Each level SHALL be a static function returning `Font`.

#### Scenario: Display font applied
- **WHEN** the app title "Trạm Thiền Trà" is rendered on TraThatView
- **THEN** it uses `ZenFont.display()` (40 pt serif bold)

#### Scenario: Caption2 applied
- **WHEN** a supplementary label smaller than caption is needed
- **THEN** `ZenFont.caption2()` is used and renders at 11 pt

### Requirement: ZenCard component
`ZenCard<Content: View>` SHALL be a generic SwiftUI view that wraps its content with: 20 pt padding, `.ultraThinMaterial` background, `Color.white.opacity(0.1)` secondary background layer, 20 pt corner radius, a `RoundedRectangle` stroke of `Color.white.opacity(0.2)` at 1 pt line width, and a drop shadow of `Color.black.opacity(0.1)` with radius 10, offset (0, 5).

#### Scenario: Card renders on light gradient
- **WHEN** a ZenCard is placed over the `suongSom` gradient
- **THEN** the card is visually distinct from the background with legible content and a visible frosted border

#### Scenario: Card renders on dark gradient
- **WHEN** a ZenCard is placed over the `traDenDem` gradient
- **THEN** the card remains legible; the white overlay layer ensures it is not invisible against the dark background

### Requirement: ZenButton primary variant
`ZenButton` SHALL provide a primary variant with a gradient fill using `zenBrown` to `zenBrownDark`, white label text, 14 pt corner radius, scale animation to 0.96 with a spring response on press, and a `UIImpactFeedbackGenerator(.medium)` haptic triggered on press. It SHALL accept an optional leading icon.

#### Scenario: Press animation
- **WHEN** the user presses and holds a primary ZenButton
- **THEN** the button scales to 0.96 with a spring animation; releasing returns it to 1.0

#### Scenario: Haptic feedback
- **WHEN** the user taps a primary ZenButton
- **THEN** a medium impact haptic fires on the main thread

#### Scenario: Icon variant
- **WHEN** a ZenButton is initialized with a non-nil icon parameter
- **THEN** the icon appears to the left of the label text within the button

### Requirement: ZenButton secondary variant
`ZenButton` SHALL provide a secondary (ghost) variant with a transparent fill, a 1 pt `zenSage` border, `zenBrown` label color, and a subtle `zenSage.opacity(0.1)` fill that appears only while the button is pressed.

#### Scenario: Ghost button at rest
- **WHEN** a secondary ZenButton is rendered
- **THEN** it shows only a border with no fill

#### Scenario: Ghost button pressed
- **WHEN** the user presses a secondary ZenButton
- **THEN** a subtle sage fill appears for the duration of the press

### Requirement: ZenTextField component
`ZenTextField` SHALL be a SwiftUI view that wraps a `TextField` (or `TextEditor`) in a ZenCard-style container. It SHALL display a focus ring (1 pt `zenSage` stroke) when the field is first responder. It SHALL show an inline character counter in the bottom-right corner of the field when a `limit` parameter is provided, displayed as "n / limit" in `ZenFont.caption2()` using `zenBrown.opacity(0.4)`.

#### Scenario: Focus ring appears
- **WHEN** the user taps into a ZenTextField
- **THEN** a 1 pt zenSage ring animates onto the border of the container

#### Scenario: Character counter visible
- **WHEN** a ZenTextField is initialized with a character limit
- **THEN** the counter shows current count and limit in the bottom-right corner of the field at all times

#### Scenario: Counter at limit
- **WHEN** the character count equals the limit
- **THEN** the counter text color changes to `zenGold` to signal the boundary
