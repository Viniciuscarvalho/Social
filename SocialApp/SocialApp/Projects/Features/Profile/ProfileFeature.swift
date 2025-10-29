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
        case myTicketsSheetClosed
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
        
        // Ticket management notifications
        case ticketDeleted // Nova action para quando um ticket for deletado
        case ticketCreated // Nova action para quando um ticket for criado
        case refreshMyTickets // Action para recarregar "Meus Ingressos" após mudanças
        
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
                
                if var user = state.user {
                    user.ticketsCount = count
                    state.user = user
                }
                return .none
                
            case let .ticketsCountResponse(.failure(error)):
                state.isLoading = false
                state.error = error.userFriendlyMessage
                return .none
                
            case .editProfileTapped:
                state.showingEditProfile = true
                return .none
                
            case .changeProfileImageTapped:
                state.showingImagePicker = true
                return .none
                
            case .myTicketsTapped:
                state.showingMyTickets = true
                return .none
                
            case .myTicketsSheetClosed:
                return .run { send in
                    await send(.loadTicketsCount)
                }
                
            case .ticketDeleted:
                // Atualizar contador após deletar ticket
                return .run { send in
                    await send(.loadTicketsCount)
                }
                
            case .ticketCreated:
                // Atualizar contador após criar ticket
                return .run { send in
                    await send(.loadTicketsCount)
                }
                
            case .refreshMyTickets:
                // Recarrega contagem de tickets após mudanças
                return .run { send in
                    await send(.loadTicketsCount)
                }
                
            case .supportTapped:
                return .none
                
            case .privacySettingsTapped:
                return .none
                
            case .signOutTapped:
                return .none
                
            case let .togglePushNotifications(enabled):
                state.pushNotifications = enabled
                return .none
                
            case let .setShowingEditProfile(showing):
                state.showingEditProfile = showing
                return .none
                
            case let .setShowingImagePicker(showing):
                state.showingImagePicker = showing
                return .none
                
            case let .setShowingMyTickets(showing):
                state.showingMyTickets = showing
                return .none
                
            case let .updateProfile(user):
                state.user = user
                return .none
                
            case let .updateProfileResponse(.success(user)):
                state.user = user
                return .none
                
            case let .updateProfileResponse(.failure(error)):
                state.error = error.userFriendlyMessage
                return .none
                
            case .dismissError:
                state.error = nil
                return .none
                
            case .userProfileResponse:
                return .none
            }
        }
    }
}
