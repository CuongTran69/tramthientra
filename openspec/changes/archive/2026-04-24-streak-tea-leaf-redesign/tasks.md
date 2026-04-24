## 1. Color Tokens

- [x] 1.1 Add 6 tea-leaf color tokens to `ZenColor` in `TramThienTra/Utilities/Constants.swift`: `zenTeaSpring` (#8AAE7A), `zenTeaLight` (#7BA27B), `zenTeaDeep` (#5A7F5A), `zenTeaRich` (#4D7A4D), `zenTeaVein` (#4A6B4A), `zenTeaWilted` (#8A7A60)
- [x] 1.2 Add 3 time-adaptive computed properties to `ThoiGian` in `TramThienTra/Utilities/ThoiGian.swift`: `leafTint`, `leafGlow`, and `leafGlowOpacity` with values per the 6 time slots defined in the spec <- (verify: all 6 time slots have correct hex values matching spec, leafGlow for buoiSang returns clear/none)

## 2. Stage Rename

- [x] 2.1 Rename `LeafStage` enum cases in `TramThienTra/ViewModels/StreakViewModel.swift`: seed->hatTra, sprout->mamTra, young->bupNon, green->laNon, lush->laXanh, greatTree->traChin
- [x] 2.2 Update `LeafStage.title` computed property with new Vietnamese titles: "Hat Tra", "Mam Tra", "Bup Non", "La Non", "La Xanh", "Tra Chin"
- [x] 2.3 Update `checkStreak()` method to use the renamed enum cases (day thresholds remain unchanged) <- (verify: enum compiles, raw values 0-5 preserved, day mapping unchanged, all references to old case names eliminated)

## 3. Tea Leaf Shapes

- [x] 3.1 Create `TramThienTra/Views/Components/LaTraView.swift` with struct `LaTraView: View` accepting `streak: Int` and `stage: StreakViewModel.LeafStage`, with `@EnvironmentObject var thoiGianVM: ThoiGianViewModel` and `@Environment(\.accessibilityReduceMotion)`
- [x] 3.2 Implement `hatTra` shape: teardrop seed Path in `ZenColor.zenBrownDark`, approximately 14x18pt, centered in 48x48 frame
- [x] 3.3 Implement `mamTra` shape: curled sprout with seed pod and tiny emerging leaf Path using `ZenColor.zenTeaSpring`
- [x] 3.4 Implement `bupNon` shape: tea bud with 2 unfurling leaves Path using `ZenColor.zenTeaLight`
- [x] 3.5 Implement `laNon` shape: recognizable tea leaf with veins (`ZenColor.zenTeaVein`) and serrated edges using `ZenColor.zenSage`
- [x] 3.6 Implement `laXanh` shape: full lush leaf with `ZenColor.zenGold` edge shimmer using `ZenColor.zenTeaDeep`
- [x] 3.7 Implement `traChin` shape: 2-3 overlapping leaves with glow halo using `ZenColor.zenTeaRich` <- (verify: all 6 shapes render correctly in SwiftUI previews, fit within 48x48 frame, use only ZenColor tokens and ThoiGian properties -- zero inline Color(hex:) calls)

## 4. Animations

- [x] 4.1 Implement idle sway animation: `rotationEffect` oscillating +/- 2 degrees with 3-4 second period for stages bupNon and above, gated by `accessibilityReduceMotion`
- [x] 4.2 Implement idle breathing animation: scale 1.0 to 1.03 with 4-5 second period for stages laXanh and above, composited with sway, gated by `accessibilityReduceMotion`
- [x] 4.3 Preserve existing stage-change bounce: spring scale 1.0 -> 1.08 -> 1.0 (response 0.4, dampingFraction 0.55) on stage change, opacity crossfade when reduceMotion is true <- (verify: sway only appears on stages 2+, breathing only on stages 4+, all animations disabled when reduceMotion is true, stage bounce still works)

## 5. Layout and Time Coloring

- [x] 5.1 Build the LaTraView body: HStack(spacing:12) with shape (48x48) | VStack(title zenHeadline + count zenCaption) | Spacer | 6 progress dots (8x8 circles)
- [x] 5.2 Apply time-adaptive leaf tint via `thoiGianVM.current.leafTint` blended with stage colors
- [x] 5.3 Apply leaf glow effect using `thoiGianVM.current.leafGlow` and `leafGlowOpacity` (shadow or overlay)
- [x] 5.4 Set background: `streakTextPrimary.opacity(0.08)` default, `traDenDem` uses warm gold background. Corner radius 20
- [x] 5.5 Add accessibility: `.accessibilityElement(children: .combine)` with label "\(stage.title), streak \(streak) ngay", progress dots `.accessibilityHidden(true)` <- (verify: layout matches existing CayThienView structure, night mode uses moonlit sage #9DB89D tint with warm gold glow, VoiceOver reads correct label)

## 6. Integration and Cleanup

- [x] 6.1 Update `TraThatView.swift` line 78: replace `CayThienView(streak:stage:)` with `LaTraView(streak:stage:)`
- [x] 6.2 Delete `TramThienTra/Views/Components/CayThienView.swift`
- [x] 6.3 Update `TramThienTra.xcodeproj/project.pbxproj`: remove CayThienView.swift file reference, add LaTraView.swift file reference
- [x] 6.4 Build the project and verify zero compiler errors <- (verify: project builds successfully, no references to CayThienView remain anywhere in the codebase, LaTraView renders in TraThatView)
