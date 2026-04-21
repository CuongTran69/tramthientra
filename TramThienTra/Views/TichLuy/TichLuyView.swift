import SwiftUI
import SwiftData

// MARK: - SPEC §2.3 Gratitude entry form — ZenTextField, ZenButton (redesigned)

struct TichLuyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TichLuyViewModel()
    @State private var showLoginPrompt = false
    @State private var isSignedIn: Bool = AuthService.shared.getCurrentUserId() != nil

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

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
                            .font(.title3.weight(.medium))
                            .foregroundColor(ZenColor.zenBrown)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Đóng")
                    .accessibilityHint("Đóng màn hình tích luỹ")

                    Spacer()

                    Text("Tích luỹ — Ngày \(dateFormatter.string(from: Date()))")
                        .font(ZenFont.headline())
                        .foregroundColor(ZenColor.zenBrownDark)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Section label + decoration
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ba điều biết ơn hôm nay")
                                .font(ZenFont.subheadline())
                                .foregroundColor(ZenColor.zenBrown)
                                .accessibilityAddTraits(.isHeader)

                            Rectangle()
                                .fill(ZenColor.zenSage.opacity(0.4))
                                .frame(width: 48, height: 1)
                        }
                        .padding(.top, 24)

                        VStack(spacing: 12) {
                            ZenTextField(
                                placeholder: "Điều tạ ơn thứ nhất…",
                                text: $viewModel.item1,
                                limit: Constants.maxCharacterLimit,
                                multiline: true
                            )
                            .accessibilityLabel("Điều tạ ơn thứ nhất")

                            ZenTextField(
                                placeholder: "Điều tạ ơn thứ hai…",
                                text: $viewModel.item2,
                                limit: Constants.maxCharacterLimit,
                                multiline: true
                            )
                            .accessibilityLabel("Điều tạ ơn thứ hai")

                            ZenTextField(
                                placeholder: "Điều tạ ơn thứ ba…",
                                text: $viewModel.item3,
                                limit: Constants.maxCharacterLimit,
                                multiline: true
                            )
                            .accessibilityLabel("Điều tạ ơn thứ ba")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)

                // Save button — water drop animated button, docked at bottom
                NutGiotNuocView(isEnabled: viewModel.isFormValid && !viewModel.isSaving) {
                    if isSignedIn {
                        performSave()
                    } else {
                        showLoginPrompt = true
                    }
                }
                .disabled(!viewModel.isFormValid || viewModel.isSaving)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showLoginPrompt) {
            LoginPromptView(isSignedIn: $isSignedIn) { _ in
                // After the prompt resolves (sign-in or "Để sau"), save anyway —
                // SPEC §2.4: guest saves are allowed; sync runs once signed in.
                performSave()
            }
        }
    }

    private func performSave() {
        Task {
            await viewModel.saveGratitude(modelContext: modelContext)
            dismiss()
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
