# Proposal: ios-xcode-bootstrap

## Change Overview

| Field | Value |
|---|---|
| **Change name** | `ios-xcode-bootstrap` |
| **Change type** | Infrastructure / Project Bootstrap |
| **Author** | Claude Opus 4.6 |
| **Date** | 2026-04-16 |
| **Spec reference** | `SPEC.md` §1, §3.1, §4 |
| **Status** | Proposed |

---

## 1. Executive Summary

Bootstrap a greenfield XcodeGen-powered iOS project for **Trạm Thiền Trà** — a Vietnamese mindfulness/meditation iOS app built with SwiftUI, SwiftData, and MVVM + Clean Architecture. The directory is empty (only `SPEC.md` exists). This change creates the full project scaffold, all stub Swift files, `project.yml`, and a verified build via `xcodebuild`.

---

## 2. Context & Motivation

- The app has a clear, stable specification (`SPEC.md`) covering UI/UX, architecture, API contracts, and design language.
- No existing iOS project files are present — this is a greenfield setup.
- All key architectural decisions have been pre-approved (see §4 below).
- Subsequent changes will implement features incrementally against this scaffold.
- A reproducible, CI-friendly bootstrap is required before any feature work begins.

---

## 3. Key Decisions (Pre-Approved)

These decisions are confirmed by the change requester and documented in `SPEC.md §1.1`. They are **not** to be revisited in this change.

| # | Decision | Value | Spec ref |
|---|---|---|---|
| 1 | Project generator | XcodeGen (`project.yml` YAML) | — |
| 2 | Package manager | Swift Package Manager (SPM) — no CocoaPods | — |
| 3 | Deployment target | iOS 16.0 | SPEC §3.1 |
| 4 | Architecture | MVVM + Clean Architecture (Presentation/Domain/Data/Core layers implied) | SPEC §3.1 |
| 5 | Project name | `TramThienTra` | — |
| 6 | Bundle ID | `com.tramthientra.app` | — |
| 7 | Title font | Noto Serif (fallback `.serif` iOS) | SPEC §4.2 |
| 8 | Body font | SF Pro (system) | SPEC §4.2 |
| 9 | Orientation | Portrait only | SPEC §1.1 #6 |
| 10 | Dependencies | SnapKit (SPM), Kingfisher (SPM) | SPEC §3.1 |
| 11 | Swift version | 5.9 | — |
| 12 | Schemes | Debug / Release | — |
| 13 | Test target | `TramThienTraTests` (XCTest) | — |

---

## 4. Directory Structure

All directories are created relative to the project root `/Users/cuongtran/Project/ZenTea/`.

```
TramThienTra/
├── App/
│   ├── TramThienTraApp.swift          # @main entry point + SwiftData container
│   └── AppDelegate.swift              # UIApplication lifecycle hooks (notification registration)
├── Models/
│   ├── GratitudeLog.swift             # @Model SwiftData — synced flag, date, items[]
│   └── AppUser.swift                  # @Model SwiftData — appleUserId, apnsToken, createdAt
├── ViewModels/
│   ├── TraThatViewModel.swift         # Main screen state, streak, navigation
│   ├── TichLuyViewModel.swift         # Gratitude entry form, save, validation
│   ├── BuongBoViewModel.swift         # Release text, clear logic
│   └── StreakViewModel.swift          # Streak calculation, phase mapping
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift       # 3-page swipeable, skip button, hasCompletedOnboarding
│   ├── TraThat/
│   │   ├── TraThatView.swift          # Main screen — teapot canvas, nav buttons, streak bar
│   │   └── TraXongView.swift          # Ấm trà + khói: TimelineView + Canvas, 5-8 smoke particles
│   ├── TichLuy/
│   │   ├── TichLuyView.swift          # 3 TextField form (300-char limit each), save button
│   │   └── NutGiotNuocView.swift       # Animated drop: spring 0.5s, ripple easeOut 0.4s
│   ├── BuongBo/
│   │   ├── BuongBoView.swift           # TextEditor + Buông button
│   │   └── KhoiTanView.swift          # Smoke fade: easeInOut 2.0s, opacity 1→0, scale 1→1.3, blur 0→3
│   ├── History/
│   │   ├── HistoryView.swift          # List, swipe-to-delete, empty state
│   │   └── HistoryDetailView.swift    # Full entry detail
│   ├── Settings/
│   │   └── SettingsView.swift         # Notifications toggle, Sign in/out, Privacy Policy, Version
│   └── Components/
│       ├── NenDongView.swift          # DynamicBackground: 4 time slots, 2s easeInOut transition
│       ├── CayThienView.swift         # 5-stage leaf/streak viz: phase-based 0.6s animation
│       └── AppleDangNhapView.swift    # Sign in with Apple button
├── Services/
│   ├── AuthService.swift              # Sign in with Apple, JWT handling
│   ├── SyncService.swift              # Guest→login migration, background sync, retry 3x
│   ├── NotificationService.swift      # Local notification scheduling (21:00 daily), APNs token reg
│   └── HapticService.swift            # UIImpactFeedbackGenerator wrappers
├── Utilities/
│   ├── ThoiGian.swift                 # ThoiGian enum (4 slots), gradient color mapping, light/dark
│   └── Constants.swift                 # Bundle ID, UserDefaults keys, char limits, API base
└── Resources/
    ├── Assets.xcassets/               # AccentColor, DynamicBackground (light/dark sets)
    │   ├── AccentColor.colorset/
    │   └── DynamicBackground.colorset/ # 4 appearance variants per time slot
    └── droplet.wav                      # Sound asset placeholder (tiếng nước nhỏ)
```

> **Note:** `AppDelegate.swift` is included for notification registration hooks even though the app is SwiftUI-first. `Core/` and `Domain/`/`Data/` layers are not stubbed in this change — they are folded into the existing structure per SPEC §3.1.

---

## 5. XcodeGen `project.yml` Specification

```yaml
name: TramThienTra
options:
  bundleIdPrefix: com.tramthientra
  deploymentTarget:
    iOS: "16.0"
  xcodeVersion: "15.0"
  generateEmptyDirectories: true

settings:
  base:
    SWIFT_VERSION: "5.9"
    TARGETED_DEVICE_FAMILY: "1"
    INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents: YES
    INFOPLIST_KEY_UILaunchScreen_Generation: YES
    INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait

packages:
  SnapKit:
    url: https://github.com/SnapKit/SnapKit.git
    from: "5.7.0"
  Kingfisher:
    url: https://github.com/onevcat/Kingfisher.git
    from: "7.10.0"

targets:
  TramThienTra:
    type: application
    platform: iOS
    sources:
      - path: TramThienTra
        excludes:
          - "**/.DS_Store"
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.tramthientra.app
        MARKETING_VERSION: "1.0.0"
        CURRENT_PROJECT_VERSION: "1"
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        CODE_SIGN_STYLE: Automatic
        DEVELOPMENT_TEAM: ""
        ENABLE_PREVIEWS: YES
    dependencies:
      - package: SnapKit
      - package: Kingfisher
    info:
      path: TramThienTra/Info.plist
      properties:
        CFBundleDisplayName: Trạm Thiền Trà
        CFBundleName: TramThienTra
        UILaunchScreen: {}
        NSUserActivityTypes: []
    entitlements:
      path: TramThienTra/TramThienTra.entitlements
      properties:
        com.apple.developer.applesignin:
          - Default
        aps-environment: development

  TramThienTraTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: TramThienTraTests
    dependencies:
      - target: TramThienTra
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.tramthientra.app.tests

schemes:
  TramThienTra:
    build:
      targets:
        TramThienTra: all
        TramThienTraTests: [test]
    run:
      config: Debug
    test:
      config: Debug
      targets:
        - TramThienTraTests
    profile:
      config: Release
    analyze:
      config: Debug
    archive:
      config: Release
```

### Files to create alongside `project.yml`

| File | Purpose |
|---|---|
| `TramThienTra/Info.plist` | Generated by XcodeGen; manual override only if needed |
| `TramThienTra/TramThienTra.entitlements` | `com.apple.developer.applesignin: [Default]`, `aps-environment: development` |
| `TramThienTraTests/TramThienTraTests.swift` | XCTestCase stub with one passing test |

---

## 6. Task Breakdown

> All tasks are sequential infrastructure setup. Feature implementation is out of scope.

### Task 1 — Create directory structure

```bash
mkdir -p TramThienTra/{App,Models,ViewModels,Views/{Onboarding,TraThat,TichLuy,BuongBo,History,Settings,Components},Services,Utilities,Resources/Assets.xcassets/{AccentColor.colorset,AppIcon.appiconset,DynamicBackground.colorset}}
mkdir -p TramThienTraTests
```

### Task 2 — Create `project.yml`

Write the file defined in §5 above at the project root.

### Task 3 — Create Swift stub files

Each file contains:
- The appropriate `@main`, `@Model`, `@StateObject`, or `@Observable` declaration
- A `// MARK:` block referencing the SPEC.md section it implements
- A `// TODO:` comment pointing to the feature spec to implement later
- No real business logic — only structure and comments

Key stub details:

| File | Key content |
|---|---|
| `TramThienTraApp.swift` | `@main App`, `ModelContainer` setup, `hasCompletedOnboarding` check → route |
| `AppDelegate.swift` | `UIApplicationDelegate`, `registerForRemoteNotifications` stub |
| `GratitudeLog.swift` | `@Model class GratitudeLog`: `id: UUID`, `date: Date`, `items: [String]`, `synced: Bool`, `@Attribute(.unique)复合索引` |
| `AppUser.swift` | `@Model class AppUser`: `id: UUID`, `appleUserId: String`, `apnsToken: String?`, `createdAt: Date` |
| `TraThatViewModel.swift` | `@Observable class TraThatViewModel`: streak, currentTimeSlot, navigation state |
| `TichLuyViewModel.swift` | `@Observable class TichLuyViewModel`: items[3], validation, save(), haptic + sound |
| `BuongBoViewModel.swift` | `@Observable class BuongBoViewModel`: releaseText, buong() → clear + animation trigger |
| `StreakViewModel.swift` | `@Observable class StreakViewModel`: calculateStreak(), streakPhase enum (5 stages) |
| `OnboardingView.swift` | SwiftUI `TabView(PageTabViewStyle)`, 3 pages, skip button, `hasCompletedOnboarding = true` |
| `TraThatView.swift` | Main layout: settings top-left, history top-right, `TraXongView` center, TichLuy/BuongBo buttons, `CayThienView` |
| `TraXongView.swift` | `TimelineView(.animation)` + `Canvas`, teapot path, 5-8 smoke particles looping 0.8s |
| `TichLuyView.swift` | 3 × `TextField(300-char)`, animated save button (`NutGiotNuocView`) |
| `NutGiotNuocView.swift` | `spring` drop animation (0.5s) + ripple `easeOut` (0.4s, scale 1→1.5, opacity 1→0) |
| `BuongBoView.swift` | `TextEditor`, "Buông" button → calls `KhoiTanView` fade animation |
| `KhoiTanView.swift` | `easeInOut` 2.0s: opacity 1→0, scale 1→1.3, blur 0→3 |
| `HistoryView.swift` | `List`, swipe-delete, empty state, infinite scroll (20 per page) |
| `HistoryDetailView.swift` | Date header + full 3 gratitude items |
| `SettingsView.swift` | Toggle notifications, `AppleDangNhapView`, privacy policy link, version |
| `NenDongView.swift` | `ThoiGian` → `LinearGradient`, 4 time slots, `withAnimation(.easeInOut(duration: 2))` |
| `CayThienView.swift` | 5 phase shapes (Seed, Sprout, YoungLeaf, GreenTree, GreatTree), phase-based 0.6s animation |
| `AppleDangNhapView.swift` | `SignInWithAppleButton`, `ASAuthorizationAppleIDCredential` handling |
| `AuthService.swift` | Full Sign in with Apple flow, JWT decode stub |
| `SyncService.swift` | Guest→login migration, background sync, 3× retry with `syncPending` flag |
| `NotificationService.swift` | `UNUserNotificationCenter`, request permission, schedule daily 21:00 |
| `HapticService.swift` | `UIImpactFeedbackGenerator(.light/.medium)`, `UINotificationFeedbackGenerator` |
| `ThoiGian.swift` | `enum ThoiGian`: `suongSom`, `banNgay`, `hoangHon`, `traDenDem` + `gradientColors(for:)` |
| `Constants.swift` | `bundleId`, `apiBase`, `userDefaultsKeys`, `charLimit = 300`, `entriesPerPage = 20` |

### Task 4 — Create asset catalogs

| Asset | Content |
|---|---|
| `Assets.xcassets/AccentColor.colorset/Contents.json` | `#8FBC8F` (Trà xanh nhạt) |
| `Assets.xcassets/DynamicBackground.colorset/Contents.json` | Placeholder; actual multi-appearance sets handled in code via `ThoiGian` |
| `Assets.xcassets/AppIcon.appiconset/Contents.json` | Placeholder (App Icon out of scope per SPEC §1.1 #5) |
| `Resources/droplet.wav` | Empty placeholder file |

### Task 5 — Run XcodeGen

```bash
xcodegen generate
```

Verify `TramThienTra.xcodeproj` exists.

### Task 6 — Build verification

```bash
xcodebuild \
  -project TramThienTra.xcodeproj \
  -scheme TramThienTra \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

**Expected outcome:** `BUILD SUCCEEDED` — zero compile errors, zero linker errors.

> **Known acceptable conditions at this stage:**
> - SwiftData `@Model` macro emits "no schema" warnings until real properties are wired
> - Asset catalog may show missing image warnings
> - `droplet.wav` placeholder will log a benign missing-asset warning — it will be replaced in a sound asset change

---

## 7. Verification & Acceptance Criteria

| # | Criterion | Method |
|---|---|---|
| AC1 | `TramThienTra.xcodeproj` exists in project root | `ls TramThienTra.xcodeproj` |
| AC2 | All 27 Swift source files exist at the paths in §4 | Glob + count |
| AC3 | `project.yml` is valid YAML and references iOS 16.0, Swift 5.9, SnapKit, Kingfisher | Manual review |
| AC4 | `xcodebuild build` exits with code 0 on iPhone 16 Simulator | CI / manual run |
| AC5 | No Swift compile errors in the stub files | Build log review |
| AC6 | `TramThienTraTests` target is present and has one passing test | `xcodebuild test` |

---

## 8. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| XcodeGen not installed on developer machine | Medium | Blocks build | Document `brew install xcodegen` in README or CI script |
| SPM package resolution timeout on first build | Low | Delays verification | Run `xcodebuild -resolvePackageDependencies` before full build |
| Bundle ID collision on App Store | Low | Blocks submission | `com.tramthientra.app` is namespaced; register early |
| Missing code signing team causes build warning | Low | Non-blocking | `DEVELOPMENT_TEAM: ""` in project.yml; CI sets real team |
| `droplet.wav` missing asset warning | Low | Benign | Placeholder created; replace in sound-asset change |

---

## 9. Out of Scope (Not in This Change)

- Any feature implementation (animations, SwiftData queries, API calls, notifications, Sign in with Apple flow)
- Backend (Go service)
- App Icon assets
- Privacy Policy URL
- Unit tests beyond the stub `TramThienTraTests.swift` one-pass test
- Dark mode color overrides in asset catalog (handled in code via `ThoiGian`)

---

## 10. Dependencies on This Change

This change is a **prerequisite** for all subsequent changes:

| Subsequent change | Depends on |
|---|---|
| `ios-onboarding-implementation` | AC1, AC2, AC5 |
| `ios-trathat-traxong-implementation` | AC1, AC2, AC5 |
| `ios-tichluy-form-implementation` | AC1, AC2, AC5 |
| `ios-streak-system-implementation` | AC1, AC2, AC5 |
| `ios-notification-service` | AC1, AC2, AC5 |
| `ios-auth-service` | AC1, AC2, AC5 |

---

## 11. Rollback Plan

Since this change creates new files in an empty directory:

1. **Before running xcodegen:** commit the state (empty scaffold + SPEC.md).
2. If `xcodebuild` fails on AC4, the stub files and `project.yml` are the only artifacts to remove.
3. Rollback command: `rm -rf TramThienTra TramThienTra.xcodeproj TramThienTraTests`

No existing source code is modified — rollback is safe and complete.
