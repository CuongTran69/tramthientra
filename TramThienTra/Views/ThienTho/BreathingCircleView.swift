import SwiftUI

// MARK: - Breathing Circle Animation Component
// Spec §1.3: Expanding/contracting circle with phase-based animation

struct BreathingCircleView: View {
    let phase: BreathingPhase
    let progress: Double
    let isRunning: Bool
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private var circleScale: CGFloat {
        guard !reduceMotion else { return 0.7 }
        
        switch phase {
        case .inhale:
            // 0.4 → 1.0
            return 0.4 + (0.6 * progress)
        case .hold:
            return 1.0
        case .exhale:
            // 1.0 → 0.4
            return 1.0 - (0.6 * progress)
        case .idle:
            return 0.4
        }
    }
    
    private var circleOpacity: Double {
        guard !reduceMotion else { return 1.0 }
        
        switch phase {
        case .inhale:
            return 0.6 + (0.4 * progress)
        case .hold:
            return 1.0
        case .exhale:
            return 1.0 - (0.4 * progress)
        case .idle:
            return 0.6
        }
    }
    
    private var glowRadius: CGFloat {
        switch phase {
        case .hold: return 40
        case .inhale, .exhale: return 20
        case .idle: return 12
        }
    }
    
    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ZenColor.zenSage.opacity(0.4),
                            ZenColor.zenSage.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 40,
                        endRadius: 160
                    )
                )
                .frame(width: 280, height: 280)
                .scaleEffect(circleScale)
                .opacity(circleOpacity * 0.6)
            
            // Main breathing circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            ZenColor.zenSage,
                            ZenColor.zenSageLight
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(circleScale)
                .opacity(circleOpacity)
                .shadow(
                    color: ZenColor.zenSage.opacity(0.5),
                    radius: glowRadius,
                    x: 0,
                    y: 0
                )
            
            // Inner highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.0)
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(circleScale)
                .opacity(circleOpacity)
            
            // Phase label (center text)
            VStack(spacing: 8) {
                Text(phase == .idle ? "Sẵn sàng" : phase.rawValue)
                    .font(ZenFont.title())
                    .foregroundColor(.white)
                    .shadow(color: ZenColor.zenBrown.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.3),
            value: phase
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(phase.accessibilityAnnouncement)
        .accessibilityAddTraits(.updatesFrequently)
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
        
        BreathingCircleView(
            phase: .inhale,
            progress: 0.5,
            isRunning: true
        )
    }
}
