import SwiftUI

// MARK: - SPEC §2.4 Login prompt — gentle invitation before first save
//
// Shown as a `.sheet` from TichLuyView when the user has not yet signed in.
// Wraps the design system: ZenCard panel, ZenColor tokens, ZenFont typography.
// Two actions:
//   • Sign in with Apple   → primary (AppleDangNhapView)
//   • "Để sau"             → secondary, dismisses and continues guest save
//
// Accessibility: title is announced as a header, body text is grouped, both
// actions have accessibility labels and hints.

struct LoginPromptView: View {
    /// Set to `true` once Apple Sign-In completes successfully.
    @Binding var isSignedIn: Bool
    /// Called when the user dismisses by either path (signed-in or "Để sau").
    /// `signedIn` indicates whether sign-in was successful before dismissing.
    let onDismiss: (_ signedIn: Bool) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            ZenColor.zenCream
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 24)

                // Decorative leaf icon (decorative — hidden from VoiceOver)
                ZStack {
                    Circle()
                        .fill(ZenColor.zenSage.opacity(0.18))
                        .frame(width: 96, height: 96)
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40, weight: .regular))
                        .foregroundColor(ZenColor.zenSage)
                }
                .accessibilityHidden(true)

                VStack(spacing: 12) {
                    Text("Giữ lại những điều tốt đẹp")
                        .font(ZenFont.title())
                        .foregroundColor(ZenColor.zenBrownDark)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)

                    Text("Hãy tạo một góc nhỏ để giữ lại những điều tốt đẹp này không bao giờ mất.")
                        .font(ZenFont.body())
                        .foregroundColor(ZenColor.zenBrown)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 16)
                }
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 12) {
                    AppleDangNhapView(isSignedIn: $isSignedIn)
                        .frame(height: 50)
                        .accessibilityHint("Đăng nhập để đồng bộ và sao lưu nhật ký của bạn")
                        .onChange(of: isSignedIn) { _, signedIn in
                            if signedIn {
                                onDismiss(true)
                                dismiss()
                            }
                        }

                    Button {
                        onDismiss(false)
                        dismiss()
                    } label: {
                        Text("Để sau")
                            .font(ZenFont.headline())
                            .foregroundColor(ZenColor.zenBrown)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Để sau")
                    .accessibilityHint("Bỏ qua đăng nhập và lưu nhật ký dưới dạng khách")
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    LoginPromptView(isSignedIn: .constant(false), onDismiss: { _ in })
}
