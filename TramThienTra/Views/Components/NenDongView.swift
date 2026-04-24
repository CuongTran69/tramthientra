import SwiftUI

// MARK: - SPEC §2.3 Dynamic background — 6 time slots, 3-layer animated ZStack
//
// Layer 1: LinearGradient base — 3.0s easeInOut slot transition, 8s breathing drift
// Layer 2: Mist particles — TimelineView+Canvas blurred ellipses, reduce-motion hidden
// Layer 3: Radial glow — 12s sine pulse between 0.20–0.35, reduce-motion frozen at 0.20

struct NenDongView: View {
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            // ── Layer 1: Base LinearGradient with breathing drift ──
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let baseY = 0.0
                let driftY = reduceMotion ? 0.0 : sin(t * 2 * .pi / 8.0) * 0.06
                LinearGradient(
                    colors: thoiGianVM.current.colors,
                    startPoint: UnitPoint(x: 0.5, y: baseY + driftY),
                    endPoint: .bottom
                )
            }
            .animation(.easeInOut(duration: 3.0), value: thoiGianVM.current)

            // ── Layer 2: Mist particles ──
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let count = thoiGianVM.current.mistCount
                    let color = thoiGianVM.current.mistColor
                    let opacity = thoiGianVM.current.mistOpacity

                    for i in 0..<count {
                        let idx = Double(i)
                        // Each particle has an independent slow drift speed
                        let speed = 0.012 + idx * 0.003
                        let xBase = (idx / Double(max(count, 1))) * size.width
                        let xDrift = sin(t * 0.3 + idx * 1.2) * 40
                        let yPos = (t * speed * 100 + idx * size.height / Double(max(count, 1)))
                            .truncatingRemainder(dividingBy: size.height)

                        let radius = CGFloat(24 + (i % 3) * 12)  // 24, 36, or 48 pt
                        let cx = xBase + xDrift
                        let cy = CGFloat(yPos)

                        let particleRect = CGRect(
                            x: cx - radius,
                            y: cy - radius,
                            width: radius * 2,
                            height: radius * 2
                        )

                        var blurContext = context
                        blurContext.addFilter(.blur(radius: 18))
                        blurContext.fill(
                            Path(ellipseIn: particleRect),
                            with: .color(color.opacity(opacity))
                        )
                    }
                }
            }
            .opacity(reduceMotion ? 0 : 1)

            // ── Layer 3: Radial glow ──
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let pulseOpacity = reduceMotion
                    ? 0.20
                    : 0.20 + 0.15 * sin(t * 2 * .pi / 12.0)

                RadialGradient(
                    colors: [
                        thoiGianVM.current.glowColor.opacity(pulseOpacity),
                        thoiGianVM.current.glowColor.opacity(0)
                    ],
                    center: thoiGianVM.current.glowCenter,
                    startRadius: 0,
                    endRadius: 300 * thoiGianVM.current.glowRadius
                )
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NenDongView()
        .environmentObject(ThoiGianViewModel())
}
