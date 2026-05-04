import SwiftUI

// MARK: - SPEC §2.1 Main screen — Trà thât (redesigned)

struct TraThatView: View {
    @StateObject private var viewModel = TraThatViewModel()
    @EnvironmentObject var streakViewModel: StreakViewModel
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel
    @State private var showSettings = false
    @State private var showHistory = false
    @State private var showTichLuy = false
    @State private var showBuongBo = false
    @State private var showThienTho = false
    @State private var showSamHoi = false

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
                        accessibilityHint: "Xem lịch sử các lần ghi biết ơn"
                    ) {
                        showHistory = true
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Time greeting — contextual phrase then app name
                Text(thoiGianVM.current.greetingPhrase)
                    .font(ZenFont.title())
                    .foregroundColor(thoiGianVM.current.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .accessibilityAddTraits(.isHeader)
                    .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)

                Text("Trạm Thiền Trà")
                    .font(ZenFont.caption())
                    .foregroundColor(thoiGianVM.current.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                    .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)

                Spacer(minLength: 20)

                // Teapot canvas — 220×220 pt with gold glow shadow
                TeapotSceneView()
                    .frame(width: 220, height: 220)
                    .shadow(
                        color: ZenColor.zenGold.opacity(0.35),
                        radius: 20,
                        x: 0,
                        y: 0
                    )
                    .accessibilityLabel("Trạm Thiền Trà – ấm trà thiền định")
                    .accessibilityHidden(false)

                Spacer().frame(height: 20)

                // Streak card — elevated between teapot and dock
                ZenCard {
                    LaTraView(streak: streakViewModel.streak, stage: streakViewModel.stage)
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 16)

                // Bottom action dock — glassmorphism container
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ZenSquareButton("Biết ơn", variant: .primary, icon: "drop.fill") {
                        showTichLuy = true
                    }
                    .accessibilityLabel("Biết ơn")
                    .accessibilityHint("Mở màn hình ghi lại điều biết ơn hôm nay")

                    ZenSquareButton("Buông bỏ", variant: .secondary, icon: "leaf.fill") {
                        showBuongBo = true
                    }
                    .accessibilityLabel("Buông bỏ")
                    .accessibilityHint("Mở màn hình viết ra và buông bỏ những lo âu")

                    ZenSquareButton("Thiền Thở", variant: .secondary, icon: "wind") {
                        showThienTho = true
                    }
                    .accessibilityLabel("Thiền Thở")
                    .accessibilityHint("Mở màn hình thiền thở")

                    ZenSquareButton("Sám hối", variant: .secondary, icon: "hands.sparkles.fill") {
                        showSamHoi = true
                    }
                    .accessibilityLabel("Sám hối")
                    .accessibilityHint("Mở phòng sám hối để quán chiếu và sám hối qua sáu căn")
                }
                .padding(16)
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                thoiGianVM.current.dockOverlayColor
                                    .opacity(thoiGianVM.current.dockOverlayOpacity)
                            )
                            .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(thoiGianVM.current.dockStrokeColor, lineWidth: 1)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: ZenColor.zenBrown.opacity(0.10), radius: 20, x: 0, y: 8)
                .padding(.horizontal, 20)

                Spacer().frame(height: 32)
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
            .environmentObject(thoiGianVM)
        }
        .sheet(isPresented: $showHistory) {
            NavigationStack {
                HistoryView()
            }
            .environmentObject(thoiGianVM)
        }
        .fullScreenCover(isPresented: $showTichLuy) {
            TichLuyView()
                .environmentObject(thoiGianVM)
        }
        .fullScreenCover(isPresented: $showBuongBo) {
            BuongBoView()
                .environmentObject(thoiGianVM)
        }
        .fullScreenCover(isPresented: $showThienTho) {
            ThienThoView()
                .environmentObject(thoiGianVM)
        }
        .fullScreenCover(isPresented: $showSamHoi) {
            SamHoiView()
                .environmentObject(thoiGianVM)
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
                .foregroundColor(thoiGianVM.current.navIconTint)
                .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                .frame(width: 36, height: 36)
                .background(
                    Circle().fill(thoiGianVM.current.navIconBgColor.opacity(thoiGianVM.current.navIconBgOpacity))
                )
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }
}

#Preview {
    TraThatView()
        .environmentObject(ThoiGianViewModel())
        .environmentObject(StreakViewModel())
}
