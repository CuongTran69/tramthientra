## Context

TramThienTra is a SwiftUI iOS app centered on zen tea and mindfulness. It tracks meditation streaks and visualizes progress through a stage-based growth metaphor. The current implementation (`CayThienView`) uses generic geometric primitives (Circle, Ellipse, Rectangle) arranged to resemble a growing tree. This tree metaphor does not align with the app's tea identity.

The streak visualization is consumed in a single location (`TraThatView`, line 78). The `LeafStage` enum lives in `StreakViewModel` and is only referenced by the view model itself and `CayThienView`, making this a well-isolated change.

The app already has a comprehensive time-of-day system (`ThoiGian` enum with 6 slots), a centralized color token system (`ZenColor`), and accessibility patterns (reduceMotion guards, VoiceOver labels) that the new view must continue to follow.

## Goals / Non-Goals

**Goals:**
- Replace tree shapes with tea-leaf bezier curves that visually connect to the app's zen tea identity
- Rename stage terminology from tree vocabulary to tea vocabulary throughout
- Add time-of-day adaptive coloring so leaves shift tint with the ambient light system
- Add subtle idle animations (sway and breathing) that complement the existing stage-change bounce
- Maintain the existing layout contract: HStack with 48x48 shape, title + count, progress dots

**Non-Goals:**
- Redesigning the TraThatView layout or the streak tracking logic
- Adding new streak features (sharing, badges, milestones)
- Changing the day-to-stage mapping thresholds
- Animating transitions between stages (beyond the existing bounce)
- Supporting landscape or iPad-specific layouts

## Decisions

### 1. Custom Path bezier curves over SF Symbols or image assets

**Decision**: Draw all 6 tea leaf stages using SwiftUI `Path` within `Shape` conformances.

**Rationale**: Path-based shapes are resolution-independent, tintable via time-of-day colors, animatable via SwiftUI's shape interpolation, and add zero asset bundle overhead. SF Symbols lack tea-specific iconography. Raster assets would require managing 6 images x multiple scales and could not be dynamically tinted per time slot.

**Alternatives considered**:
- SF Symbols: No tea leaf symbols available; closest (`leaf.fill`) is generic and cannot represent 6 distinct growth stages.
- SVG assets: Would require an SVG renderer dependency or pre-rasterization; cannot be dynamically tinted per time slot without additional processing.
- Lottie animations: Adds a third-party dependency (approximately 1.5 MB); overly complex for 6 static shapes with simple sway animations.

### 2. Idle animations via SwiftUI animation modifiers

**Decision**: Implement sway (rotationEffect +/- 2 degrees) for stages 2+ (bupNon onward) and breathing scale for stages 4+ (laXanh onward) using `withAnimation` on a repeating timer, gated by `accessibilityReduceMotion`.

**Rationale**: SwiftUI's declarative animation system handles interruption, composition, and accessibility automatically. A repeating animation keeps the leaf feeling alive without user interaction, reinforcing the zen/mindfulness atmosphere. The animations are subtle enough to avoid distraction.

**Alternatives considered**:
- CADisplayLink-based animation: Lower-level, harder to integrate with SwiftUI's state system, no accessibility gating built in.
- TimelineView: More appropriate for high-frequency updates; overkill for a slow sway/breathe cycle (3-4 second period).

### 3. Color tokens in ZenColor, time-adaptive tints in ThoiGian

**Decision**: Add 6 static leaf color tokens to `ZenColor` for stage-specific fills. Add 3 time-adaptive computed properties (`leafTint`, `leafGlow`, `leafGlowOpacity`) to `ThoiGian` for ambient coloring.

**Rationale**: This follows the established pattern where `ZenColor` holds semantic tokens and `ThoiGian` holds time-of-day variations. The leaf tint from `ThoiGian` is blended with or used alongside the stage color from `ZenColor`, so the leaf changes both with growth stage and with time of day.

**Alternatives considered**:
- All colors in ZenColor with no time variation: Misses the opportunity to integrate with the existing ambient system.
- All colors computed in ThoiGian: Would duplicate stage logic outside the view model and violate the token/ambient separation.

### 4. File rename (CayThienView -> LaTraView) instead of incremental refactor

**Decision**: Delete `CayThienView.swift` and create `LaTraView.swift` as a new file rather than editing the existing file in place.

**Rationale**: The view body, shapes, and animations are entirely replaced -- no code is reused from the old implementation except the outer HStack layout. A clean file avoids confusion and makes the git diff reviewable. The Xcode project file (.pbxproj) must be updated to reflect the rename.

**Alternatives considered**:
- Rename in place with git mv: Would preserve history but the file contents are so different that history continuity has little value.
- Keep CayThienView name with new internals: Confusing -- "Cay Thien" means "meditation tree," which contradicts the new tea leaf concept.

### 5. Enum case rename strategy

**Decision**: Rename all `LeafStage` enum cases and their `title` strings in a single commit. No deprecation wrapper or typealias needed.

**Rationale**: The enum is only used in `StreakViewModel` and `CayThienView` (soon `LaTraView`). There are no external consumers, no persistence of raw values, and no public API surface. A clean rename is safe and avoids accumulating technical debt from compatibility shims.

## Risks / Trade-offs

**[Bezier curve complexity]** Custom `Path` code for 6 stages is verbose and hard to validate without visual inspection. **Mitigation**: Each stage shape is an isolated `Shape` struct or function, testable in SwiftUI previews. Keep control points well-commented with descriptive variable names.

**[Xcode project file merge conflicts]** The .pbxproj file is notoriously conflict-prone. **Mitigation**: Make the file reference change (remove CayThienView.swift, add LaTraView.swift) in a dedicated step. If conflicts arise, resolve by re-adding the file via Xcode.

**[Night mode visual regression]** The new leaf colors and glow may look incorrect against the dark gradient background of traDenDem. **Mitigation**: The spec includes specific night-mode colors (moonlit sage #9DB89D, warm gold glow). Test all 6 time slots in previews using a ThoiGian override.

**[Animation jank on older devices]** Idle sway + breathing + stage bounce could stack. **Mitigation**: Animations are simple transforms (rotation, scale) composited by the GPU. No custom drawing loop. Performance is equivalent to the existing implementation.

**[Accessibility label change]** VoiceOver users may notice the stage names changed from tree to tea terminology. **Mitigation**: The format remains "\(stage.title), streak \(streak) ngay" -- only the stage names change. Vietnamese titles are already descriptive ("La Non" = "Young Leaf").
