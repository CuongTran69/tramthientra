import Foundation
import SwiftUI

// MARK: - SPEC §4.1 Time-of-day enum with three-stop gradient color mapping

enum ThoiGian: Int, CaseIterable {
    case suongSom = 0   // 5:00 – 11:59
    case banNgay = 1    // 12:00 – 17:59
    case hoangHon = 2   // 18:00 – 20:59
    case traDenDem = 3  // 21:00 –  4:59

    static var current: ThoiGian {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:   return .suongSom
        case 12..<18:  return .banNgay
        case 18..<21:  return .hoangHon
        default:       return .traDenDem
        }
    }

    /// Three-stop gradient colors for this time slot.
    /// All consumers must use exactly these three stops via LinearGradient(colors:startPoint:endPoint:).
    var colors: [Color] {
        switch self {
        case .suongSom:
            return [Color(hex: "FDF8F3"), Color(hex: "F5EDE4"), Color(hex: "EDE3D6")]
        case .banNgay:
            return [Color(hex: "E8F0F2"), Color(hex: "D4E5EB"), Color(hex: "C1D9E3")]
        case .hoangHon:
            return [Color(hex: "F9EDE3"), Color(hex: "F0DFD0"), Color(hex: "E5CEB8")]
        case .traDenDem:
            // Darkest stop is #141318 — not pure black, preserves shadow detail
            return [Color(hex: "2D2B3A"), Color(hex: "1F1D28"), Color(hex: "141318")]
        }
    }

    /// Deprecated: use `colors` (three-stop). Kept for backward compatibility.
    var gradientColors: [Color] { colors }

    var title: String {
        switch self {
        case .suongSom:  return "Sáng sớm"
        case .banNgay:   return "Ban ngày"
        case .hoangHon:  return "Hoàng hôn"
        case .traDenDem: return "Trà đêm"
        }
    }
}

// MARK: - Color hex extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
