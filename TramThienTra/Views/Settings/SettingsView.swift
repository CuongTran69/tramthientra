import SwiftUI

// MARK: - SPEC §2.6 Settings — notifications, Sign in/out, Privacy Policy, version (redesigned)

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("dailyReminderEnabled") private var dailyReminder = true
    @State private var isSignedIn = false
    @State private var showSignOutAlert = false

    var body: some View {
        ZStack {
            NenDongView()
                .ignoresSafeArea()

            List {
                // Notifications section
                Section {
                    Toggle(isOn: $dailyReminder) {
                        Label {
                            Text("Nhắc nhở hàng ngày")
                                .font(ZenFont.body())
                                .foregroundColor(ZenColor.zenBrownDark)
                        } icon: {
                            Image(systemName: "bell.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(ZenColor.zenSage)
                        }
                    }
                    .tint(ZenColor.zenSage)
                    .frame(minHeight: 44)
                    .onChange(of: dailyReminder) { _, newValue in
                        if newValue {
                            NotificationService.shared.scheduleDailyReminder()
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
                } header: {
                    sectionHeader("Thông báo")
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.vertical, 2)
                )

                // Account section
                Section {
                    if isSignedIn {
                        Button(role: .destructive) {
                            showSignOutAlert = true
                        } label: {
                            Label {
                                Text("Đăng xuất")
                                    .font(ZenFont.body())
                                    .foregroundColor(.red)
                            } icon: {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(minHeight: 44)
                        .accessibilityLabel("Đăng xuất")
                        .accessibilityHint("Đăng xuất khỏi tài khoản của bạn")
                    } else {
                        AppleDangNhapView(isSignedIn: $isSignedIn)
                            .frame(minHeight: 44)
                    }
                } header: {
                    sectionHeader("Tài khoản")
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.vertical, 2)
                )

                // About section
                Section {
                    Link(destination: URL(string: "https://tramthientra.com/privacy")!) {
                        Label {
                            Text("Chính sách riêng tư")
                                .font(ZenFont.body())
                                .foregroundColor(ZenColor.zenBrownDark)
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(ZenColor.zenSage)
                        }
                    }
                    .frame(minHeight: 44)
                    .accessibilityLabel("Chính sách riêng tư")
                    .accessibilityHint("Mở trang chính sách riêng tư")

                    HStack {
                        Label {
                            Text("Phiên bản")
                                .font(ZenFont.body())
                                .foregroundColor(ZenColor.zenBrownDark)
                        } icon: {
                            Image(systemName: "info.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(ZenColor.zenSage)
                        }
                        Spacer()
                        Text("1.0.0")
                            .font(ZenFont.body())
                            .foregroundColor(ZenColor.zenBrown.opacity(0.6))
                    }
                    .frame(minHeight: 44)
                    .accessibilityLabel("Phiên bản 1.0.0")
                } header: {
                    sectionHeader("Về ứng dụng")
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.vertical, 2)
                )
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Cài đặt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(ZenColor.zenBrown)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Đóng")
                    .accessibilityHint("Đóng màn hình cài đặt")
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

    // MARK: - Section header: uppercase + 1.5 pt tracking using ZenFont.caption()

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(ZenFont.caption())
            .tracking(1.5)
            .foregroundColor(ZenColor.zenBrown.opacity(0.6))
    }
}
