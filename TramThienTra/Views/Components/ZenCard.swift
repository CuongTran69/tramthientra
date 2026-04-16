import SwiftUI

// MARK: - ZenCard glassmorphism container component
//
// Wraps content in an .ultraThinMaterial background with:
// - 20 pt padding
// - Color.white.opacity(0.1) secondary background layer (ensures legibility over dark gradients)
// - 20 pt corner radius
// - 1 pt RoundedRectangle white stroke (Color.white.opacity(0.2))
// - Drop shadow: Color.black.opacity(0.1), radius 10, offset (0, 5)
//
// Use over any time-slot gradient background. The white overlay ensures the card
// is always legible regardless of system material rendering or iOS version.

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
                    // Base: system material for blur
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                    // Secondary overlay: keeps card visible against dark gradients
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                    // Frosted border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
            }
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: ThoiGian.suongSom.colors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack(spacing: 16) {
            ZenCard {
                Text("ZenCard on light gradient")
                    .font(ZenFont.body())
                    .foregroundColor(ZenColor.zenBrown)
            }

            ZenCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card with multiple children")
                        .font(ZenFont.headline())
                        .foregroundColor(ZenColor.zenBrown)
                    Text("Secondary content inside the card.")
                        .font(ZenFont.caption())
                        .foregroundColor(ZenColor.zenBrown.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 24)
    }
}
