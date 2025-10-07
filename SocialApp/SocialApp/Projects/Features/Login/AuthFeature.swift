import ComposableArchitecture
import Foundation

@Reducer
struct AuthFeature {
    @ObservableState
    struct State: Equatable {
        var isAuthenticated = false
        var currentUser: User?
        var isFirstLaunch = true
        var isLoading = false
        var errorMessage: String?
        var authToken: String?
        var currentUserId: String?
        
        var signInForm = SignInForm.State()
        var signUpForm = SignUpForm.State()
        
        init() {
            checkAuthStatus()
        }
        
        mutating func checkAuthStatus() {
            if let userData = UserDefaults.standard.data(forKey: "currentUser"),
               let user = try? JSONDecoder().decode(User.self, from: userData) {
                currentUser = user
                isAuthenticated = true
                authToken = UserDefaults.standard.string(forKey: "authToken")
                currentUserId = UserDefaults.standard.string(forKey: "currentUserId")
            }
            
            isFirstLaunch = UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == false
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case signIn(email: String, password: String)
        case signUp(name: String, email: String, password: String)
        case signOut
        case refreshUserProfile
        case authResponse(Result<APIAuthResponse, NetworkError>)
        case userProfileResponse(Result<APIUser, NetworkError>)
        case clearError
        case signInForm(SignInForm.Action)
        case signUpForm(SignUpForm.Action)
    }
    
    @Dependency(\.authClient) var authClient
    
    var body: some ReducerOf<Self> {
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
                        let response = try await authClient.signIn(email, password)
                        await send(.authResponse(.success(response)))
                    } catch let error as NetworkError {
                        await send(.authResponse(.failure(error)))
                    } catch {
                        await send(.authResponse(.failure(.unknown(error))))
                    }
                }
                
            case let .signUp(name, email, password):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let response = try await authClient.signUp(name, email, password)
                        await send(.authResponse(.success(response)))
                    } catch let error as NetworkError {
                        await send(.authResponse(.failure(error)))
                    } catch {
                        await send(.authResponse(.failure(.unknown(error))))
                    }
                }
                
            case .signOut:
                // Remove dados locais
                UserDefaults.standard.removeObject(forKey: "currentUser")
                UserDefaults.standard.removeObject(forKey: "authToken")
                UserDefaults.standard.removeObject(forKey: "currentUserId")
                
                // Limpa estado
                state.currentUser = nil
                state.isAuthenticated = false
                state.authToken = nil
                state.currentUserId = nil
                state.errorMessage = nil
                return .none
                
            case .refreshUserProfile:
                guard let userId = state.currentUserId else { return .none }
                return .run { send in
                    do {
                        let apiUser = try await authClient.getUserProfile(userId)
                        await send(.userProfileResponse(.success(apiUser)))
                    } catch let error as NetworkError {
                        await send(.userProfileResponse(.failure(error)))
                    } catch {
                        await send(.userProfileResponse(.failure(.unknown(error))))
                    }
                }
                
            case let .authResponse(.success(response)):
                state.isLoading = false
                state.errorMessage = nil
                
                // Converte o modelo da API para o modelo de domínio
                let user = response.user.toDomainModel()
                
                // Salva os dados localmente
                saveUserData(user: user, token: response.token, userId: response.user.id)
                
                // Atualiza o estado
                state.currentUser = user
                state.isAuthenticated = true
                state.isFirstLaunch = false
                state.authToken = response.token
                state.currentUserId = response.user.id
                return .none
                
            case let .authResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.errorDescription
                return .none
                
            case let .userProfileResponse(.success(apiUser)):
                let user = apiUser.toDomainModel()
                
                // Atualiza o usuário local
                if let encoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encoded, forKey: "currentUser")
                    state.currentUser = user
                }
                return .none
                
            case let .userProfileResponse(.failure(error)):
                print("Erro ao atualizar perfil do usuário: \(error)")
                return .none
                
            case .clearError:
                state.errorMessage = nil
                return .none
                
            case .signInForm(.signInTapped(let email, let password)):
                return .send(.signIn(email: email, password: password))
                
            case .signUpForm(.signUpTapped(let name, let email, let password)):
                return .send(.signUp(name: name, email: email, password: password))
                
            case .signInForm, .signUpForm:
                return .none
            }
        }
    }
}

// MARK: - SignIn Form Feature

@Reducer
struct SignInForm {
    @ObservableState
    struct State: Equatable {
        var email = ""
        var password = ""
        var rememberMe = false
        var showAlert = false
        var alertMessage = ""
    }
    
    enum Action: Equatable {
        case emailChanged(String)
        case passwordChanged(String)
        case rememberMeToggled
        case signInTapped(email: String, password: String)
        case alertDismissed
        case showAlert(String)
    }
    
    var body: some ReducerOf<Self> {
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
                    return .send(.showAlert("Por favor, insira seu email"))
                }
                
                guard !state.password.isEmpty else {
                    return .send(.showAlert("Por favor, insira sua senha"))
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
struct SignUpForm {
    @ObservableState
    struct State: Equatable {
        var name = ""
        var email = ""
        var password = ""
        var confirmPassword = ""
        var showAlert = false
        var alertMessage = ""
    }
    
    enum Action: Equatable {
        case nameChanged(String)
        case emailChanged(String)
        case passwordChanged(String)
        case confirmPasswordChanged(String)
        case signUpTapped(name: String, email: String, password: String)
        case alertDismissed
        case showAlert(String)
    }
    
    var body: some ReducerOf<Self> {
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
                    return .send(.showAlert("Por favor, insira seu nome"))
                }
                
                guard !state.email.isEmpty else {
                    return .send(.showAlert("Por favor, insira seu email"))
                }
                
                guard !state.password.isEmpty else {
                    return .send(.showAlert("Por favor, insira sua senha"))
                }
                
                guard state.password == state.confirmPassword else {
                    return .send(.showAlert("As senhas não coincidem"))
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
