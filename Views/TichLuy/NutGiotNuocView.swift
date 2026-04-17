import SwiftUI
import AVFoundation

// MARK: - SPEC §2.3 Animated drop button — spring + pulsing gold glow ring (redesigned)
// Glow ring: Circle overlay animating opacity 0→0.35→0 and scale 1.0→1.3→1.0 over 1.8s repeating.
// Reduce-motion: glow ring shows as a static low-opacity ring, no animation.

struct NutGiotNuocView: View {
    let isEnabled: Bool
    let action: () -> Void
    @State private var isPressed = false
    @State private var rippleScale: CGFloat = 1
    @State private var rippleOpacity: Double = 0
    @State private var glowScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Pulsing gold glow ring
            Circle()
                .stroke(ZenColor.zenGold, lineWidth: 2)
                .frame(width: 70, height: 70)
                .scaleEffect(glowScale)
                .opacity(reduceMotion ? 0.12 : glowOpacity) // static low-opacity ring under reduce-motion
                .animation(nil, value: reduceMotion) // don't animate the reduce-motion switch itself

            // Ripple circle (tap feedback)
            Circle()
                .fill(ZenColor.zenSage.opacity(0.3))
                .frame(width: 70, height: 70)
                .scaleEffect(rippleScale)
                .opacity(rippleOpacity)

            // Main drop button
            Image(systemName: "drop.fill")
                .font(.system(size: 28))
                .foregroundColor(isEnabled ? ZenColor.zenSage : ZenColor.zenSage.opacity(0.3))
                .frame(width: 64, height: 64)
                .background(Color.white)
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.85 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isPressed)
        }
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Circle())
        .onTapGesture {
            guard isEnabled else { return }
            isPressed = true

            _ = try? AVAudioSession.sharedInstance().setActive(true)

            // Ripple animation
            withAnimation(.easeOut(duration: 0.4)) {
                rippleScale = 1.5
                rippleOpacity = 0
            }

            action()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                rippleScale = 1
                rippleOpacity = 0
                isPressed = false
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            startGlowRingAnimation()
        }
        .onChange(of: reduceMotion) { _, newValue in
            if newValue {
                // Stop animation — show static ring
                glowScale = 1.0
                glowOpacity = 0.0
            } else {
                startGlowRingAnimation()
            }
        }
    }

    // MARK: - Glow ring: 1.8s ease-in-out repeating pulse
    // opacity 0 → 0.35 → 0, scale 1.0 → 1.3 → 1.0

    private func startGlowRingAnimation() {
        glowOpacity = 0.0
        glowScale = 1.0
        withAnimation(
            .easeInOut(duration: 1.8)
            .repeatForever(autoreverses: true)
        ) {
            glowOpacity = 0.35
            glowScale = 1.3
        }
    }
}
