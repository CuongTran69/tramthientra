import SwiftUI

// MARK: - Teapot Scene — Vietnamese Bat Trang teapot with floating animation and steam

struct TeapotSceneView: View {
    @State private var isFloating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Steam particle count — similar density to KhoiTanView (9 particles)
    private let steamCount = 7

    var body: some View {
        ZStack {
            // Layer 1: Teapot image with gentle floating animation
            Image("teapot_batrang")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(y: -1)  // Flip vertically — CoreGraphics origin fix
                .padding(16)
                .offset(y: reduceMotion ? 0 : (isFloating ? -5 : 5))
                .scaleEffect(reduceMotion ? 1.0 : (isFloating ? 1.02 : 0.98))
                .animation(
                    reduceMotion
                        ? nil
                        : .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                    value: isFloating
                )

            // Layer 2: Steam particles rising from spout area
            if !reduceMotion {
                steamParticles
            }
        }
        .onAppear {
            if !reduceMotion {
                isFloating = true
            }
        }
    }

    // MARK: - Steam Particles (TimelineView + Canvas — matches KhoiTanView pattern)

    private var steamParticles: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                let duration: Double = 3.5

                // Spout tip position (relative to canvas)
                // The teapot image has the spout on the right side, roughly at:
                // x: ~75% of width, y: ~35% of height
                let spoutX = size.width * 0.78
                let spoutY = size.height * 0.28

                for i in 0..<steamCount {
                    let seed = Double(i)
                    let delay = seed * (duration / Double(steamCount))

                    // Progress through lifecycle (0..1)
                    let rawT = (now - delay)
                        .truncatingRemainder(dividingBy: duration + delay * 0.3)
                    let t = min(1.0, max(0, rawT / duration))

                    // Ease-out for natural deceleration as steam rises
                    let eased = 1.0 - pow(1.0 - t, 2.0)

                    // Vertical rise: steam goes up from spout
                    let riseDistance = size.height * 0.35
                    let yOffset = eased * riseDistance

                    // Horizontal drift: gentle sine wave
                    let xDrift = sin(now * 0.8 + seed * 1.4) * 8.0
                        + sin(seed * 2.1) * 4.0

                    let pos = CGPoint(
                        x: spoutX + CGFloat(xDrift),
                        y: spoutY - CGFloat(yOffset)
                    )

                    // Size: particles grow as they rise (3pt -> 10pt)
                    let baseRadius: CGFloat = 3.0
                        + CGFloat(seed.truncatingRemainder(dividingBy: 3.0))
                    let radius = baseRadius * CGFloat(1.0 + eased * 1.8)

                    // Opacity: fade in quickly, then fade out
                    let fadeIn = min(1.0, t * 4.0)
                    let fadeOut = max(0, 1.0 - eased)
                    let opacity = fadeIn * fadeOut * 0.35

                    guard opacity > 0.01 else { continue }

                    let rect = CGRect(
                        x: pos.x - radius,
                        y: pos.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )

                    // Blur increases as particle rises (soft appearance)
                    let blur = eased * 4.0
                    var steamContext = context
                    steamContext.addFilter(.blur(radius: blur))
                    steamContext.fill(
                        Path(ellipseIn: rect),
                        with: .color(Color.white.opacity(opacity))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    TeapotSceneView()
        .frame(width: 220, height: 220)
        .background(Color(hex: "E8D8C0"))
}
