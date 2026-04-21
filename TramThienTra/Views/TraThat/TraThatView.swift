import SwiftUI

// MARK: - SPEC §2.1 Main screen — Trà thât (redesigned)

struct TraThatView: View {
    @StateObject private var viewModel = TraThatViewModel()
    @EnvironmentObject var streakViewModel: StreakViewModel
    @State private var showSettings = false
    @State private var showHistory = false
    @State private var showTichLuy = false
    @State private var showBuongBo = false

    var body: some View {
        ZStack {
            NenDongView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top navigation bar — pill-style glass icon buttons
                HStack {
                    navIconButton(
                        systemName: "gearshape.fill",
                        accessibilityLabel: "Cài đặt",
                        accessibilityHint: "Mở màn hình cài đặt ứng dụng"
                    ) {
                        showSettings = true
                    }

                    Spacer()

                    navIconButton(
                        systemName: "clock.arrow.circlepath",
                        accessibilityLabel: "Lịch sử",
                        accessibilityHint: "Xem lịch sử các lần tích luỹ"
                    ) {
                        showHistory = true
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()

                // App title
                Text("Trạm Thiền Trà")
                    .font(ZenFont.display())
                    .foregroundColor(ZenColor.zenBrownDark)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)

                // Teapot canvas — 240×240 pt with gold glow shadow
                TraXongView()
                    .frame(width: 240, height: 240)
                    .shadow(
                        color: ZenColor.zenGold.opacity(0.35),
                        radius: 20,
                        x: 0,
                        y: 0
                    )
                    .accessibilityLabel("Trạm Thiền Trà – ấm trà thiền định")
                    .accessibilityHidden(false)

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    ZenButton("Tích luỹ", variant: .primary, icon: "drop.fill") {
                        showTichLuy = true
                    }
                    .accessibilityLabel("Tích luỹ")
                    .accessibilityHint("Mở màn hình ghi lại điều biết ơn hôm nay")

                    ZenButton("Buông bỏ", variant: .secondary) {
                        showBuongBo = true
                    }
                    .accessibilityLabel("Buông bỏ")
                    .accessibilityHint("Mở màn hình viết ra và buông bỏ những lo âu")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // Streak bar wrapped in ZenCard
                ZenCard {
                    CayThienView(streak: streakViewModel.streak, stage: streakViewModel.stage)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .sheet(isPresented: $showHistory) {
            NavigationStack {
                HistoryView()
            }
        }
        .fullScreenCover(isPresented: $showTichLuy) {
            TichLuyView()
        }
        .fullScreenCover(isPresented: $showBuongBo) {
            BuongBoView()
        }
    }

    // MARK: - Pill-style glass icon button for top nav

    @ViewBuilder
    private func navIconButton(
        systemName: String,
        accessibilityLabel: String,
        accessibilityHint: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(ZenColor.zenBrown)
                .frame(width: 44, height: 44)
                .background(
                    ZStack {
                        Circle().fill(.ultraThinMaterial)
                        Circle().fill(Color.white.opacity(0.45))
                        Circle().stroke(Color.white.opacity(0.6), lineWidth: 1)
                    }
                )
                .shadow(color: ZenColor.zenBrown.opacity(0.08), radius: 8, x: 0, y: 3)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }
}
