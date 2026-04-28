import SwiftUI

// MARK: - SPEC §2.2 Onboarding — 3-page introduction (redesigned)

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel
    @State private var currentPage = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Chào mừng đến Trạm Thiền Trà",
            subtitle: "Mỗi ngày, một tách trà. Mỗi ngày, một bước gần hơn với con người ta.",
            viewType: .teaPot
        ),
        OnboardingPage(
            title: "Nghi thức Tích luỹ",
            subtitle: "Ghi lại 3 điều bạn biết ơn mỗi ngày. Những điều nhỏ bé thường là quý giá nhất. Như sương mai trên núi, như hương sen hồ Tây.",
            viewType: .drop
        ),
        OnboardingPage(
            title: "Nghi thức Buông bỏ",
            subtitle: "Viết ra những bực dọc, buồn phiền. Rồi buông nó đi — chúng tan theo làn khói trà, nhẹ nhàng như chưa từng có.",
            viewType: .smoke
        )
    ]

    var body: some View {
        ZStack {
            // Time-adaptive background
            NenDongView()
                .ignoresSafeArea()

            // Decorative soft halo behind illustrations — time-adaptive
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

                // Action: "Bắt đầu" on last page, else "Tiếp theo"
                VStack(spacing: 0) {
                    if currentPage == pages.count - 1 {
                        ZenButton("Bắt đầu", variant: .primary) {
                            withAnimation { completeOnboarding() }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                        .accessibilityLabel("Bắt đầu")
                        .accessibilityHint("Hoàn tất giới thiệu và bắt đầu sử dụng ứng dụng")
                    } else {
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
    case teaPot, drop, smoke
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
