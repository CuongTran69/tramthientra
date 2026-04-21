## 1. Design System Foundation

- [x] 1.1 Add `ZenColor` namespace to `Constants.swift` with tokens: `zenBrown`, `zenBrownDark`, `zenSage`, `zenSageLight`, `zenGold`, `zenCream`
- [x] 1.2 Add deprecated alias `static let zenAccent = zenSage` to `ZenColor` in `Constants.swift`
- [x] 1.3 Add `ZenFont` namespace to `Constants.swift` with levels: `display`, `title`, `headline`, `subheadline`, `body`, `caption`, `caption2`
- [x] 1.4 Add letter-spacing (`.tracking`) view modifier helpers to `ZenFont` for uppercase label use cases ← (verify: all tokens compile, ZenFont levels render at correct sizes in SwiftUI preview, zenAccent alias resolves to zenSage)

## 2. Gradient System Upgrade

- [x] 2.1 Update `ThoiGian` enum to expose a `colors: [Color]` computed property with three-stop arrays for each case using the new hex values
- [x] 2.2 Update `NenDongView` to consume `ThoiGian.colors` via `LinearGradient(colors:startPoint:endPoint:)` replacing the two-stop calls
- [x] 2.3 Add 1.5 s linear cross-fade animation in `NenDongView` when the active `ThoiGian` case changes ← (verify: all four gradient slots render correct 3-stop colors, time-slot transition animates smoothly, night gradient is not pure black)

## 3. Shared UI Components

- [x] 3.1 Create `TramThienTra/Views/Components/ZenCard.swift` with the glassmorphism card implementation (ultraThinMaterial + white overlay + stroke + shadow)
- [x] 3.2 Create `TramThienTra/Views/Components/ZenButton.swift` with primary variant (gradient fill, scale animation, haptic) and secondary variant (ghost style, press fill)
- [x] 3.3 Add optional icon parameter support to `ZenButton` primary variant
- [x] 3.4 Create `TramThienTra/Views/Components/ZenTextField.swift` wrapping TextField/TextEditor in a ZenCard container with focus ring and optional inline character counter ← (verify: ZenCard renders correctly on both light and dark gradients; ZenButton press animation and haptic work; ZenTextField focus ring appears and counter displays)

## 4. TraThatView Redesign

- [x] 4.1 Add "Trạm Thiền Trà" title using `ZenFont.display()` to the TraThatView header
- [x] 4.2 Scale teapot illustration to 240×240 pt and add `zenGold.opacity(0.35)` drop shadow with radius 20
- [x] 4.3 Replace existing ritual action buttons with `ZenButton` primary variant
- [x] 4.4 Wrap streak summary row in `ZenCard` ← (verify: title visible, teapot glow present, both ritual buttons use ZenButton gradient style, streak bar inside ZenCard)

## 5. OnboardingView Redesign

- [x] 5.1 Resize onboarding illustrations to 160×160 pt
- [x] 5.2 Add 0.4 s opacity fade-in animation for page title and body text on page change
- [x] 5.3 Replace dot page indicators with a thin horizontal progress bar that fills proportionally as pages advance
- [x] 5.4 Replace "Bắt đầu" button with `ZenButton` primary variant ← (verify: illustration sizing correct, text fades in on swipe, progress bar shows correct fill, start button uses gradient style)

## 6. TichLuyView Redesign

- [x] 6.1 Replace text input fields with `ZenTextField` (ZenCard container + focus ring)
- [x] 6.2 Move character counter inside the field (bottom-right) via `ZenTextField` limit parameter
- [x] 6.3 Add 1 pt `zenSage.opacity(0.4)` horizontal decoration line below section header text ← (verify: focus ring appears on field tap, counter is inside the field not below it, decoration line renders below header)

## 7. BuongBoView Redesign

- [x] 7.1 Replace the release text area with a full-width `ZenCard` wrapping a `TextEditor`
- [x] 7.2 Add a 0.6 s smoke/dissolve icon animation to the "Buông" button that plays before dismissal
- [x] 7.3 Update `KhoiTanView` to increase particle count by 40% and change particle colors to `zenSage.opacity(0.6)` with random radius 3–8 pt ← (verify: text area is full-width glassmorphism, smoke icon animates 0.6 s on confirm, KhoiTan particles are softer and denser)

## 8. HistoryView Redesign

- [x] 8.1 Wrap each history list row in a `ZenCard`
- [x] 8.2 Implement stagger appear animation: each row starts offset 20 pt down at 0 opacity, animates in with 0.05 s delay per row
- [x] 8.3 Add empty-state view with an empty-teacup illustration and descriptive message
- [x] 8.4 Convert list sections to use sticky date headers ← (verify: rows use ZenCard, stagger animation plays on appear, empty state shows illustration, date headers are sticky on scroll)

## 9. SettingsView Polish

- [x] 9.1 Apply uppercase + 1.5 pt letter spacing to section headers using `ZenFont.caption()` with `.tracking`
- [x] 9.2 Set all settings row icons to 22×22 pt with `zenSage` tint
- [x] 9.3 Apply `zenSage` tint to system `Toggle` controls ← (verify: headers are uppercase with visible tracking, icons are consistently sized and tinted, toggles show sage color)

## 10. Animation Enhancements

- [x] 10.1 Add gold glow layer to `TraXongView` smoke particles using `.shadow(color: zenGold.opacity(0.4), radius: 12)` with a 2 s ease-in-out pulsing opacity animation
- [x] 10.2 Add spring bounce (scale 1.08 → 1.0, response 0.4, dampingFraction 0.55) to `CayThienView` triggered only on stage change
- [x] 10.3 Add pulsing glow ring to `NutGiotNuocView`: Circle overlay animating opacity 0 → 0.35 → 0 and scale 1.0 → 1.3 → 1.0 over 1.8 s repeating ← (verify: TraXong glow visible and pulsing, CayThien bounces only on stage change, NutGiotNuoc ring pulses at ~1.8 s cycle, 60 fps maintained on iPhone 12)

## 11. Accessibility Pass

- [x] 11.1 Audit all interactive elements for 44×44 pt touch targets; add `.contentShape(Rectangle())` or `.frame(minWidth:minHeight:)` where needed
- [x] 11.2 Add `.accessibilityLabel` to all buttons, toggles, and tappable elements across TraThatView, OnboardingView, TichLuyView, BuongBoView, HistoryView, SettingsView
- [x] 11.3 Add `.accessibilityHint` to all action buttons describing the activation result
- [x] 11.4 Verify WCAG AA contrast for all text/background combinations; confirm `zenGold` is not used as text color anywhere
- [x] 11.5 Add `@Environment(\.accessibilityReduceMotion)` checks to: ZenButton scale animation, CayThienView bounce, NutGiotNuocView glow ring, OnboardingView page transition (replace with crossfade) ← (verify: VoiceOver reads correct labels and hints for all interactive elements, no touch target under 44×44 pt, reduce motion disables all non-essential animations and replaces with opacity transitions)

## 12. Cleanup

- [x] 12.1 Search entire codebase for inline `Color(hex:)` calls outside `Constants.swift`; replace each with the appropriate `ZenColor` token
- [x] 12.2 Remove deprecated `zenAccent` alias from `Constants.swift` after confirming zero remaining usages ← (verify: no hardcoded hex strings outside Constants.swift, zenAccent alias removed, project builds cleanly with zero warnings related to color tokens)
