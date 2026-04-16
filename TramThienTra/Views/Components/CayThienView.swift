import SwiftUI

// MARK: - SPEC §2.1 CayThien streak visualization — 5 stage leaf/tree shapes

struct CayThienView: View {
    let streak: Int
    let stage: StreakViewModel.LeafStage
    @State private var animatedStage: StreakViewModel.LeafStage = .seed

    var body: some View {
        HStack(spacing: 12) {
            // Stage visualization
            ZStack {
                stageShape(for: animatedStage)
                    .frame(width: 48, height: 48)
                    .animation(.easeInOut(duration: 0.6), value: animatedStage)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(animatedStage.title)
                    .zenHeadline()
                    .foregroundColor(.white)
                Text("\(streak) ngày")
                    .zenCaption()
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            // Progress dots
            HStack(spacing: 4) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index <= animatedStage.rawValue ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.15))
        .cornerRadius(20)
        .onAppear {
            animatedStage = stage
        }
        .onChange(of: stage) { _, newValue in
            animatedStage = newValue
        }
    }

    @ViewBuilder
    private func stageShape(for stage: StreakViewModel.LeafStage) -> some View {
        switch stage {
        case .seed:
            Circle()
                .fill(Color(hex: "#3A2A18"))
                .frame(width: 16, height: 16)
        case .sprout:
            VStack(spacing: 0) {
                Ellipse()
                    .fill(Color.zenAccent)
                    .frame(width: 12, height: 20)
                Rectangle()
                    .fill(Color(hex: "#3A2A18"))
                    .frame(width: 3, height: 14)
            }
        case .young:
            HStack(spacing: 0) {
                Ellipse()
                    .fill(Color.zenAccent)
                    .frame(width: 14, height: 22)
                    .rotationEffect(.degrees(-20))
                Rectangle()
                    .fill(Color(hex: "#3A2A18"))
                    .frame(width: 4, height: 22)
                Ellipse()
                    .fill(Color.zenAccent)
                    .frame(width: 14, height: 22)
                    .rotationEffect(.degrees(20))
            }
        case .green:
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Ellipse().fill(Color.zenAccent).frame(width: 16, height: 26).rotationEffect(.degrees(-25))
                    Ellipse().fill(Color.zenAccent).frame(width: 16, height: 26)
                    Ellipse().fill(Color.zenAccent).frame(width: 16, height: 26).rotationEffect(.degrees(25))
                }
                Rectangle().fill(Color(hex: "#3A2A18")).frame(width: 5, height: 20)
            }
        case .lush:
            VStack(spacing: 0) {
                HStack(spacing: -4) {
                    ForEach(0..<4, id: \.self) { _ in
                        Ellipse().fill(Color.zenAccent).frame(width: 18, height: 30)
                    }
                }
                Rectangle().fill(Color(hex: "#3A2A18")).frame(width: 6, height: 24)
            }
        case .greatTree:
            VStack(spacing: 0) {
                HStack(spacing: -4) {
                    ForEach(0..<5, id: \.self) { _ in
                        Ellipse().fill(Color.zenAccent).frame(width: 20, height: 34)
                    }
                }
                Rectangle().fill(Color(hex: "#3A2A18")).frame(width: 8, height: 28)
            }
        }
    }
}