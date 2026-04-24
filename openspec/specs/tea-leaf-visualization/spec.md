## ADDED Requirements

### Requirement: Tea leaf stage shapes
The system SHALL render 6 distinct tea leaf shapes corresponding to streak stages, each drawn using SwiftUI `Path` bezier curves within a 48x48 point frame.

The stages and their visual characteristics SHALL be:
- **hatTra** (0 days): Small teardrop seed shape in `ZenColor.zenBrownDark`, approximately 14x18pt
- **mamTra** (1-3 days): Curled sprout with seed pod and a tiny emerging leaf in `ZenColor.zenTeaSpring`
- **bupNon** (4-7 days): Tea bud with 2 unfurling leaves in `ZenColor.zenTeaLight`
- **laNon** (8-14 days): Single recognizable tea leaf with visible veins and serrated edges in `ZenColor.zenSage`
- **laXanh** (15-29 days): Full lush tea leaf with `ZenColor.zenGold` edge shimmer in `ZenColor.zenTeaDeep`
- **traChin** (30+ days): 2-3 overlapping tea leaves with a glow halo in `ZenColor.zenTeaRich`

#### Scenario: Seed stage rendering
- **WHEN** the streak count is 0
- **THEN** the system SHALL display a teardrop seed shape in `ZenColor.zenBrownDark` at approximately 14x18pt centered within the 48x48 frame

#### Scenario: Maximum stage rendering
- **WHEN** the streak count is 30 or more
- **THEN** the system SHALL display 2-3 overlapping tea leaf shapes in `ZenColor.zenTeaRich` with a glow halo effect

#### Scenario: All shapes at 48x48
- **WHEN** any stage shape is rendered
- **THEN** the shape SHALL fit within a 48x48 point frame and be visually legible at all supported Dynamic Type sizes

---

### Requirement: Tea leaf stage naming
The `LeafStage` enum SHALL use tea-based terminology for its cases and Vietnamese display titles.

The mapping SHALL be:
| Case | Raw Value | Title |
|------|-----------|-------|
| hatTra | 0 | "Hat Tra" |
| mamTra | 1 | "Mam Tra" |
| bupNon | 2 | "Bup Non" |
| laNon | 3 | "La Non" |
| laXanh | 4 | "La Xanh" |
| traChin | 5 | "Tra Chin" |

The day-to-stage mapping thresholds SHALL remain unchanged: 0, 1-3, 4-7, 8-14, 15-29, 30+.

#### Scenario: Stage title display
- **WHEN** the user has a streak of 5 days
- **THEN** the stage title SHALL display "Bup Non"

#### Scenario: Stage enum case names
- **WHEN** code references a streak stage
- **THEN** the enum cases SHALL be named `hatTra`, `mamTra`, `bupNon`, `laNon`, `laXanh`, `traChin`

---

### Requirement: Tea leaf color tokens
The `ZenColor` namespace SHALL include 6 tea-leaf-specific color tokens.

| Token | Hex | Purpose |
|-------|-----|---------|
| zenTeaSpring | #8AAE7A | Early sprout stage fill |
| zenTeaLight | #7BA27B | Young bud stage fill |
| zenTeaDeep | #5A7F5A | Mature leaf stage fill |
| zenTeaRich | #4D7A4D | Master stage fill |
| zenTeaVein | #4A6B4A | Vein detail lines on leaf shapes |
| zenTeaWilted | #8A7A60 | Desaturated color for broken streaks |

#### Scenario: Token availability
- **WHEN** any view file needs a tea leaf color
- **THEN** it SHALL reference a `ZenColor.zenTea*` token instead of using an inline hex string

#### Scenario: No inline hex in LaTraView
- **WHEN** `LaTraView.swift` is compiled
- **THEN** it SHALL contain zero inline `Color(hex:)` calls -- all colors SHALL come from `ZenColor` tokens or `ThoiGian` computed properties

---

### Requirement: Time-adaptive leaf coloring
The `ThoiGian` enum SHALL provide 3 computed properties for time-of-day leaf appearance: `leafTint`, `leafGlow`, and `leafGlowOpacity`.

| Property | suongSom | buoiSang | banNgay | chieuTa | hoangHon | traDenDem |
|----------|----------|----------|---------|---------|----------|-----------|
| leafTint | #8AAE7A | #6B8F6B | #5A8A6A | #7A9A5A | #6B7F55 | #9DB89D |
| leafGlow | #D4E8D0 | none | #C0E0D8 | #E8D8B0 | #D4A574 | #C8A882 |
| leafGlowOpacity | 0.20 | 0.0 | 0.12 | 0.18 | 0.22 | 0.25 |

`LaTraView` SHALL use `thoiGianVM.current.leafTint` as the dynamic tint for leaf shapes, blended with or used alongside the stage-specific `ZenColor` token.

#### Scenario: Morning leaf appearance
- **WHEN** the time is between 9:00 and 11:59 (buoiSang)
- **THEN** the leaf tint SHALL be #6B8F6B and there SHALL be no glow effect (opacity 0.0)

#### Scenario: Night leaf appearance
- **WHEN** the time is between 21:00 and 4:59 (traDenDem)
- **THEN** the leaf tint SHALL be #9DB89D (moonlit sage) and the glow SHALL be #C8A882 at 0.25 opacity

---

### Requirement: Idle leaf animation
`LaTraView` SHALL display subtle idle animations that vary by stage:
- **Stages 0-1** (hatTra, mamTra): No idle animation
- **Stages 2-3** (bupNon, laNon): Gentle sway via `rotationEffect` oscillating +/- 2 degrees with a 3-4 second period
- **Stages 4-5** (laXanh, traChin): Sway animation plus a breathing scale effect (1.0 to 1.03) with a 4-5 second period

All idle animations SHALL be disabled when `accessibilityReduceMotion` is true.

The existing stage-change bounce animation (spring scale 1.0 -> 1.08 -> 1.0, response 0.4, dampingFraction 0.55) SHALL be preserved.

#### Scenario: Reduce motion enabled
- **WHEN** the system accessibility setting `reduceMotion` is true
- **THEN** no sway or breathing animation SHALL be applied; stage changes SHALL use opacity crossfade only

#### Scenario: Idle sway for middle stages
- **WHEN** the stage is bupNon or laNon and reduceMotion is false
- **THEN** the leaf shape SHALL continuously sway +/- 2 degrees with a smooth repeating animation

#### Scenario: Idle breathe for high stages
- **WHEN** the stage is laXanh or traChin and reduceMotion is false
- **THEN** the leaf shape SHALL sway +/- 2 degrees AND pulse its scale between 1.0 and 1.03

---

### Requirement: Layout and accessibility
`LaTraView` SHALL maintain the existing layout structure:
- HStack with 12pt spacing
- 48x48 shape frame on the left
- VStack with stage title (zenHeadline) and "\(streak) ngay" count (zenCaption) in the center
- Spacer
- 6 progress dots (8x8 circles) on the right

The background SHALL be `thoiGianVM.current.streakTextPrimary.opacity(0.08)`, with `traDenDem` using `Color(hex: "C8A882").opacity(0.15)` via a ZenColor token or ThoiGian property.

The view SHALL use `.accessibilityElement(children: .combine)` with label `"\(stage.title), streak \(streak) ngay"`.

Progress dots SHALL be hidden from VoiceOver with `.accessibilityHidden(true)`.

#### Scenario: VoiceOver announcement
- **WHEN** VoiceOver focuses on the LaTraView
- **THEN** it SHALL announce the combined label in format "\(stage.title), streak \(streak) ngay"

#### Scenario: Progress dot state
- **WHEN** the current stage has rawValue N
- **THEN** dots at indices 0 through N SHALL be filled with `streakTextPrimary` and dots at indices N+1 through 5 SHALL be filled with `streakTextSecondary.opacity(0.4)`

---

### Requirement: View file and reference update
The streak visualization view SHALL be defined in a file named `LaTraView.swift` in `TramThienTra/Views/Components/`.

`TraThatView.swift` SHALL reference `LaTraView(streak:stage:)` instead of `CayThienView(streak:stage:)`.

The Xcode project file (`.pbxproj`) SHALL reference `LaTraView.swift` instead of `CayThienView.swift`.

`CayThienView.swift` SHALL be removed from the project.

#### Scenario: Build success after rename
- **WHEN** the project is built after all changes
- **THEN** the build SHALL succeed with zero errors related to missing `CayThienView` references

#### Scenario: Single consumer update
- **WHEN** `TraThatView.swift` is compiled
- **THEN** it SHALL reference `LaTraView` and SHALL NOT reference `CayThienView`
