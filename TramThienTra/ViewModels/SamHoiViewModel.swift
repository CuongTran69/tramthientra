import Foundation
import SwiftUI

// MARK: - Sam Hoi Tab Enum

enum SamHoiTab: String, CaseIterable {
    case samHoi = "Sám hối"
    case kinhTung = "Kinh tụng"
}

// MARK: - SamHoiViewModel — Repentance text release

@MainActor
final class SamHoiViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var vowText: String = ""
    @Published var isReleasing: Bool = false
    @Published var selectedTab: SamHoiTab = .samHoi

    /// Whether the user can submit: repentance text is non-empty and not currently releasing.
    var canSubmit: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isReleasing
    }

    /// Triggers the release animation and clears both text fields — NO data is saved.
    /// Privacy is guaranteed: this view never persists anything.
    func releaseAndDismiss() async {
        isReleasing = true
        // Animation duration is handled by the view; this VM just manages state.
        try? await Task.sleep(nanoseconds: 2_500_000_000) // ~2.5s
        text = ""
        vowText = ""
        isReleasing = false
    }
}
