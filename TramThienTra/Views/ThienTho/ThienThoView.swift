import SwiftUI

// MARK: - SPEC §4 ThienTho breathing exercise screen

struct ThienThoView: View {
    @StateObject private var viewModel = ThienThoViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var thoiGianVM: ThoiGianViewModel

    var body: some View {
        ZStack {
            NenDongView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ZenScreenHeader(title: "Thiền thở", dismissAction: { dismiss() })

                Spacer()

                // Breathing circle + cycle counter wrapped in ZenCard
                ZenCard {
                    VStack(spacing: 0) {
                        BreathingCircleView(
                            phase: viewModel.currentPhase,
                            progress: viewModel.phaseProgress,
                            isRunning: viewModel.isRunning
                        )

                        // Cycle counter — shown only when a session is active
                        if !viewModel.cycleText.isEmpty {
                            Text(viewModel.cycleText)
                                .font(ZenFont.subheadline())
                                .foregroundColor(thoiGianVM.current.textSecondary)
                                .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                                .padding(.top, 16)
                                .accessibilityLabel(viewModel.cycleText)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Start / Pause button
                ZenButton(
                    viewModel.isRunning ? "Tạm dừng" : "Bắt đầu",
                    variant: .primary,
                    icon: viewModel.isRunning ? "pause.fill" : "play.fill"
                ) {
                    viewModel.toggleSession()
                }
                .accessibilityLabel(viewModel.isRunning ? "Tạm dừng" : "Bắt đầu")
                .accessibilityHint(viewModel.isRunning ? "Tạm dừng phiên thiền thở" : "Bắt đầu phiên thiền thở")
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    ThienThoView()
        .environmentObject(ThoiGianViewModel())
}
