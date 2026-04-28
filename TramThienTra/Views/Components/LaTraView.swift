import SwiftUI

// MARK: - Tea leaf streak visualization — 6 stage bezier leaf shapes
//
// Animation behavior:
//   - On stage change: spring bounce (scale 1.0 -> 1.08 -> 1.0,
//     response 0.4, dampingFraction 0.55).
//   - Idle sway: +/- 2 degrees rotationEffect, 3.5s period (stages bupNon+).
//   - Idle breathe: scale 1.0 to 1.03, 4.5s period (stages laXanh+).
//   - Reduce Motion: opacity crossfade only, no scaling or idle animations.
//
// Token usage:
//   - No inline Color(hex:) — all colors resolve via ZenColor or ThoiGian properties.

struct LaTraView: View {
    let streak: Int
    let stage: StreakViewModel.LeafStage

    @State private var animatedStage: StreakViewModel.LeafStage = .hatTra
    @State private var bounceScale: CGFloat = 1.0
    @State private var swayAngle: Double = -2.0
    @State private var breatheScale: CGFloat = 1.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Stage visualization — bezier tea leaf shape
            ZStack {
                stageShape(for: animatedStage)
                    .frame(width: 48, height: 48)
                    .scaleEffect(bounceScale * breatheScale)
                    .rotationEffect(.degrees(swayAngle))
                    .shadow(
                        color: thoiGianVM.current.leafGlow.opacity(thoiGianVM.current.leafGlowOpacity),
                        radius: 6,
                        x: 0,
                        y: 0
                    )
                    .animation(.easeInOut(duration: 0.3), value: animatedStage)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(animatedStage.title)
                    .zenHeadline()
                    .foregroundColor(thoiGianVM.current.streakTextPrimary)
                Text("\(streak) ngày")
                    .zenCaption()
                    .foregroundColor(thoiGianVM.current.streakTextSecondary)
            }

            Spacer()

            // Progress dots
            HStack(spacing: 4) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index <= animatedStage.rawValue
                              ? thoiGianVM.current.streakTextPrimary
                              : thoiGianVM.current.streakTextSecondary.opacity(0.4))
                        .frame(width: 8, height: 8)
                }
            }
            .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            thoiGianVM.current == .traDenDem
                ? ZenColor.zenNightGold.opacity(0.15)
                : thoiGianVM.current.streakTextPrimary.opacity(0.08)
        )
        .cornerRadius(20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(animatedStage.title), streak \(streak) ngày")
        .onAppear {
            // First render: set stage without bouncing
            animatedStage = stage
            startIdleAnimations()
        }
        .onChange(of: stage) { _, newValue in
            animatedStage = newValue
            guard !reduceMotion else { return }
            // Spring bounce: 1.0 -> 1.08 -> 1.0
            withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
                bounceScale = 1.08
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
                    bounceScale = 1.0
                }
            }
        }
        .onChange(of: reduceMotion) { _, _ in
            if reduceMotion {
                swayAngle = -2.0
                breatheScale = 1.0
            } else {
                startIdleAnimations()
            }
        }
    }

    // MARK: - Idle animations

    private func startIdleAnimations() {
        guard !reduceMotion else { return }

        // Sway for stages bupNon (2) and above
        if animatedStage.rawValue >= 2 {
            withAnimation(
                .easeInOut(duration: 3.5)
                .repeatForever(autoreverses: true)
            ) {
                swayAngle = 2.0
            }
        }

        // Breathing for stages laXanh (4) and above
        if animatedStage.rawValue >= 4 {
            withAnimation(
                .easeInOut(duration: 4.5)
                .repeatForever(autoreverses: true)
            ) {
                breatheScale = 1.03
            }
        }
    }

    // MARK: - Tea leaf shapes (custom Path bezier curves)

    @ViewBuilder
    private func stageShape(for stage: StreakViewModel.LeafStage) -> some View {
        switch stage {
        case .hatTra:
            hatTraShape()
        case .mamTra:
            mamTraShape()
        case .bupNon:
            bupNonShape()
        case .laNon:
            laNonShape()
        case .laXanh:
            laXanhShape()
        case .traChin:
            traChinShape()
        }
    }

    // MARK: hatTra — teardrop seed

    @ViewBuilder
    private func hatTraShape() -> some View {
        Path { path in
            // Teardrop seed, ~14x18pt, centered in 48x48
            let cx: CGFloat = 24
            let top: CGFloat = 15
            let bottom: CGFloat = 33

            path.move(to: CGPoint(x: cx, y: top))
            // Right curve
            path.addQuadCurve(
                to: CGPoint(x: cx, y: bottom),
                control: CGPoint(x: cx + 10, y: top + 6)
            )
            // Left curve
            path.addQuadCurve(
                to: CGPoint(x: cx, y: top),
                control: CGPoint(x: cx - 10, y: top + 6)
            )
            path.closeSubpath()
        }
        .fill(ZenColor.zenBrownDark)
    }

    // MARK: mamTra — curled sprout with seed pod

    @ViewBuilder
    private func mamTraShape() -> some View {
        ZStack {
            // Seed pod at bottom
            Path { path in
                let cx: CGFloat = 24
                let bottom: CGFloat = 36
                let podH: CGFloat = 8

                path.move(to: CGPoint(x: cx, y: bottom))
                path.addQuadCurve(
                    to: CGPoint(x: cx, y: bottom - podH),
                    control: CGPoint(x: cx + 6, y: bottom - podH / 2)
                )
                path.addQuadCurve(
                    to: CGPoint(x: cx, y: bottom),
                    control: CGPoint(x: cx - 6, y: bottom - podH / 2)
                )
                path.closeSubpath()
            }
            .fill(ZenColor.zenBrownDark)

            // Tiny emerging leaf curling upward
            Path { path in
                path.move(to: CGPoint(x: 24, y: 28))
                path.addCurve(
                    to: CGPoint(x: 28, y: 14),
                    control1: CGPoint(x: 20, y: 22),
                    control2: CGPoint(x: 32, y: 16)
                )
                path.addCurve(
                    to: CGPoint(x: 24, y: 20),
                    control1: CGPoint(x: 26, y: 13),
                    control2: CGPoint(x: 22, y: 16)
                )
                path.closeSubpath()
            }
            .fill(thoiGianVM.current.leafTint)
        }
    }

    // MARK: bupNon — tea bud with 2 unfurling leaves

    @ViewBuilder
    private func bupNonShape() -> some View {
        ZStack {
            // Central bud
            Path { path in
                path.move(to: CGPoint(x: 24, y: 12))
                path.addCurve(
                    to: CGPoint(x: 24, y: 36),
                    control1: CGPoint(x: 30, y: 16),
                    control2: CGPoint(x: 28, y: 30)
                )
                path.addCurve(
                    to: CGPoint(x: 24, y: 12),
                    control1: CGPoint(x: 20, y: 30),
                    control2: CGPoint(x: 18, y: 16)
                )
                path.closeSubpath()
            }
            .fill(thoiGianVM.current.leafTint)

            // Left unfurling leaf
            Path { path in
                path.move(to: CGPoint(x: 22, y: 24))
                path.addCurve(
                    to: CGPoint(x: 10, y: 18),
                    control1: CGPoint(x: 18, y: 22),
                    control2: CGPoint(x: 12, y: 16)
                )
                path.addCurve(
                    to: CGPoint(x: 22, y: 24),
                    control1: CGPoint(x: 12, y: 22),
                    control2: CGPoint(x: 18, y: 26)
                )
                path.closeSubpath()
            }
            .fill(ZenColor.zenTeaLight)

            // Right unfurling leaf
            Path { path in
                path.move(to: CGPoint(x: 26, y: 24))
                path.addCurve(
                    to: CGPoint(x: 38, y: 18),
                    control1: CGPoint(x: 30, y: 22),
                    control2: CGPoint(x: 36, y: 16)
                )
                path.addCurve(
                    to: CGPoint(x: 26, y: 24),
                    control1: CGPoint(x: 36, y: 22),
                    control2: CGPoint(x: 30, y: 26)
                )
                path.closeSubpath()
            }
            .fill(ZenColor.zenTeaLight)
        }
    }

    // MARK: laNon — recognizable tea leaf with veins and serrated edges

    @ViewBuilder
    private func laNonShape() -> some View {
        ZStack {
            // Main leaf body with serrated edges
            Path { path in
                path.move(to: CGPoint(x: 24, y: 8))
                // Right edge with serrations
                path.addCurve(
                    to: CGPoint(x: 36, y: 20),
                    control1: CGPoint(x: 30, y: 10),
                    control2: CGPoint(x: 35, y: 14)
                )
                path.addLine(to: CGPoint(x: 34, y: 21))
                path.addCurve(
                    to: CGPoint(x: 37, y: 28),
                    control1: CGPoint(x: 36, y: 23),
                    control2: CGPoint(x: 38, y: 26)
                )
                path.addLine(to: CGPoint(x: 35, y: 29))
                path.addCurve(
                    to: CGPoint(x: 30, y: 38),
                    control1: CGPoint(x: 36, y: 32),
                    control2: CGPoint(x: 34, y: 36)
                )
                // Bottom tip
                path.addCurve(
                    to: CGPoint(x: 24, y: 42),
                    control1: CGPoint(x: 28, y: 40),
                    control2: CGPoint(x: 26, y: 42)
                )
                // Left edge with serrations
                path.addCurve(
                    to: CGPoint(x: 18, y: 38),
                    control1: CGPoint(x: 22, y: 42),
                    control2: CGPoint(x: 20, y: 40)
                )
                path.addCurve(
                    to: CGPoint(x: 13, y: 29),
                    control1: CGPoint(x: 14, y: 36),
                    control2: CGPoint(x: 12, y: 32)
                )
                path.addLine(to: CGPoint(x: 15, y: 28))
                path.addCurve(
                    to: CGPoint(x: 11, y: 21),
                    control1: CGPoint(x: 10, y: 26),
                    control2: CGPoint(x: 12, y: 23)
                )
                path.addLine(to: CGPoint(x: 14, y: 20))
                path.addCurve(
                    to: CGPoint(x: 24, y: 8),
                    control1: CGPoint(x: 13, y: 14),
                    control2: CGPoint(x: 18, y: 10)
                )
                path.closeSubpath()
            }
            .fill(ZenColor.zenSage)

            // Central vein
            Path { path in
                path.move(to: CGPoint(x: 24, y: 10))
                path.addLine(to: CGPoint(x: 24, y: 40))
            }
            .stroke(ZenColor.zenTeaVein, lineWidth: 1.2)

            // Side veins
            Path { path in
                // Right veins
                path.move(to: CGPoint(x: 24, y: 18))
                path.addLine(to: CGPoint(x: 32, y: 15))
                path.move(to: CGPoint(x: 24, y: 24))
                path.addLine(to: CGPoint(x: 33, y: 22))
                path.move(to: CGPoint(x: 24, y: 30))
                path.addLine(to: CGPoint(x: 32, y: 29))
                // Left veins
                path.move(to: CGPoint(x: 24, y: 18))
                path.addLine(to: CGPoint(x: 16, y: 15))
                path.move(to: CGPoint(x: 24, y: 24))
                path.addLine(to: CGPoint(x: 15, y: 22))
                path.move(to: CGPoint(x: 24, y: 30))
                path.addLine(to: CGPoint(x: 16, y: 29))
            }
            .stroke(ZenColor.zenTeaVein, lineWidth: 0.8)
        }
    }

    // MARK: laXanh — full lush leaf with gold edge shimmer

    @ViewBuilder
    private func laXanhShape() -> some View {
        ZStack {
            // Main leaf body
            Path { path in
                path.move(to: CGPoint(x: 24, y: 6))
                path.addCurve(
                    to: CGPoint(x: 40, y: 22),
                    control1: CGPoint(x: 32, y: 8),
                    control2: CGPoint(x: 40, y: 14)
                )
                path.addCurve(
                    to: CGPoint(x: 24, y: 42),
                    control1: CGPoint(x: 40, y: 32),
                    control2: CGPoint(x: 32, y: 40)
                )
                path.addCurve(
                    to: CGPoint(x: 8, y: 22),
                    control1: CGPoint(x: 16, y: 40),
                    control2: CGPoint(x: 8, y: 32)
                )
                path.addCurve(
                    to: CGPoint(x: 24, y: 6),
                    control1: CGPoint(x: 8, y: 14),
                    control2: CGPoint(x: 16, y: 8)
                )
                path.closeSubpath()
            }
            .fill(ZenColor.zenTeaDeep)

            // Gold edge shimmer outline
            Path { path in
                path.move(to: CGPoint(x: 24, y: 6))
                path.addCurve(
                    to: CGPoint(x: 40, y: 22),
                    control1: CGPoint(x: 32, y: 8),
                    control2: CGPoint(x: 40, y: 14)
                )
                path.addCurve(
                    to: CGPoint(x: 24, y: 42),
                    control1: CGPoint(x: 40, y: 32),
                    control2: CGPoint(x: 32, y: 40)
                )
                path.addCurve(
                    to: CGPoint(x: 8, y: 22),
                    control1: CGPoint(x: 16, y: 40),
                    control2: CGPoint(x: 8, y: 32)
                )
                path.addCurve(
                    to: CGPoint(x: 24, y: 6),
                    control1: CGPoint(x: 8, y: 14),
                    control2: CGPoint(x: 16, y: 8)
                )
                path.closeSubpath()
            }
            .stroke(ZenColor.zenGold.opacity(0.5), lineWidth: 1.5)

            // Central vein
            Path { path in
                path.move(to: CGPoint(x: 24, y: 8))
                path.addLine(to: CGPoint(x: 24, y: 40))
            }
            .stroke(ZenColor.zenTeaVein, lineWidth: 1.0)

            // Side veins
            Path { path in
                path.move(to: CGPoint(x: 24, y: 16))
                path.addLine(to: CGPoint(x: 35, y: 13))
                path.move(to: CGPoint(x: 24, y: 22))
                path.addLine(to: CGPoint(x: 37, y: 20))
                path.move(to: CGPoint(x: 24, y: 28))
                path.addLine(to: CGPoint(x: 36, y: 27))
                path.move(to: CGPoint(x: 24, y: 34))
                path.addLine(to: CGPoint(x: 32, y: 34))

                path.move(to: CGPoint(x: 24, y: 16))
                path.addLine(to: CGPoint(x: 13, y: 13))
                path.move(to: CGPoint(x: 24, y: 22))
                path.addLine(to: CGPoint(x: 11, y: 20))
                path.move(to: CGPoint(x: 24, y: 28))
                path.addLine(to: CGPoint(x: 12, y: 27))
                path.move(to: CGPoint(x: 24, y: 34))
                path.addLine(to: CGPoint(x: 16, y: 34))
            }
            .stroke(ZenColor.zenTeaVein.opacity(0.6), lineWidth: 0.7)
        }
    }

    // MARK: traChin — 2-3 overlapping leaves with glow halo

    @ViewBuilder
    private func traChinShape() -> some View {
        ZStack {
            // Glow halo
            Circle()
                .fill(thoiGianVM.current.leafGlow.opacity(thoiGianVM.current.leafGlowOpacity * 1.5))
                .frame(width: 46, height: 46)
                .blur(radius: 4)

            // Back leaf (left, slightly rotated)
            Path { path in
                path.move(to: CGPoint(x: 18, y: 10))
                path.addCurve(
                    to: CGPoint(x: 30, y: 22),
                    control1: CGPoint(x: 24, y: 11),
                    control2: CGPoint(x: 30, y: 16)
                )
                path.addCurve(
                    to: CGPoint(x: 18, y: 38),
                    control1: CGPoint(x: 30, y: 30),
                    control2: CGPoint(x: 24, y: 36)
                )
                path.addCurve(
                    to: CGPoint(x: 8, y: 22),
                    control1: CGPoint(x: 12, y: 36),
                    control2: CGPoint(x: 8, y: 30)
                )
                path.addCurve(
                    to: CGPoint(x: 18, y: 10),
                    control1: CGPoint(x: 8, y: 16),
                    control2: CGPoint(x: 12, y: 11)
                )
                path.closeSubpath()
            }
            .fill(ZenColor.zenTeaRich.opacity(0.7))
            .rotationEffect(.degrees(-12))

            // Middle leaf (right, slightly rotated)
            Path { path in
                path.move(to: CGPoint(x: 28, y: 8))
                path.addCurve(
                    to: CGPoint(x: 40, y: 20),
                    control1: CGPoint(x: 34, y: 9),
                    control2: CGPoint(x: 40, y: 14)
                )
                path.addCurve(
                    to: CGPoint(x: 28, y: 36),
                    control1: CGPoint(x: 40, y: 28),
                    control2: CGPoint(x: 34, y: 34)
                )
                path.addCurve(
                    to: CGPoint(x: 18, y: 20),
                    control1: CGPoint(x: 22, y: 34),
                    control2: CGPoint(x: 18, y: 28)
                )
                path.addCurve(
                    to: CGPoint(x: 28, y: 8),
                    control1: CGPoint(x: 18, y: 14),
                    control2: CGPoint(x: 22, y: 9)
                )
                path.closeSubpath()
            }
            .fill(ZenColor.zenTeaRich.opacity(0.85))
            .rotationEffect(.degrees(8))

            // Front leaf (center, full opacity)
            Path { path in
                path.move(to: CGPoint(x: 24, y: 6))
                path.addCurve(
                    to: CGPoint(x: 38, y: 22),
                    control1: CGPoint(x: 32, y: 8),
                    control2: CGPoint(x: 38, y: 14)
                )
                path.addCurve(
                    to: CGPoint(x: 24, y: 42),
                    control1: CGPoint(x: 38, y: 32),
                    control2: CGPoint(x: 32, y: 40)
                )
                path.addCurve(
                    to: CGPoint(x: 10, y: 22),
                    control1: CGPoint(x: 16, y: 40),
                    control2: CGPoint(x: 10, y: 32)
                )
                path.addCurve(
                    to: CGPoint(x: 24, y: 6),
                    control1: CGPoint(x: 10, y: 14),
                    control2: CGPoint(x: 16, y: 8)
                )
                path.closeSubpath()
            }
            .fill(ZenColor.zenTeaRich)

            // Front leaf vein
            Path { path in
                path.move(to: CGPoint(x: 24, y: 8))
                path.addLine(to: CGPoint(x: 24, y: 40))
            }
            .stroke(ZenColor.zenTeaVein, lineWidth: 0.8)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ForEach(StreakViewModel.LeafStage.allCases, id: \.rawValue) { stage in
            LaTraView(streak: stage.rawValue * 5, stage: stage)
        }
    }
    .padding()
    .environmentObject(ThoiGianViewModel())
}
