## 1. Expand ThoiGian enum to 6 slots

- [x] 1.1 Add `buoiSang` (raw value 1) and `chieuTa` (raw value 3) cases to the enum, re-number existing cases to maintain correct Int ordering: suongSom=0, buoiSang=1, banNgay=2, chieuTa=3, hoangHon=4, traDenDem=5
- [x] 1.2 Update `ThoiGian.current` switch to cover all 6 hour ranges: 5..<9 → suongSom, 9..<12 → buoiSang, 12..<15 → banNgay, 15..<18 → chieuTa, 18..<21 → hoangHon, default → traDenDem
- [x] 1.3 Update the `colors: [Color]` switch to add cases for buoiSang (#F5F0E8, #EDE7D8, #E5DCC8) and chieuTa (#F2E8D8, #E8D8C0, #DCC8A8), keeping all 4 existing cases
- [x] 1.4 Add `textPrimary: Color` computed property with all 6 cases (suongSom/buoiSang #3A2A18, banNgay #2C3E4A, chieuTa #3D2A14, hoangHon #3D2410, traDenDem #F0EBE3)
- [x] 1.5 Add `textSecondary: Color` computed property returning `textPrimary` at the documented per-slot opacity (suongSom/buoiSang 60%, banNgay/chieuTa/hoangHon 55%, traDenDem 70%)
- [x] 1.6 Add `navIconTint: Color` computed property for all 6 slots
- [x] 1.7 Add `glowCenter: UnitPoint`, `glowColor: Color`, `glowRadius: CGFloat` computed properties for all 6 slots using the documented values
- [x] 1.8 Add `mistColor: Color`, `mistOpacity: Double`, `mistCount: Int` computed properties for all 6 slots using the documented values
- [x] 1.9 Add `dockOverlayColor: Color` and `dockOverlayOpacity: Double` computed properties for all 6 slots
- [x] 1.10 Add `cardOverlayOpacity: Double` computed property for all 6 slots (suongSom 0.55, buoiSang 0.50, banNgay 0.45, chieuTa 0.48, hoangHon 0.42, traDenDem 0.10)
- [x] 1.11 Add `smokeColor: Color`, `smokeOpacity: Double`, `glowTint: Color` computed properties for all 6 slots
- [x] 1.12 Add `greetingPhrase` cases for buoiSang ("Ngày mới tươi sáng") and chieuTa ("Chiều tà thong thả"), keeping existing 4 cases
- [x] 1.13 Update `title` switch to include buoiSang and chieuTa cases
- [x] 1.14 Remove `gradientColors` and `darkGradientColors` deprecated computed properties ← (verify: project compiles without errors; grep confirms zero references to gradientColors/darkGradientColors outside ThoiGian.swift)

## 2. Create ThoiGianViewModel

- [x] 2.1 Create file `TramThienTra/ViewModels/ThoiGianViewModel.swift` with `class ThoiGianViewModel: ObservableObject`
- [x] 2.2 Add `@Published var current: ThoiGian` initialized to `ThoiGian.current`
- [x] 2.3 Add `@Published var progress: Double` initialized by computing position within the current slot at init time
- [x] 2.4 Add a private `computeProgress() -> Double` helper that reads `Date()`, determines the current slot's start and end hours, and returns (elapsed seconds / total slot seconds) clamped to 0.0–1.0
- [x] 2.5 Add a private `Timer` property (main thread, 30-second interval) that calls `current = ThoiGian.current` and `progress = computeProgress()` on each tick
- [x] 2.6 Start the timer in `init()` and store the cancellable/timer reference to prevent deallocation
- [x] 2.7 Verify `ThoiGianViewModel` compiles and Xcode shows no warnings ← (verify: @Published updates occur on main thread; timer interval is exactly 30 s; progress resets near 0 when slot changes)

## 3. Inject ThoiGianViewModel at app root

- [x] 3.1 In `TramThienTraApp.swift`, add `@StateObject private var thoiGianViewModel = ThoiGianViewModel()` alongside `streakViewModel`
- [x] 3.2 Chain `.environmentObject(thoiGianViewModel)` on `ContentView()` after the existing `.environmentObject(streakViewModel)` call ← (verify: app launches without crash; @EnvironmentObject resolves in TraThatView, NenDongView, TraXongView, and ZenCard without runtime exceptions)

## 4. Upgrade NenDongView to 3-layer ZStack

- [x] 4.1 Add `@EnvironmentObject var thoiGianVM: ThoiGianViewModel` and `@Environment(\.accessibilityReduceMotion) var reduceMotion` to `NenDongView`; remove `@State private var currentColors` and the local `Timer.publish`
- [x] 4.2 Replace the `Rectangle` body with a `ZStack` containing three layers; wrap the whole ZStack in `.ignoresSafeArea()`
- [x] 4.3 Layer 1 — base `LinearGradient`: read `thoiGianVM.current.colors`; wrap color update in `withAnimation(.easeInOut(duration: 3.0))`; use a nested `TimelineView(.animation)` for gradient breathing drift (±6% Y on 8s sine cycle) that reads `reduceMotion` and fixes `startPoint` at `.top` when true
- [x] 4.4 Layer 2 — mist particles: add a `TimelineView(.animation)` containing a `Canvas` that draws `thoiGianVM.current.mistCount` blurred ellipses using `mistColor` at `mistOpacity`; each particle uses its index to derive an independent drift offset from `context.date.timeIntervalSinceReferenceDate`; set `opacity(reduceMotion ? 0 : 1)` on the TimelineView
- [x] 4.5 Layer 3 — radial glow: add a `TimelineView(.animation)` containing a `RadialGradient` at `thoiGianVM.current.glowCenter` with `glowColor` and radius `glowRadius`; opacity is `0.20 + 0.15 * sin(t * 2π / 12)` where `t` is elapsed seconds; freeze at 0.20 when `reduceMotion` is true
- [x] 4.6 Remove the `.onReceive(timer)` and `.onAppear` blocks from the old implementation ← (verify: all 3 layers render correctly in Preview for all 6 ThoiGian cases; reduce-motion snapshot shows only static gradient; Instruments frame rate stays above 58fps on iPhone 12 class hardware)

## 5. Adapt TraThatView

- [x] 5.1 Add `@EnvironmentObject var thoiGianVM: ThoiGianViewModel` to `TraThatView`
- [x] 5.2 Replace hardcoded greeting text foreground color with `thoiGianVM.current.textPrimary` wrapped in `withAnimation(.easeInOut(duration: 2.0))`
- [x] 5.3 Replace hardcoded app name color with `thoiGianVM.current.textPrimary` wrapped in `withAnimation(.easeInOut(duration: 2.0))`
- [x] 5.4 Replace hardcoded nav icon foreground tint with `thoiGianVM.current.navIconTint` wrapped in `withAnimation(.easeInOut(duration: 2.0))`
- [x] 5.5 Replace hardcoded dock overlay color with `thoiGianVM.current.dockOverlayColor` and opacity with `thoiGianVM.current.dockOverlayOpacity`, both wrapped in `withAnimation(.easeInOut(duration: 2.0))` ← (verify: all 6 slots render correct text and icon colors in Preview; color transition animates smoothly when slot is changed in simulation)

## 6. Adapt TraXongView

- [x] 6.1 Add `@EnvironmentObject var thoiGianVM: ThoiGianViewModel` to `TraXongView`
- [x] 6.2 Replace hardcoded smoke foreground color with `thoiGianVM.current.smokeColor` at `thoiGianVM.current.smokeOpacity`
- [x] 6.3 Replace hardcoded glow tint with `thoiGianVM.current.glowTint`; apply a 0.55 opacity multiplier when `thoiGianVM.current == .traDenDem` ← (verify: smoke renders correctly in all 6 slots in Preview; night slot glow is visually dimmer than day slot)

## 7. Adapt ZenCard

- [x] 7.1 Add `@EnvironmentObject var thoiGianVM: ThoiGianViewModel` to `ZenCard`
- [x] 7.2 Replace the hardcoded `0.55` opacity on the white overlay `RoundedRectangle` with `thoiGianVM.current.cardOverlayOpacity` wrapped in `withAnimation(.easeInOut(duration: 2.0))`
- [x] 7.3 Add `ThoiGianViewModel()` to the `#Preview` environment via `.environmentObject(ThoiGianViewModel())` ← (verify: card overlay opacity matches spec values for each slot; Preview compiles and runs without missing environment object crash)

## 8. Final integration and build validation

- [x] 8.1 Run a full project build and confirm zero errors and zero warnings introduced by this change
- [x] 8.2 Run a codebase-wide search for `gradientColors` and `darkGradientColors` to confirm no remaining references
- [x] 8.3 Verify `ThoiGian.current` resolves to the correct slot for each of the 6 hour-range boundaries using a unit test or manual validation in a Playground
- [x] 8.4 Confirm reduce-motion accessibility path: enable Reduce Motion in iOS Simulator, launch the app, and verify no looping animations are visible while gradient slot-change transitions still work ← (verify: build is clean, no deprecated alias references exist, reduce-motion path confirmed, all 6 slot visuals match design spec screenshots)
