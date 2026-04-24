## ADDED Requirements

### Requirement: Six time slots with typed color properties
The `ThoiGian` enum SHALL define exactly 6 cases — suongSom (05:00–08:59), buoiSang (09:00–11:59), banNgay (12:00–14:59), chieuTa (15:00–17:59), hoangHon (18:00–20:59), traDenDem (21:00–04:59) — each providing all color and appearance properties as computed Swift values.

#### Scenario: Correct slot returned for each hour
- **WHEN** `ThoiGian.current` is called at hours 5, 9, 12, 15, 18, 21
- **THEN** the returned cases are suongSom, buoiSang, banNgay, chieuTa, hoangHon, traDenDem respectively

#### Scenario: Midnight and pre-dawn resolve to traDenDem
- **WHEN** `ThoiGian.current` is called at hours 0, 1, 2, 3, 4
- **THEN** the returned case is traDenDem

### Requirement: Three-stop gradient per slot
Each slot SHALL expose a `colors: [Color]` property returning exactly 3 Color values forming the slot's LinearGradient from top to bottom.

#### Scenario: buoiSang gradient colors
- **WHEN** `ThoiGian.buoiSang.colors` is read
- **THEN** the array contains exactly 3 entries: #F5F0E8, #EDE7D8, #E5DCC8 (sRGB)

#### Scenario: chieuTa gradient colors
- **WHEN** `ThoiGian.chieuTa.colors` is read
- **THEN** the array contains exactly 3 entries: #F2E8D8, #E8D8C0, #DCC8A8 (sRGB)

### Requirement: WCAG AA text contrast colors per slot
Each slot SHALL expose `textPrimary: Color` and `textSecondary: Color` satisfying WCAG AA (≥4.5:1) contrast ratio against the slot's midpoint gradient color.

#### Scenario: Light slot text colors
- **WHEN** `textPrimary` is read for suongSom or buoiSang
- **THEN** the color resolves to #3A2A18

#### Scenario: Night slot text colors
- **WHEN** `textPrimary` is read for traDenDem
- **THEN** the color resolves to #F0EBE3

#### Scenario: Secondary text opacity
- **WHEN** `textSecondary` is read for any slot
- **THEN** it is `textPrimary` at the documented opacity (55%–70%) for that slot

### Requirement: Nav icon tint per slot
Each slot SHALL expose `navIconTint: Color` for use as the tab-bar icon foreground color.

#### Scenario: Nav icon tint changes between day and night
- **WHEN** `navIconTint` is read for banNgay versus traDenDem
- **THEN** the two colors are visually distinct with sufficient contrast against their respective dock overlays

### Requirement: Dock glassmorphism overlay per slot
Each slot SHALL expose `dockOverlayColor: Color` and `dockOverlayOpacity: Double` for the dock/tab-bar glassmorphism tint.

#### Scenario: banNgay dock overlay
- **WHEN** `dockOverlayColor` and `dockOverlayOpacity` are read for banNgay
- **THEN** color is #E8F2F8 and opacity is 0.28

#### Scenario: traDenDem dock overlay is darker
- **WHEN** `dockOverlayOpacity` is read for traDenDem
- **THEN** the value is 0.08 (the lowest across all slots)

### Requirement: ZenCard overlay opacity per slot
Each slot SHALL expose `cardOverlayOpacity: Double` for the white glassmorphism overlay on ZenCard.

#### Scenario: Light slots have higher card opacity
- **WHEN** `cardOverlayOpacity` is read for suongSom
- **THEN** the value is 0.55

#### Scenario: Night slot has lowest card opacity
- **WHEN** `cardOverlayOpacity` is read for traDenDem
- **THEN** the value is 0.10

### Requirement: Smoke appearance per slot
Each slot SHALL expose `smokeColor: Color`, `smokeOpacity: Double`, and `glowTint: Color` for the teapot smoke animation in TraXongView.

#### Scenario: Night slot smoke opacity is highest
- **WHEN** `smokeOpacity` is read for traDenDem
- **THEN** the value is 0.22 (the highest among all slots)

#### Scenario: banNgay smoke color is white-based
- **WHEN** `smokeColor` is read for banNgay
- **THEN** the color resolves to white at opacity 0.18

### Requirement: Slot greeting phrase
Each slot SHALL expose `greetingPhrase: String` with a contextual greeting for display on the home screen.

#### Scenario: New slot greetings
- **WHEN** `greetingPhrase` is read for buoiSang
- **THEN** the value is "Ngày mới tươi sáng"

#### Scenario: chieuTa greeting
- **WHEN** `greetingPhrase` is read for chieuTa
- **THEN** the value is "Chiều tà thong thả"

### Requirement: Deprecated aliases removed
The `gradientColors` and `darkGradientColors` computed properties SHALL be removed from `ThoiGian`. Any remaining call site that references these properties SHALL produce a compile error.

#### Scenario: Alias removal is compile-enforced
- **WHEN** the project is compiled after removing the aliases
- **THEN** no reference to `gradientColors` or `darkGradientColors` exists anywhere in the codebase (confirmed by build success)

### Requirement: Shared ThoiGianViewModel updates every 30 seconds
`ThoiGianViewModel` SHALL be an `ObservableObject` that publishes `current: ThoiGian` and `progress: Double`. A main-thread `Timer` SHALL fire every 30 seconds and update both properties. `progress` is 0.0 at the start of a slot and 1.0 at its end.

#### Scenario: Published values update on tick
- **WHEN** the 30-second timer fires while still within the same slot
- **THEN** `current` remains unchanged and `progress` advances by approximately 30/(total slot minutes * 60)

#### Scenario: Slot transition on tick
- **WHEN** the 30-second timer fires and the clock hour crosses a slot boundary
- **THEN** `current` changes to the new slot and `progress` resets to near 0.0

### Requirement: ThoiGianViewModel injected at app root
`ThoiGianViewModel` SHALL be created as a `@StateObject` in `TramThienTraApp` and injected into the environment alongside `StreakViewModel`, making it available to all descendant views.

#### Scenario: Environment object available in all views
- **WHEN** any view below `TramThienTraApp` declares `@EnvironmentObject var thoiGianVM: ThoiGianViewModel`
- **THEN** the property resolves without a runtime crash

### Requirement: TraThatView uses time-aware text and icon colors
`TraThatView` SHALL read `thoiGianVM.current` from the environment and apply `textPrimary`, `textSecondary`, `navIconTint`, `dockOverlayColor`, and `dockOverlayOpacity` via `withAnimation(.easeInOut(duration: 2.0))` on slot change.

#### Scenario: Greeting text color changes at slot boundary
- **WHEN** the slot transitions (e.g., from suongSom to buoiSang at 09:00)
- **THEN** the greeting text foreground color animates from suongSom.textPrimary to buoiSang.textPrimary over 2.0 seconds

### Requirement: TraXongView uses time-aware smoke appearance
`TraXongView` SHALL read `thoiGianVM.current` from the environment and apply `smokeColor`, `smokeOpacity`, and `glowTint`. For traDenDem, the glow multiplier applied to smoke SHALL be 0.55.

#### Scenario: Night glow multiplier applied
- **WHEN** the current slot is traDenDem
- **THEN** the smoke glow color is rendered at `glowTint.opacity(glowTint.nativeOpacity * 0.55)` relative to other slots

### Requirement: ZenCard white overlay opacity driven by slot
`ZenCard` SHALL read `thoiGianVM.current.cardOverlayOpacity` from `@EnvironmentObject` and use it as the white overlay opacity, animated with `withAnimation(.easeInOut(duration: 2.0))`. The hardcoded value of 0.55 SHALL be removed.

#### Scenario: Card adapts opacity on slot change
- **WHEN** the slot transitions
- **THEN** the ZenCard white overlay opacity animates to the new slot's `cardOverlayOpacity` over 2.0 seconds
