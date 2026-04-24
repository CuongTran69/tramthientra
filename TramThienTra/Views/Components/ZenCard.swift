import SwiftUI

// MARK: - ZenCard glassmorphism container component
//
// Wraps content in an .ultraThinMaterial background with:
// - 20 pt padding
// - Color.white at cardOverlayOpacity (time-slot driven) secondary background layer
// - 20 pt corner radius
// - 1 pt RoundedRectangle white stroke with gradient
// - Drop shadow: Color.black.opacity(0.1), radius 10, offset (0, 5)
//
// Use over any time-slot gradient background. The white overlay opacity changes per
// slot via ThoiGianViewModel environment object and animates with 2s easeInOut.

struct ZenCard<Content: View>: View {
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel
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
                    // Secondary overlay: white wash with slot-driven opacity
                    RoundedRectangle(cornerRadius: 20)
                        .fill(thoiGianVM.current.cardOverlayColor.opacity(thoiGianVM.current.cardOverlayOpacity))
                        .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                    // Subtle inner highlight along the top edge
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    thoiGianVM.current.cardStrokeTop,
                                    thoiGianVM.current.cardStrokeBottom
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
            }
            // Layered shadow: close tight shadow + soft wider ambient
            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
            .shadow(color: ZenColor.zenBrown.opacity(0.08), radius: 18, x: 0, y: 8)
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
    .environmentObject(ThoiGianViewModel())
}
