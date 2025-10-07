import ComposableArchitecture
import Foundation

@DependencyClient
struct AuthClient {
    var signIn: @Sendable (_ email: String, _ password: String) async throws -> AuthResponse
    var signUp: @Sendable (_ name: String, _ email: String, _ password: String) async throws -> AuthResponse
    var signOut: @Sendable () async throws -> Void
}

extension AuthClient: DependencyKey {
    static let liveValue = Self(
        signIn: { email, password in
            let request = LoginRequest(email: email, password: password)
            return try await NetworkService.shared.request(
                endpoint: "/auth/login",
                method: .POST,
                body: request,
                requiresAuth: false
            )
        },
        signUp: { name, email, password in
            let request = RegisterRequest(name: name, email: email, password: password)
            return try await NetworkService.shared.request(
                endpoint: "/auth/register",
                method: .POST,
                body: request,
                requiresAuth: false
            )
        },
        signOut: {
            // Clear local authentication data
            UserDefaults.standard.removeObject(forKey: "authToken")
            UserDefaults.standard.removeObject(forKey: "currentUser")
            UserDefaults.standard.removeObject(forKey: "currentUserId")
            
            // Optionally notify server to invalidate token
            // Uncomment if your backend supports logout endpoint
            /*
            do {
                let _: EmptyResponse = try await NetworkService.shared.request(
                    endpoint: "/auth/logout",
                    method: .POST,
                    requiresAuth: true
                )
            } catch {
                // Ignore server logout errors for now
                print("Erro ao fazer logout no servidor: \(error)")
            }
            */
        }
    )
    
    static let testValue = Self(
        signIn: unimplemented("AuthClient.signIn"),
        signUp: unimplemented("AuthClient.signUp"),
        signOut: { }
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
