## Why

The UI/UX redesign is complete but five critical functional gaps prevent the app from working end-to-end: the streak counter never increments, notifications silently fail to schedule, background sync never runs on launch, the breathing feature is unreachable from navigation, and two unused SPM dependencies bloat the binary. These wiring issues must be resolved before the app can ship.

## What Changes

- Wire `StreakViewModel.incrementStreak()` into `TichLuyViewModel.saveGratitude()` so the streak advances on each successful save
- Add a `.task {}` modifier in `TramThienTraApp` that calls `SyncService.shared.syncAllPending()` on launch when a user session exists
- Fix notification scheduling in `SettingsView` to call `requestAuthorization()` before `scheduleDailyReminder()`, and make `requestAuthorization()` async in `NotificationService`
- Create `ThienThoView.swift` wrapping `BreathingCircleView` with `ThienThoViewModel`, and add a "Thiền Thở" button in `TraThatView` that presents it via `.fullScreenCover`
- Remove `SnapKit` and `Kingfisher` from `project.yml` packages and target dependencies
- Delete stale top-level `/Views/` and `/Utilities/` directories which are outside the XcodeGen source path and are never compiled

## Capabilities

### New Capabilities
- `thientho-screen`: ThienTho breathing exercise screen with navigation entry point from TraThatView, wrapping the existing BreathingCircleView component

### Modified Capabilities
- None

## Impact

- Files created: `TramThienTra/Views/ThienTho/ThienThoView.swift`
- Files modified: `TramThienTra/App/TramThienTraApp.swift`, `TramThienTra/ViewModels/TichLuyViewModel.swift`, `TramThienTra/Views/TichLuy/TichLuyView.swift`, `TramThienTra/Views/Settings/SettingsView.swift`, `TramThienTra/Services/NotificationService.swift`, `TramThienTra/Views/TraThat/TraThatView.swift`, `project.yml`
- Files deleted: top-level `Views/` and `Utilities/` directories
- No new external dependencies introduced
- No data model schema changes
