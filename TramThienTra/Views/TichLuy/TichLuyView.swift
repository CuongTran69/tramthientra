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
        ("Bi\u{1EBF}t \u{01A1}n l\u{00E0} h\u{1EA1}nh ph\u{00FA}c \u{0111}\u{01A1}n gi\u{1EA3}n nh\u{1EA5}t.", ""),
        ("Gi\u{1ECD}t n\u{01B0}\u{1EDB}c nh\u{1ECF} l\u{00E0}m \u{0111}\u{1EA7}y \u{0111}\u{1EA1}i d\u{01B0}\u{01A1}ng.", ""),
        ("M\u{1ED7}i ng\u{00E0}y \u{0111}\u{1EC1}u l\u{00E0} m\u{1ED9}t m\u{00F3}n qu\u{00E0}.", ""),
        ("H\u{1EA1}t gi\u{1ED1}ng bi\u{1EBF}t \u{01A1}n s\u{1EBD} n\u{1EDF} hoa h\u{1EA1}nh ph\u{00FA}c.", ""),
        ("L\u{00F2}ng bi\u{1EBF}t \u{01A1}n bi\u{1EBF}n nh\u{1EEF}ng g\u{00EC} ta c\u{00F3} th\u{00E0}nh \u{0111}\u{1EE7} \u{0111}\u{1EA7}y.", ""),
        ("Khi bi\u{1EBF}t \u{01A1}n, ta th\u{1EA5}y \u{0111}\u{1EDD}i \u{0111}\u{1EB9}p h\u{01A1}n.", ""),
        ("H\u{1EA1}nh ph\u{00FA}c kh\u{00F4}ng \u{1EDF} \u{0111}\u{00E2}u xa, m\u{00E0} \u{1EDF} ngay trong l\u{00F2}ng bi\u{1EBF}t \u{01A1}n.", ""),
        ("M\u{1ED9}t tr\u{00E1}i tim bi\u{1EBF}t \u{01A1}n l\u{00E0} m\u{1ED9}t tr\u{00E1}i tim h\u{1EA1}nh ph\u{00FA}c.", ""),
        ("Cu\u{1ED9}c s\u{1ED1}ng kh\u{00F4}ng ho\u{00E0}n h\u{1EA3}o, nh\u{01B0}ng lu\u{00F4}n c\u{00F3} \u{0111}i\u{1EC1}u \u{0111}\u{00E1}ng tr\u{00E2}n tr\u{1ECD}ng.", ""),
        ("Bi\u{1EBF}t \u{01A1}n h\u{00F4}m nay, b\u{00EC}nh an ng\u{00E0}y mai.", ""),
        ("N\u{01B0}\u{1EDB}c ch\u{1EA3}y \u{0111}\u{00E1} m\u{00F2}n, \u{01A1}n s\u{00E2}u ngh\u{0129}a n\u{1EB7}ng.", ""),
        ("\u{0102}n qu\u{1EA3} nh\u{1EDB} k\u{1EBB} tr\u{1ED3}ng c\u{00E2}y.", "Ca dao Vi\u{1EC7}t Nam"),
        ("U\u{1ED1}ng n\u{01B0}\u{1EDB}c nh\u{1EDB} ngu\u{1ED3}n.", "Ca dao Vi\u{1EC7}t Nam"),
        ("M\u{1ED9}t ch\u{00FA}t bi\u{1EBF}t \u{01A1}n m\u{1ED7}i ng\u{00E0}y, \u{0111}\u{1ED5}i thay c\u{1EA3} cu\u{1ED9}c \u{0111}\u{1EDD}i.", ""),
        ("Tr\u{00E2}n tr\u{1ECD}ng \u{0111}i\u{1EC1}u nh\u{1ECF}, nh\u{1EAD}n ra h\u{1EA1}nh ph\u{00FA}c l\u{1EDB}n.", ""),
        ("Kh\u{00F4}ng c\u{00F3} g\u{00EC} l\u{00E0} \u{0111}\u{01B0}\u{01A1}ng nhi\u{00EA}n, m\u{1ECD}i th\u{1EE9} \u{0111}\u{1EC1}u l\u{00E0} \u{00E2}n ph\u{00FA}c.", ""),
        ("S\u{1ED1}ng ch\u{1EAD}m l\u{1EA1}i, bi\u{1EBF}t \u{01A1}n nhi\u{1EC1}u h\u{01A1}n.", ""),
        ("L\u{00E1} r\u{01A1}i v\u{1EC1} c\u{1ED9}i, n\u{01B0}\u{1EDB}c ch\u{1EA3}y v\u{1EC1} ngu\u{1ED3}n.", "Ca dao Vi\u{1EC7}t Nam"),
        ("Bi\u{1EBF}t \u{0111}\u{1EE7} th\u{00EC} \u{0111}\u{1EE7}, \u{0111}\u{1EE3}i \u{0111}\u{1EE7} bao gi\u{1EDD} \u{0111}\u{1EE7}.", ""),
        ("T\u{00E2}m an, v\u{1EA1}n s\u{1EF1} an.", ""),
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
                            Text("Ba \u{0111}i\u{1EC1}u bi\u{1EBF}t \u{01A1}n h\u{00F4}m nay")
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

        // Start celebration immediately — form fades out first
        startCelebration()

        // Save data in the background while animation plays
        Task {
            do {
                try await viewModel.saveGratitude(modelContext: modelContext)
                streakViewModel.incrementStreak()
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

                // Water drop icon
                Image(systemName: "drop.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(ZenColor.zenSage.opacity(0.85))
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
