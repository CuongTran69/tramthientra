import SwiftUI

// MARK: - SPEC §2.4 Buông bỏ — text release view (design-system aligned)
//
// Uses ZenTextField + ZenButton for visual & interaction consistency with
// TichLuyView. Spacing follows the 8 pt grid (8/16/24/32). All interactive
// elements meet the 44×44 pt minimum touch-target rule and have explicit
// focus / disabled / loading states.

struct BuongBoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var viewModel = BuongBoViewModel()
    @State private var smokeIconOpacity: Double = 1.0
    @State private var smokeIconScale: CGFloat = 1.0

    private var canRelease: Bool {
        !viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !viewModel.isReleasing
    }

    var body: some View {
        ZStack {
            NenDongView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Section helper text — caption tone, matches TichLuyView pattern
                        Text("Viết ra những gì đang làm bạn trì trệ, rồi buông bỏ. Không ai đọc được.")
                            .font(ZenFont.caption())
                            .foregroundColor(ZenColor.zenBrown.opacity(0.7))
                            .multilineTextAlignment(.leading)
                            .accessibilityAddTraits(.isStaticText)

                        ZenTextField(
                            placeholder: "Những gì bạn muốn buông bỏ…",
                            text: $viewModel.text,
                            limit: nil,
                            multiline: true,
                            minHeight: 200,
                            maxHeight: 320
                        )
                        .opacity(viewModel.isReleasing ? 0 : 1)
                        .animation(.easeInOut(duration: 0.25), value: viewModel.isReleasing)
                        .accessibilityLabel("Nhập nội dung muốn buông bỏ")

                        // Smoke overlay shown during release animation
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
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)

                // Release action — uses ZenButton.primary so it inherits haptics,
                // press-scale animation, reduce-motion handling, and the brand
                // gradient. Smoke icon overlays the leading edge during dismiss.
                ZenButton(
                    "Buông",
                    variant: .primary,
                    icon: nil
                ) {
                    guard canRelease else { return }
                    playSmokeDismissAnimation()
                }
                .overlay(alignment: .leading) {
                    OnboardingSmokeArt()
                        .frame(width: 24, height: 24)
                        .opacity(smokeIconOpacity)
                        .scaleEffect(smokeIconScale)
                        .padding(.leading, 40)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
                .disabled(!canRelease)
                .opacity(canRelease ? 1.0 : 0.5)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .accessibilityLabel("Buông")
                .accessibilityHint(
                    canRelease
                        ? "Buông bỏ những gì bạn đã viết và xóa chúng đi"
                        : "Hãy viết điều gì đó trước khi buông"
                )
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3.weight(.medium))
                    .foregroundColor(ZenColor.zenBrown)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Đóng")
            .accessibilityHint("Đóng màn hình buông bỏ")

            Spacer()

            Text("Buông bỏ")
                .font(ZenFont.headline())
                .foregroundColor(ZenColor.zenBrownDark)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Smoke icon 0.6s dissolve animation before dismissal

    private func playSmokeDismissAnimation() {
        let duration: Double = reduceMotion ? 0.0 : 0.3
        withAnimation(.easeInOut(duration: duration)) {
            smokeIconOpacity = 0
            smokeIconScale = reduceMotion ? 1.0 : 1.4
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.1 : 0.6)) {
            smokeIconOpacity = 1.0
            smokeIconScale = 1.0
            Task {
                await viewModel.releaseAndDismiss()
            }
        }
    }
}
