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
            do {
                guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
                    throw NetworkError.unauthorized
                }
                
                print("👤 Fetching current user from API: \(userId)")
                let apiResponse: APIUserResponse = try await NetworkService.shared.requestSingle(
                    endpoint: "/users/\(userId)",
                    method: .GET,
                    requiresAuth: true
                )
                
                print("✅ Successfully fetched current user from API")
                return apiResponse.toUser()
            } catch {
                print("❌ Failed to fetch current user: \(error)")
                throw error
            }
        },
        fetchCurrentUser: {
            do {
                guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
                    throw NetworkError.unauthorized
                }
                
                print("👤 Fetching current user from API (alias): \(userId)")
                let apiResponse: APIUserResponse = try await NetworkService.shared.requestSingle(
                    endpoint: "/users/\(userId)",
                    method: .GET,
                    requiresAuth: true
                )
                
                print("✅ Successfully fetched current user from API")
                return apiResponse.toUser()
            } catch {
                print("❌ Failed to fetch current user: \(error)")
                throw error
            }
        },
        getUserProfile: { userId in
            do {
                print("👤 Fetching user profile from API: \(userId)")
                let apiResponse: APIUserResponse = try await NetworkService.shared.requestSingle(
                    endpoint: "/users/\(userId)",
                    method: .GET,
                    requiresAuth: true
                )
                print("✅ Successfully fetched user profile from API")
                return apiResponse.toUser()
            } catch {
                print("❌ Failed to fetch user profile: \(error)")
                throw error
            }
        },
        getUserTickets: { userId in
            do {
                print("🎫 Fetching user tickets from API: \(userId)")
                let apiResponse: [APITicketResponse] = try await NetworkService.shared.requestArray(
                    endpoint: "/users/\(userId)/tickets",
                    method: .GET,
                    requiresAuth: true
                )
                print("✅ Successfully fetched \(apiResponse.count) user tickets from API")
                return apiResponse.map { $0.toTicket() }
            } catch {
                print("❌ Failed to fetch user tickets: \(error)")
                throw error
            }
        },
        updateUserProfile: { user in
            do {
                guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
                    throw NetworkError.unauthorized
                }
                
                print("✏️ Updating user profile: \(userId)")
                let updateRequest = UserUpdateRequest(
                    name: user.name,
                    title: user.title,
                    email: user.email
                )
                
                let apiResponse: APIUserResponse = try await NetworkService.shared.requestSingle(
                    endpoint: "/users/\(userId)",
                    method: .PUT,
                    body: updateRequest,
                    requiresAuth: true
                )
                
                print("✅ Successfully updated user profile")
                
                // Atualiza os dados locais também
                let updatedUser = apiResponse.toUser()
                if let userData = try? JSONEncoder().encode(updatedUser) {
                    UserDefaults.standard.set(userData, forKey: "currentUser")
                }
                
                return updatedUser
            } catch {
                print("❌ Failed to update user profile: \(error)")
                throw error
            }
        },
        uploadProfileImage: { imageData in
            do {
                guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
                    throw NetworkError.unauthorized
                }
                
                print("📷 Uploading profile image for user: \(userId)")
                
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
                
                let imageURL = "https://ticketplace-api.onrender.com/uploads/profile/\(userId)/\(UUID().uuidString).jpg"
                print("✅ Successfully uploaded profile image: \(imageURL)")
                return imageURL
            } catch {
                print("❌ Failed to upload profile image: \(error)")
                throw error
            }
        }
    )
    
    public static let testValue = Self(
        getCurrentUser: {
            // ✅ Retorna usuário padrão para desenvolvimento  
            var defaultUser = User(
                name: "Usuário Teste",
                title: "Desenvolvedor",
                profileImageURL: "https://example.com/test-profile.jpg",
                email: "teste@example.com"
            )
            defaultUser.id = "TEST_USER_001"
            defaultUser.isVerified = true
            defaultUser.followersCount = 150
            defaultUser.followingCount = 89
            defaultUser.ticketsCount = 5
            return defaultUser
        },
        fetchCurrentUser: {
            // ✅ Alias para getCurrentUser
            var defaultUser = User(
                name: "Usuário Teste", 
                title: "Desenvolvedor",
                profileImageURL: "https://example.com/test-profile.jpg",
                email: "teste@example.com"
            )
            defaultUser.id = "TEST_USER_001"
            defaultUser.isVerified = true
            defaultUser.followersCount = 150
            defaultUser.followingCount = 89
            defaultUser.ticketsCount = 5
            return defaultUser
        },
        getUserProfile: { userId in
            // ✅ Retorna perfil baseado no userId ou usuário padrão
            if userId == "TEST_USER_001" {
                var defaultUser = User(
                    name: "Usuário Teste",
                    title: "Desenvolvedor", 
                    profileImageURL: "https://example.com/test-profile.jpg",
                    email: "teste@example.com"
                )
                defaultUser.id = "TEST_USER_001"
                defaultUser.isVerified = true
                defaultUser.followersCount = 150
                defaultUser.followingCount = 89
                defaultUser.ticketsCount = 5
                return defaultUser
            } else {
                // Retorna um dos sellers de exemplo
                return SharedMockData.sampleSellerProfiles.first { $0.id == userId } 
                    ?? SharedMockData.sampleSellerProfiles[0]
            }
        },
        getUserTickets: { _ in
            return SharedMockData.sampleTickets
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
