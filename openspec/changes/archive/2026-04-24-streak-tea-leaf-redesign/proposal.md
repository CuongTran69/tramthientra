## Why

The streak visualization in TramThienTra uses a tree growth metaphor (CayThienView) that is disconnected from the app's core identity as a zen tea experience. The current view renders generic shapes (circles, ellipses, rectangles) representing tree stages from seed to "great tree." Replacing this with a tea leaf growth concept aligns the streak UI with the app's teapot, tea ceremony, and mindfulness branding -- making the visual language cohesive across the entire experience.

## What Changes

- **Add 6 tea-leaf color tokens** to `ZenColor` in Constants.swift for leaf stages and states (spring, light, deep, rich, vein, wilted).
- **Add 3 time-adaptive computed properties** to ThoiGian.swift (`leafTint`, `leafGlow`, `leafGlowOpacity`) so leaf visuals shift with the 6 time-of-day slots.
- **Rename `LeafStage` enum values** in StreakViewModel.swift from tree terminology (seed/sprout/young/green/lush/greatTree) to tea terminology (hatTra/mamTra/bupNon/laNon/laXanh/traChin) with updated Vietnamese titles.
- **Replace CayThienView.swift with LaTraView.swift** -- a new component using custom `Path` bezier curves to draw tea leaf shapes at each stage, with subtle idle animations (sway, breathing scale) and time-of-day tinting.
- **Update TraThatView.swift** to reference `LaTraView` instead of `CayThienView`.
- **Update Xcode project file** (.pbxproj) to reflect the renamed source file.

## Capabilities

### New Capabilities
- `tea-leaf-visualization`: Custom bezier-curve tea leaf shapes rendered per streak stage, with time-adaptive coloring, idle animations, and night mode support.

### Modified Capabilities
_(none -- no existing specs are affected)_

## Impact

- **Files modified**: Constants.swift, ThoiGian.swift, StreakViewModel.swift, TraThatView.swift, project.pbxproj
- **File removed**: CayThienView.swift
- **File added**: LaTraView.swift
- **APIs**: No external API changes. Internal `LeafStage` enum cases are renamed but the enum is self-contained within StreakViewModel and CayThienView (now LaTraView).
- **Dependencies**: No new dependencies. All drawing uses SwiftUI's built-in `Path` and `Shape`.
- **Accessibility**: VoiceOver label format preserved; animation respects `accessibilityReduceMotion`.
- **Risk**: Low. The streak visualization is used in a single location (TraThatView line 78), and the rename is scoped to two files.
