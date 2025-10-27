import ComposableArchitecture
import Foundation

@Reducer
public struct AuthFeature {
    @ObservableState
    public struct State: Equatable {
        public var isAuthenticated = false
        public var currentUser: User?
        public var isFirstLaunch = true
        public var isLoading = false
        public var errorMessage: String?
        public var authToken: String?
        public var currentUserId: String?
        
        public var signInForm = SignInForm.State()
        public var signUpForm = SignUpForm.State()
        
        public init() {
            checkAuthStatus()
        }
        
        public mutating func checkAuthStatus() {
            if let userData = UserDefaults.standard.data(forKey: "currentUser"),
               var user = try? JSONDecoder().decode(User.self, from: userData) {
                
                // Load interests if saved
                if let interestsData = UserDefaults.standard.data(forKey: "userInterests"),
                   let interests = try? JSONDecoder().decode([String].self, from: interestsData) {
                    user.interests = interests
                }
                
                currentUser = user
                isAuthenticated = true
                authToken = UserDefaults.standard.string(forKey: "authToken")
                currentUserId = UserDefaults.standard.string(forKey: "currentUserId")
            }
            
            isFirstLaunch = UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == false
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case signIn(email: String, password: String)
        case signUp(name: String, email: String, password: String)
        case signOut
        case refreshUserProfile
        case updateCurrentUser(User)
        case authResponse(Result<AuthResponse, NetworkError>)
        case userProfileResponse(Result<User, NetworkError>)
        case clearError
        case signInForm(SignInForm.Action)
        case signUpForm(SignUpForm.Action)
    }
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.userClient) var userClient
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.signInForm, action: \.signInForm) {
            SignInForm()
        }
        
        Scope(state: \.signUpForm, action: \.signUpForm) {
            SignUpForm()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.checkAuthStatus()
                return .none
                
            case let .signIn(email, password):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        print("🔐 Tentando fazer login: \(email)")
                        let response = try await authClient.signIn(email, password)
                        print("✅ Login realizado com sucesso: \(response.user.name)")
                        await send(.authResponse(.success(response)))
                    } catch let error as NetworkError {
                        print("❌ Erro no login (NetworkError): \(error)")
                        await send(.authResponse(.failure(error)))
                    } catch {
                        print("❌ Erro no login (Desconhecido): \(error)")
                        await send(.authResponse(.failure(.unknown(error.localizedDescription))))
                    }
                }
                
            case let .signUp(name, email, password):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        print("📝 Tentando cadastrar usuário: \(email)")
                        let response = try await authClient.signUp(name, email, password)
                        print("✅ Cadastro realizado com sucesso: \(response.user.name)")
                        await send(.authResponse(.success(response)))
                    } catch let error as NetworkError {
                        print("❌ Erro no cadastro (NetworkError): \(error)")
                        await send(.authResponse(.failure(error)))
                    } catch {
                        print("❌ Erro no cadastro (Desconhecido): \(error)")
                        await send(.authResponse(.failure(.unknown(error.localizedDescription))))
                    }
                }
                
            case .signOut:
                // Limpa estado local e chama o logout do cliente de auth
                state.currentUser = nil
                state.isAuthenticated = false
                state.authToken = nil
                state.currentUserId = nil
                state.errorMessage = nil
                
                return .run { _ in
                    try? await authClient.signOut()
                }
                
            case let .updateCurrentUser(user):
                // Atualiza o usuário atual no estado
                state.currentUser = user
                if let encoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encoded, forKey: "currentUser")
                }
                return .none
                
            case .refreshUserProfile:
                guard let userId = state.currentUserId else { return .none }
                return .run { send in
                    do {
                        let user = try await userClient.getUserProfile(userId)
                        await send(.userProfileResponse(.success(user)))
                    } catch let error as NetworkError {
                        await send(.userProfileResponse(.failure(error)))
                    } catch {
                        await send(.userProfileResponse(.failure(.unknown(error.localizedDescription))))
                    }
                }
                
            case let .authResponse(.success(response)):
                state.isLoading = false
                state.errorMessage = nil
                
                let user = response.user
                
                // Salva os dados localmente
                saveUserData(user: user, token: response.token, userId: user.id)
                
                // Atualiza o estado
                state.currentUser = user
                state.isAuthenticated = true
                state.isFirstLaunch = false
                state.authToken = response.token
                state.currentUserId = user.id
                return .none
                
            case let .authResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.errorDescription
                return .none
                
            case let .userProfileResponse(.success(user)):
                // Atualiza o usuário local
                if let encoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encoded, forKey: "currentUser")
                }
                state.currentUser = user
                return .none
                
            case let .userProfileResponse(.failure(error)):
                print("Erro ao atualizar perfil do usuário: \(error)")
                return .none
                
            case .clearError:
                state.errorMessage = nil
                return .none
                
            case .signInForm(.signInTapped(let email, let password)):
                return .run { send in
                    await send(.signIn(email: email, password: password))
                }
                
            case .signUpForm(.signUpTapped(let name, let email, let password)):
                return .run { send in
                    await send(.signUp(name: name, email: email, password: password))
                }
                
            case .signInForm, .signUpForm:
                return .none
            }
        }
    }
}

// MARK: - SignIn Form Feature

@Reducer
public struct SignInForm {
    @ObservableState
    public struct State: Equatable {
        public var email = ""
        public var password = ""
        public var rememberMe = false
        public var showAlert = false
        public var alertMessage = ""
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case emailChanged(String)
        case passwordChanged(String)
        case rememberMeToggled
        case signInTapped(email: String, password: String)
        case alertDismissed
        case showAlert(String)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(email):
                state.email = email
                return .none
                
            case let .passwordChanged(password):
                state.password = password
                return .none
                
            case .rememberMeToggled:
                state.rememberMe.toggle()
                return .none
                
            case .signInTapped:
                guard !state.email.isEmpty else {
                    return .run { send in
                        await send(.showAlert("Por favor, insira seu email"))
                    }
                }
                 
                guard !state.password.isEmpty else {
                    return .run { send in
                        await send(.showAlert("Por favor, insira sua senha"))
                    }
                }
                
                return .none
                
            case .alertDismissed:
                state.showAlert = false
                state.alertMessage = ""
                return .none
                
            case let .showAlert(message):
                state.alertMessage = message
                state.showAlert = true
                return .none
            }
        }
    }
}

// MARK: - SignUp Form Feature

@Reducer
public struct SignUpForm {
    @ObservableState
    public struct State: Equatable {
        public var name = ""
        public var email = ""
        public var password = ""
        public var confirmPassword = ""
        public var showAlert = false
        public var alertMessage = ""
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case nameChanged(String)
        case emailChanged(String)
        case passwordChanged(String)
        case confirmPasswordChanged(String)
        case signUpTapped(name: String, email: String, password: String)
        case alertDismissed
        case showAlert(String)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .nameChanged(name):
                state.name = name
                return .none
                
            case let .emailChanged(email):
                state.email = email
                return .none
                
            case let .passwordChanged(password):
                state.password = password
                return .none
                
            case let .confirmPasswordChanged(confirmPassword):
                state.confirmPassword = confirmPassword
                return .none
                
            case .signUpTapped:
                guard !state.name.isEmpty else {
                    return .run { send in
                        await send(.showAlert("Por favor, insira seu nome"))
                    }
                }
                
                guard !state.email.isEmpty else {
                    return .run { send in
                        await send(.showAlert("Por favor, insira seu email"))
                    }
                }
                
                guard !state.password.isEmpty else {
                    return .run { send in
                        await send(.showAlert("Por favor, insira sua senha"))
                    }
                }
                
                guard state.password == state.confirmPassword else {
                    return .run { send in
                        await send(.showAlert("As senhas não coincidem"))
                    }
                }
                
                return .none
                
            case .alertDismissed:
                state.showAlert = false
                state.alertMessage = ""
                return .none
                
            case let .showAlert(message):
                state.alertMessage = message
                state.showAlert = true
                return .none
            }
        }
    }
}

// MARK: - Helper Functions

private func saveUserData(user: User, token: String, userId: String) {
    // Salva o usuário
    if let encoded = try? JSONEncoder().encode(user) {
        UserDefaults.standard.set(encoded, forKey: "currentUser")
    }
    
    // Salva o token de autenticação
    UserDefaults.standard.set(token, forKey: "authToken")
    
    // Salva o ID do usuário
    UserDefaults.standard.set(userId, forKey: "currentUserId")
    
    // Marca que o app já foi aberto
    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
}

