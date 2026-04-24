## 1. ThoiGian Greeting Property

- [x] 1.1 Open `TramThienTra/Utilities/ThoiGian.swift` and add a `var greetingPhrase: String` computed property to the `ThoiGian` enum
- [x] 1.2 Implement the switch: `suongSom` → "Buổi sáng an lành", `banNgay` → "Trà chiều tĩnh lặng", `hoangHon` → "Hoàng hôn nhẹ nhàng", `traDenDem` → "Đêm trà thư giãn" ← (verify: all four cases are covered, the computed property compiles without error, and `ThoiGian.current.greetingPhrase` returns the correct string at runtime for the active time period)

## 2. TraXongView Surface Shadow

- [x] 2.1 Open `TramThienTra/Views/TraThat/TraXongView.swift` and locate the Canvas draw call section where the teapot body is drawn
- [x] 2.2 After the teapot body draw and before any smoke particle draws, add a `context.addFilter(.shadow(color: ..., radius: 8))` or equivalent blurred ellipse draw using `zenBrownDark.opacity(0.18)` at `(centerX - 38, centerY + 38, width: 76, height: 16)` ← (verify: shadow renders beneath the teapot body and below smoke particles, the ellipse is visually grounded and does not appear above the spout or lid)
- [x] 2.3 Confirm that smoke particle draw calls are positioned after the shadow draw call in the Canvas block

## 3. Nav Icon Button Restyle

- [x] 3.1 Open `TramThienTra/Views/TraThat/TraThatView.swift` and locate the `navIconButton()` helper function
- [x] 3.2 Change the visual frame from 44pt to 36pt
- [x] 3.3 Replace the `.ultraThinMaterial` background and any white overlay layers with a single `Circle().fill(Color.white.opacity(0.25))`
- [x] 3.4 Add or confirm `.contentShape(Circle())` sized at 44pt to preserve the WCAG-compliant touch target ← (verify: visual circle is 36pt, tappable area is at least 44pt, VoiceOver reads the original accessibility label and hint unchanged)

## 4. CayThienView Padding Reduction

- [x] 4.1 Open `TramThienTra/Views/Components/CayThienView.swift` and locate the internal padding declarations
- [x] 4.2 Change horizontal padding from 20pt to 16pt and vertical padding from 16pt to 12pt ← (verify: streak card renders without clipping, content is fully visible at typical iPhone screen heights)

## 5. TraThatView Layout Restructure

- [x] 5.1 Open `TramThienTra/Views/TraThat/TraThatView.swift` and identify all existing @State variables, `.sheet`, and `.fullScreenCover` modifiers — do not remove or alter any of them
- [x] 5.2 Replace the outer VStack body content with the Tea Table Scene structure: nav strip at top, then time greeting (`ThoiGian.current.greetingPhrase` in ZenFont.title()), then app name "Trạm Thiền Trà" in ZenFont.caption() at muted opacity, then a flexible `Spacer(minLength: 20)`
- [x] 5.3 Add `TraXongView` at 220×220pt (down from 240) with a gold shadow modifier below the spacer
- [x] 5.4 Add a fixed 20pt Spacer, then `ZenCard { CayThienView() }` for the streak card
- [x] 5.5 Add a fixed 16pt Spacer, then the bottom action dock container: `.background(.ultraThinMaterial)` combined with `Color.white.opacity(isNight ? 0.08 : 0.40)` overlay, white stroke, corner radius 24pt, padding 16pt, shadow `zenBrown.opacity(0.10)` radius 20 y 8
- [x] 5.6 Inside the dock, add `ZenButton("Tích luỹ", .primary, icon: "drop.fill")` at full width, then an HStack(spacing: 10) with `ZenButton("Buông bỏ", .secondary)` and `ZenButton("Thiền Thở", .secondary, icon: "wind")` each at `.frame(maxWidth: .infinity)`
- [x] 5.7 Add 32pt bottom safe area padding after the dock
- [x] 5.8 Wire each dock button to its corresponding existing @State variable (same assignments as the original buttons) ← (verify: all three buttons present in the sheet and trigger their original sheets/covers, no @State variables were removed, NenDongView background is still applied, layout renders correctly on iPhone SE and iPhone Pro Max screen sizes)

## 6. Final Review

- [ ] 6.1 Build the project and confirm zero new compiler errors or warnings introduced by this change
- [ ] 6.2 Run the app on a simulator and visually confirm the Tea Table Scene layout at all four ThoiGian periods ← (verify: greeting text is correct for each period, dock night adaptation is visible for traDenDem, teapot shadow is present, streak card is positioned between teapot and dock, all accessibility labels remain intact)
