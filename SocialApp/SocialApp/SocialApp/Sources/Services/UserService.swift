import Foundation

@MainActor
final class UserService {
    static let shared = UserService()
    private let networkService = NetworkService.shared
    
    private init() {}
    
    // MARK: - User Authentication
    
    /// POST /api/users - Cria novo usuário
    func createUser(name: String, email: String, password: String) async throws -> AuthResponse {
        let request = RegisterRequest(
            name: name,
            email: email,
            password: password
        )
        
        let response: AuthResponse = try await networkService.request(
            endpoint: "/api/users",
            method: .POST,
            body: request
        )
        
        return response
    }
    
    /// Login do usuário (assumindo que existe um endpoint de auth separado)
    func signIn(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(
            email: email,
            password: password
        )
        
        let response: AuthResponse = try await networkService.request(
            endpoint: "/api/auth/login",
            method: .POST,
            body: request
        )
        
        return response
    }
    
    // MARK: - User Management
    
    /// GET /api/users - Lista todos os usuários
    func getAllUsers() async throws -> UsersListResponse {
        let response: UsersListResponse = try await networkService.request(
            endpoint: "/api/users",
            method: .GET
        )
        
        return response
    }
    
    /// GET /api/users/:id - Busca usuário específico (com tickets)
    func getUserById(_ userId: String) async throws -> UserResponse {
        let response: UserResponse = try await networkService.request(
            endpoint: "/api/users/\(userId)",
            method: .GET
        )
        
        return response
    }
    
    /// GET /api/users/:id/tickets - Lista tickets do usuário
    func getUserTickets(userId: String) async throws -> [Ticket] {
        let response: [Ticket] = try await networkService.request(
            endpoint: "/api/users/\(userId)/tickets",
            method: .GET
        )
        
        return response
    }
    
    /// PUT /api/users/:id - Atualiza usuário
    func updateUser(userId: String, updateRequest: UserUpdateRequest) async throws -> User {
        let response: User = try await networkService.request(
            endpoint: "/api/users/\(userId)",
            method: .PUT,
            body: updateRequest
        )
        
        return response
    }
    
    /// POST /api/users/:id/follow - Seguir/Desseguir usuário
    func toggleFollowUser(userId: String) async throws -> FollowResponse {
        let response: FollowResponse = try await networkService.request(
            endpoint: "/api/users/\(userId)/follow",
            method: .POST
        )
        
        return response
    }
    
    // MARK: - Convenience Methods
    
    /// Método de conveniência para atualizar perfil completo
    func updateProfile(userId: String, name: String? = nil, title: String? = nil, profileImageURL: String? = nil, email: String? = nil) async throws -> User {
        let updateRequest = UserUpdateRequest(
            name: name,
            title: title,
            profileImageURL: profileImageURL,
            email: email
        )
        
        return try await updateUser(userId: userId, updateRequest: updateRequest)
    }
    
    /// Método de conveniência para obter usuário com tickets
    func getUserWithTickets(userId: String) async throws -> (user: User, tickets: [Ticket]) {
        let response = try await getUserById(userId)
        return (user: response.user, tickets: response.tickets)
    }
}