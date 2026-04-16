import SwiftUI
import AVFoundation

// MARK: - SPEC §2.3 Animated drop button — spring + ripple

struct NutGiotNuocView: View {
    let isEnabled: Bool
    let action: () -> Void
    @State private var isPressed = false
    @State private var rippleScale: CGFloat = 1
    @State private var rippleOpacity: Double = 0

    var body: some View {
        ZStack {
            // Ripple circle
            Circle()
                .fill(Color.zenAccent.opacity(0.5))
                .frame(width: 70, height: 70)
                .scaleEffect(rippleScale)
                .opacity(rippleOpacity)

            // Main button
            Image(systemName: "drop.fill")
                .font(.system(size: 28))
                .foregroundColor(isEnabled ? Color.zenAccent : .gray)
                .frame(width: 64, height: 64)
                .background(Color.white)
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.85 : 1.0)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            guard isEnabled else { return }
            isPressed = true
            // Haptic & Sound are managed here visually
            // Assume HapticService/SoundService are available
            _ = try? AVAudioSession.sharedInstance().setActive(true)
            
            // Ripple animation
            withAnimation(.easeOut(duration: 0.4)) {
                rippleScale = 1.5
                rippleOpacity = 0
            }
            
            action() // Trigger parent action
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                rippleScale = 1
                rippleOpacity = 0
                isPressed = false
            }
        }
    }
}