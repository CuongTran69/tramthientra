## Why

The TramThienTra app currently offers gratitude journaling (Biet On), letting go (Buong Bo), and breathing meditation (Thien Tho) as its core mindfulness practices. Repentance (Sam Hoi) is a foundational practice in Vietnamese Buddhist tradition that complements these existing features. Adding a dedicated Phong Sam Hoi (Repentance Room) gives users a private, guided space to reflect on harmful actions through the six senses and read traditional repentance sutras, completing the app's spiritual practice toolkit.

## What Changes

- Add a new "Phong Sam Hoi" full-screen view with two tabs: Sam Hoi (write repentance) and Kinh Tung (read sutras)
- Sam Hoi tab: guided repentance text input with rotating six-sense prompts, transformation vow field, smoke animation on submit, and inspirational quote display — following the existing BuongBoView pattern
- Kinh Tung tab: scrollable Vietnamese repentance sutra text (Sam Hoi Sau Can) with six sections, one per sense organ, styled for meditative reading
- Add SamHoiViewModel following BuongBoViewModel pattern with tab state, text state, and release animation logic
- Add navigation entry point from TraThatView bottom dock as a new full-width secondary button row
- Privacy by design: no data persistence, text cleared after animation

## Capabilities

### New Capabilities
- `sam-hoi-repentance`: Guided repentance writing experience with six-sense prompts, smoke animation, and quote display. Covers the Sam Hoi tab interaction flow, animation sequence, and privacy guarantees.
- `kinh-tung-sutra-reader`: Sutra reading experience for the Kinh Tung tab. Covers the six-section Sam Hoi Sau Can sutra content, formatting, and meditative reading atmosphere.

### Modified Capabilities
<!-- No existing spec-level requirements are changing. The TraThatView navigation addition is an implementation detail, not a spec-level behavior change. -->

## Impact

- **New files**: `SamHoiViewModel.swift`, `SamHoiView.swift` (under new `Views/SamHoi` group)
- **Modified files**: `TraThatView.swift` (add navigation state + button + fullScreenCover)
- **Xcode project**: `project.pbxproj` updated to include new files and group
- **Reused components**: KhoiTanView (smoke), NenDongView (background), ZenScreenHeader, ZenCard, ZenTextField, NutGiotNuocView, ZenButton, ZenFont, ZenColor
- **Dependencies**: None new — all components already exist in the design system
- **Risk**: Low — additive feature with no changes to existing behavior or data models
