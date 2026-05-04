## Context

TramThienTra is a Vietnamese Buddhist mindfulness iOS app built with SwiftUI. It currently offers three practice screens accessible from the main TraThatView dock: Biet On (gratitude journaling), Buong Bo (letting go), and Thien Tho (breathing meditation). Each screen follows a consistent architectural pattern: a dedicated ViewModel (ObservableObject), a full-screen View presented via `.fullScreenCover`, and shared design-system components (NenDongView, ZenScreenHeader, ZenCard, ZenTextField, NutGiotNuocView, ZenFont, ZenColor).

The app uses a time-adaptive theming system via ThoiGianViewModel, which provides colors and gradients that shift throughout the day. All views consume this via `@EnvironmentObject`.

This change adds a fourth practice screen: Phong Sam Hoi (Repentance Room), which introduces a tabbed interface (a first for the app) combining guided repentance writing with sutra reading.

## Goals / Non-Goals

**Goals:**
- Provide a guided repentance writing experience following the six-sense Buddhist framework
- Include a sutra reading tab for the Sam Hoi Sau Can (Six-Sense Repentance) text
- Maintain full consistency with existing design patterns (BuongBoView architecture, design system components)
- Guarantee privacy: no data persistence whatsoever
- Support accessibility (VoiceOver, reduceMotion, 44pt touch targets)

**Non-Goals:**
- Audio playback or chanting accompaniment for the Kinh Tung tab (future enhancement)
- Data persistence or journaling history for repentance entries
- Sharing or exporting repentance text
- Custom sutra content or user-uploaded texts
- Bookmark or progress tracking within sutras

## Decisions

### 1. Tabbed interface via Picker with .segmented style

The Sam Hoi and Kinh Tung tabs will use a SwiftUI `Picker` with `.segmented` style, not a `TabView`. This matches the compact, single-screen feel of the app and avoids introducing a new navigation paradigm. The segmented control sits below the ZenScreenHeader, keeping the visual hierarchy consistent.

**Alternative considered**: TabView with page style. Rejected because it introduces swipe-based navigation that could conflict with ScrollView gestures in the Kinh Tung tab, and the visual chrome of TabView does not match the app's minimal aesthetic.

### 2. Rotating six-sense prompts with Timer-based animation

The six prompts will rotate every 5 seconds using a SwiftUI `.onReceive(Timer.publish(...))` pattern with `.transition(.opacity)` fade animation. Only one prompt is visible at a time to avoid overwhelming the user.

**Alternative considered**: Displaying all six prompts in a vertical list. Rejected because it clutters the interface and reduces the contemplative quality of the experience. The rotating approach creates a gentle, meditative pacing.

### 3. Reuse BuongBoView animation pattern exactly

The celebration/release animation sequence (button fade -> form fade -> KhoiTanView smoke -> quote overlay -> form return) will be replicated from BuongBoView. The KhoiTanView component is already extracted and reusable. The timing constants and animation phases will match BuongBoView for consistency.

**Alternative considered**: Creating a shared animation coordinator. Rejected as premature abstraction for two screens. If a third screen needs this pattern, extraction would be warranted.

### 4. Transformation vow as a second text field

A smaller ZenTextField below the main repentance text captures the user's transformation vow ("How will you act differently?"). This is a separate field rather than a section within the main text area, making the two-part reflection structure explicit.

### 5. Sutra content as static data in the view

The Kinh Tung sutra text will be defined as static string constants within the view file. There is no need for a data model, JSON file, or Core Data entity since the content is fixed, read-only, and small (6 sections of 6 lines each).

**Alternative considered**: Loading from a JSON/plist resource file. Rejected because the content is static, small, and tightly coupled to the view's presentation. A resource file adds indirection without benefit.

### 6. Navigation entry point as a third row in the dock

The TraThatView bottom dock will gain a new full-width row below the existing 2-column row (Buong Bo | Thien Tho). The new row contains a single secondary-variant ZenButton for "Sam hoi". This preserves the existing layout while making the new feature discoverable.

## Risks / Trade-offs

- **[Dock crowding]** Adding a third row to the bottom dock increases vertical space usage. Mitigation: the button uses `variant: .secondary` and full width, keeping it visually subordinate to the primary "Biet on" button. Monitor on smaller devices (iPhone SE) for layout overflow.
- **[Tab state not persisted]** Switching away from SamHoiView and returning always resets to the Sam Hoi tab. This is acceptable for a privacy-first design where no state should persist.
- **[Sutra text accuracy]** The Sam Hoi Sau Can text is a simplified Vietnamese adaptation, not a canonical translation. The attribution line "Theo truyen thong Phat giao Viet Nam" makes this clear.
- **[Animation timing duplication]** The celebration animation timing is duplicated from BuongBoView rather than shared. If timing needs to change, both files must be updated. Acceptable trade-off for simplicity at this stage.
