## ADDED Requirements

### Requirement: Three-layer animated background
`NenDongView` SHALL replace its single `Rectangle` with a `ZStack` containing exactly three layers: (1) a base `LinearGradient` frame, (2) a `TimelineView`+`Canvas` mist particle layer, and (3) a `RadialGradient` glow layer. All layers SHALL be stacked in that order (gradient at the back, glow at the front).

#### Scenario: Layer ordering
- **WHEN** NenDongView renders
- **THEN** the base gradient is drawn first (bottom), mist particles above it, and the radial glow on top; no layer obscures content above NenDongView

### Requirement: Base gradient with 3.0s easeInOut transition
Layer 1 SHALL animate slot changes using `withAnimation(.easeInOut(duration: 3.0))`, replacing the existing 1.5s linear cross-fade. The gradient SHALL read `colors` and `glowCenter` from `thoiGianVM.current`.

#### Scenario: Slot change triggers animated gradient update
- **WHEN** `thoiGianVM.current` changes
- **THEN** the LinearGradient colors animate to the new slot's colors over 3.0 seconds with an easeInOut curve

### Requirement: Gradient breathing via animated start point drift
Layer 1's gradient `startPoint` SHALL drift by ±6% on the Y axis using a sine function over an 8-second period, driven by a `TimelineView`. The breathing SHALL stop (startPoint fixed at top) when reduce-motion is enabled.

#### Scenario: Breathing animation active at normal motion setting
- **WHEN** `accessibilityReduceMotion` is false
- **THEN** the gradient's startPoint Y oscillates between approximately 0.94 and 1.06 of its base value over an 8-second cycle

#### Scenario: Breathing suppressed under reduce-motion
- **WHEN** `accessibilityReduceMotion` is true
- **THEN** the gradient startPoint is fixed and does not animate

### Requirement: Mist particle layer using TimelineView and Canvas
Layer 2 SHALL draw mist as large blurred ellipses drifting slowly across the canvas. Particle count, color, and opacity SHALL be read from `thoiGianVM.current` (`mistCount`, `mistColor`, `mistOpacity`). Each particle SHALL drift at an independent sub-pixel-per-frame speed derived from its index.

#### Scenario: Correct particle count per slot
- **WHEN** the current slot is suongSom
- **THEN** exactly 8 mist particles are drawn on the canvas

#### Scenario: Night slot minimal particles
- **WHEN** the current slot is traDenDem
- **THEN** exactly 3 mist particles are drawn on the canvas

#### Scenario: Mist hidden under reduce-motion
- **WHEN** `accessibilityReduceMotion` is true
- **THEN** the TimelineView+Canvas mist layer has opacity 0 (no draw calls visible)

### Requirement: Radial glow layer with 12-second opacity pulse
Layer 3 SHALL be a `RadialGradient` positioned at `glowCenter`, colored `glowColor`, with radius `glowRadius`, driven from `thoiGianVM.current`. Its opacity SHALL pulse between 0.20 and 0.35 over a 12-second sine cycle via a `TimelineView`. The pulse SHALL freeze at 0.20 when reduce-motion is enabled.

#### Scenario: Glow pulse oscillates between bounds
- **WHEN** `accessibilityReduceMotion` is false
- **THEN** the radial glow layer opacity oscillates between 0.20 and 0.35 over a period of approximately 12 seconds

#### Scenario: Glow position matches slot spec
- **WHEN** the current slot is hoangHon
- **THEN** the radial gradient center is at UnitPoint(x: 0.72, y: 0.18)

#### Scenario: Glow frozen under reduce-motion
- **WHEN** `accessibilityReduceMotion` is true
- **THEN** the radial glow layer opacity is fixed at 0.20 and does not animate

### Requirement: NenDongView reads from ThoiGianViewModel environment object
`NenDongView` SHALL declare `@EnvironmentObject var thoiGianVM: ThoiGianViewModel` and remove its local `Timer` and `@State private var currentColors`. All slot-dependent values SHALL be read from the view model.

#### Scenario: Local timer removed
- **WHEN** NenDongView is compiled
- **THEN** no `Timer.publish` call exists within the NenDongView struct

#### Scenario: Environment object drives updates
- **WHEN** `thoiGianVM.current` changes due to the view model's 30-second tick
- **THEN** all three NenDongView layers reflect the new slot's parameters without NenDongView managing any timer itself

### Requirement: Full reduce-motion compliance
All animated behavior in NenDongView (gradient breathing, mist drift, glow pulse) SHALL be suppressed when `@Environment(\.accessibilityReduceMotion)` is true. The gradient SHALL still cross-fade on slot change (transition is functional, not decorative). Only decorative looping animations SHALL be suppressed.

#### Scenario: Reduce-motion leaves gradient cross-fade intact
- **WHEN** `accessibilityReduceMotion` is true and the slot changes
- **THEN** the base gradient still updates to the new colors (via withAnimation), but breathing, mist, and glow pulse are suppressed
