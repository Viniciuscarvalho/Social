import ComposableArchitecture
import Foundation

@DependencyClient
public struct UserClient {
    var getCurrentUser: @Sendable () async throws -> User
    var fetchCurrentUser: @Sendable () async throws -> User
    var getUserProfile: @Sendable (_ userId: String) async throws -> User
    var getUserTickets: @Sendable (_ userId: String) async throws -> [Ticket]
    var updateUserProfile: @Sendable (User) async throws -> User
    var uploadProfileImage: @Sendable (Data) async throws -> String
}

extension UserClient: DependencyKey {
    public static let liveValue = Self(
        getCurrentUser: {
            guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
                throw NetworkError.unauthorized
            }
            
            let apiResponse: UserResponse = try await NetworkService.shared.request(
                endpoint: "/users/\(userId)",
                method: .GET,
                requiresAuth: true
            )
            
            return apiResponse.toUser()
        },
        fetchCurrentUser: {
            // Alias para getCurrentUser para compatibilidade
            guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
                throw NetworkError.unauthorized
            }
            
            let apiResponse: UserResponse = try await NetworkService.shared.request(
                endpoint: "/users/\(userId)",
                method: .GET,
                requiresAuth: true
            )
            
            return apiResponse.toUser()
        },
        getUserProfile: { userId in
            let apiResponse: UserResponse = try await NetworkService.shared.request(
                endpoint: "/users/\(userId)",
                method: .GET,
                requiresAuth: true
            )
            return apiResponse.toUser()
        },
        getUserTickets: { userId in
            let apiResponse: [Ticket] = try await NetworkService.shared.request(
                endpoint: "/users/\(userId)/tickets",
                method: .GET,
                requiresAuth: true
            )
            return apiResponse
        },
        updateUserProfile: { user in
            guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
                throw NetworkError.unauthorized
            }
            
            let updateRequest = UserUpdateRequest(
                name: user.name,
                title: user.title,
                email: user.email
            )
            
            let apiResponse: UserResponse = try await NetworkService.shared.request(
                endpoint: "/users/\(userId)",
                method: .PUT,
                body: updateRequest,
                requiresAuth: true
            )
            
            // Atualiza os dados locais também
            let updatedUser = apiResponse.toUser()
            if let userData = try? JSONEncoder().encode(updatedUser) {
                UserDefaults.standard.set(userData, forKey: "currentUser")
            }
            
            return updatedUser
        },
        uploadProfileImage: { imageData in
            guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
                throw NetworkError.unauthorized
            }
            
            // TODO: Implementar upload multipart/form-data para imagem
            // Em uma implementação real, você criaria uma requisição multipart como:
            /*
            var request = URLRequest(url: URL(string: "\(NetworkConfig.baseURL)\(NetworkConfig.apiPath)/users/\(userId)/avatar")!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var data = Data()
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(imageData)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            let (responseData, _) = try await URLSession.shared.upload(for: request, from: data)
            let response = try JSONDecoder().decode(APIUploadResponse.self, from: responseData)
            return response.imageURL
            */
            
            // Por enquanto, simula o upload
            try await Task.sleep(nanoseconds: 1_500_000_000)
            
            return "https://ticketplace-api.onrender.com/uploads/profile/\(userId)/\(UUID().uuidString).jpg"
        }
    )
    
    public static let testValue = Self(
        getCurrentUser: {
            return User(
                name: "Usuário Teste",
                title: "Desenvolvedor",
                profileImageURL: nil,
                email: "teste@example.com"
            )
        },
        fetchCurrentUser: {
            return User(
                name: "Usuário Teste",
                title: "Desenvolvedor",
                profileImageURL: nil,
                email: "teste@example.com"
            )
        },
        getUserProfile: { _ in
            return User(
                name: "Usuário Teste",
                title: "Desenvolvedor",
                profileImageURL: nil,
                email: "teste@example.com"
            )
        },
        getUserTickets: { _ in
            return []
        },
        updateUserProfile: { user in
            // Retorna o usuário sem modificações
            return user
        },
        uploadProfileImage: { _ in
            return "https://example.com/test-profile.jpg"
        }
    )
}

extension DependencyValues {
    public var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}
