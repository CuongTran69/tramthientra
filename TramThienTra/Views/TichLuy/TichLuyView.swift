import SwiftUI
import SwiftData

// MARK: - SPEC §2.3 Gratitude entry form — ZenTextField, ZenButton (redesigned)

struct TichLuyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TichLuyViewModel()
    @State private var showLoginPrompt = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    var body: some View {
        ZStack {
            NenDongView()
                .ignoresSafeArea()

            VStack(spacing: 24) {
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
                    .accessibilityHint("Đóng màn hình tích luỹ")

                    Spacer()

                    Text("Tích luỹ — Ngày \(dateFormatter.string(from: Date()))")
                        .font(ZenFont.headline())
                        .foregroundColor(ZenColor.zenBrownDark)

                    Spacer()

                    Color.clear.frame(width: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Section header with decoration line
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ba điều biết ơn hôm nay")
                        .font(ZenFont.subheadline())
                        .foregroundColor(ZenColor.zenBrown)

                    // 1 pt decoration line below section header
                    Rectangle()
                        .fill(ZenColor.zenSage.opacity(0.4))
                        .frame(height: 1)
                }
                .padding(.horizontal, 24)

                VStack(spacing: 16) {
                    ZenTextField(
                        placeholder: "Điều tạ ơn thứ nhất...",
                        text: $viewModel.item1,
                        limit: Constants.maxCharacterLimit,
                        multiline: true
                    )
                    .accessibilityLabel("Điều tạ ơn thứ nhất")

                    ZenTextField(
                        placeholder: "Điều tạ ơn thứ hai...",
                        text: $viewModel.item2,
                        limit: Constants.maxCharacterLimit,
                        multiline: true
                    )
                    .accessibilityLabel("Điều tạ ơn thứ hai")

                    ZenTextField(
                        placeholder: "Điều tạ ơn thứ ba...",
                        text: $viewModel.item3,
                        limit: Constants.maxCharacterLimit,
                        multiline: true
                    )
                    .accessibilityLabel("Điều tạ ơn thứ ba")
                }
                .padding(.horizontal, 24)

                Spacer()

                // Save button — water drop animated button
                NutGiotNuocView(isEnabled: viewModel.isFormValid && !viewModel.isSaving) {
                    Task {
                        await viewModel.saveGratitude(modelContext: modelContext)
                        dismiss()
                    }
                }
                .disabled(!viewModel.isFormValid || viewModel.isSaving)
                .padding(.bottom, 40)
                .accessibilityLabel("Lưu")
                .accessibilityHint("Lưu ba điều biết ơn hôm nay")
            }
        }
        .alert("Đăng nhập", isPresented: $showLoginPrompt) {
            Button("Đăng nhập", role: .cancel) {
                // TODO: Navigate to Sign in with Apple
            }
            Button("Huỷ", role: .destructive) {}
        } message: {
            Text("Bạn cần đăng nhập để lưu dữ liệu tạ ơn.")
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
