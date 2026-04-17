import SwiftUI

// MARK: - SPEC §2.1 CayThien streak visualization — 5 stage leaf/tree shapes (redesigned)
// Animation: spring bounce (scale 1.08→1.0) only on stage change, with reduce-motion support.

struct CayThienView: View {
    let streak: Int
    let stage: StreakViewModel.LeafStage
    @State private var animatedStage: StreakViewModel.LeafStage = .seed
    @State private var bounceScale: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            // Stage visualization with spring bounce on stage change
            ZStack {
                stageShape(for: animatedStage)
                    .frame(width: 48, height: 48)
                    .scaleEffect(bounceScale)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(animatedStage.title)
                    .font(ZenFont.headline())
                    .foregroundColor(ZenColor.zenBrownDark)
                Text("\(streak) ngày")
                    .font(ZenFont.caption())
                    .foregroundColor(ZenColor.zenBrown.opacity(0.7))
            }

            Spacer()

            // Progress dots
            HStack(spacing: 4) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index <= animatedStage.rawValue ? ZenColor.zenSage : ZenColor.zenSage.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .onAppear {
            animatedStage = stage
        }
        .onChange(of: stage) { _, newValue in
            animatedStage = newValue
            triggerBounce()
        }
    }

    // MARK: - Spring bounce triggered only on stage change

    private func triggerBounce() {
        guard !reduceMotion else {
            // Reduce motion: fade instead of bounce
            withAnimation(.easeInOut(duration: 0.3)) {
                bounceScale = 1.0
            }
            return
        }
        // Spring: scale to 1.08, then settle back to 1.0
        // response 0.4, dampingFraction 0.55
        bounceScale = 1.08
        withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
            bounceScale = 1.0
        }
    }

    // MARK: - Stage shape renderer

    @ViewBuilder
    private func stageShape(for stage: StreakViewModel.LeafStage) -> some View {
        switch stage {
        case .seed:
            Circle()
                .fill(ZenColor.zenBrownDark)
                .frame(width: 16, height: 16)
        case .sprout:
            VStack(spacing: 0) {
                Ellipse()
                    .fill(ZenColor.zenSage)
                    .frame(width: 12, height: 20)
                Rectangle()
                    .fill(ZenColor.zenBrownDark)
                    .frame(width: 3, height: 14)
            }
        case .young:
            HStack(spacing: 0) {
                Ellipse()
                    .fill(ZenColor.zenSage)
                    .frame(width: 14, height: 22)
                    .rotationEffect(.degrees(-20))
                Rectangle()
                    .fill(ZenColor.zenBrownDark)
                    .frame(width: 4, height: 22)
                Ellipse()
                    .fill(ZenColor.zenSage)
                    .frame(width: 14, height: 22)
                    .rotationEffect(.degrees(20))
            }
        case .green:
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Ellipse().fill(ZenColor.zenSage).frame(width: 16, height: 26).rotationEffect(.degrees(-25))
                    Ellipse().fill(ZenColor.zenSage).frame(width: 16, height: 26)
                    Ellipse().fill(ZenColor.zenSage).frame(width: 16, height: 26).rotationEffect(.degrees(25))
                }
                Rectangle().fill(ZenColor.zenBrownDark).frame(width: 5, height: 20)
            }
        case .lush:
            VStack(spacing: 0) {
                HStack(spacing: -4) {
                    ForEach(0..<4, id: \.self) { _ in
                        Ellipse().fill(ZenColor.zenSage).frame(width: 18, height: 30)
                    }
                }
                Rectangle().fill(ZenColor.zenBrownDark).frame(width: 6, height: 24)
            }
        case .greatTree:
            VStack(spacing: 0) {
                HStack(spacing: -4) {
                    ForEach(0..<5, id: \.self) { _ in
                        Ellipse().fill(ZenColor.zenSage).frame(width: 20, height: 34)
                    }
                }
                Rectangle().fill(ZenColor.zenBrownDark).frame(width: 8, height: 28)
            }
        }
    }
}
