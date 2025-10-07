import ComposableArchitecture
import Foundation

@DependencyClient
struct AuthClient {
    var signIn: @Sendable (_ email: String, _ password: String) async throws -> APIAuthResponse
    var signUp: @Sendable (_ name: String, _ email: String, _ password: String) async throws -> APIAuthResponse
    var getUserProfile: @Sendable (_ userId: String) async throws -> APIUser
    var getUserTickets: @Sendable (_ userId: String) async throws -> [APITicket]
}

extension AuthClient: DependencyKey {
    static let liveValue = Self(
        signIn: { email, password in
            let request = APILoginRequest(email: email, password: password)
            return try await NetworkService.shared.request(
                endpoint: "/auth/login",
                method: .POST,
                body: request,
                requiresAuth: false
            )
        },
        signUp: { name, email, password in
            let request = APIRegisterRequest(name: name, email: email, password: password)
            return try await NetworkService.shared.request(
                endpoint: "/auth/register",
                method: .POST,
                body: request,
                requiresAuth: false
            )
        },
        getUserProfile: { userId in
            return try await NetworkService.shared.request(
                endpoint: "/users/\(userId)",
                method: .GET,
                requiresAuth: true
            )
        },
        getUserTickets: { userId in
            return try await NetworkService.shared.request(
                endpoint: "/users/\(userId)/tickets",
                method: .GET,
                requiresAuth: true
            )
        }
    )
    
    static let testValue = Self(
        signIn: unimplemented("AuthClient.signIn"),
        signUp: unimplemented("AuthClient.signUp"),
        getUserProfile: unimplemented("AuthClient.getUserProfile"),
        getUserTickets: unimplemented("AuthClient.getUserTickets")
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
