## Context

TraThatView is the Home screen of the TramThienTra app. It currently uses a plain VStack with three equal-weight full-width buttons, a floating teapot animation (TraXongView) that has no visual anchor to the surface, and a streak card (CayThienView wrapped in ZenCard) placed at the bottom of the stack. The layout communicates "form" rather than "ceremony," conflicting with the app's calm, mindful tea ritual identity.

ThoiGian is an existing enum in `TramThienTra/Utilities/ThoiGian.swift` that categorizes the current time into four periods (suongSom, banNgay, hoangHon, traDenDem) and drives background and color adaptation throughout the app.

TraXongView renders the animated teapot using a Canvas draw call. The teapot body is drawn first, then smoke particles are layered on top.

CayThienView renders the streak counter and is currently padded at 20pt horizontal / 16pt vertical.

## Goals / Non-Goals

**Goals:**
- Restructure TraThatView into a top-greeting / centered-teapot / elevated-streak-card / bottom-dock layout that evokes a "tea table scene."
- Ground the teapot visually with an elliptical surface shadow.
- Surface time-contextual greeting text to orient the user to the current tea period.
- Consolidate the three action buttons into a glassmorphism dock anchored to the bottom, with night mode adaptation.
- Restyle nav icon buttons to be visually lighter while preserving 44pt touch targets.
- Preserve all accessibility labels, hints, sheet/fullScreenCover navigation, and @State variables unchanged.

**Non-Goals:**
- Changes to app navigation, routing, or sheet content.
- Changes to data models, persistence, or business logic.
- New animations beyond the existing teapot smoke.
- Localization of greeting strings beyond the four defined periods.
- Dark mode system-level theming (this is time-of-day theming only).

## Decisions

### D1: Greeting text lives on ThoiGian, not TraThatView

Adding `greetingPhrase` as a computed property on the `ThoiGian` enum keeps the mapping collocated with the existing period logic (`backgroundColor`, `zenColor`, etc.). The alternative — a `switch` inline in TraThatView — would scatter period semantics across the view layer.

### D2: Glassmorphism dock uses `.ultraThinMaterial` + white overlay, not a custom blur

SwiftUI's `.ultraThinMaterial` adapts automatically to system appearance and is GPU-efficient. A custom `NSVisualEffectView` or manual blur would require UIKit bridging for no gain. The white overlay (`Color.white.opacity(0.40)`) applies on top to control the dock brightness independently of the material. Night adaptation reduces this overlay to `0.08` when `ThoiGian.current == .traDenDem`.

### D3: Surface shadow is drawn inside the Canvas, not as a SwiftUI `.shadow` modifier

TraXongView already uses a Canvas for performance. Inserting the elliptical shadow as a GraphicsContext draw call (blurred ellipse) before the teapot body keeps all rendering in one pass and avoids compositing a SwiftUI shadow on top of a Canvas layer, which can cause visual artifacts.

### D4: Nav icon visual frame shrinks to 36pt, touch target stays 44pt via `.contentShape(Circle())`

WCAG 2.5.5 requires a 44×44pt minimum touch target. Shrinking the visible circle to 36pt while keeping the `.contentShape` at 44pt satisfies both the design goal (lighter icons) and the accessibility requirement. The `.ultraThinMaterial` background layers are removed; a single `Circle().fill(Color.white.opacity(0.25))` replaces them.

### D5: Streak card moves up, CayThienView padding reduces by 4pt on each axis

The streak card now sits between the teapot and the bottom dock. The available vertical space is smaller. Reducing padding from `20/16` to `16/12` prevents the card from feeling cramped while keeping the teapot at 220pt (down from 240pt). The 20pt reduction in teapot size and the 8pt total padding reduction together reclaim roughly 28pt of vertical space.

## Risks / Trade-offs

- [Risk] `.ultraThinMaterial` renders differently on older iOS versions (below iOS 15). → Mitigation: TramThienTra already targets iOS 15+; this is not a regression.
- [Risk] The elliptical shadow in Canvas requires a `drawLayer` or `addFilter(.shadow(...))` call; incorrect placement in the draw order will cause the shadow to render above smoke particles. → Mitigation: The task explicitly specifies the draw order: shadow after teapot body, before smoke particles.
- [Risk] Reducing teapot size from 240pt to 220pt may clip existing smoke particle paths if they reference hard-coded offsets relative to 240pt. → Mitigation: TraXongView should be reviewed; if smoke paths use relative offsets from center, no change is needed. This is called out as a verify point in tasks.
- [Risk] Greeting strings are hard-coded in Vietnamese. If localization is added later, these will need extraction. → Mitigation: Acceptable for now; strings are isolated to a single computed property in ThoiGian.swift.
