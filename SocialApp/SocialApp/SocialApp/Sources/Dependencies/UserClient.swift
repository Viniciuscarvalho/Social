import ComposableArchitecture
import Foundation

@DependencyClient
public struct UserClient {
    var getCurrentUser: @Sendable () async throws -> User
    var updateUserProfile: @Sendable (User) async throws -> User
    var uploadProfileImage: @Sendable (Data) async throws -> String
    var signOut: @Sendable () async throws -> Void
}

extension UserClient: DependencyKey {
    static let liveValue = Self(
        getCurrentUser: {
            // Opção 1: Usar chamada direta à API
            guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
                throw NetworkError.unauthorized
            }
            
            // Faz a chamada real para a API
            let apiResponse: UserResponse = try await NetworkService.shared.request(
                endpoint: "/users/\(userId)",
                method: .GET,
                requiresAuth: true
            )
            
            return apiResponse.toUser()
            
            // Opção 2: Usar o UserClient existente (comentado por enquanto)
            // @Dependency(\.userClient) var userClient
            // return try await userClient.fetchCurrentUser()
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
        },
        signOut: {
            // Remove dados de autenticação locais
            UserDefaults.standard.removeObject(forKey: "authToken")
            UserDefaults.standard.removeObject(forKey: "currentUser")
            UserDefaults.standard.removeObject(forKey: "currentUserId")
            
            // Opcional: Fazer chamada para logout no servidor para invalidar tokens
            // Comentado por enquanto, mas pode ser adicionado se necessário
            /*
            do {
                let _: EmptyResponse = try await NetworkService.shared.request(
                    endpoint: "/auth/logout",
                    method: .POST,
                    requiresAuth: true
                )
            } catch {
                // Ignora erro de logout no servidor se houver
                print("Erro ao fazer logout no servidor: \(error)")
            }
            */
        }
    )
    
    static let testValue = Self(
        getCurrentUser: {
            // Retorna um usuário de teste
            return User(
                id: UUID(uuidString: "12345678-1234-1234-1234-123456789012") ?? UUID(),
                name: "Usuário Teste",
                title: "Desenvolvedor",
                profileImageURL: nil,
                email: "teste@example.com"
            )
        },
        updateUserProfile: { user in
            // Retorna o usuário sem modificações
            return user
        },
        uploadProfileImage: { _ in
            return "https://example.com/test-profile.jpg"
        },
        signOut: {
            // Não faz nada em testes
        }
    )
}

extension DependencyValues {
    public var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}
