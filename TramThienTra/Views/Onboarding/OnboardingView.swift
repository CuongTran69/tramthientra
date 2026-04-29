import SwiftUI

// MARK: - SPEC §2.2 Onboarding — 4-page introduction with notification permission step

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel
    @State private var currentPage = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Trạm Thiền Trà",
            subtitle: "Hương trà tĩnh tâm, hơi thở an trí. Hãy để mỗi ngày là một bước chân thong dong trở về với sự bình yên vẹn tròn.",
            viewType: .teaPot
        ),
        OnboardingPage(
            title: "Nghi thức Biết ơn",
            subtitle: "Nhặt nhạnh những niềm vui bé nhỏ. Từng ân tình được lưu lại tựa giọt sương mai đọng trên phiến lá, trong trẻo và bình an.",
            viewType: .drop
        ),
        OnboardingPage(
            title: "Nghi thức Buông bỏ",
            subtitle: "Viết ra những phiền muộn vương vấn, rồi nhắm mắt để chúng tan biến theo làn khói mờ. Trả lại cho tâm hồn sự tĩnh tại vốn có.",
            viewType: .smoke
        ),
        OnboardingPage(
            title: "Nhắc nhở hàng ngày",
            subtitle: "Để mỗi ngày đều trọn vẹn, hãy để Trạm Thiền Trà nhẹ nhàng nhắc bạn dành chút thời gian tạ ơn cuộc sống.",
            viewType: .bell
        )
    ]

    /// Index of the notification page (last page)
    private var notificationPageIndex: Int { pages.count - 1 }

    var body: some View {
        ZStack {
            NenDongView()
                .ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            thoiGianVM.current.textPrimary.opacity(0.08),
                            thoiGianVM.current.textPrimary.opacity(0)
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .offset(y: -120)
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                // Dismiss button (ZenScreenHeader pattern)
                HStack {
                    Spacer()
                    Button {
                        withAnimation { completeOnboarding() }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(thoiGianVM.current.navIconTint)
                            .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.white.opacity(0.25)))
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Bỏ qua phần giới thiệu")
                    .accessibilityHint("Bỏ qua và bắt đầu sử dụng ứng dụng ngay")
                }
                .padding(.trailing, 16)
                .padding(.top, 8)

                // Page content — TabView drives page swiping
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            isActive: currentPage == index,
                            reduceMotion: reduceMotion
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(
                    reduceMotion ? .easeInOut(duration: 0.3) : nil,
                    value: currentPage
                )

                // Dot indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentPage
                                  ? thoiGianVM.current.textPrimary
                                  : thoiGianVM.current.textSecondary.opacity(0.4))
                            .frame(width: index == currentPage ? 10 : 8,
                                   height: index == currentPage ? 10 : 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 24)
                .accessibilityLabel("Trang \(currentPage + 1) trong \(pages.count)")

                // MARK: - Action buttons

                VStack(spacing: 12) {
                    if currentPage == notificationPageIndex {
                        // MARK: - SPEC: Notification page — accept / skip actions

                        ZenButton("Bật thông báo", variant: .primary, icon: "bell.fill") {
                            Task {
                                let granted = await NotificationService.shared.requestAuthorization()
                                if granted {
                                    UserDefaults.standard.set(true, forKey: Constants.dailyReminderEnabledKey)
                                    NotificationService.shared.scheduleDailyReminder()
                                } else {
                                    UserDefaults.standard.set(false, forKey: Constants.dailyReminderEnabledKey)
                                }
                                withAnimation { completeOnboarding() }
                            }
                        }
                        .padding(.horizontal, 20)
                        .accessibilityLabel("Bật thông báo")
                        .accessibilityHint("Cho phép nhắc nhở hàng ngày và hoàn tất giới thiệu")

                        Button {
                            UserDefaults.standard.set(false, forKey: Constants.dailyReminderEnabledKey)
                            withAnimation { completeOnboarding() }
                        } label: {
                            Text("Bỏ qua")
                                .font(ZenFont.subheadline())
                                .foregroundColor(thoiGianVM.current.textSecondary)
                                .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                                .frame(minWidth: 44, minHeight: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 20)
                        .accessibilityLabel("Bỏ qua")
                        .accessibilityHint("Bỏ qua thông báo và hoàn tất giới thiệu")
                    } else {
                        // Content pages: "Tiếp theo" on all non-notification pages
                        ZenButton("Tiếp theo", variant: .primary) {
                            withAnimation { currentPage += 1 }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                        .accessibilityLabel("Tiếp theo")
                        .accessibilityHint("Chuyển sang trang giới thiệu tiếp theo")
                    }
                }
            }
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: Constants.hasCompletedOnboardingKey)
        hasCompletedOnboarding = true
    }
}

// MARK: - Illustration type

enum IllustrationType {
    case teaPot, drop, smoke, bell
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let viewType: IllustrationType
}

// MARK: - Per-page view with fade-in animation

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    let reduceMotion: Bool
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel

    @State private var contentOpacity: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Real component illustrations at 180x180 pt
            Group {
                switch page.viewType {
                case .teaPot:
                    TeapotSceneView()
                case .drop:
                    // Decorative-only drop: use the visual elements but not interactive
                    NutGiotNuocView(isEnabled: false, action: {}, icon: "drop.fill", label: "Giọt nước biết ơn")
                case .smoke:
                    KhoiTanView()
                case .bell:
                    // MARK: - SPEC: Bell illustration for notification onboarding page
                    Image(systemName: "bell.badge.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(ZenColor.zenGold)
                }
            }
            .frame(width: 180, height: 180)
            .shadow(color: ZenColor.zenGold.opacity(0.25), radius: 16, x: 0, y: 0)
            .accessibilityHidden(true)

            ZenCard {
                VStack(spacing: 16) {
                    Text(page.title)
                        .font(page.viewType == .teaPot ? ZenFont.display() : ZenFont.title())
                        .foregroundColor(thoiGianVM.current.textPrimary)
                        .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                        .multilineTextAlignment(.center)

                    Text(page.subtitle)
                        .font(ZenFont.body())
                        .foregroundColor(thoiGianVM.current.textSecondary)
                        .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
            Spacer()
        }
        .opacity(contentOpacity)
        .offset(y: contentOpacity == 1 ? 0 : 16)
        .onAppear {
            if isActive {
                if reduceMotion {
                    contentOpacity = 1
                } else {
                    withAnimation(.easeIn(duration: 0.4)) {
                        contentOpacity = 1
                    }
                }
            }
        }
        .onChange(of: isActive) { _, active in
            if active {
                contentOpacity = 0
                if reduceMotion {
                    contentOpacity = 1
                } else {
                    withAnimation(.easeIn(duration: 0.4)) {
                        contentOpacity = 1
                    }
                }
            }
        }
    }
}
