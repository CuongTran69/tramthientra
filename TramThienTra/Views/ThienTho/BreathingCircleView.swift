import SwiftUI

// MARK: - Beautiful Tea Leaf Shape
struct TeaLeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Top tip
        path.move(to: CGPoint(x: w / 2, y: 0))
        // Right curve
        path.addQuadCurve(
            to: CGPoint(x: w / 2, y: h),
            control: CGPoint(x: w * 1.1, y: h * 0.5)
        )
        // Left curve
        path.addQuadCurve(
            to: CGPoint(x: w / 2, y: 0),
            control: CGPoint(x: -w * 0.1, y: h * 0.5)
        )
        
        return path
    }
}

// MARK: - Breathing Circle Animation Component
// Spec §1.3: Expanding/contracting circle with phase-based animation
struct BreathingCircleView: View {
    let phase: BreathingPhase
    let progress: Double
    let isRunning: Bool
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Scale for the entire breathing animation
    private var animationScale: Double {
        guard !reduceMotion else { return 0.7 }
        switch phase {
        case .inhale: return 0.5 + (0.5 * progress)
        case .hold: return 1.0
        case .exhale: return 1.0 - (0.5 * progress)
        case .idle: return 0.5
        }
    }
    
    // Opacity for the breathing elements
    private var animationOpacity: Double {
        guard !reduceMotion else { return 1.0 }
        switch phase {
        case .inhale: return 0.4 + (0.6 * progress)
        case .hold: return 1.0
        case .exhale: return 1.0 - (0.6 * progress)
        case .idle: return 0.4
        }
    }
    
    // Phase text with elegant typography
    private var phaseText: String {
        phase == .idle ? "Sẵn sàng" : phase.rawValue
    }
    
    var body: some View {
        ZStack {
            // 1. Soft glowing "Thủy mặc" (Ink wash) aura using SwiftUI Blur
            // Using multiple circles to create a complex, organic glow without Canvas clipping
            ZStack {
                // Outer wide soft glow
                Circle()
                    .fill(ZenColor.zenSageLight.opacity(0.3))
                    .frame(width: 280, height: 280)
                    .blur(radius: 40)
                    .scaleEffect(animationScale * 1.1)
                
                // Inner warmer glow
                Circle()
                    .fill(ZenColor.zenTeaSpring.opacity(0.5))
                    .frame(width: 220, height: 220)
                    .blur(radius: 30)
                    .scaleEffect(animationScale)
                
                // Core deep glow
                Circle()
                    .fill(ZenColor.zenSage.opacity(0.6))
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                    .scaleEffect(animationScale * 0.9)
            }
            .opacity(animationOpacity)
            
            // 2. Elegant Tea Leaf focal point
            ZStack {
                // Leaf Fill
                TeaLeafShape()
                    .fill(
                        LinearGradient(
                            colors: [ZenColor.zenTeaLight, ZenColor.zenTeaDeep],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(0.85)
                
                // Leaf Outline for crispness
                TeaLeafShape()
                    .stroke(ZenColor.zenCream.opacity(0.6), lineWidth: 1.5)
                
                // Central vein line
                Path { path in
                    // Manually hardcoded to match the 150x200 frame below
                    path.move(to: CGPoint(x: 75, y: 10))
                    path.addQuadCurve(
                        to: CGPoint(x: 75, y: 190),
                        control: CGPoint(x: 85, y: 100)
                    )
                }
                .stroke(ZenColor.zenCream.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }
            .frame(width: 150, height: 200)
            .scaleEffect(animationScale)
            .opacity(animationOpacity)
            // Adding a subtle drop shadow to lift the leaf off the blurry background
            .shadow(color: ZenColor.zenBrownDark.opacity(0.2), radius: 10, x: 0, y: 5)
            
            // 3. Crisp, highly legible Phase Text
            Text(phaseText)
                .font(ZenFont.title())
                .foregroundColor(ZenColor.zenCream)
                .shadow(color: ZenColor.zenBrownDark.opacity(0.6), radius: 3, x: 0, y: 1)
                // Small scale effect so text breathes slightly, but not as much as the shape
                .scaleEffect(reduceMotion ? 1.0 : 1.0 + (animationScale - 1.0) * 0.1)
                .animation(.easeInOut(duration: 0.3), value: phase)
        }
        // Give ZStack plenty of room so blur doesn't get clamped if it's placed inside tight parents
        .frame(width: 350, height: 350)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(phase.accessibilityAnnouncement)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        // Simulating NenDongView background
        Color(hex: "#F5EDE4").ignoresSafeArea()
        
        VStack(spacing: 40) {
            BreathingCircleView(
                phase: .inhale,
                progress: 0.8,
                isRunning: true
            )
            
            BreathingCircleView(
                phase: .hold,
                progress: 1.0,
                isRunning: true
            )
        }
    }
}
