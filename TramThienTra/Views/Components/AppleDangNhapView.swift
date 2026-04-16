import SwiftUI
import AuthenticationServices

// MARK: - SPEC §2.6 Sign in with Apple button

struct AppleDangNhapView: View {
    @Binding var isSignedIn: Bool
    @State private var isLoading = false

    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                isLoading = false
                switch result {
                case .success(let authorization):
                    if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        let userId = appleIdCredential.user
                        AuthService.shared.handleSignInSuccess(userId: userId)
                        isSignedIn = true
                    }
                case .failure(let error):
                    print("[Apple SignIn] Error: \(error.localizedDescription)")
                }
            }
        )
        .signInWithAppleButtonStyle(.white)
        .frame(height: 50)
        .cornerRadius(12)
        .onTapGesture {
            isLoading = true
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .tint(.black)
            }
        }
    }
}