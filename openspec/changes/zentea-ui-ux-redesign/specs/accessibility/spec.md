## ADDED Requirements

### Requirement: Minimum touch target size
Every interactive element in the app (buttons, toggles, links, tappable rows) SHALL have a tappable area of at least 44×44 pt. Views smaller than this SHALL use `.frame(minWidth: 44, minHeight: 44)` or `.contentShape(Rectangle())` to extend the hit area without changing visual size.

#### Scenario: Small icon button meets target
- **WHEN** an icon-only button renders smaller than 44×44 pt visually
- **THEN** its tappable area is extended to 44×44 pt via contentShape or frame

#### Scenario: List row tap area
- **WHEN** a history list row is tapped anywhere within its ZenCard
- **THEN** the tap registers regardless of whether the tap landed on text or padding

### Requirement: VoiceOver labels on interactive elements
Every button, toggle, text field, and tappable element SHALL have an explicit `.accessibilityLabel(_:)` modifier with a descriptive Vietnamese or English label. Action buttons SHALL additionally carry `.accessibilityHint(_:)` describing the result of activation.

#### Scenario: ZenButton VoiceOver
- **WHEN** VoiceOver focus lands on a ZenButton
- **THEN** VoiceOver reads the button's label and hint aloud

#### Scenario: Teapot area accessibility
- **WHEN** VoiceOver focus lands on the teapot area in TraThatView
- **THEN** a meaningful label is announced (e.g., "Trạm Thiền Trà – nhấn để bắt đầu thiền")

### Requirement: WCAG AA color contrast
All text rendered over gradient backgrounds or card surfaces SHALL meet WCAG AA minimum contrast ratio: 4.5:1 for normal text (< 18 pt) and 3:1 for large text (≥ 18 pt or 14 pt bold). `zenGold` SHALL NOT be used for body or label text; it is decorative only.

#### Scenario: Body text contrast on light gradient
- **WHEN** `zenBrown` (#4A3728) text is rendered on `suongSom`'s lightest stop (#FDF8F3)
- **THEN** the contrast ratio is ≥ 4.5:1 (actual: ~9.2:1, passes AA)

#### Scenario: Gold color not used for text
- **WHEN** any text element is inspected
- **THEN** no body or label text uses `zenGold` as its foreground color

### Requirement: Reduce motion alternatives
When the system "Reduce Motion" accessibility setting is enabled, all non-essential animations SHALL be disabled or replaced with a simple opacity transition. This applies to: onboarding page transitions (replace parallax with crossfade), ZenButton scale animation (disable scale, keep haptic), CayThienView bounce (replace with fade), glow ring pulse (disable).

#### Scenario: Reduce motion disables scale animation
- **WHEN** "Reduce Motion" is enabled and the user taps a ZenButton
- **THEN** no scale animation plays; only the haptic fires

#### Scenario: Reduce motion disables glow pulse
- **WHEN** "Reduce Motion" is enabled
- **THEN** the NutGiotNuocView glow ring does not animate; it shows a static low-opacity ring instead

#### Scenario: Onboarding crossfade under reduce motion
- **WHEN** "Reduce Motion" is enabled and the user swipes to a new onboarding page
- **THEN** the transition is a simple crossfade with no sliding or parallax motion
