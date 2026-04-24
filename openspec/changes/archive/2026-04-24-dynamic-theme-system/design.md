## Context

The app currently uses a 4-case `ThoiGian` enum (suongSom, banNgay, hoangHon, traDenDem) to drive a single flat `LinearGradient` background. The gradient cross-fades in 1.5s on a per-view 60-second timer managed inside `NenDongView`. No other UI surface reads from `ThoiGian` — text colors, nav icons, cards, dock, and smoke effects are all hardcoded. The `ZenCard` white overlay is set to a fixed opacity of 0.55 regardless of time slot. There is no shared time-awareness mechanism; any future view that needs time-reactive color must manage its own timer.

This change expands `ThoiGian` to 6 cases with 17 new computed properties per case, introduces a shared `ThoiGianViewModel` as the single source of truth, and propagates time-aware values to the background, text layers, nav icons, dock, cards, and smoke effects.

## Goals / Non-Goals

**Goals:**

- Expand to 6 time slots with finer morning and afternoon granularity
- Add all per-slot color and animation parameters as typed Swift computed properties on the enum
- Create a single shared `ThoiGianViewModel` with a 30-second update cycle so every view reads from one source
- Upgrade `NenDongView` to a 3-layer animated ZStack (gradient + mist particles + radial glow) with full reduce-motion compliance
- Apply time-aware colors to text, nav icons, dock, card overlay, and smoke via environment object injection
- Remove deprecated `gradientColors` and `darkGradientColors` aliases
- Maintain iOS 17+ compatibility and WCAG AA text contrast for all 6 slots

**Non-Goals:**

- User-configurable or manually overridable themes
- Slate/dark-mode split beyond what the existing traDenDem slot already covers
- New package dependencies (no third-party animation libraries)
- Changes to any view other than the 5 listed (NenDongView, TraThatView, TraXongView, ZenCard, TramThienTraApp)

## Decisions

**D1 — Shared ViewModel over per-view timers**

All time-reactive views previously would need their own `Timer`. Instead, `ThoiGianViewModel` is a single `@StateObject` created at app root and injected as an `@EnvironmentObject`. This means one 30-second tick drives every surface simultaneously, eliminating timer drift between views.

Alternative considered: keep per-view timers and add a `@Published` computed property. Rejected because it creates N independent timers and makes it impossible to guarantee synchronised transitions across the tab bar and background.

**D2 — Enum computed properties over a struct-based theme dictionary**

All per-slot values live directly on the `ThoiGian` enum as computed properties. This keeps the model self-contained, avoids a separate theme registry, and makes the switch-exhaustiveness compiler check enforce completeness whenever a new slot is added.

Alternative considered: a `ThemeConfig` struct stored in a dictionary keyed by `ThoiGian`. Rejected because it requires a dictionary lookup at every read site and loses exhaustiveness checking.

**D3 — ThoiGianViewModel publishes `current: ThoiGian` and `progress: Double`**

`progress` (0.0–1.0 position within the current slot) is pre-computed in the view model so that animated layers (mist drift speed, glow pulse phase) can consume a single stable value without each recalculating clock arithmetic.

Alternative considered: publish only `current` and let views compute progress themselves. Rejected to avoid duplicated Date arithmetic and to keep views declarative.

**D4 — 3-layer ZStack in NenDongView, not a custom Canvas renderer**

Layer 1 (base gradient) uses `LinearGradient` with `withAnimation(.easeInOut(duration: 3.0))` — the same pattern as today but with a longer curve. Layer 2 (mist) uses `TimelineView` + `Canvas` for efficient particle drawing without creating SwiftUI view nodes per particle. Layer 3 (radial glow) uses `RadialGradient` inside a `TimelineView` whose opacity oscillates with a sine function over 12s. This keeps all three layers in SwiftUI, requires no Metal shaders, and compiles on Xcode 15 / iOS 17.

Alternative considered: a single Canvas layer drawing everything. Rejected because it makes the base gradient non-animatable via SwiftUI's standard `withAnimation` and requires manual interpolation.

**D5 — Reduce-motion: static gradient only, no structural branching**

`@Environment(\.accessibilityReduceMotion)` is read in `NenDongView`. When true, layers 2 and 3 are hidden via `opacity(reduceMotion ? 0 : 1)` and the gradient breathing drift is suppressed. This avoids `if/else` branching that would teardown/rebuild the view hierarchy on toggle, which itself can cause a jarring flash.

**D6 — Gradient breathing via animated startPoint/endPoint**

The base gradient's `startPoint` drifts ±6% (i.e., `UnitPoint(x: 0.5, y: baseY + sin(phase) * 0.06)`) on an 8-second cycle using a `TimelineView`. This produces a gentle undulation that reads as organic warmth without crossing into distraction.

**D7 — ZenCard receives ThoiGianViewModel via @EnvironmentObject**

`ZenCard` reads `cardOverlayOpacity` from the environment object rather than accepting it as a parameter, preserving its zero-argument call-site API across the codebase. The white overlay `Rectangle` is wrapped in `withAnimation(.easeInOut(duration: 2.0))`.

## Risks / Trade-offs

`TimelineView` scheduling precision — `TimelineView` on iOS 17 fires at approximately the requested schedule but is not frame-exact. The mist particle positions use accumulated time, so minor jitter in firing intervals is invisible in practice. Mitigation: use `.animation` timing mode (not `.everyMinute`) to get sub-second granularity.

`@EnvironmentObject` crash if missing — any view that reads `ThoiGianViewModel` via `@EnvironmentObject` will crash if the object is not in the environment. Mitigation: inject at `TramThienTraApp` root (same level as `streakViewModel`) so it is always present for every view in the hierarchy.

`ThoiGian.current` called from background timer thread — the `Timer` in `ThoiGianViewModel` fires on the main run loop, so `Date()` reads and `@Published` assignments are on the main thread. No additional isolation is needed beyond the existing pattern already used by `StreakViewModel`.

Removing deprecated aliases (`gradientColors`, `darkGradientColors`) — any call site still using these will produce a compile error. A codebase-wide search confirms the aliases are not called anywhere outside `ThoiGian.swift` itself, so removal is safe.

`cardOverlayOpacity` via environment vs. parameter — `ZenCard` is used in many places. Introducing an environment dependency means Xcode Previews for `ZenCard` must supply a `ThoiGianViewModel` in scope. Each affected preview must be updated. Mitigation: provide a static preview helper `ThoiGianViewModel.preview` with a fixed slot.

Performance of 8 mist particles using `Canvas` — each particle is a blurred ellipse drawn in a `Canvas` draw closure. On an iPhone 12 this is well within budget for a background layer. The particle count is capped at 8 (suongSom/hoangHon). Mitigation: on reduce-motion, the entire Canvas layer is hidden, so no draw calls occur.
