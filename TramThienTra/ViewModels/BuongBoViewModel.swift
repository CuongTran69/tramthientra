import Foundation
import SwiftUI

// MARK: - SPEC §3.3 ViewModel — Buông bỏ text release

@MainActor
final class BuongBoViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var isReleasing: Bool = false

    /// Triggers the release animation and clears text — NO data is saved.
    /// Privacy is guaranteed: this view never persists anything.
    func releaseAndDismiss() async {
        isReleasing = true
        // Animation duration is handled by the view; this VM just manages state.
        // After the animation completes the view should clear text.
        try? await Task.sleep(nanoseconds: 2_500_000_000) // ~2.5s
        text = ""
        isReleasing = false
    }
}