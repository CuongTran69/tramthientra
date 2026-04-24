## Context

The ZenTea/TramThienTra iOS app (SwiftUI, SwiftData, iOS 17+) completed a UI/UX redesign pass. All screens were rebuilt using the ZenUI design system (ZenButton, ZenTextField, ZenCard, NenDongView, ZenFont, ZenColor). The architectural pattern is ViewModel-per-screen with `@StateObject` ownership at instantiation, `@EnvironmentObject` for cross-cutting state like `StreakViewModel`, and SwiftData's `@Environment(\.modelContext)` for persistence. `SyncService` is an `actor`; `NotificationService`, `AuthService`, and `HapticService` are singleton classes.

Five integration gaps remain:

1. `StreakViewModel.incrementStreak()` exists but is never called — `TichLuyViewModel.saveGratitude()` has no reference to it.
2. `SyncService.syncAllPending(modelContext:)` exists but is never triggered at app launch.
3. `NotificationService.requestAuthorization()` is synchronous (callback-based); `SettingsView` calls `scheduleDailyReminder()` directly on toggle without first requesting authorization.
4. `ThienThoViewModel` and `BreathingCircleView` exist in `TramThienTra/Views/ThienTho/` and `TramThienTra/ViewModels/` respectively, but no `ThienThoView` screen exists, and there is no navigation path into the breathing feature.
5. `SnapKit` and `Kingfisher` are declared in `project.yml` and linked as target dependencies but are not imported anywhere in the codebase.

Additionally, stale top-level `/Views/` and `/Utilities/` directories exist at the repository root but are outside the XcodeGen source path (`TramThienTra/`) and are never compiled.

## Goals / Non-Goals

**Goals:**
- Streak counter increments exactly once per successful gratitude save
- Background sync runs automatically at launch when a user session exists
- Notification authorization is requested before any notification is scheduled
- The ThienTho breathing screen is reachable via a "Thiền Thở" button on TraThatView and follows the established visual and navigation patterns
- Binary size is reduced by removing two unused SPM packages
- Repository is cleaned of stale uncompiled source directories

**Non-Goals:**
- Changing streak persistence from UserDefaults to SwiftData
- Adding new sync triggers beyond app launch (e.g., background fetch, foreground-refresh)
- Building new breathing patterns or configuring the 4-7-8 rhythm (already implemented in ThienThoViewModel)
- Any UI redesign of existing screens

## Decisions

**D1: Streak increment via EnvironmentObject threading through TichLuyView**

`TichLuyView` already receives `StreakViewModel` through the environment (injected at the root `TramThienTraApp` level). The cleanest call site is `TichLuyView.performSave()` — after `viewModel.saveGratitude()` succeeds, call `streakViewModel.incrementStreak()`. This avoids making `TichLuyViewModel` aware of `StreakViewModel`, preserving the single-responsibility boundary: the ViewModel handles data persistence; the View coordinates the post-save side effects that involve other ViewModels.

Alternative considered: pass `StreakViewModel` into `TichLuyViewModel.saveGratitude()`. Rejected because it creates a cross-ViewModel dependency that complicates testing and breaks the existing pattern — no other ViewModel in the codebase references another ViewModel.

**D2: Launch sync via `.task {}` on ContentView**

`ContentView` in `TramThienTraApp.swift` is the earliest SwiftUI lifecycle point that has access to `@Environment(\.modelContext)`. A `.task {}` modifier fires once on first appear, is automatically cancelled if the view disappears, and runs on the cooperative thread pool — appropriate for an `actor`-isolated async call. The check `AuthService.shared.getCurrentUserId() != nil` ensures guest users do not hit the network.

Alternative considered: `onAppear` in `TramThienTraApp.body`. Rejected because `App.body` does not provide `modelContext` from the environment; it would require storing a reference to `sharedModelContainer` and accessing `mainContext` directly, which bypasses SwiftData's environment injection and creates a secondary reference path.

**D3: Make `requestAuthorization()` async/await-compatible**

`NotificationService.requestAuthorization()` currently uses a callback closure. Converting it to `async throws` using `withCheckedContinuation` lets `SettingsView` `await` authorization before scheduling. This is necessary because `scheduleDailyReminder()` must only run after the OS has granted permission — calling it without permission silently enqueues a notification that the OS will never deliver.

`SettingsView.onChange(of: dailyReminder)` will wrap the call in a `Task { await ... }` block, which is the idiomatic SwiftUI pattern for async work in a synchronous onChange closure.

**D4: ThienThoView wraps BreathingCircleView with standard screen shell**

`ThienThoView` follows the exact pattern of `TichLuyView` and `BuongBoView`: `NenDongView()` background ignoring safe area, `@StateObject private var viewModel = ThienThoViewModel()`, header bar with xmark dismiss button, and content area. The "Thiền Thở" button is added as a third `ZenButton` with `.secondary` variant (matching "Buông bỏ") in `TraThatView`'s action button stack, presented via `.fullScreenCover`.

Alternative considered: presenting as a `.sheet`. Rejected because the breathing exercise is an immersive full-screen experience. All non-settings screens in the app use `.fullScreenCover`.

**D5: Remove SPM packages by editing project.yml**

`SnapKit` and `Kingfisher` are defined in `project.yml` under `packages:` and linked in `targets.TramThienTra.dependencies`. Neither is imported in any Swift file. Removing both entries from `project.yml` and re-running `xcodegen generate` eliminates them from the Xcode project and stops them from being resolved and embedded.

## Risks / Trade-offs

- [Streak double-increment] If `performSave()` is called twice (e.g., a user taps the save button rapidly), `incrementStreak()` fires twice. Mitigation: `TichLuyView` disables the save button while `viewModel.isSaving` is true (already implemented via `.disabled(!viewModel.isFormValid || viewModel.isSaving)`), so the button cannot be activated again until the first save completes and `dismiss()` is called.

- [Async auth request blocks toggle UI] `requestAuthorization()` presents a system dialog. If the user has already denied permission, the system dialog does not appear and the call returns immediately. The `Task { await ... }` wrapper in `onChange` is non-blocking from the UI perspective, so the toggle appears to respond instantly even while the auth request is in flight.

- [SyncService actor isolation and modelContext] `SyncService.syncAllPending(modelContext:)` is declared on an `actor`. The `modelContext` from `@Environment(\.modelContext)` is `@MainActor`-bound. Passing it across actor boundaries must be done carefully. Since `modelContext` is a reference type that is not `Sendable`, the call must happen on the actor that owns the context. The `.task {}` modifier runs on the main actor by default, so passing `modelContext` to `syncAllPending` is safe as long as `SyncService` fetches within its own actor and does not retain the context.

- [Stale directory deletion] Deleting `/Views/` and `/Utilities/` at the repository root is irreversible without git. Since the branch is clean and these paths are not in the XcodeGen source path, there is no compilation risk. Mitigation: confirm with `git status` after deletion that no tracked files were removed unexpectedly.
