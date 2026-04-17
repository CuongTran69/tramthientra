import SwiftUI

// MARK: - SPEC §2.1 Teapot with smoke particles — upgraded: gold glow layer, 2s pulsing opacity

struct TraXongView: View {
    @State private var glowOpacity: Double = 0.3
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let centerX = size.width / 2
                    let centerY = size.height / 2 + 10

                    // ── Teapot body ──
                    let bodyRect = CGRect(x: centerX - 40, y: centerY - 20, width: 80, height: 60)
                    context.fill(Path(ellipseIn: bodyRect), with: .color(ZenColor.zenBrownDark))

                    // ── Teapot lid ──
                    let lidPath = Path { path in
                        path.move(to: CGPoint(x: centerX - 30, y: centerY - 20))
                        path.addQuadCurve(
                            to: CGPoint(x: centerX + 30, y: centerY - 20),
                            control: CGPoint(x: centerX, y: centerY - 38)
                        )
                    }
                    context.stroke(lidPath, with: .color(ZenColor.zenBrownDark), lineWidth: 3)

                    // ── Teapot spout (right side) ──
                    let spoutPath = Path { path in
                        path.move(to: CGPoint(x: centerX + 40, y: centerY - 5))
                        path.addQuadCurve(
                            to: CGPoint(x: centerX + 65, y: centerY - 25),
                            control: CGPoint(x: centerX + 55, y: centerY - 20)
                        )
                    }
                    context.stroke(spoutPath, with: .color(ZenColor.zenBrownDark), lineWidth: 4)

                    // ── Teapot handle (left side) ──
                    let handlePath = Path { path in
                        path.move(to: CGPoint(x: centerX - 40, y: centerY - 5))
                        path.addQuadCurve(
                            to: CGPoint(x: centerX - 40, y: centerY + 25),
                            control: CGPoint(x: centerX - 65, y: centerY + 10)
                        )
                    }
                    context.stroke(handlePath, with: .color(ZenColor.zenBrownDark), lineWidth: 4)

                    // ── Smoke particles with gold glow ──
                    let elapsed = timeline.date.timeIntervalSinceReferenceDate
                    let particleCount = 6
                    for i in 0..<particleCount {
                        let phase = elapsed + Double(i) * 0.8
                        let t = (phase.truncatingRemainder(dividingBy: 4.0)) / 4.0
                        let yOffset = CGFloat(t) * 60
                        let xWobble = sin(elapsed * 2 + Double(i)) * 6
                        let opacity = max(0, 1 - t * 1.5)
                        let radius = 6 + CGFloat(t) * 12

                        let smokePos = CGPoint(
                            x: centerX + 65 + xWobble,
                            y: centerY - 25 - yOffset
                        )
                        let smokeRect = CGRect(
                            x: smokePos.x - radius, y: smokePos.y - radius,
                            width: radius * 2, height: radius * 2
                        )

                        // Base smoke particle
                        context.fill(
                            Path(ellipseIn: smokeRect),
                            with: .color(ZenColor.zenBrownDark.opacity(opacity * 0.15))
                        )

                        // Gold glow layer — pulsing via @State glowOpacity
                        if !reduceMotion {
                            let glowRadius = radius * 1.3
                            let glowRect = CGRect(
                                x: smokePos.x - glowRadius, y: smokePos.y - glowRadius,
                                width: glowRadius * 2, height: glowRadius * 2
                            )
                            var glowContext = context
                            glowContext.addFilter(.blur(radius: 4))
                            glowContext.fill(
                                Path(ellipseIn: glowRect),
                                with: .color(ZenColor.zenGold.opacity(opacity * glowOpacity * 0.4))
                            )
                        }
                    }
                }
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            // 2s ease-in-out repeating: opacity 0.3 → 0.5 → 0.3
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowOpacity = 0.5
            }
        }
    }
}
