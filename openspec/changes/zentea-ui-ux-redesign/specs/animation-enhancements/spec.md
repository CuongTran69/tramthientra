## ADDED Requirements

### Requirement: TraXongView smoke glow
The smoke animation in TraXongView SHALL add a glow layer to smoke particles using `.shadow(color: zenGold.opacity(0.4), radius: 12, x: 0, y: 0)` applied to the Canvas drawing context. The glow SHALL pulse with a 2 s ease-in-out repeat animation varying opacity between 0.3 and 0.5.

#### Scenario: Glow visible on smoke
- **WHEN** the teapot smoke animation is active
- **THEN** a warm gold glow is visible around the smoke particles

#### Scenario: Glow pulses
- **WHEN** the smoke animation runs for more than 2 seconds
- **THEN** the glow opacity has visibly cycled at least once

### Requirement: KhoiTanView softer particles
The smoke-dissolve animation in KhoiTanView SHALL increase particle count by 40% and use softer particle colors: base color `zenSage.opacity(0.6)` replacing any prior stark white or high-opacity colors. Particle radius SHALL vary randomly between 3 and 8 pt per particle.

#### Scenario: Increased particle count
- **WHEN** KhoiTanView animation plays
- **THEN** there are visibly more particles than the prior version (qualitative check: feels denser/fuller)

#### Scenario: Soft sage particle colors
- **WHEN** particles are rendered
- **THEN** they use a muted sage tone rather than stark white or high-contrast colors

### Requirement: CayThienView stage-change bounce
When the streak stage advances (e.g., seed to sprout), the `CayThienView` illustration SHALL play a vertical bounce animation: scale to 1.08, then settle back to 1.0 with a spring (response 0.4, dampingFraction 0.55). The animation SHALL trigger only on stage change, not on every render.

#### Scenario: Bounce on stage advance
- **WHEN** the streak stage increments
- **THEN** the tree/plant illustration bounces with a spring animation

#### Scenario: No bounce on re-render
- **WHEN** CayThienView re-renders without a stage change (e.g., view refresh)
- **THEN** no bounce animation plays

### Requirement: NutGiotNuocView glow ring
The water-drop button (`NutGiotNuocView`) SHALL display a pulsing glow ring around the drop: a `Circle` overlay with `zenGold.opacity(0.0 → 0.35 → 0.0)` and scale `1.0 → 1.3 → 1.0` on a 1.8 s ease-in-out repeat animation.

#### Scenario: Glow ring visible
- **WHEN** NutGiotNuocView is rendered
- **THEN** a gold glow ring pulses outward from the drop button

#### Scenario: Glow ring timing
- **WHEN** the glow animation runs
- **THEN** it completes one full pulse cycle approximately every 1.8 seconds

### Requirement: Animation performance
All upgraded animations SHALL maintain 60 fps on an iPhone 12 or newer. No animation frame SHALL exceed 2 ms GPU render time. Animations using `Canvas` SHALL avoid creating new `CGPath` objects per frame; paths SHALL be cached or constructed from primitives.

#### Scenario: Smoke animation frame time
- **WHEN** TraXongView smoke animation is active
- **THEN** Instruments Time Profiler shows no dropped frames at 60 fps on iPhone 12

#### Scenario: Path caching
- **WHEN** a Canvas animation view is rendering
- **THEN** it does not allocate a new path object on every frame (verified via Instruments allocations)
