## Why

The Home screen (TraThatView) uses a generic vertical-stack layout that presents three equal-weight full-width buttons, a visually ungrounded floating teapot, and a streak card buried at the bottom. This produces a sterile "form" feel that undermines the app's core "tea ceremony" identity and calm aesthetic.

## What Changes

- Add `greetingPhrase` computed property to the `ThoiGian` enum, returning a time-contextual Vietnamese greeting for each period (suongSom, banNgay, hoangHon, traDenDem).
- Add an elliptical surface shadow beneath the teapot body in `TraXongView` to visually ground the teapot on a surface.
- Replace the TraThatView vertical-stack layout with a "Tea Table Scene" structure: time greeting at top, teapot centered, streak card elevated above the bottom, and a glassmorphism action dock anchored to the bottom edge. Night adaptation dims the dock overlay for `.traDenDem`.
- Restyle the nav icon button helper to use a single lighter opacity fill (white 0.25) and keep a 44pt touch target via `.contentShape(Circle())` for WCAG compliance, while shrinking the visual frame to 36pt.
- Reduce internal padding in `CayThienView` from 20pt/16pt to 16pt/12pt to accommodate the streak card's new mid-screen position.

## Capabilities

### New Capabilities

- `view-redesign`: TraThatView layout restructured from a flat vertical stack into a layered "Tea Table Scene" with a bottom glassmorphism action dock and time-contextual greeting.

### Modified Capabilities

(none — no existing spec files are present; this is a purely visual refactor with no behavior or data model changes)

## Impact

- Files modified: `TramThienTra/Utilities/ThoiGian.swift`, `TramThienTra/Views/TraThat/TraXongView.swift`, `TramThienTra/Views/TraThat/TraThatView.swift`, `TramThienTra/Views/Components/CayThienView.swift`
- No files created or deleted
- No new dependencies introduced
- No API or data model changes
- All existing accessibility labels, hints, and sheet/fullScreenCover navigation preserved
