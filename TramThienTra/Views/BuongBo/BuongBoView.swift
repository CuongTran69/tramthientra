import SwiftUI

// MARK: - SPEC §2.4 Buông bỏ — text release view (redesigned)

struct BuongBoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BuongBoViewModel()
    @State private var smokeIconOpacity: Double = 1.0
    @State private var smokeIconScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            NenDongView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(ZenColor.zenBrown)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Đóng")
                    .accessibilityHint("Đóng màn hình buông bỏ")

                    Spacer()

                    Text("Buông bỏ")
                        .font(ZenFont.headline())
                        .foregroundColor(ZenColor.zenBrownDark)

                    Spacer()

                    Color.clear.frame(width: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Text("Viết ra những gì đang làm bạn trì trệ, rồi buông bỏ. Không ai đọc được.")
                    .font(ZenFont.caption())
                    .foregroundColor(ZenColor.zenBrown.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)

                // Text area — full-width ZenCard wrapping a TextEditor
                ZenCard {
                    ZStack(alignment: .topLeading) {
                        if viewModel.text.isEmpty {
                            Text("Những gì bạn muốn buông bỏ...")
                                .font(ZenFont.body())
                                .foregroundColor(ZenColor.zenBrown.opacity(0.4))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .allowsHitTesting(false)
                        }

                        TextEditor(text: $viewModel.text)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .font(ZenFont.body())
                            .foregroundColor(ZenColor.zenBrown)
                            .frame(minHeight: 160)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .frame(maxWidth: .infinity)
                .opacity(viewModel.isReleasing ? 0 : 1)
                .accessibilityLabel("Nhập nội dung muốn buông bỏ")

                // Smoke overlay shown during release animation
                if viewModel.isReleasing {
                    KhoiTanView()
                        .frame(width: 200, height: 200)
                        .transition(.opacity)
                }

                Spacer()

                // Buông button with 0.6s smoke/dissolve icon animation
                Button {
                    guard !viewModel.text.isEmpty && !viewModel.isReleasing else { return }
                    playSmokeDismissAnimation()
                } label: {
                    HStack(spacing: 8) {
                        OnboardingSmokeArt()
                            .frame(width: 24, height: 24)
                            .opacity(smokeIconOpacity)
                            .scaleEffect(smokeIconScale)
                        Text("Buông")
                            .font(ZenFont.headline())
                            .foregroundColor(ZenColor.zenBrownDark)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.85))
                .cornerRadius(25)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
                .disabled(viewModel.text.isEmpty || viewModel.isReleasing)
                .accessibilityLabel("Buông")
                .accessibilityHint("Buông bỏ những gì bạn đã viết và xóa chúng đi")
            }
        }
    }

    // MARK: - Smoke icon 0.6s dissolve animation before dismissal

    private func playSmokeDismissAnimation() {
        // 0.6s smoke/dissolve: scale up and fade out the icon
        withAnimation(.easeInOut(duration: 0.3)) {
            smokeIconOpacity = 0
            smokeIconScale = 1.4
        }
        // After 0.6s total, trigger the viewmodel release
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Reset icon state
            smokeIconOpacity = 1.0
            smokeIconScale = 1.0
            Task {
                await viewModel.releaseAndDismiss()
            }
        }
    }
}
