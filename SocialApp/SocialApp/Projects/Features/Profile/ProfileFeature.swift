import ComposableArchitecture
import Foundation

@Reducer
public struct ProfileFeature {
    @ObservableState
    public struct State: Equatable {
        public var user: User?
        public var isLoading = false
        public var error: String?
        public var ticketsCount: Int = 0
        public var showingEditProfile = false
        public var showingImagePicker = false
        public var showingMyTickets = false
        public var pushNotifications = true
        
        public init(user: User? = nil) {
            self.user = user
        }
    }
    
    public enum Action {
        case onAppear
        case loadUserProfile
        case loadTicketsCount
        case userProfileResponse(Result<User, NetworkError>)
        case ticketsCountResponse(Result<Int, NetworkError>)
        
        // UI Actions
        case editProfileTapped
        case changeProfileImageTapped
        case myTicketsTapped
        case supportTapped
        case privacySettingsTapped
        case signOutTapped
        case togglePushNotifications(Bool)
        
        // Sheet management
        case setShowingEditProfile(Bool)
        case setShowingImagePicker(Bool)
        case setShowingMyTickets(Bool)
        
        // Profile update
        case updateProfile(User)
        case updateProfileResponse(Result<User, NetworkError>)
        
        case dismissError
    }
    
    @Dependency(\.ticketsClient) var ticketsClient
    @Dependency(\.profileClient) var profileClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.loadUserProfile)
                    await send(.loadTicketsCount)
                }
                
            case .loadUserProfile:
                // Se já temos o usuário, não precisa recarregar
                guard state.user != nil else { return .none }
                return .none
                
            case .loadTicketsCount:
                state.isLoading = true
                return .run { send in
                    do {
                        let count = try await ticketsClient.fetchMyTicketsCount()
                        await send(.ticketsCountResponse(.success(count)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.ticketsCountResponse(.failure(networkError)))
                    }
                }
                
            case let .ticketsCountResponse(.success(count)):
                state.isLoading = false
                state.ticketsCount = count
                
                // Atualiza também o user.ticketsCount se existir
                if var user = state.user {
                    user.ticketsCount = count
                    state.user = user
                }
                return .none
                
            case let .ticketsCountResponse(.failure(error)):
                state.isLoading = false
                state.error = error.userFriendlyMessage
                return .none
                
            // UI Actions
            case .editProfileTapped:
                state.showingEditProfile = true
                return .none
                
            case .changeProfileImageTapped:
                state.showingImagePicker = true
                return .none
                
            case .myTicketsTapped:
                state.showingMyTickets = true
                return .none
                
            case .supportTapped:
                // TODO: Implementar suporte
                return .none
                
            case .privacySettingsTapped:
                // TODO: Implementar configurações de privacidade
                return .none
                
            case .signOutTapped:
                // Esta action será tratada pelo SocialAppFeature
                return .none
                
            case let .togglePushNotifications(enabled):
                state.pushNotifications = enabled
                // TODO: Salvar configuração
                return .none
                
            // Sheet management
            case let .setShowingEditProfile(showing):
                state.showingEditProfile = showing
                return .none
                
            case let .setShowingImagePicker(showing):
                state.showingImagePicker = showing
                return .none
                
            case let .setShowingMyTickets(showing):
                state.showingMyTickets = showing
                return .none
                
            // Profile update
            case let .updateProfile(updatedUser):
                state.isLoading = true
                state.error = nil
                
                return .run { send in
                    do {
                        // TODO: Implementar update via ProfileClient quando necessário
                        // Por enquanto, apenas atualiza o estado local
                        await send(.updateProfileResponse(.success(updatedUser)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.updateProfileResponse(.failure(networkError)))
                    }
                }
                
            case let .updateProfileResponse(.success(updatedUser)):
                state.isLoading = false
                state.user = updatedUser
                state.showingEditProfile = false
                return .none
                
            case let .updateProfileResponse(.failure(error)):
                state.isLoading = false
                state.error = error.userFriendlyMessage
                return .none
                
            case .userProfileResponse:
                // TODO: Implementar se necessário
                return .none
                
            case .dismissError:
                state.error = nil
                return .none
            }
        }
    }
}

// MARK: - Equatable Conformance

extension ProfileFeature.Action: Equatable {
    public static func == (lhs: ProfileFeature.Action, rhs: ProfileFeature.Action) -> Bool {
        switch (lhs, rhs) {
        case (.onAppear, .onAppear),
             (.loadUserProfile, .loadUserProfile),
             (.loadTicketsCount, .loadTicketsCount),
             (.editProfileTapped, .editProfileTapped),
             (.changeProfileImageTapped, .changeProfileImageTapped),
             (.myTicketsTapped, .myTicketsTapped),
             (.supportTapped, .supportTapped),
             (.privacySettingsTapped, .privacySettingsTapped),
             (.signOutTapped, .signOutTapped),
             (.dismissError, .dismissError):
            return true
            
        case let (.togglePushNotifications(lhsEnabled), .togglePushNotifications(rhsEnabled)):
            return lhsEnabled == rhsEnabled
            
        case let (.setShowingEditProfile(lhsShowing), .setShowingEditProfile(rhsShowing)):
            return lhsShowing == rhsShowing
            
        case let (.setShowingImagePicker(lhsShowing), .setShowingImagePicker(rhsShowing)):
            return lhsShowing == rhsShowing
            
        case let (.setShowingMyTickets(lhsShowing), .setShowingMyTickets(rhsShowing)):
            return lhsShowing == rhsShowing
            
        case let (.updateProfile(lhsUser), .updateProfile(rhsUser)):
            return lhsUser == rhsUser
            
        case let (.userProfileResponse(lhsResult), .userProfileResponse(rhsResult)):
            switch (lhsResult, rhsResult) {
            case let (.success(lhsUser), .success(rhsUser)):
                return lhsUser == rhsUser
            case let (.failure(lhsError), .failure(rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
            
        case let (.ticketsCountResponse(lhsResult), .ticketsCountResponse(rhsResult)):
            switch (lhsResult, rhsResult) {
            case let (.success(lhsCount), .success(rhsCount)):
                return lhsCount == rhsCount
            case let (.failure(lhsError), .failure(rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
            
        case let (.updateProfileResponse(lhsResult), .updateProfileResponse(rhsResult)):
            switch (lhsResult, rhsResult) {
            case let (.success(lhsUser), .success(rhsUser)):
                return lhsUser == rhsUser
            case let (.failure(lhsError), .failure(rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
            
        default:
            return false
        }
    }
}