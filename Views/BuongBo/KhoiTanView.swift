import SwiftUI

// MARK: - SPEC §2.4 Smoke fade animation — upgraded: 40% more particles, sage colors, 3–8 pt radius

struct KhoiTanView: View {
    // Particle count: original 6 → increased by 40% = 9 particles
    private let particleCount = 9

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                let duration: Double = 2.0

                for i in 0..<particleCount {
                    let seed = Double(i)
                    let delay = seed * (2.0 / Double(particleCount))

                    // Deterministic per-particle position (no new objects per frame)
                    let baseX = size.width / 2 + CGFloat(sin(seed * 1.7) * 30)
                    let baseY = size.height * 0.75 + CGFloat(cos(seed * 2.3) * 10)

                    // Radius varies 3–8 pt per particle (seeded per index)
                    let baseRadius = CGFloat(3.0 + (seed.truncatingRemainder(dividingBy: 5.0) / 5.0) * 5.0)

                    let t = min(1.0, max(0, (now - delay).truncatingRemainder(dividingBy: duration + delay) / duration))
                    let eased = t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2

                    let yOffset = eased * size.height * 0.5
                    let scale = 1.0 + eased * 0.3
                    let opacity = max(0, 1.0 - eased)

                    let pos = CGPoint(
                        x: baseX + CGFloat(sin(now * 2 + seed) * 10),
                        y: baseY - CGFloat(yOffset)
                    )

                    let radius = baseRadius * CGFloat(scale)
                    let rect = CGRect(
                        x: pos.x - radius, y: pos.y - radius,
                        width: radius * 2, height: radius * 2
                    )

                    // Soft sage particle: zenSage.opacity(0.6) * particle opacity
                    var smokeContext = context
                    smokeContext.addFilter(.blur(radius: eased * 2.5))
                    smokeContext.fill(
                        Path(ellipseIn: rect),
                        with: .color(ZenColor.zenSage.opacity(opacity * 0.6))
                    )
                }
            }
        }
    }
}
