import Foundation
import SwiftUI
import UIKit

// MARK: - SPEC §3.1 App-wide constants

enum Constants {
    // Bundle
    static let bundleId = "com.tramthientra.app"

    // API
    static let apiBaseURL = "https://api.tramthientra.com"

    // UserDefaults keys
    static let streakKey = "streak_count"
    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    static let dailyReminderEnabledKey = "dailyReminderEnabled"

    // Limits
    static let maxGratitudeItems = 3
    static let maxCharacterLimit = 300

    // Notification
    static let notificationHour = 21
    static let notificationMinute = 0

    // Pagination
    static let historyPageSize = 20
}

// MARK: - Color Hex Extension
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

// MARK: - Design System: ZenColor token namespace

/// All brand colors for the app. No view file should contain a hardcoded hex string
/// or inline Color(hex:) call — always reference a named token from this namespace.
enum ZenColor {
    /// Warm tea brown — used for body text and teapot illustrations (#4A3728)
    static let zenBrown = Color(hex: "#4A3728")
    /// Deep tea brown — used for button gradients and strong accents (#3A2A18)
    static let zenBrownDark = Color(hex: "#3A2A18")
    /// Muted sage green — primary accent, focus rings, icon tints (#6B8F6B)
    static let zenSage = Color(hex: "#6B8F6B")
    /// Light sage — secondary accent, subtle backgrounds (#9DB89D)
    static let zenSageLight = Color(hex: "#9DB89D")
    /// Warm gold — decorative elements only, never body text (#D4A574)
    static let zenGold = Color(hex: "#D4A574")
    /// Warm cream — light background base (#F5EDE4)
    static let zenCream = Color(hex: "#F5EDE4")

    // MARK: Tea-leaf stage tokens
    /// Early sprout stage fill (#8AAE7A)
    static let zenTeaSpring = Color(hex: "#8AAE7A")
    /// Young bud stage fill (#7BA27B)
    static let zenTeaLight = Color(hex: "#7BA27B")
    /// Mature leaf stage fill (#5A7F5A)
    static let zenTeaDeep = Color(hex: "#5A7F5A")
    /// Master stage fill (#4D7A4D)
    static let zenTeaRich = Color(hex: "#4D7A4D")
    /// Vein detail lines on leaf shapes (#4A6B4A)
    static let zenTeaVein = Color(hex: "#4A6B4A")
    /// Desaturated color for broken streaks (#8A7A60)
    static let zenTeaWilted = Color(hex: "#8A7A60")
    /// Warm night-gold — traDenDem background tint (#C8A882)
    static let zenNightGold = Color(hex: "#C8A882")
}

// MARK: - Text / background color helpers (adaptive to light & dark mode)
extension Color {
    static let zenPrimaryText = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#F5F5F5") : UIColor(hex: "#2C2C2C")
    })

    static let zenSecondaryText = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#AAAAAA") : UIColor(hex: "#6B6B6B")
    })

    static let zenCardBackground = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(white: 1.0, alpha: 0.1) : UIColor(white: 1.0, alpha: 0.2)
    })

    static let zenDivider = Color.white.opacity(0.15)
}

// MARK: - Design System: ZenFont typography scale

/// Centralized typography scale. Each level returns a `Font` value.
/// Use letter-spacing modifiers on Text via `.zenTracking()` for uppercase labels.
enum ZenFont {
    /// 40 pt serif bold — app title display
    static func display() -> Font {
        .system(size: 40, weight: .bold, design: .serif)
    }

    /// 28 pt serif semibold — screen titles
    static func title() -> Font {
        .system(size: 28, weight: .semibold, design: .serif)
    }

    /// 17 pt default semibold — section headlines
    static func headline() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    /// 15 pt default medium — subheadlines
    static func subheadline() -> Font {
        .system(size: 15, weight: .medium, design: .default)
    }

    /// 16 pt default regular — body text
    static func body() -> Font {
        .system(size: 16, weight: .regular, design: .default)
    }

    /// 13 pt default regular — captions and section headers
    static func caption() -> Font {
        .system(size: 13, weight: .regular, design: .default)
    }

    /// 11 pt default regular — supplementary labels, character counters
    static func caption2() -> Font {
        .system(size: 11, weight: .regular, design: .default)
    }
}

// MARK: - ZenFont View Modifier Helpers

extension View {
    /// Applies display font (40 pt serif bold)
    func zenDisplay() -> some View {
        self.font(ZenFont.display())
    }

    /// Applies title font (28 pt serif semibold)
    func zenTitle() -> some View {
        self.font(ZenFont.title())
    }

    /// Applies headline font (17 pt semibold)
    func zenHeadline() -> some View {
        self.font(ZenFont.headline())
    }

    /// Applies subheadline font (15 pt medium)
    func zenSubheadline() -> some View {
        self.font(ZenFont.subheadline())
    }

    /// Applies body font (16 pt regular)
    func zenBody() -> some View {
        self.font(ZenFont.body())
    }

    /// Applies caption font (13 pt regular)
    func zenCaption() -> some View {
        self.font(ZenFont.caption())
    }

    /// Applies caption2 font (11 pt regular)
    func zenCaption2() -> some View {
        self.font(ZenFont.caption2())
    }

    /// Applies 1.5 pt letter spacing — use on uppercase section header labels
    func zenTracking() -> some View {
        self.tracking(1.5)
    }
}

// MARK: - Legacy ZenTypography (kept for backward compatibility during migration)

struct ZenTypography {
    static func largeTitle() -> Font {
        .system(size: 34, weight: .bold, design: .serif)
    }

    static func title() -> Font {
        ZenFont.title()
    }

    static func headline() -> Font {
        ZenFont.headline()
    }

    static func body() -> Font {
        ZenFont.body()
    }

    static func caption() -> Font {
        ZenFont.caption()
    }
}

extension View {
    func zenLargeTitle() -> some View {
        self.font(ZenTypography.largeTitle())
    }
}
