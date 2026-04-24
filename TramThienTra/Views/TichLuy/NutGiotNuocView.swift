import SwiftUI

// MARK: - SPEC §2.3 Animated drop button — spring press + ripple
//
// Visual states (all required by accessibility checklist):
//   • default  — sage drop on white circle, soft sage shadow
//   • hover/pressed — scales to 0.88 with spring (skipped under Reduce Motion)
//   • disabled — desaturated, opacity 0.4, no haptic, no animation
//   • action   — single ripple wave expands 1 → 1.6 and fades 0.45 → 0
//
// Honors `prefers-reduced-motion` by collapsing animations to a brief
// opacity flash. Plays a light haptic on successful tap.

struct NutGiotNuocView: View {
    let isEnabled: Bool
    let action: () -> Void
    var icon: String = "drop.fill"
    var label: String = "Lưu nhật ký biết ơn"
    var hint: String? = nil

    @State private var isPressed = false
    @State private var rippleScale: CGFloat = 1
    @State private var rippleOpacity: Double = 0
    // Continuous pulsing glow ring (Task 10.3)
    // Animates opacity 0 → 0.35 → 0 and scale 1.0 → 1.3 → 1.0 over 1.8s, repeating.
    @State private var glowScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let buttonSize: CGFloat = 64
    private let rippleSize: CGFloat = 88
    private let glowRingSize: CGFloat = 80

    var body: some View {
        Button(action: triggerAction) {
            ZStack {
                // Continuous pulsing glow ring (only when enabled & motion allowed)
                Circle()
                    .stroke(ZenColor.zenSage.opacity(0.55), lineWidth: 2)
                    .frame(width: glowRingSize, height: glowRingSize)
                    .scaleEffect(glowScale)
                    .opacity(glowOpacity)
                    .accessibilityHidden(true)

                // Ripple wave (only visible during action)
                Circle()
                    .stroke(ZenColor.zenSage.opacity(0.6), lineWidth: 2)
                    .frame(width: rippleSize, height: rippleSize)
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)
                    .accessibilityHidden(true)

                // Main drop circle
                Circle()
                    .fill(Color.white)
                    .overlay(
                        Circle()
                            .stroke(
                                isEnabled ? ZenColor.zenSage.opacity(0.4) : Color.gray.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                    .frame(width: buttonSize, height: buttonSize)
                    .shadow(
                        color: ZenColor.zenSage.opacity(isEnabled ? 0.25 : 0),
                        radius: 10,
                        x: 0,
                        y: 4
                    )
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(isEnabled ? ZenColor.zenSage : Color.gray.opacity(0.6))
                    )
                    .scaleEffect((isPressed && !reduceMotion) ? 0.88 : 1.0)
            }
            // Touch target ≥ 44 pt
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Circle())
            .opacity(isEnabled ? 1.0 : 0.4)
            .animation(
                reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.6),
                value: isPressed
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(label)
        .accessibilityHint(hint ?? (isEnabled
            ? "Lưu lại những điều biết ơn của bạn hôm nay"
            : "Hãy nhập ít nhất một điều biết ơn để có thể lưu"))
        .accessibilityAddTraits(.isButton)
        .onAppear { startGlowPulseIfNeeded() }
        .onChange(of: isEnabled) { _, _ in startGlowPulseIfNeeded() }
    }

    // MARK: - Continuous pulsing glow (Task 10.3)
    //
    // Cycle (1.8s total, repeats forever):
    //   • opacity 0    → 0.35 → 0
    //   • scale   1.0  → 1.3  → 1.0
    // Skipped entirely when:
    //   • Reduce Motion is enabled, OR
    //   • the button is currently disabled (no glow draws attention to a dead control)
    private func startGlowPulseIfNeeded() {
        guard !reduceMotion, isEnabled else {
            // Reset to invisible/idle state
            glowOpacity = 0
            glowScale = 1.0
            return
        }
        // Reset and kick off the repeating animation
        glowOpacity = 0
        glowScale = 1.0
        withAnimation(
            .easeInOut(duration: 1.8).repeatForever(autoreverses: true)
        ) {
            glowOpacity = 0.35
            glowScale = 1.3
        }
    }

    private func triggerAction() {
        guard isEnabled else { return }
        HapticService.shared.playLight()
        SoundService.shared.playDroplet()

        if reduceMotion {
            action()
            return
        }

        // Press scale
        isPressed = true
        // Reset ripple to inner state, then animate outwards
        rippleScale = 1
        rippleOpacity = 0.45
        withAnimation(.easeOut(duration: 0.5)) {
            rippleScale = 1.6
            rippleOpacity = 0
        }
        // Release press shortly after
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            isPressed = false
        }
        action()
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: ThoiGian.suongSom.colors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack(spacing: 32) {
            NutGiotNuocView(isEnabled: true, action: {})
            NutGiotNuocView(isEnabled: false, action: {})
        }
    }
}