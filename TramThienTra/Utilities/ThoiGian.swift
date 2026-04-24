import Foundation
import SwiftUI

// MARK: - SPEC §4.1 Time-of-day enum with three-stop gradient color mapping

enum ThoiGian: Int, CaseIterable {
    case suongSom   = 0   // 5:00  –  8:59
    case buoiSang   = 1   // 9:00  – 11:59
    case banNgay    = 2   // 12:00 – 14:59
    case chieuTa    = 3   // 15:00 – 17:59
    case hoangHon   = 4   // 18:00 – 20:59
    case traDenDem  = 5   // 21:00 –  4:59

    /// Returns the current time-of-day based on the device clock.
    static var current: ThoiGian {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<9:   return .suongSom
        case 9..<12:  return .buoiSang
        case 12..<15: return .banNgay
        case 15..<18: return .chieuTa
        case 18..<21: return .hoangHon
        default:      return .traDenDem   // 21–23 and 0–4
        }
    }

    // MARK: - Gradient colors

    /// Three-stop gradient colors for this time slot.
    /// All consumers must use exactly these three stops via LinearGradient(colors:startPoint:endPoint:).
    var colors: [Color] {
        switch self {
        case .suongSom:
            // Early morning: warm paper white → cream → light tan
            return [Color(hex: "FDF8F3"), Color(hex: "F5EDE4"), Color(hex: "EDE3D6")]
        case .buoiSang:
            // Morning: bright warm white → soft cream → light tan
            return [Color(hex: "F5F0E8"), Color(hex: "EDE7D8"), Color(hex: "E5DCC8")]
        case .banNgay:
            // Day: pale sky → light blue → muted cornflower
            return [Color(hex: "E8F0F2"), Color(hex: "D4E5EB"), Color(hex: "C1D9E3")]
        case .chieuTa:
            // Afternoon: warm cream → soft sand → deeper warm
            return [Color(hex: "F2E8D8"), Color(hex: "E8D8C0"), Color(hex: "DCC8A8")]
        case .hoangHon:
            // Dusk: warm linen → warm sand → deeper warm tan
            return [Color(hex: "F9EDE3"), Color(hex: "F0DFD0"), Color(hex: "E5CEB8")]
        case .traDenDem:
            // Night: deep plum → dark navy → near-black
            return [Color(hex: "2D2B3A"), Color(hex: "1F1D28"), Color(hex: "141318")]
        }
    }

    // MARK: - Text colors

    var textPrimary: Color {
        switch self {
        case .suongSom:  return Color(hex: "3A2A18")
        case .buoiSang:  return Color(hex: "3A2A18")
        case .banNgay:   return Color(hex: "2C3E4A")
        case .chieuTa:   return Color(hex: "3D2A14")
        case .hoangHon:  return Color(hex: "3D2410")
        case .traDenDem: return Color(hex: "F0EBE3")
        }
    }

    var textSecondary: Color {
        switch self {
        case .suongSom:  return textPrimary.opacity(0.80)
        case .buoiSang:  return textPrimary.opacity(0.80)
        case .banNgay:   return textPrimary.opacity(0.85)
        case .chieuTa:   return textPrimary.opacity(0.80)
        case .hoangHon:  return textPrimary.opacity(0.78)
        case .traDenDem: return textPrimary.opacity(0.70)
        }
    }

    // MARK: - Nav icon tint

    var navIconTint: Color {
        switch self {
        case .suongSom:  return Color(hex: "5C3D1E")
        case .buoiSang:  return Color(hex: "5C3D1E")
        case .banNgay:   return Color(hex: "2C4A5A")
        case .chieuTa:   return Color(hex: "5C3A10")
        case .hoangHon:  return Color(hex: "6B3A1A")
        case .traDenDem: return Color(hex: "C8B8A0")
        }
    }

    // MARK: - Glow parameters

    var glowCenter: UnitPoint {
        switch self {
        case .suongSom:  return UnitPoint(x: 0.5, y: 0.15)
        case .buoiSang:  return UnitPoint(x: 0.55, y: 0.12)
        case .banNgay:   return UnitPoint(x: 0.5, y: 0.10)
        case .chieuTa:   return UnitPoint(x: 0.6, y: 0.15)
        case .hoangHon:  return UnitPoint(x: 0.72, y: 0.18)
        case .traDenDem: return UnitPoint(x: 0.5, y: 0.20)
        }
    }

    var glowColor: Color {
        switch self {
        case .suongSom:  return Color(hex: "FFE8C0")
        case .buoiSang:  return Color(hex: "FFF0D0")
        case .banNgay:   return Color(hex: "D0F0FF")
        case .chieuTa:   return Color(hex: "FFD8A0")
        case .hoangHon:  return Color(hex: "FF8C42")
        case .traDenDem: return Color(hex: "8080C0")
        }
    }

    var glowRadius: CGFloat {
        switch self {
        case .suongSom:  return 0.45
        case .buoiSang:  return 0.42
        case .banNgay:   return 0.50
        case .chieuTa:   return 0.45
        case .hoangHon:  return 0.55
        case .traDenDem: return 0.40
        }
    }

    // MARK: - Mist particle parameters

    var mistColor: Color {
        switch self {
        case .suongSom:  return Color.white
        case .buoiSang:  return Color.white
        case .banNgay:   return Color(hex: "E8F4FC")
        case .chieuTa:   return Color(hex: "FFF4E0")
        case .hoangHon:  return Color(hex: "FFE4C0")
        case .traDenDem: return Color(hex: "C0C0E0")
        }
    }

    var mistOpacity: Double {
        switch self {
        case .suongSom:  return 0.28
        case .buoiSang:  return 0.22
        case .banNgay:   return 0.18
        case .chieuTa:   return 0.22
        case .hoangHon:  return 0.30
        case .traDenDem: return 0.20
        }
    }

    var mistCount: Int {
        switch self {
        case .suongSom:  return 8
        case .buoiSang:  return 6
        case .banNgay:   return 4
        case .chieuTa:   return 5
        case .hoangHon:  return 7
        case .traDenDem: return 3
        }
    }

    // MARK: - Dock overlay

    var dockOverlayColor: Color {
        switch self {
        case .suongSom:  return Color(hex: "F5EFE0")
        case .buoiSang:  return Color(hex: "F0EAD8")
        case .banNgay:   return Color(hex: "E8F2F8")
        case .chieuTa:   return Color(hex: "F5E8D0")
        case .hoangHon:  return Color(hex: "F0DEC8")
        case .traDenDem: return Color(hex: "1A1828")
        }
    }

    var dockOverlayOpacity: Double {
        switch self {
        case .suongSom:  return 0.32
        case .buoiSang:  return 0.30
        case .banNgay:   return 0.28
        case .chieuTa:   return 0.30
        case .hoangHon:  return 0.25
        case .traDenDem: return 0.08
        }
    }

    // MARK: - Card overlay

    var cardOverlayOpacity: Double {
        switch self {
        case .suongSom:  return 0.55
        case .buoiSang:  return 0.50
        case .banNgay:   return 0.45
        case .chieuTa:   return 0.48
        case .hoangHon:  return 0.42
        case .traDenDem: return 0.10
        }
    }

    // MARK: - Streak text colors

    var streakTextPrimary: Color {
        switch self {
        case .traDenDem: return .white
        default: return Color(hex: "3A2A18")
        }
    }

    var streakTextSecondary: Color {
        switch self {
        case .traDenDem: return Color.white.opacity(0.70)
        default: return Color(hex: "3A2A18").opacity(0.65)
        }
    }

    // MARK: - Smoke appearance

    var smokeColor: Color {
        switch self {
        case .suongSom:  return Color(hex: "C8B090")
        case .buoiSang:  return Color.white
        case .banNgay:   return Color.white
        case .chieuTa:   return Color(hex: "D0B080")
        case .hoangHon:  return Color(hex: "C0804A")
        case .traDenDem: return Color(hex: "8080A8")
        }
    }

    var smokeOpacity: Double {
        switch self {
        case .suongSom:  return 0.15
        case .buoiSang:  return 0.14
        case .banNgay:   return 0.12
        case .chieuTa:   return 0.14
        case .hoangHon:  return 0.18
        case .traDenDem: return 0.22
        }
    }

    var glowTint: Color {
        switch self {
        case .suongSom:  return Color(hex: "D4A855")
        case .buoiSang:  return Color(hex: "D4A855")
        case .banNgay:   return Color(hex: "A0C8D8")
        case .chieuTa:   return Color(hex: "D4904A")
        case .hoangHon:  return Color(hex: "D4663A")
        case .traDenDem: return Color(hex: "7878B8")
        }
    }

    // MARK: - Display text

    var title: String {
        switch self {
        case .suongSom:  return "Sáng sớm"
        case .buoiSang:  return "Buổi sáng"
        case .banNgay:   return "Ban ngày"
        case .chieuTa:   return "Chiều tà"
        case .hoangHon:  return "Hoàng hôn"
        case .traDenDem: return "Trà đêm"
        }
    }

    /// Time-contextual greeting phrase shown on the Home screen.
    var greetingPhrase: String {
        switch self {
        case .suongSom:  return "Buổi sáng an lành"
        case .buoiSang:  return "Ngày mới tươi sáng"
        case .banNgay:   return "Trà chiều tĩnh lặng"
        case .chieuTa:   return "Chiều tà thong thả"
        case .hoangHon:  return "Hoàng hôn nhẹ nhàng"
        case .traDenDem: return "Đêm trà thư giãn"
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
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
