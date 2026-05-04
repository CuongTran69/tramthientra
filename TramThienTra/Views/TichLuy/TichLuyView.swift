import SwiftUI
import SwiftData

// MARK: - SPEC §2.3 Gratitude entry form — ZenTextField, ZenButton (redesigned)

struct TichLuyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TichLuyViewModel()
    @EnvironmentObject private var streakViewModel: StreakViewModel
    @EnvironmentObject private var thoiGianVM: ThoiGianViewModel

    // Celebration animation state
    @State private var showGratitudeAnimation = false
    @State private var showQuote = false
    @State private var formVisible = true
    @State private var buttonVisible = true
    @State private var currentQuoteIndex = 0

    /// Whether celebration is in progress (disables save button)
    private var isCelebrating: Bool {
        showGratitudeAnimation || showQuote || !formVisible || !buttonVisible
    }

    // MARK: - Gratitude Quotes

    private static let gratitudeQuotes: [(quote: String, author: String)] = [
        ("Lòng biết ơn biến những gì ta có thành sự đủ đầy viên mãn.", ""),
        ("Một chén trà trong, một nụ cười nhẹ, ngần ấy thôi đã là hạnh phúc trọn vẹn.", ""),
        ("Thở vào tâm tĩnh lặng, thở ra miệng mỉm cười.", ""),
        ("Trân trọng trọn vẹn từng khoảnh khắc hiện tại, bình yên sẽ tự tìm về.", ""),
        ("Hạnh phúc không nằm ở việc sở hữu nhiều hơn, mà là biết ơn những gì ta đang có.", ""),
        ("Khi tĩnh lặng nhìn lại, mọi điều nhỏ bé đều là một ân phước.", ""),
        ("Đóa hoa hạnh phúc chỉ nở rộ trên mảnh đất của lòng biết ơn.", ""),
        ("Chậm lại một chút để lắng nghe nhịp đập của sự sống đang thầm lặng trôi.", ""),
        ("Mỗi giọt sương mai, mỗi ngọn gió mát đều mang đến một lời nhắc nhở nhẹ nhàng.", ""),
        ("Mỗi buổi sáng thức dậy là một món quà mới để ta thêm trân quý cuộc đời.", ""),
        ("Bình yên không phải là khi đời lặng im, mà là khi lòng không gợn sóng.", ""),
        ("Sự tĩnh tại thực sự bắt nguồn từ một trái tim biết đón nhận và tha thứ.", ""),
        ("Chén trà ngon nhất là chén trà được thưởng thức bằng trọn vẹn sự chú tâm.", ""),
        ("Không có điều gì là hiển nhiên, mọi thứ đến trong đời đều xứng đáng được nói lời cảm ơn.", ""),
        ("Khởi đầu ngày mới bằng lòng biết ơn, kết thúc một ngày bằng sự thanh thản.", ""),
        ("Hạt giống an nhiên nảy mầm từ phần tĩnh lặng nhất của tâm hồn.", ""),
        ("Một chút lòng biết ơn gom nhặt mỗi ngày, sẽ tưới mát cả một đời người.", ""),
        ("Chỉ khi lòng nhẹ nhàng buông bỏ những ưu phiền, niềm vui mới có không gian đậu lại.", ""),
        ("Mái hiên tĩnh lặng, gió nhẹ mây trôi. Trân trọng hiện tại, vạn sự tuỳ duyên.", ""),
        ("Trái tim luôn ghi nhớ những ân tình là khởi nguồn cho vạn sự bình an.", "")
    ]

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
                // Header
                ZenScreenHeader(title: "Bi\u{1EBF}t \u{01A1}n", dismissAction: { dismiss() })

                // Form content — fades out during celebration
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Section label + decoration
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Lưu giữ ba điều biết ơn ngày hôm nay")
                                .font(ZenFont.subheadline())
                                .foregroundColor(thoiGianVM.current.textSecondary)
                                .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                                .accessibilityAddTraits(.isHeader)

                            LinearGradient(
                                colors: [ZenColor.zenSage.opacity(0), ZenColor.zenSage.opacity(0.5), ZenColor.zenSage.opacity(0)],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .frame(height: 1)
                            .padding(.horizontal, 40)
                        }
                        .padding(.top, 24)

                        ZenCard {
                            VStack(spacing: 12) {
                                ZenTextField(
                                    placeholder: "\u{0110}i\u{1EC1}u t\u{1EA1} \u{01A1}n th\u{1EE9} nh\u{1EA5}t\u{2026}",
                                    text: $viewModel.item1,
                                    limit: Constants.maxCharacterLimit,
                                    multiline: true
                                )
                                .accessibilityLabel("\u{0110}i\u{1EC1}u t\u{1EA1} \u{01A1}n th\u{1EE9} nh\u{1EA5}t")

                                ZenTextField(
                                    placeholder: "\u{0110}i\u{1EC1}u t\u{1EA1} \u{01A1}n th\u{1EE9} hai\u{2026}",
                                    text: $viewModel.item2,
                                    limit: Constants.maxCharacterLimit,
                                    multiline: true
                                )
                                .accessibilityLabel("\u{0110}i\u{1EC1}u t\u{1EA1} \u{01A1}n th\u{1EE9} hai")

                                ZenTextField(
                                    placeholder: "\u{0110}i\u{1EC1}u t\u{1EA1} \u{01A1}n th\u{1EE9} ba\u{2026}",
                                    text: $viewModel.item3,
                                    limit: Constants.maxCharacterLimit,
                                    multiline: true
                                )
                                .accessibilityLabel("\u{0110}i\u{1EC1}u t\u{1EA1} \u{01A1}n th\u{1EE9} ba")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
                .opacity(formVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: formVisible)

                // Save button — separate opacity for synchronized fade with animation drop
                NutGiotNuocView(isEnabled: viewModel.isFormValid && !viewModel.isSaving && !isCelebrating) {
                    performSave()
                }
                .disabled(!viewModel.isFormValid || viewModel.isSaving || isCelebrating)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .opacity(buttonVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: buttonVisible)
            }

            // Celebration overlay — transparent, NenDongView shows through
            if showGratitudeAnimation || showQuote {
                ZStack {
                    // Very subtle dark wash for contrast
                    Color.black.opacity(0.1)

                    if showGratitudeAnimation {
                        GratitudeDropAnimationView {
                            // When drop animation completes, transition to quote
                            showGratitudeAnimation = false
                            withAnimation(.easeInOut(duration: 0.7)) {
                                showQuote = true
                            }
                        }
                    }

                    if showQuote {
                        quoteOverlayView
                    }
                }
                .ignoresSafeArea()
                .transition(.opacity)
            }
        }
    }

    // MARK: - Celebration Views

    /// Inspirational quote displayed after the ripple animation.
    private var quoteOverlayView: some View {
        VStack(spacing: 16) {
            Text(Self.gratitudeQuotes[currentQuoteIndex].quote)
                .font(ZenFont.title())
                .foregroundColor(thoiGianVM.current.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if !Self.gratitudeQuotes[currentQuoteIndex].author.isEmpty {
                Text("\u{2014} \(Self.gratitudeQuotes[currentQuoteIndex].author)")
                    .font(ZenFont.caption())
                    .foregroundColor(thoiGianVM.current.textSecondary)
            }
        }
        .opacity(showQuote ? 1 : 0)
        .scaleEffect(showQuote ? 1 : 0.9)
        .animation(.easeInOut(duration: 0.5), value: showQuote)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Actions

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func performSave() {
        dismissKeyboard()
        Task {
            do {
                try await viewModel.saveGratitude(modelContext: modelContext)
                streakViewModel.incrementStreak()
                startCelebration()
            } catch {
                print("[TichLuy] performSave failed: \(error)")
            }
        }
    }

    /// Orchestrates the multi-phase celebration animation sequence.
    ///
    /// - Phase 1: Button fades out (0.3s), form fades out (0.5s) — synchronized
    /// - Phase 2: Water drop appears at top, falls to center, ripples (~4.3s) — skipped when Reduce Motion is enabled
    /// - Phase 3: Show inspirational quote (fade in 0.7s, hold 3.0s, fade out 0.7s)
    /// - Phase 4: Fade form and button back in (0.7s) with cleared fields ready for next entry
    private func startCelebration() {
        let useReducedMotion = UIAccessibility.isReduceMotionEnabled

        // Pick a random quote
        currentQuoteIndex = Int.random(in: 0..<Self.gratitudeQuotes.count)

        // Button fades out FIRST (0.3s) — syncs with drop appearing at top
        withAnimation(.easeInOut(duration: 0.3)) {
            buttonVisible = false
        }

        // Form fades out slightly slower (0.5s)
        withAnimation(.easeInOut(duration: 0.5)) {
            formVisible = false
        }

        // Start drop animation after button has faded (0.3s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if useReducedMotion {
                withAnimation(.easeInOut(duration: 0.7)) {
                    showQuote = true
                }
            } else {
                showGratitudeAnimation = true
                // GratitudeDropAnimationView handles timing internally
                // and calls onComplete to trigger showQuote
            }
        }

        // Schedule quote dismissal and form return
        if useReducedMotion {
            let quoteEnd = 0.3 + 0.7 + 3.0
            DispatchQueue.main.asyncAfter(deadline: .now() + quoteEnd) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    showQuote = false
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + quoteEnd + 0.8) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    formVisible = true
                    buttonVisible = true
                }
            }
            return
        }

        // Normal motion: drop animation takes ~4.3s, then onComplete triggers quote
        let quoteStartTime = 0.3 + 4.3 + 0.1
        let quoteDuration = 3.0
        let quoteFadeOut = 0.7

        DispatchQueue.main.asyncAfter(deadline: .now() + quoteStartTime + quoteDuration) {
            withAnimation(.easeInOut(duration: quoteFadeOut)) {
                showQuote = false
            }
        }

        // Form AND button fade back in together
        DispatchQueue.main.asyncAfter(deadline: .now() + quoteStartTime + quoteDuration + quoteFadeOut + 0.2) {
            withAnimation(.easeInOut(duration: 0.7)) {
                formVisible = true
                buttonVisible = true
            }
        }
    }
}

// MARK: - Gratitude Drop Animation

/// Water drop appears at top, falls to center, creates ripples on impact.
/// Handles the entire drop animation sequence internally and calls `onComplete` when ripples finish.
struct GratitudeDropAnimationView: View {
    /// Callback when the entire animation finishes (ripples complete)
    var onComplete: () -> Void = {}

    // Drop position and appearance
    @State private var dropOffsetY: CGFloat = -280   // Start near top
    @State private var dropScale: CGFloat = 0.7
    @State private var dropOpacity: Double = 0       // Start invisible

    // Ripple state
    @State private var showRipples = false

    var body: some View {
        GeometryReader { geo in
            let centerY = geo.size.height / 2

            ZStack {
                // Ripple rings — appear when drop hits center
                if showRipples {
                    RippleRingsView()
                        .position(x: geo.size.width / 2, y: centerY)
                }

                // Water drop icon using custom organic shape
                InkDropShape()
                    .fill(
                        LinearGradient(
                            colors: [ZenColor.zenTeaLight, ZenColor.zenSage],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 32, height: 44)
                    .scaleEffect(dropScale)
                    .opacity(dropOpacity)
                    .position(x: geo.size.width / 2, y: centerY + dropOffsetY)
            }
        }
        .accessibilityHidden(true)
        .onAppear {
            startSequence()
        }
    }

    private func startSequence() {
        // Drop starts at top of screen, invisible
        dropOffsetY = -280  // near top
        dropScale = 0.7
        dropOpacity = 0

        // Fade in at top (synchronized with button fading out)
        withAnimation(.easeInOut(duration: 0.3)) {
            dropOpacity = 1.0
            dropScale = 0.8
        }

        // Fall from top to center (1.8s, easeIn — natural gravity, slow and gentle)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 1.8)) {
                dropOffsetY = 0     // center
                dropScale = 1.2     // grows slightly as it falls
            }
        }

        // Hit center — ripples + drop fades
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            showRipples = true

            withAnimation(.easeOut(duration: 0.8)) {
                dropScale = 0.3
                dropOpacity = 0
            }

            HapticService.shared.playLight()
        }

        // Signal completion after ripples finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.3) {
            onComplete()
        }
    }
}

// MARK: - Ripple Rings (extracted for correct animation)

/// Concentric ripple rings that expand outward on appear.
/// Uses internal @State to ensure SwiftUI sees the false->true transition.
private struct RippleRingsView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { ring in
                Circle()
                    .stroke(
                        ZenColor.zenSage.opacity(0.7 - Double(ring) * 0.12),
                        lineWidth: max(3.0 - CGFloat(ring) * 0.5, 1.0)
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(animate ? 3.5 + CGFloat(ring) * 0.8 : 0.3)
                    .opacity(animate ? 0 : 0.8)
                    .blur(radius: 2) // Added blur for a soft ink-wash ripple effect
                    .animation(
                        .easeOut(duration: 2.0).delay(Double(ring) * 0.25),
                        value: animate
                    )
            }
        }
        .onAppear {
            // Small delay so SwiftUI renders the initial state first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animate = true
            }
        }
    }
}

// MARK: - Legacy GratitudeTextField kept for backward compatibility
// New code should use ZenTextField directly.

struct GratitudeTextField: View {
    @Binding var text: String
    let placeholder: String
    let limit: Int

    var body: some View {
        ZenTextField(
            placeholder: placeholder,
            text: $text,
            limit: limit,
            multiline: true
        )
    }
}

#Preview {
    let container = try! ModelContainer(
        for: GratitudeLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return TichLuyView()
        .modelContainer(container)
        .environmentObject(ThoiGianViewModel())
        .environmentObject(StreakViewModel())
}
