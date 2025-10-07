import Foundation

// DEPRECATED: Prefer using TCA clients (AuthClient, UserClient) instead of UserService.
@MainActor
final class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isFirstLaunch = true
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authClient = AuthClient.liveValue
    private let userClient = UserClient.liveValue
    private var authToken: String?
    private var currentUserId: String?
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isAuthenticated = true
            authToken = UserDefaults.standard.string(forKey: "authToken")
            currentUserId = UserDefaults.standard.string(forKey: "currentUserId")
        }
        
        isFirstLaunch = UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == false
    }
    
    func signUp(name: String, email: String, password: String) {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await authClient.signUp(name, email, password)
                
                // Salva os dados localmente
                await saveUserData(
                    user: response.user,
                    token: response.token,
                    userId: response.user.id.uuidString
                )
                
                // Atualiza o estado
                currentUser = response.user
                isAuthenticated = true
                isFirstLaunch = false
                
            } catch let error as NetworkError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Erro inesperado ao criar conta"
            }
            
            isLoading = false
        }
    }
    
    func signIn(email: String, password: String) {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await authClient.signIn(email, password)
                
                // Salva os dados localmente
                await saveUserData(
                    user: response.user,
                    token: response.token,
                    userId: response.user.id.uuidString
                )
                
                // Atualiza o estado
                currentUser = response.user
                isAuthenticated = true
                
            } catch let error as NetworkError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Erro inesperado ao fazer login"
            }
            
            isLoading = false
        }
    }
    
    func signOut() {
        Task { @MainActor in
            try? await authClient.signOut()
            currentUser = nil
            isAuthenticated = false
            authToken = nil
            currentUserId = nil
            errorMessage = nil
        }
    }
    
    func refreshUserProfile() {
        guard let userId = currentUserId else { return }
        
        Task {
            do {
                let user = try await userClient.getUserProfile(userId)
                if let encoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encoded, forKey: "currentUser")
                    currentUser = user
                }
            } catch {
                print("Erro ao atualizar perfil do usuário: \(error)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func saveUserData(user: User, token: String?, userId: String) async {
        // Salva o usuário
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
        
        // Salva o token de autenticação
        if let token = token {
            UserDefaults.standard.set(token, forKey: "authToken")
            authToken = token
        }
        
        // Salva o ID do usuário
        UserDefaults.standard.set(userId, forKey: "currentUserId")
        currentUserId = userId
        
        // Marca que o app já foi aberto
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
    }
}
