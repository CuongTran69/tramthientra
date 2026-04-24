## 1. Wire Streak Increment to Save Flow

- [x] 1.1 In `TichLuyView.swift`, add `@EnvironmentObject private var streakViewModel: StreakViewModel` at the top of the struct (alongside existing `@Environment` properties)
- [x] 1.2 In `TichLuyView.performSave()`, after `await viewModel.saveGratitude(modelContext: modelContext)` succeeds and before `dismiss()`, call `streakViewModel.incrementStreak()` ← (verify: save a gratitude entry and confirm the streak counter on TraThatView increments by 1; confirm rapid double-tap is blocked by the isSaving guard)

## 2. Trigger syncAllPending on App Launch

- [x] 2.1 In `TramThienTraApp.swift`, add `@Environment(\.modelContext) private var modelContext` to `ContentView`
- [x] 2.2 Add a `.task {}` modifier to `ContentView.body`'s root view that checks `AuthService.shared.getCurrentUserId() != nil` and, if true, calls `await SyncService.shared.syncAllPending(modelContext: modelContext)` ← (verify: launch the app with an authenticated session and confirmed unsynced logs; check console output that syncAllPending runs; verify guest launch skips the call)

## 3. Fix Notification Authorization Flow

- [x] 3.1 In `NotificationService.swift`, convert `requestAuthorization()` from a callback closure to `async` using `withCheckedContinuation`, returning the granted `Bool`
- [x] 3.2 In `SettingsView.swift`, change the `onChange(of: dailyReminder)` handler to `Task { await NotificationService.shared.requestAuthorization(); NotificationService.shared.scheduleDailyReminder() }` for the `newValue == true` branch ← (verify: toggle the reminder on for the first time; confirm the system authorization dialog appears before any notification is scheduled; toggle on a device where permission was already granted and confirm scheduling succeeds without a dialog)

## 4. Create ThienThoView Screen

- [x] 4.1 Create `TramThienTra/Views/ThienTho/ThienThoView.swift` with `@StateObject private var viewModel = ThienThoViewModel()`, `@Environment(\.dismiss) private var dismiss`, a `NenDongView()` background ignoring safe area, a header bar with an xmark dismiss button (accessibilityLabel: "Đóng", accessibilityHint: "Đóng màn hình thiền thở"), and `BreathingCircleView(phase: viewModel.currentPhase, progress: viewModel.phaseProgress, isRunning: viewModel.isRunning)` centered in the content area
- [x] 4.2 Add start/pause button in ThienThoView that calls `viewModel.toggleSession()` and a cycle counter text showing `viewModel.cycleText` when non-empty
- [x] 4.3 In `TraThatView.swift`, add `@State private var showThienTho = false` alongside existing state variables
- [x] 4.4 In `TraThatView.swift`, add a third `ZenButton("Thiền Thở", variant: .secondary, icon: "wind")` after the "Buông bỏ" button with accessibilityLabel "Thiền Thở" and accessibilityHint "Mở màn hình thiền thở", setting `showThienTho = true` in its action
- [x] 4.5 Add `.fullScreenCover(isPresented: $showThienTho) { ThienThoView() }` to `TraThatView` alongside existing fullScreenCover modifiers ← (verify: tap "Thiền Thở" from TraThatView; confirm ThienThoView appears full screen with NenDongView background; start a session and confirm the circle animates through inhale/hold/exhale phases; dismiss and confirm return to TraThatView)

## 5. Remove Unused SPM Dependencies

- [x] 5.1 In `project.yml`, delete the `SnapKit` and `Kingfisher` entries under the top-level `packages:` key (lines 18-22)
- [x] 5.2 In `project.yml`, delete the `- package: SnapKit` and `- package: Kingfisher` entries under `targets.TramThienTra.dependencies` (lines 43-44)
- [x] 5.3 Run `xcodegen generate` from the project root to regenerate the Xcode project and confirm no build errors ← (verify: open the regenerated .xcodeproj; confirm SnapKit and Kingfisher are absent from Package Dependencies; build the app target and confirm it compiles cleanly)

## 6. Delete Stale Root-Level Directories

- [x] 6.1 Run `git rm -r Views/ Utilities/` from the repository root to remove the stale top-level `/Views/` and `/Utilities/` directories and stage the deletions
- [x] 6.2 Confirm with `git status` that only files from `/Views/` and `/Utilities/` are staged for deletion and no files under `TramThienTra/` are affected ← (verify: run `xcodegen generate` and build; confirm the app compiles cleanly with no missing file errors)
