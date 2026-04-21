import SwiftUI
import AuthenticationServices

// MARK: - SPEC §2.6 Sign in with Apple button
//
// Uses Apple's native SignInWithAppleButton for compliance with Apple's Human
// Interface Guidelines and App Store review. Style adapts to the ambient color
// scheme so the button stays legible over cream (light) and dark gradients.
// No custom gesture overlays are attached — that would swallow the native tap
// handler and break Apple's flow.

struct AppleDangNhapView: View {
    @Binding var isSignedIn: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: handleCompletion
        )
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 50)
        .frame(minHeight: 44)
        .cornerRadius(12)
        .accessibilityLabel("Đăng nhập với Apple")
        .accessibilityHint("Đăng nhập để đồng bộ và sao lưu nhật ký")
    }

    private func handleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                return
            }
            AuthService.shared.handleSignInSuccess(userId: credential.user)
            HapticService.shared.playSuccess()
            isSignedIn = true
        case .failure(let error):
            HapticService.shared.playError()
            print("[Apple SignIn] Error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AppleDangNhapView(isSignedIn: .constant(false))
    }
    .padding(24)
    .background(ZenColor.zenCream)
}