## 1. ViewModel

- [x] 1.1 Create `TramThienTra/ViewModels/SamHoiViewModel.swift` with `@MainActor final class SamHoiViewModel: ObservableObject` following BuongBoViewModel pattern
- [x] 1.2 Add `SamHoiTab` enum (`samHoi`, `kinhTung`) with `CaseIterable` and Vietnamese raw values
- [x] 1.3 Add published properties: `text` (repentance), `vowText` (transformation vow), `isReleasing`, `selectedTab`
- [x] 1.4 Implement `releaseAndDismiss()` async method: set `isReleasing = true`, sleep 2.5s, clear both text fields, set `isReleasing = false`
- [x] 1.5 Add computed `canSubmit` property: text is non-empty (trimmed) and not currently releasing <- (verify: matches BuongBoViewModel pattern, all state transitions correct)

## 2. Sam Hoi Tab View

- [x] 2.1 Create `TramThienTra/Views/SamHoi/SamHoiView.swift` with `NenDongView` background, `ZenScreenHeader` title "Phong Sam Hoi", and segmented `Picker` for tab switching
- [x] 2.2 Implement rotating six-sense prompts: `@State` for current prompt index, `Timer.publish(every: 5)` with `.onReceive`, fade transition between prompts, reduceMotion support
- [x] 2.3 Add helper text in caption style with secondary text color: "Lang long quan chieu sau can, thanh tam sam hoi nhung dieu da gay ton thuong."
- [x] 2.4 Add main repentance `ZenTextField` inside `ZenCard` (multiline, no limit, minHeight 180, maxHeight 300)
- [x] 2.5 Add transformation vow `ZenTextField` with prompt text (minHeight 60, maxHeight 120)
- [x] 2.6 Add `NutGiotNuocView` submit button with icon "hands.sparkles.fill" and label "Sam hoi", disabled when `canSubmit` is false
- [x] 2.7 Implement celebration animation sequence: `startCelebration()` method replicating BuongBoView pattern (button fade 0.3s, form fade 0.5s, smoke via KhoiTanView, quote fade in 0.7s, hold 3s, fade out 0.7s, form return 0.7s)
- [x] 2.8 Add 15 repentance quotes as static array and random quote selection on submit
- [x] 2.9 Add quote overlay view matching BuongBoView's `quoteOverlayView` pattern <- (verify: full animation sequence works end-to-end, text fields clear after animation, reduceMotion shortens timings)

## 3. Kinh Tung Tab View

- [x] 3.1 Implement Kinh Tung tab content as a `ScrollView` within `SamHoiView` (shown when `selectedTab == .kinhTung`)
- [x] 3.2 Add sutra title "Sam Hoi Sau Can" in headline font and attribution "Theo truyen thong Phat giao Viet Nam" in caption font
- [x] 3.3 Add all six sutra sections as static data: Nhan Can (Mat), Nhi Can (Tai), Ty Can (Mui), Thiet Can (Luoi), Than Can (Than), Y Can (Tam) with section headers in headline font and verse text in body font
- [x] 3.4 Apply time-adaptive colors via `thoiGianVM.current` for all text elements with `.animation(.easeInOut(duration: 2.0))` <- (verify: all six sections render correctly, time-adaptive colors apply, scroll works smoothly)

## 4. Accessibility

- [x] 4.1 Add VoiceOver labels and hints to submit button, text fields, and tab picker
- [x] 4.2 Mark sutra section headers with `.accessibilityAddTraits(.isHeader)`
- [x] 4.3 Ensure all interactive elements meet 44pt minimum touch target
- [x] 4.4 Support `accessibilityReduceMotion` in prompt rotation and celebration animation <- (verify: VoiceOver can navigate all elements, reduceMotion disables animations, touch targets meet 44pt minimum)

## 5. Navigation Integration

- [x] 5.1 Add `@State private var showSamHoi = false` to `TraThatView`
- [x] 5.2 Add full-width `ZenButton("Sam hoi", variant: .secondary, icon: "hands.sparkles.fill")` as a new row below the existing Buong Bo / Thien Tho HStack in the dock
- [x] 5.3 Add `.fullScreenCover(isPresented: $showSamHoi) { SamHoiView().environmentObject(thoiGianVM) }`
- [x] 5.4 Add accessibility label and hint to the new button <- (verify: button appears in dock below existing row, tapping opens SamHoiView as full-screen cover, ThoiGianViewModel is passed correctly)

## 6. Xcode Project Configuration

- [x] 6.1 Add `SamHoiViewModel.swift` and `SamHoiView.swift` to the Xcode project (`project.pbxproj`)
- [x] 6.2 Create `SamHoi` group under `Views` in the Xcode project structure
- [x] 6.3 Build the project and verify zero errors <- (verify: project builds successfully, new files appear in correct groups, no warnings related to new files)
