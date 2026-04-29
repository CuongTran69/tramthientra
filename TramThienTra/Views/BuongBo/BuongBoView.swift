import SwiftUI

// MARK: - SPEC §2.4 Buông bỏ — text release view (design-system aligned)
//
// Uses ZenTextField + NutGiotNuocView for visual & interaction consistency with
// TichLuyView. Spacing follows the 8 pt grid (8/16/24/32). All interactive
// elements meet the 44x44 pt minimum touch-target rule and have explicit
// focus / disabled / loading states.

struct BuongBoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var viewModel = BuongBoViewModel()
    @EnvironmentObject private var thoiGianVM: ThoiGianViewModel

    // Celebration animation state
    @State private var showQuote = false
    @State private var formVisible = true
    @State private var buttonVisible = true
    @State private var currentQuoteIndex = 0

    // MARK: - Release Quotes

    private static let releaseQuotes: [(quote: String, author: String)] = [
        ("Buông bỏ không phải là từ bỏ, mà là trao cho mình quyền được nhẹ nhàng.", ""),
        ("Khi ta ngừng níu giữ, hai tay mới rảnh rang đón nhận điều mới.", ""),
        ("Những muộn phiền xưa cũ, hãy để gió mang đi như khói tan vào trời.", ""),
        ("Tha thứ cho người khác là món quà ta tặng chính bản thân mình.", ""),
        ("Nước chảy qua kẽ đá không giữ lại vết hằn, tâm an nhiên cũng vậy.", ""),
        ("Giữ chặt nỗi buồn như nắm cát trong tay, buông ra mới thấy nhẹ tênh.", ""),
        ("Mỗi lần buông bỏ là một lần tái sinh, nhẹ nhàng hơn, thanh thản hơn.", ""),
        ("Không phải mọi câu chuyện đều cần kết thúc đẹp, chỉ cần ta bình yên bước tiếp.", ""),
        ("Lá rụng để cây đâm chồi mới, buông xả để tâm hồn nảy mầm hy vọng.", ""),
        ("Hơi thở nhẹ nhàng, tâm trí lắng trong, bao ưu phiền dần tan theo làn khói.", ""),
        ("Đời người như dòng nước, cứ buông xuôi sẽ tự tìm được hướng đi.", ""),
        ("Buông bỏ là nghệ thuật sống nhẹ nhàng giữa muôn vàn bộn bề.", ""),
        ("Khi lòng không còn vướng bận, mỗi bước chân đều là bước chân tự do.", ""),
        ("Trà nguội rồi thì đừng tiếc, pha ấm mới, cuộc đời lại thơm.", ""),
        ("Giông bão nào rồi cũng sẽ qua, bầu trời sau mưa luôn trong xanh hơn.", "")
    ]

    private var isCelebrating: Bool {
        viewModel.isReleasing || showQuote || !formVisible || !buttonVisible
    }

    private var canRelease: Bool {
        !viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isCelebrating
    }

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
                ZenScreenHeader(title: "Buông bỏ", dismissAction: { dismiss() })

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Section helper text — caption tone, matches TichLuyView pattern
                        Text("Viết ra những muộn phiền đang vướng bận, rồi nhẹ nhàng buông bỏ. Trạm sẽ giữ kín những tâm sự này cho riêng bình yên của bạn.")
                            .font(ZenFont.caption())
                            .foregroundColor(thoiGianVM.current.textSecondary)
                            .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                            .multilineTextAlignment(.leading)
                            .accessibilityAddTraits(.isStaticText)

                        ZenCard {
                            ZenTextField(
                                placeholder: "Những gì bạn muốn buông bỏ…",
                                text: $viewModel.text,
                                limit: nil,
                                multiline: true,
                                minHeight: 200,
                                maxHeight: 320
                            )
                        }
                        .accessibilityLabel("Nhập nội dung muốn buông bỏ")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
                .opacity(formVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: formVisible)

                // Smoke overlay — outside ScrollView so it stays visible when form fades out
                if viewModel.isReleasing {
                    HStack {
                        Spacer()
                        KhoiTanView()
                            .frame(width: 200, height: 200)
                            .transition(.opacity)
                            .accessibilityHidden(true)
                        Spacer()
                    }
                }

                // Release action — circular animated button matching Biết ơn pattern
                NutGiotNuocView(
                    isEnabled: canRelease,
                    action: {
                        dismissKeyboard()
                        startCelebration()
                    },
                    icon: "leaf.fill",
                    label: "Buông bỏ",
                    hint: canRelease
                        ? "Buông bỏ những gì bạn đã viết và xóa chúng đi"
                        : "Hãy viết điều gì đó trước khi buông"
                )
                .disabled(!canRelease)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .opacity(buttonVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: buttonVisible)
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

    // MARK: - Quote Overlay

    private var quoteOverlayView: some View {
        VStack(spacing: 16) {
            Text(Self.releaseQuotes[currentQuoteIndex].quote)
                .font(ZenFont.title())
                .foregroundColor(thoiGianVM.current.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if !Self.releaseQuotes[currentQuoteIndex].author.isEmpty {
                Text("— \(Self.releaseQuotes[currentQuoteIndex].author)")
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
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
        currentQuoteIndex = Int.random(in: 0..<Self.releaseQuotes.count)

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

        // Show quote after smoke finishes (~2.5s release + delays)
        let quoteStartTime: Double = useReducedMotion ? 0.5 : 3.2
        DispatchQueue.main.asyncAfter(deadline: .now() + quoteStartTime) {
            withAnimation(.easeInOut(duration: 0.7)) {
                showQuote = true
            }
        }

        // Dismiss quote after hold
        let quoteDuration = 3.0
        let quoteFadeOut = 0.7
        DispatchQueue.main.asyncAfter(deadline: .now() + quoteStartTime + 0.7 + quoteDuration) {
            withAnimation(.easeInOut(duration: quoteFadeOut)) {
                showQuote = false
            }
        }

        // Form and button fade back in
        DispatchQueue.main.asyncAfter(deadline: .now() + quoteStartTime + 0.7 + quoteDuration + quoteFadeOut + 0.2) {
            withAnimation(.easeInOut(duration: 0.7)) {
                formVisible = true
                buttonVisible = true
            }
        }
    }
}

#Preview {
    BuongBoView()
        .environmentObject(ThoiGianViewModel())
}
