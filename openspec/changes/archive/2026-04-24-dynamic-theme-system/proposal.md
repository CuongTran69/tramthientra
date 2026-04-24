## Why

The current background system cycles through only 4 time slots using a flat LinearGradient with a simple 1.5s cross-fade, making the app feel static regardless of the actual time of day — 7AM and 11:59AM look identical. Additionally, the theme only affects the background; all other UI surfaces (text, icons, cards, navigation, smoke effects) remain constant, which weakens the mindfulness and tea ceremony aesthetic that depends on evoking the natural passage of time.

## What Changes

- Expand from 4 to 6 named time slots in `ThoiGian.swift` — adding `buoiSang` (09:00–11:59) and `chieuTa` (15:00–17:59) for finer morning/afternoon granularity
- Add 17 new computed properties per time slot covering text colors, nav icon tint, glow parameters, mist particle settings, dock overlay, card overlay opacity, and smoke appearance
- Remove deprecated `gradientColors` and `darkGradientColors` aliases
- Create `ThoiGianViewModel.swift` — a shared `ObservableObject` with a 30-second Timer that publishes current slot and intra-slot progress, replacing scattered per-view timers
- Replace `NenDongView`'s single Rectangle with a 3-layer animated ZStack: base gradient (3s easeInOut), mist particle canvas (TimelineView), and radial glow (pulsing 0.20–0.35 opacity over 12s); full reduce-motion compliance
- Inject `ThoiGianViewModel` at app root alongside `StreakViewModel`
- Adapt `TraThatView` to drive greeting text, app name, and nav icon colors from the view model with 2s easeInOut transitions
- Adapt `TraXongView` to drive smoke color, opacity, and glow tint from the view model, with a 0.55x night glow multiplier
- Adapt `ZenCard` to read `cardOverlayOpacity` from the current slot instead of the hardcoded value 0.55, animated with 2s easeInOut

## Capabilities

### New Capabilities

- `time-aware-theme`: Per-slot color system covering background gradients, text, icons, cards, dock, mist, glow, and smoke — updated every 30 seconds via a shared view model; 6 time slots with WCAG AA-verified text contrast
- `ambient-background-animation`: 3-layer animated background with gradient breathing, mist particle drifting, and radial glow pulsing; reduce-motion safe

### Modified Capabilities

- none

## Impact

- Files created: `TramThienTra/ViewModels/ThoiGianViewModel.swift`
- Files modified: `ThoiGian.swift`, `NenDongView.swift`, `TraThatView.swift`, `TraXongView.swift`, `ZenCard.swift`, `TramThienTraApp.swift`
- No new package dependencies; iOS 17+ maintained
- Accessibility: reduce-motion path disables mist, breathing, and glow pulse, leaving a static gradient only
