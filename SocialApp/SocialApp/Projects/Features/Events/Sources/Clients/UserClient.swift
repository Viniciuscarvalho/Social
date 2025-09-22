import ComposableArchitecture
import Foundation
import SharedModels

@DependencyClient
public struct UserClient {
    public var fetchCurrentUser: () async throws -> User
    public var updateUser: (User) async throws -> User
}

extension UserClient: DependencyKey {
    public static let liveValue = UserClient(
        fetchCurrentUser: {
            try await Task.sleep(for: .milliseconds(500))
            // For now, return the same sample user as used in tests
            // In a real app, this would fetch from a network API
            return MockEventData.sampleUser
        },
        updateUser: { user in
            // Logic to update user
            return user
        }
    )
    
    public static let testValue = UserClient(
        fetchCurrentUser: { MockEventData.sampleUser },
        updateUser: { user in user }
    )
}

extension DependencyValues {
    public var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}
