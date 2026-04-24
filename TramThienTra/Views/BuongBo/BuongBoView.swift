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

    private var canRelease: Bool {
        !viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !viewModel.isReleasing
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
                        Text("Viết ra những gì đang làm bạn trì trệ, rồi buông bỏ. Không ai đọc được.")
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

                // Release action — circular animated button matching Biết ơn pattern
                NutGiotNuocView(
                    isEnabled: canRelease,
                    action: {
                        dismissKeyboard()
                        playSmokeDismissAnimation()
                    },
                    icon: "leaf.fill",
                    label: "Buông bỏ",
                    hint: canRelease
                        ? "Buông bỏ những gì bạn đã viết và xóa chúng đi"
                        : "Hãy viết điều gì đó trước khi buông"
                )
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Dismiss keyboard

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - Delayed release after button animation

    private func playSmokeDismissAnimation() {
        let delay: Double = reduceMotion ? 0.1 : 0.6
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            Task {
                await viewModel.releaseAndDismiss()
            }
        }
    }
}

#Preview {
    BuongBoView()
        .environmentObject(ThoiGianViewModel())
}
