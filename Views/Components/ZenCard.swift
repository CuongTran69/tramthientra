import SwiftUI

// MARK: - ZenCard glassmorphism container component
//
// Wraps content in an .ultraThinMaterial background with:
// - 20 pt padding
// - Color.white.opacity(0.1) secondary background layer (ensures legibility over dark gradients)
// - 20 pt corner radius
// - 1 pt RoundedRectangle white stroke (Color.white.opacity(0.2))
// - Drop shadow: Color.black.opacity(0.1), radius 10, offset (0, 5)

struct ZenCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
            }
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
