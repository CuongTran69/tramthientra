import SwiftUI

// MARK: - SPEC: Reusable notification prompt component
//
// Used in both the onboarding notification page and the in-app reminder sheet.
// Accepts closures for accept/dismiss so behavior varies by context.

struct NotificationPromptView: View {
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel

    let onAccept: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            NenDongView()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Bell icon
                Image(systemName: "bell.badge.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundColor(ZenColor.zenGold)
                    .shadow(color: ZenColor.zenGold.opacity(0.3), radius: 12, x: 0, y: 4)
                    .accessibilityHidden(true)

                ZenCard {
                    VStack(spacing: 16) {
                        Text("Bật nhắc nhở?")
                            .font(ZenFont.title())
                            .foregroundColor(thoiGianVM.current.textPrimary)
                            .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                            .multilineTextAlignment(.center)

                        Text("Trạm Thiền Trà có thể nhắc bạn mỗi ngày để thực hành tạ ơn cuộc sống.")
                            .font(ZenFont.body())
                            .foregroundColor(thoiGianVM.current.textSecondary)
                            .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, 20)

                // Accept button
                ZenButton("Bật thông báo", variant: .primary, icon: "bell.fill") {
                    onAccept()
                }
                .padding(.horizontal, 20)
                .accessibilityLabel("Bật thông báo")
                .accessibilityHint("Cho phép ứng dụng gửi nhắc nhở hàng ngày")

                // Dismiss button
                Button {
                    onDismiss()
                } label: {
                    Text("Để sau")
                        .font(ZenFont.subheadline())
                        .foregroundColor(thoiGianVM.current.textSecondary)
                        .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Để sau")
                .accessibilityHint("Bỏ qua nhắc nhở thông báo")

                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NotificationPromptView(
        onAccept: { print("Accepted") },
        onDismiss: { print("Dismissed") }
    )
    .environmentObject(ThoiGianViewModel())
}
