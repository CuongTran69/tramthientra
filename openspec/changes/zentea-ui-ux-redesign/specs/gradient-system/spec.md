## ADDED Requirements

### Requirement: Three-stop time-based gradients
`ThoiGian` enum cases SHALL each expose a `[Color]` array with exactly three color stops. `NenDongView` SHALL consume this array via `LinearGradient(colors:startPoint:endPoint:)`. No gradient in the app SHALL use fewer than three stops.

The stops SHALL be:
- `.suongSom`: `[#FDF8F3, #F5EDE4, #EDE3D6]`
- `.banNgay`: `[#E8F0F2, #D4E5EB, #C1D9E3]`
- `.hoangHon`: `[#F9EDE3, #F0DFD0, #E5CEB8]`
- `.traDenDem`: `[#2D2B3A, #1F1D28, #141318]`

#### Scenario: Morning gradient renders
- **WHEN** the current time falls in the `suongSom` slot
- **THEN** `NenDongView` renders a top-to-bottom gradient transitioning through `#FDF8F3`, `#F5EDE4`, and `#EDE3D6`

#### Scenario: Night gradient is smooth
- **WHEN** the current time falls in the `traDenDem` slot
- **THEN** the gradient transitions smoothly from `#2D2B3A` through `#1F1D28` to `#141318` without visible banding

#### Scenario: Gradient slot coverage
- **WHEN** any time of day is evaluated
- **THEN** exactly one of the four gradient sets is active and all three stops are applied

### Requirement: Gradient transition animation
When the active time slot changes (e.g., dusk to night), `NenDongView` SHALL animate the gradient transition with a linear animation of 1.5 seconds so the change is perceptible but not jarring.

#### Scenario: Time slot boundary crossed
- **WHEN** the device clock crosses a time-slot boundary while the app is in the foreground
- **THEN** the background gradient cross-fades to the new three-stop set over 1.5 seconds

### Requirement: Dark mode gradient legibility
In dark mode system appearance, the `traDenDem` gradient SHALL remain the active background regardless of time slot (dark mode overrides time-based selection is out of scope; this requirement ensures `traDenDem` colors are not pure black). The darkest stop SHALL be no darker than `#141318`.

#### Scenario: Night gradient minimum brightness
- **WHEN** `traDenDem` is active
- **THEN** the darkest gradient stop is `#141318` and UI elements placed over it remain distinguishable
