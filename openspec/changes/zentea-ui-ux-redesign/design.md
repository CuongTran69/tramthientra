## Context

ZenTea (Trạm Thiền Trà) is an iOS 17+ mindfulness app built with SwiftUI and SwiftData. Visual decisions are currently scattered — gradients are defined inline in `ThoiGian.swift`, color tokens live in `Constants.swift` without a systematic palette, and there are no shared UI primitives (cards, buttons, text fields). Each screen implements its own visual style ad-hoc, making the codebase inconsistent and the app visually flat relative to its aspirational calm/zen brand.

The redesign must ship as a non-breaking SwiftUI-only change: no new Swift packages, no minimum OS bump, no data model changes.

## Goals / Non-Goals

**Goals:**

- Establish a single source of truth for color tokens and typography in `Constants.swift`
- Replace all two-stop gradients with three-stop versions in `ThoiGian.swift` and `NenDongView.swift`
- Ship three reusable view components (`ZenCard`, `ZenButton`, `ZenTextField`) that every screen consumes
- Visually refresh all six primary screens (TraThat, Onboarding, TichLuy, BuongBo, History, Settings)
- Upgrade four animation views (TraXong, KhoiTan, CayThien, NutGiotNuoc) for higher polish
- Achieve WCAG AA color contrast and 44×44 pt touch targets throughout

**Non-Goals:**

- New features or behavior changes beyond visual presentation
- New Swift Package dependencies
- Backend, data model, or notification changes
- Android or web platforms
- Localization changes (strings stay as-is)

## Decisions

### D1: Centralize all color tokens in `Constants.swift` — no inline hex values elsewhere

**Rationale:** The current codebase has hex strings scattered across multiple files. A single `ZenColor` namespace in `Constants.swift` makes palette swaps a one-file change and enforces consistency at compile time via named static properties.

**Alternative considered:** A separate `DesignTokens.swift` file. Rejected — adds a file for no functional gain; `Constants.swift` already serves this role.

### D2: Three new SwiftUI components — `ZenCard`, `ZenButton`, `ZenTextField`

**Rationale:** Without shared primitives every screen reimplements padding, corner radius, material backgrounds, and press states differently. Centralizing these means a single fix propagates everywhere.

- `ZenCard`: `.ultraThinMaterial` + white stroke overlay + shadow. Replaces raw `RoundedRectangle` + `background` combos.
- `ZenButton`: Two variants (primary with gradient fill, secondary with ghost border). Scale-to-0.96 spring animation + `UIImpactFeedbackGenerator` haptic on press.
- `ZenTextField`: ZenCard-styled container with focus ring (1 pt `zenSage` stroke on focus), built-in character counter positioned inside the field.

**Alternative considered:** Extending `ButtonStyle` and `TextFieldStyle` protocols only. Rejected — SwiftUI style protocols don't compose well with custom geometry (focus rings, character counters inside the field).

### D3: Three-stop gradients replace two-stop gradients

**Rationale:** The current `LinearGradient` calls use two stops, resulting in visible banding. Three stops with carefully chosen midpoints produce smoother transitions and let the night gradient (`traDenDem`) avoid the stark contrast that the current `#1A1A2E → #16213E` pair creates.

New stops are defined as `[Color]` arrays on the `ThoiGian` enum cases and consumed by `NenDongView` via a `LinearGradient(colors:startPoint:endPoint:)` call.

### D4: Animation polish stays within existing Canvas/TimelineView patterns

**Rationale:** All current animations use SwiftUI `Canvas` and `TimelineView`. Staying in this pattern avoids SpriteKit or Metal complexity, keeps the diff small, and guarantees performance parity on the A15+ devices the app targets.

Glow effects use `.shadow(color: zenGold.opacity(0.4), radius: 12)` layered on existing canvas drawings. Particle count increases are bounded to keep render time under 2 ms per frame at 60 fps.

### D5: `zenAccent` retained as a deprecated alias pointing to `zenSage`

**Rationale:** Removing `zenAccent` outright would cause compile errors across callers before they are individually updated. Providing `static let zenAccent = zenSage` lets the migration happen incrementally file-by-file without a big-bang change.

**Migration path:** Each screen migration in the tasks list removes the `zenAccent` usage and replaces it with the semantically correct new token. The alias is removed in the final cleanup task.

## Risks / Trade-offs

- [`.ultraThinMaterial` appearance varies by iOS version and wallpaper] → Mitigation: Pair material with an explicit `Color.white.opacity(0.1)` background layer so the card is always legible regardless of system material rendering.
- [Scale animation on `ZenButton` may interact poorly with SwiftUI's `List` swipe actions] → Mitigation: `ZenButton` is not used inside swipeable list rows; list rows use `ZenCard` for passive containers only.
- [Three-stop gradient `traDenDem` may be too dark on older OLED panels] → Mitigation: Darkest stop is `#141318` (not pure black), preserving some shadow detail. Review on iPhone 12 OLED before shipping.
- [`UIImpactFeedbackGenerator` must be called on the main thread] → Mitigation: `ZenButton`'s press handler already runs on main; document this requirement in the component's inline comment.
- [WCAG AA contrast for `zenGold` (#D4A574) on `zenCream` (#F5EDE4) is borderline] → Mitigation: Use `zenGold` for decorative elements only (dividers, icons); body text always uses `zenBrown` (#4A3728) on light backgrounds.

## Migration Plan

1. Land `Constants.swift` color/typography additions first (additive — no callers break).
2. Add `zenAccent` alias (`static let zenAccent = zenSage`) in the same commit.
3. Land `ThoiGian.swift` gradient upgrade — `NenDongView` is the only consumer.
4. Land `ZenCard`, `ZenButton`, `ZenTextField` components (no callers yet).
5. Migrate screens one by one in dependency order: TraThat → Onboarding → TichLuy → BuongBo → History → Settings.
6. Migrate animation views: TraXong → KhoiTan → CayThien → NutGiotNuoc.
7. Remove `zenAccent` alias once all callers are updated.
8. Accessibility audit pass (touch targets, VoiceOver labels, contrast check).

**Rollback:** Each step is an independent commit. Reverting any screen migration restores that screen to its prior state without affecting others.

## Open Questions

- Should `ZenButton` expose a `isLoading` state (spinner replaces label) for the async save action in TichLuyView? Decision can be deferred to the TichLuy migration task.
- Is a custom `Toggle` style for SettingsView worth the complexity, or does a tinted system toggle suffice? Default to tinted system toggle unless the designer requests custom.
