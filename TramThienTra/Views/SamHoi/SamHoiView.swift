import SwiftUI

// MARK: - Phong Sám Hối — Repentance Room (tabbed: Sám hối + Kinh tụng)
//
// Follows BuongBoView architecture: dedicated ViewModel, full-screen presentation,
// shared design-system components (NenDongView, ZenScreenHeader, ZenCard,
// ZenTextField, NutGiotNuocView, KhoiTanView).
// Privacy by design: NO data persistence.

struct SamHoiView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var viewModel = SamHoiViewModel()
    @EnvironmentObject private var thoiGianVM: ThoiGianViewModel

    // MARK: - Six-sense rotating prompts

    @State private var currentPromptIndex = 0
    private static let sixSensePrompts: [String] = [
        "Mắt đã nhìn thấy gì gây tổn thương?",
        "Tai đã nghe điều gì bất thiện?",
        "Mũi đã tham đắm hương gì?",
        "Miệng đã nói lời nào gây khổ?",
        "Thân đã làm điều gì bất an?",
        "Tâm đã nghĩ gì bất thiện?"
    ]

    private let promptTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    // MARK: - Celebration animation state

    @State private var showQuote = false
    @State private var formVisible = true
    @State private var buttonVisible = true
    @State private var currentQuoteIndex = 0

    // MARK: - Repentance Quotes

    private static let repentanceQuotes: [(quote: String, author: String)] = [
        ("Sám hối là cánh cửa mở ra sự tự do nội tâm.", ""),
        ("Nhận ra lỗi lầm là bước đầu tiên của trí tuệ.", ""),
        ("Buông bỏ lỗi xưa, đón nhận ngày mới với tâm thanh tịnh.", ""),
        ("Mỗi lần sám hối là một lần tái sinh, nhẹ nhàng và trong sáng hơn.", ""),
        ("Nước mắt sám hối tưới mát tâm hồn khô cằn.", ""),
        ("Ai biết quay đầu, người ấy đã đến bờ giác ngộ.", ""),
        ("Lòng từ bi bắt đầu từ sự thành thật với chính mình.", ""),
        ("Sám hối không phải là tự trách, mà là tự thương.", ""),
        ("Khi tâm biết hổ thẹn, đó là lúc thiện lành nảy mầm.", ""),
        ("Đừng sợ bóng tối quá khứ, hãy thắp đèn hiện tại.", ""),
        ("Mỗi lỗi lầm là một bài học, mỗi sám hối là một bước tiến.", ""),
        ("Tâm thanh tịnh không phải không có lỗi, mà là biết sửa lỗi.", ""),
        ("Sám hối chân thành như mưa rửa sạch bụi trần.", ""),
        ("Người biết sám hối là người dũng cảm nhất.", ""),
        ("Buông xuống gánh nặng lỗi lầm, bước đi trong an lạc.", ""),
    ]

    private var isCelebrating: Bool {
        viewModel.isReleasing || showQuote || !formVisible || !buttonVisible
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            NenDongView()
                .ignoresSafeArea()

            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissKeyboard()
                }

            VStack(spacing: 0) {
                ZenScreenHeader(title: "Phòng Sám Hối", dismissAction: { dismiss() })

                // Custom Zen Tab Switcher
                HStack(spacing: 32) {
                    ForEach(SamHoiTab.allCases, id: \.self) { tab in
                        VStack(spacing: 6) {
                            Text(tab.rawValue)
                                .font(viewModel.selectedTab == tab ? ZenFont.headline() : ZenFont.body())
                                .foregroundColor(viewModel.selectedTab == tab ? thoiGianVM.current.textPrimary : thoiGianVM.current.textSecondary)
                                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedTab)
                            
                            // Indicator
                            Rectangle()
                                .fill(viewModel.selectedTab == tab ? thoiGianVM.current.glowTint : Color.clear)
                                .frame(height: 2)
                                .cornerRadius(1)
                                .padding(.horizontal, 8)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectedTab = tab
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .accessibilityLabel("Chuyển đổi giữa Sám hối và Kinh tụng")
                .accessibilityHint("Chọn mục bạn muốn xem")

                // Tab content
                if viewModel.selectedTab == .samHoi {
                    samHoiTabContent
                } else {
                    kinhTungTabContent
                }
            }

            // Celebration overlay — quote displayed after smoke animation
            if showQuote {
                ZStack {
                    Color.black.opacity(0.1)
                    quoteOverlayView
                }
                .ignoresSafeArea()
                .transition(.opacity)
            }
        }
    }

    // MARK: - Sam Hoi Tab Content

    private var samHoiTabContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Rotating six-sense prompt
                    Text(Self.sixSensePrompts[currentPromptIndex])
                        .font(ZenFont.title())
                        .foregroundColor(thoiGianVM.current.textPrimary)
                        .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                        .multilineTextAlignment(.leading)
                        .id(currentPromptIndex)
                        .transition(.opacity)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: currentPromptIndex)
                        .onReceive(promptTimer) { _ in
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.5)) {
                                currentPromptIndex = (currentPromptIndex + 1) % Self.sixSensePrompts.count
                            }
                        }
                        .accessibilityLabel("Gợi ý sám hối: \(Self.sixSensePrompts[currentPromptIndex])")

                    // Helper text
                    Text("Lắng lòng quán chiếu sáu căn, thành tâm sám hối những điều đã gây tổn thương.")
                        .font(ZenFont.caption())
                        .foregroundColor(thoiGianVM.current.textSecondary)
                        .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                        .multilineTextAlignment(.leading)
                        .accessibilityAddTraits(.isStaticText)

                    // Main repentance text field
                    ZenCard {
                        ZenTextField(
                            placeholder: "Viết ra những điều bạn muốn sám hối…",
                            text: $viewModel.text,
                            limit: nil,
                            multiline: true,
                            minHeight: 180,
                            maxHeight: 300
                        )
                    }
                    .accessibilityLabel("Nhập nội dung sám hối")
                    .accessibilityHint("Viết ra những điều bạn muốn sám hối qua sáu căn")

                    // Transformation vow text field
                    ZenCard {
                        ZenTextField(
                            placeholder: "Nguyện chuyển hoá: Bạn sẽ làm khác thế nào?",
                            text: $viewModel.vowText,
                            limit: nil,
                            multiline: true,
                            minHeight: 60,
                            maxHeight: 120
                        )
                    }
                    .accessibilityLabel("Nguyện chuyển hoá")
                    .accessibilityHint("Viết ra cách bạn sẽ hành động khác đi")
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .opacity(formVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.5), value: formVisible)

            // Smoke overlay
            if viewModel.isReleasing {
                HStack {
                    Spacer()
                    HuongTramView()
                        .frame(width: 200, height: 250)
                        .transition(.opacity)
                        .accessibilityHidden(true)
                    Spacer()
                }
            }

            // Submit button
            NutGiotNuocView(
                isEnabled: viewModel.canSubmit && !isCelebrating,
                action: {
                    dismissKeyboard()
                    startCelebration()
                },
                icon: "hands.sparkles.fill",
                label: "Sám hối",
                hint: viewModel.canSubmit
                    ? "Sám hối những điều bạn đã viết"
                    : "Hãy viết điều gì đó trước khi sám hối"
            )
            .disabled(!viewModel.canSubmit || isCelebrating)
            .padding(.top, 8)
            .padding(.bottom, 24)
            .opacity(buttonVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: buttonVisible)
        }
    }

    // MARK: - Kinh Tung Tab Content

    private var kinhTungTabContent: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                // Sutra title
                Text("Sám Hối Sáu Căn")
                    .font(ZenFont.title())
                    .foregroundColor(thoiGianVM.current.textPrimary)
                    .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityAddTraits(.isHeader)

                // Attribution
                Text("Theo truyền thống Phật giáo Việt Nam")
                    .font(ZenFont.caption())
                    .foregroundColor(thoiGianVM.current.textSecondary)
                    .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer().frame(height: 8)

                // Six sutra sections
                ForEach(Array(Self.sutraSections.enumerated()), id: \.element.title) { index, section in
                    sutraSectionView(section)
                    
                    if index < Self.sutraSections.count - 1 {
                        Text("• ✤ •")
                            .font(.system(size: 14))
                            .foregroundColor(thoiGianVM.current.textSecondary.opacity(0.5))
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 48)
        }
    }


    // MARK: - Sutra Section View

    private func sutraSectionView(_ section: SutraSection) -> some View {
        VStack(alignment: .center, spacing: 12) {
            Text(section.title)
                .font(ZenFont.headline())
                .foregroundColor(thoiGianVM.current.textPrimary)
                .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                .accessibilityAddTraits(.isHeader)

            Text(section.verse)
                .font(ZenFont.body())
                .foregroundColor(thoiGianVM.current.textSecondary)
                .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                .lineSpacing(8)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isStaticText)
        }
    }

    // MARK: - Sutra Data

    private struct SutraSection {
        let title: String
        let verse: String
    }

    private static let sutraSections: [SutraSection] = [
        SutraSection(
            title: "Nhãn Căn — Mắt",
            verse: """
            Nhãn căn tham sắc, mắt nhìn bốn phương,
            Thấy điều bất chính, khởi niệm tà vương.
            Nay con sám hối, nguyện dứt lỗi lầm,
            Mắt nhìn chánh pháp, tâm hướng thiện tâm.
            Nguyện con từ nay, mắt thấy từ bi,
            Nhìn đời bằng mắt thương yêu, hoan hỷ.
            """
        ),
        SutraSection(
            title: "Nhĩ Căn — Tai",
            verse: """
            Nhĩ căn tham thanh, tai nghe thị phi,
            Lời hay tiếng dở, phân biệt sân si.
            Nay con sám hối, nguyện lắng tâm nghe,
            Tiếng chuông chánh niệm, giác ngộ bốn bề.
            Nguyện con từ nay, tai nghe pháp âm,
            Lắng nghe khổ đau, thấu hiểu thậm thâm.
            """
        ),

        SutraSection(
            title: "Tỷ Căn — Mũi",
            verse: """
            Tỷ căn tham hương, mũi đắm mùi trần,
            Hương thơm quyến rũ, mê đắm bội phần.
            Nay con sám hối, nguyện buông tham cầu,
            Hương giới thanh tịnh, thơm ngát nhiệm mầu.
            Nguyện con từ nay, mũi ngửi hương thiền,
            Giới hương định huệ, an lạc triền miên.
            """
        ),
        SutraSection(
            title: "Thiệt Căn — Lưỡi",
            verse: """
            Thiệt căn tham vị, lưỡi nếm ngọt bùi,
            Nói lời ác độc, gây khổ cho người.
            Nay con sám hối, nguyện giữ khẩu nghiệp,
            Lời nói từ hoà, như nước cam diệp.
            Nguyện con từ nay, lưỡi nói lời lành,
            Tụng kinh niệm Phật, tâm được an bình.
            """
        ),

        SutraSection(
            title: "Thân Căn — Thân",
            verse: """
            Thân căn tham xúc, thân đắm dục trần,
            Sát sinh hại vật, tạo nghiệp vô ngần.
            Nay con sám hối, nguyện giữ thân nghiệp,
            Thân hành thiện sự, công đức chồng chất.
            Nguyện con từ nay, thân làm việc lành,
            Phụng sự chúng sinh, tâm nguyện chí thành.
            """
        ),
        SutraSection(
            title: "Ý Căn — Tâm",
            verse: """
            Ý căn tham pháp, tâm khởi vọng tưởng,
            Tham sân si mạn, phiền não vô lượng.
            Nay con sám hối, nguyện tịnh ý căn,
            Chánh niệm chánh định, trí tuệ phát sanh.
            Nguyện con từ nay, tâm ý thanh lương,
            Từ bi hỷ xả, soi sáng mười phương.
            """
        ),
    ]


    // MARK: - Quote Overlay

    private var quoteOverlayView: some View {
        VStack(spacing: 16) {
            Text(Self.repentanceQuotes[currentQuoteIndex].quote)
                .font(ZenFont.title())
                .foregroundColor(thoiGianVM.current.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if !Self.repentanceQuotes[currentQuoteIndex].author.isEmpty {
                Text("— \(Self.repentanceQuotes[currentQuoteIndex].author)")
                    .font(ZenFont.caption())
                    .foregroundColor(thoiGianVM.current.textSecondary)
            }
        }
        .opacity(showQuote ? 1 : 0)
        .scaleEffect(showQuote ? 1 : 0.9)
        .animation(.easeInOut(duration: 0.5), value: showQuote)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Dismiss keyboard

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }


    // MARK: - Celebration Animation

    /// Orchestrates the multi-phase celebration animation sequence.
    ///
    /// - Phase 1: Button fades out (0.3s), form fades out (0.5s)
    /// - Phase 2: Smoke animation plays via viewModel.isReleasing (~2.5s)
    /// - Phase 3: Show inspirational quote (fade in 0.7s, hold 3.0s, fade out 0.7s)
    /// - Phase 4: Fade form and button back in (0.7s) with cleared fields
    private func startCelebration() {
        let useReducedMotion = reduceMotion

        // Pick a random quote
        currentQuoteIndex = Int.random(in: 0..<Self.repentanceQuotes.count)

        // Phát tiếng chuông gia trì khi bắt đầu sám hối
        AudioService.shared.playEffect(name: "bell")

        // Button fades out first
        withAnimation(.easeInOut(duration: 0.3)) {
            buttonVisible = false
        }

        // Form fades out
        withAnimation(.easeInOut(duration: 0.5)) {
            formVisible = false
        }

        // Start smoke animation after button fade
        let smokeDelay: Double = useReducedMotion ? 0.1 : 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + smokeDelay) {
            Task {
                await viewModel.releaseAndDismiss()
            }
        }

        // --- 15-Second Bell Sequence Timing ---
        
        // Show quote around the time smoke finishes (at t = 6.0s)
        let quoteStartTime: Double = useReducedMotion ? 0.5 : 6.0
        DispatchQueue.main.asyncAfter(deadline: .now() + quoteStartTime) {
            // Fade in quote over 1.5s (fully visible at t=7.5s)
            withAnimation(.easeInOut(duration: 1.5)) {
                showQuote = true
            }
        }

        // Dismiss quote (hold until t=13.0s, then fade out over 2.0s to match bell end at t=15.0s)
        let quoteDuration = 5.5 // 7.5s - 13.0s
        let quoteFadeOut = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + quoteStartTime + 1.5 + quoteDuration) {
            withAnimation(.easeInOut(duration: quoteFadeOut)) {
                showQuote = false
            }
        }

        // Form and button fade back in (starts at t=15.2s, right after bell finishes ringing)
        DispatchQueue.main.asyncAfter(deadline: .now() + quoteStartTime + 1.5 + quoteDuration + quoteFadeOut + 0.2) {
            withAnimation(.easeInOut(duration: 0.8)) {
                formVisible = true
                buttonVisible = true
            }
        }
    }
}

#Preview {
    SamHoiView()
        .environmentObject(ThoiGianViewModel())
}