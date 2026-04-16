## Why

ZenTea's current visual layer uses flat gradients, an oversaturated accent color, and no shared component primitives — resulting in an inconsistent, visually low-polish experience that undercuts the app's mindfulness brand. A holistic UI/UX redesign replaces the ad-hoc visual approach with a cohesive design system built for calm, depth, and accessibility.

## What Changes

- Replace the two-stop flat gradient system with richer three-stop gradients across all four time slots (suongSom, banNgay, hoangHon, traDenDem)
- Swap `zenAccent` (#8FBC8F) for a muted sage palette (`zenSage`, `zenSageLight`) and add tea-brown and warm-gold tokens
- Introduce `ZenCard` (glassmorphism container), `ZenButton` (primary + secondary), and `ZenTextField` as shared SwiftUI components consumed across all views
- Add three new typography levels: `display`, `subheadline`, and `caption2`, with letter-spacing modifiers
- Redesign TraThatView (main screen), OnboardingView, TichLuyView, BuongBoView, HistoryView, and SettingsView to use the new components and palette
- Enhance existing animations: teapot glow in TraXongView, softer smoke in KhoiTanView, bounce in CayThienView, glow ring in NutGiotNuocView
- Enforce accessibility: 44×44 pt minimum touch targets, VoiceOver labels on all interactive elements, WCAG AA color contrast, reduce-motion alternatives

## Capabilities

### New Capabilities

- `design-system`: Shared color tokens, typography scale, and reusable SwiftUI components (ZenCard, ZenButton, ZenTextField) that form the visual foundation for all views
- `gradient-system`: Three-stop time-based gradient backgrounds replacing the current two-stop system, covering all four time slots including improved dark-mode rendering
- `view-redesign`: Full screen-by-screen visual refresh of TraThatView, OnboardingView, TichLuyView, BuongBoView, HistoryView, and SettingsView consuming the new design system
- `animation-enhancements`: Upgraded particle/smoke/glow animations across TraXongView, KhoiTanView, CayThienView, and NutGiotNuocView with 60 fps targets
- `accessibility`: Minimum touch targets, VoiceOver labels, WCAG AA contrast compliance, and reduce-motion support across the entire app

### Modified Capabilities

<!-- No existing spec-level capabilities are changing — this project has no prior specs. -->

## Impact

- **Files created**: `TramThienTra/Views/Components/ZenCard.swift`, `ZenButton.swift`, `ZenTextField.swift`
- **Files modified**: `Constants.swift`, `ThoiGian.swift`, `TraThatView.swift`, `TraXongView.swift`, `OnboardingView.swift`, `TichLuyView.swift`, `NutGiotNuocView.swift`, `BuongBoView.swift`, `KhoiTanView.swift`, `HistoryView.swift`, `SettingsView.swift`, `CayThienView.swift`, `NenDongView.swift`
- **Platform**: iOS 17+, SwiftUI, no new dependencies
- **Breaking**: Color token names change (`zenAccent` → `zenSage`); all callers must be updated
