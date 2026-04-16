import Foundation
import AuthenticationServices

// MARK: - SPEC §3.4 Sign in with Apple service

protocol AuthServiceProtocol {
    func signIn()
    func signOut()
    func handleSignInSuccess(userId: String)
    func getCurrentUserId() -> String?
}

final class AuthService: AuthServiceProtocol {
    static let shared = AuthService()

    private let keychainService = "com.tramthientra.app"
    private let userIdKey = "appleUserId"

    private init() {}

    func signIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = AuthDelegate.shared
        controller.presentationContextProvider = AuthDelegate.shared
        controller.performRequests()
    }

    func signOut() {
        KeychainHelper.delete(key: userIdKey)
        UserDefaults.standard.removeObject(forKey: Constants.hasCompletedOnboardingKey)
    }

    func handleSignInSuccess(userId: String) {
        KeychainHelper.save(userId, forKey: userIdKey)
    }

    func getCurrentUserId() -> String? {
        KeychainHelper.load(forKey: userIdKey)
    }

    func checkCredentialState(completion: @escaping (Bool) -> Void) {
        guard let userId = getCurrentUserId() else {
            completion(false)
            return
        }
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userId) { state, _ in
            DispatchQueue.main.async {
                completion(state == .authorized)
            }
        }
    }
}

// MARK: - Auth delegate handling

final class AuthDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static let shared = AuthDelegate()

    private override init() {
        super.init()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return UIWindow()
        }
        return window
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        let userId = appleIdCredential.user
        AuthService.shared.handleSignInSuccess(userId: userId)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("[Apple SignIn] Authorization error: \(error.localizedDescription)")
    }
}

// MARK: - Keychain helper

enum KeychainHelper {
    static func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.tramthientra.app",
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.tramthientra.app",
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.tramthientra.app",
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}