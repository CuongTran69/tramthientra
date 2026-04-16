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
                // Top navigation bar
                HStack {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(ZenColor.zenBrown)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Cài đặt")
                    .accessibilityHint("Mở màn hình cài đặt ứng dụng")

                    Spacer()

                    Button {
                        showHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundColor(ZenColor.zenBrown)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Lịch sử")
                    .accessibilityHint("Xem lịch sử các lần tích luỹ")
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

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
                .padding(.horizontal, 32)
                .padding(.bottom, 16)

                // Streak bar wrapped in ZenCard
                ZenCard {
                    CayThienView(streak: streakViewModel.streak, stage: streakViewModel.stage)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
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
}
