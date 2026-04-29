import SwiftUI

// MARK: - SPEC §2.6 Settings — notifications, Sign in/out, Privacy Policy, version (redesigned)

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel
    @AppStorage(Constants.dailyReminderEnabledKey) private var dailyReminder = false
    @AppStorage(Constants.notificationHourKey) private var notificationHour = Constants.notificationHour
    @AppStorage(Constants.notificationMinuteKey) private var notificationMinute = Constants.notificationMinute
    @State private var isSignedIn = false
    @State private var showSignOutAlert = false

    // MARK: - Computed binding for DatePicker from stored hour/minute

    private var reminderTime: Binding<Date> {
        Binding<Date>(
            get: {
                var components = DateComponents()
                components.hour = notificationHour
                components.minute = notificationMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                notificationHour = components.hour ?? Constants.notificationHour
                notificationMinute = components.minute ?? Constants.notificationMinute
            }
        )
    }

    var body: some View {
        ZStack {
            NenDongView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header with pill-style dismiss button
                ZenScreenHeader(title: "Cài đặt") {
                    dismiss()
                }
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 20) {
                        // Notifications card
                        ZenCard {
                            VStack(alignment: .leading, spacing: 16) {
                                // Section header
                                Text("THÔNG BÁO")
                                    .font(ZenFont.caption())
                                    .tracking(1.5)
                                    .foregroundColor(thoiGianVM.current.textSecondary)
                                    .padding(.bottom, 4)

                                // Daily reminder toggle
                                HStack(spacing: 16) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(ZenColor.zenSage)
                                        .frame(width: 32)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Nhắc nhở hàng ngày")
                                            .font(ZenFont.body())
                                            .foregroundColor(thoiGianVM.current.textPrimary)
                                        Text("Nhận thông báo để duy trì thói quen")
                                            .font(ZenFont.caption())
                                            .foregroundColor(thoiGianVM.current.textSecondary)
                                    }

                                    Spacer()

                                    Toggle("", isOn: $dailyReminder)
                                        .labelsHidden()
                                        .tint(ZenColor.zenSage)
                                }
                                .onChange(of: dailyReminder) { _, newValue in
                                    if newValue {
                                        Task {
                                            await NotificationService.shared.requestAuthorization()
                                            NotificationService.shared.scheduleDailyReminder(hour: notificationHour, minute: notificationMinute)
                                        }
                                    } else {
                                        NotificationService.shared.cancelAllPendingNotifications()
                                    }
                                }
                                .accessibilityLabel("Nhắc nhở hàng ngày")
                                .accessibilityHint(
                                    dailyReminder
                                        ? "Đang bật — chạm để tắt thông báo hàng ngày"
                                        : "Đang tắt — chạm để bật thông báo hàng ngày"
                                )

                                // Time picker (visible when toggle is ON)
                                if dailyReminder {
                                    Divider()
                                        .background(thoiGianVM.current.textSecondary.opacity(0.2))
                                        .padding(.vertical, 4)

                                    HStack(spacing: 16) {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(ZenColor.zenSage)
                                            .frame(width: 32)

                                        Text("Thời gian")
                                            .font(ZenFont.body())
                                            .foregroundColor(thoiGianVM.current.textPrimary)

                                        Spacer()

                                        DatePicker(
                                            "",
                                            selection: reminderTime,
                                            displayedComponents: .hourAndMinute
                                        )
                                        .labelsHidden()
                                        .tint(ZenColor.zenSage)
                                    }
                                    .onChange(of: reminderTime.wrappedValue) { _, _ in
                                        NotificationService.shared.scheduleDailyReminder(hour: notificationHour, minute: notificationMinute)
                                    }
                                    .accessibilityLabel("Thời gian nhắc nhở")
                                    .accessibilityHint("Chọn thời gian nhận thông báo hàng ngày")
                                }
                            }
                        }

                        // Account card
                        ZenCard {
                            VStack(alignment: .leading, spacing: 16) {
                                // Section header
                                Text("TÀI KHOẢN")
                                    .font(ZenFont.caption())
                                    .tracking(1.5)
                                    .foregroundColor(thoiGianVM.current.textSecondary)
                                    .padding(.bottom, 4)

                                if isSignedIn {
                                    // Sign out button
                                    Button {
                                        showSignOutAlert = true
                                    } label: {
                                        HStack(spacing: 16) {
                                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                                .font(.system(size: 24))
                                                .foregroundColor(.red)
                                                .frame(width: 32)

                                            Text("Đăng xuất")
                                                .font(ZenFont.body())
                                                .foregroundColor(.red)

                                            Spacer()
                                        }
                                    }
                                    .accessibilityLabel("Đăng xuất")
                                    .accessibilityHint("Đăng xuất khỏi tài khoản của bạn")
                                } else {
                                    AppleDangNhapView(isSignedIn: $isSignedIn)
                                }
                            }
                        }

                        // About card
                        ZenCard {
                            VStack(alignment: .leading, spacing: 16) {
                                // Section header
                                Text("VỀ ỨNG DỤNG")
                                    .font(ZenFont.caption())
                                    .tracking(1.5)
                                    .foregroundColor(thoiGianVM.current.textSecondary)
                                    .padding(.bottom, 4)

                                // Privacy policy link
                                Link(destination: URL(string: "https://tramthientra.com/privacy")!) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "hand.raised.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(ZenColor.zenSage)
                                            .frame(width: 32)

                                        Text("Chính sách riêng tư")
                                            .font(ZenFont.body())
                                            .foregroundColor(thoiGianVM.current.textPrimary)

                                        Spacer()

                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(thoiGianVM.current.textSecondary)
                                    }
                                }
                                .accessibilityLabel("Chính sách riêng tư")
                                .accessibilityHint("Mở trang chính sách riêng tư")

                                Divider()
                                    .background(thoiGianVM.current.textSecondary.opacity(0.2))
                                    .padding(.vertical, 4)

                                // Version info
                                HStack(spacing: 16) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(ZenColor.zenSage)
                                        .frame(width: 32)

                                    Text("Phiên bản")
                                        .font(ZenFont.body())
                                        .foregroundColor(thoiGianVM.current.textPrimary)

                                    Spacer()

                                    Text("1.0.0")
                                        .font(ZenFont.body())
                                        .foregroundColor(thoiGianVM.current.textSecondary)
                                }
                                .accessibilityLabel("Phiên bản 1.0.0")
                            }
                        }

                        // Bottom spacing
                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .alert("Đăng xuất", isPresented: $showSignOutAlert) {
            Button("Đăng xuất", role: .destructive) {
                AuthService.shared.signOut()
                isSignedIn = false
            }
            Button("Huỷ", role: .cancel) {}
        } message: {
            Text("Bạn có chắc muốn đăng xuất không?")
        }
    }

}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(ThoiGianViewModel())
}
