import SwiftUI

// MARK: - SPEC §2.2 Onboarding — 3-page introduction (redesigned)

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
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
            // Warm paper background: reuse the shared suongSom three-stop gradient
            // from ThoiGian so onboarding shares the morning palette (Task 12.1:
            // no inline Color(hex:) outside Constants / ThoiGian token sources).
            LinearGradient(
                colors: ThoiGian.suongSom.colors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorative soft sage halo behind illustrations
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ZenColor.zenSage.opacity(0.16),
                            ZenColor.zenSage.opacity(0)
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 260
                    )
                )
                .frame(width: 520, height: 520)
                .offset(y: -120)
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                // Skip button row
                HStack {
                    Spacer()
                    Button {
                        withAnimation { completeOnboarding() }
                    } label: {
                        Text("Bỏ qua")
                            .font(ZenFont.body())
                            .foregroundColor(ZenColor.zenBrown.opacity(0.65))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(Color.white.opacity(0.5))
                            )
                            .overlay(
                                Capsule().stroke(ZenColor.zenBrown.opacity(0.12), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Bỏ qua phần giới thiệu")
                    .accessibilityHint("Bỏ qua và bắt đầu sử dụng ứng dụng ngay")
                }

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

                // Progress bar
                onboardingProgressBar
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
                    .accessibilityLabel("Trang \(currentPage + 1) trong \(pages.count)")
                    .accessibilityHidden(true)

                // Action: "Bắt đầu" on last page, else "Tiếp theo"
                VStack(spacing: 0) {
                    if currentPage == pages.count - 1 {
                        ZenButton("Bắt đầu", variant: .primary) {
                            withAnimation { completeOnboarding() }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                        .accessibilityLabel("Bắt đầu")
                        .accessibilityHint("Hoàn tất giới thiệu và bắt đầu sử dụng ứng dụng")
                    } else {
                        ZenButton("Tiếp theo", variant: .primary) {
                            withAnimation { currentPage += 1 }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                        .accessibilityLabel("Tiếp theo")
                        .accessibilityHint("Chuyển sang trang giới thiệu tiếp theo")
                    }
                }
            }
        }
    }

    // MARK: - Progress bar

    private var onboardingProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(ZenColor.zenBrown.opacity(0.12))
                    .frame(height: 4)
                // Fill — sage gradient for subtle warmth
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [ZenColor.zenSage, ZenColor.zenSageLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(4, geo.size.width * CGFloat(currentPage + 1) / CGFloat(pages.count)),
                        height: 4
                    )
                    .animation(.easeInOut(duration: 0.35), value: currentPage)
            }
        }
        .frame(height: 4)
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

    @State private var contentOpacity: Double = 0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Illustration at 160×160 pt
            Group {
                switch page.viewType {
                case .teaPot:
                    OnboardingTeaPotArt()
                case .drop:
                    OnboardingDropArt()
                case .smoke:
                    OnboardingSmokeArt()
                }
            }
            .frame(width: 160, height: 160)
            .foregroundColor(ZenColor.zenBrownDark)
            .accessibilityHidden(true) // purely decorative illustrations

            VStack(spacing: 16) {
                Text(page.title)
                    .font(ZenFont.title())
                    .foregroundColor(ZenColor.zenBrownDark)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text(page.subtitle)
                    .font(ZenFont.body())
                    .foregroundColor(ZenColor.zenBrown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }
            // 0.4s opacity fade-in on page activation
            .opacity(contentOpacity)
            .onAppear {
                if isActive {
                    withAnimation(.easeIn(duration: 0.4)) {
                        contentOpacity = 1
                    }
                }
            }
            .onChange(of: isActive) { _, active in
                if active {
                    contentOpacity = 0
                    withAnimation(.easeIn(duration: 0.4)) {
                        contentOpacity = 1
                    }
                }
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Artworks

struct OnboardingTeaPotArt: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            var path = Path()

            // Thân ấm
            path.addEllipse(in: CGRect(x: w*0.2, y: h*0.4, width: w*0.6, height: h*0.5))
            // Nắp
            path.addEllipse(in: CGRect(x: w*0.35, y: h*0.35, width: w*0.3, height: h*0.1))
            path.addEllipse(in: CGRect(x: w*0.45, y: h*0.3, width: w*0.1, height: h*0.08))
            // Vòi
            var spout = Path()
            spout.move(to: CGPoint(x: w*0.25, y: h*0.55))
            spout.addQuadCurve(to: CGPoint(x: w*0.05, y: h*0.45), control: CGPoint(x: w*0.1, y: h*0.55))
            spout.addQuadCurve(to: CGPoint(x: w*0.2, y: h*0.65), control: CGPoint(x: w*0.05, y: h*0.5))
            context.fill(path, with: .color(ZenColor.zenBrownDark))
            context.fill(spout, with: .color(ZenColor.zenBrownDark))

            // Quai ấm
            var handle = Path()
            handle.move(to: CGPoint(x: w*0.75, y: h*0.5))
            handle.addQuadCurve(to: CGPoint(x: w*0.7, y: h*0.8), control: CGPoint(x: w*0.95, y: h*0.65))
            context.stroke(handle, with: .color(ZenColor.zenBrownDark), lineWidth: 6)
        }
    }
}

struct OnboardingDropArt: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            var path = Path()

            // Giọt nước cách điệu
            path.move(to: CGPoint(x: w*0.5, y: h*0.1))
            path.addCurve(to: CGPoint(x: w*0.8, y: h*0.7), control1: CGPoint(x: w*0.5, y: h*0.4), control2: CGPoint(x: w*0.8, y: h*0.5))
            path.addCurve(to: CGPoint(x: w*0.2, y: h*0.7), control1: CGPoint(x: w*0.8, y: h*0.95), control2: CGPoint(x: w*0.2, y: h*0.95))
            path.addCurve(to: CGPoint(x: w*0.5, y: h*0.1), control1: CGPoint(x: w*0.2, y: h*0.5), control2: CGPoint(x: w*0.5, y: h*0.4))

            context.fill(path, with: .color(ZenColor.zenSage))

            // Vòng sóng nước (stroke)
            var ripple = Path()
            ripple.addEllipse(in: CGRect(x: w*0.1, y: h*0.85, width: w*0.8, height: h*0.15))
            context.stroke(ripple, with: .color(ZenColor.zenSage.opacity(0.5)), lineWidth: 2)
        }
    }
}

struct OnboardingSmokeArt: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            func drawSmoke(startX: CGFloat) {
                var path = Path()
                path.move(to: CGPoint(x: startX, y: h*0.9))
                path.addCurve(to: CGPoint(x: startX + w*0.2, y: h*0.5),
                              control1: CGPoint(x: startX - w*0.1, y: h*0.7),
                              control2: CGPoint(x: startX + w*0.3, y: h*0.6))
                path.addCurve(to: CGPoint(x: startX - w*0.1, y: h*0.1),
                              control1: CGPoint(x: startX + w*0.1, y: h*0.3),
                              control2: CGPoint(x: startX - w*0.2, y: h*0.2))
                context.stroke(path, with: .color(ZenColor.zenBrownDark.opacity(0.6)), lineWidth: 4)
            }

            drawSmoke(startX: w*0.3)
            drawSmoke(startX: w*0.5)
            drawSmoke(startX: w*0.7)
        }
    }
}
