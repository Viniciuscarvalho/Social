import ComposableArchitecture
import SwiftUI

@Reducer
public struct SocialAppFeature {
    @ObservableState
    public struct State: Equatable {
        // Auth state
        public var auth = AuthFeature.State()
        
        // App state
        public var selectedTab: AppTab = .home
        public var homeFeature = HomeFeature.State()
        public var ticketsListFeature = TicketsListFeature.State()
        public var addTicket = AddTicketFeature.State()
        public var favoritesFeature = FavoritesFeature.State()
        public var profileFeature = ProfileFeature.State()
        public var sellerProfileFeature = SellerProfileFeature.State()
        public var ticketDetailFeature = TicketDetailFeature.State()
        public var eventDetailFeature: EventDetailFeature.State?
        public var navigationPath = NavigationPath()

        public var selectedEventId: UUID?
        public var selectedTicketId: UUID?
        public var selectedSellerId: UUID?
        public var showingAddTicket = false
        
        // Computed properties for easier access
        public var isAuthenticated: Bool {
            auth.isAuthenticated
        }
        
        public var isFirstLaunch: Bool {
            auth.isFirstLaunch
        }
        
        public var currentUser: User? {
            auth.currentUser
        }
        
        public init() {}
    }
    
    public enum Action: Equatable {
        // App lifecycle actions
        case onAppear
        case signOut
        
        // Auth actions
        case auth(AuthFeature.Action)
        
        // Tab navigation actions
        case tabSelected(AppTab)
        
        // Feature actions
        case homeFeature(HomeFeature.Action)
        case ticketsListFeature(TicketsListFeature.Action)
        case addTicket(AddTicketFeature.Action)
        case favoritesFeature(FavoritesFeature.Action)
        case profileFeature(ProfileFeature.Action)
        case sellerProfileFeature(SellerProfileFeature.Action)
        case ticketDetailFeature(TicketDetailFeature.Action)
        case eventDetailFeature(EventDetailFeature.Action)

        // Navigation actions
        case navigateToEventDetail(UUID)
        case navigateToTicketDetail(UUID)
        case navigateToSellerProfile(UUID)
        
        case dismissEventNavigation(UUID?)
        case dismissTicketNavigation(UUID?)
        case dismissSellerNavigation(UUID?)
        
        // Add ticket modal actions
        case addTicketTapped
        case setShowingAddTicket(Bool)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        // Auth reducer
        Scope(state: \.auth, action: \.auth) {
            AuthFeature()
        }
        
        // Feature reducers
        Scope(state: \.homeFeature, action: \.homeFeature) {
            HomeFeature()
        }
        
        Scope(state: \.ticketsListFeature, action: \.ticketsListFeature) {
            TicketsListFeature()
        }
        
        Scope(state: \.addTicket, action: \.addTicket) {
            AddTicketFeature()
        }
        
        Scope(state: \.favoritesFeature, action: \.favoritesFeature) {
            FavoritesFeature()
        }
        
        Scope(state: \.profileFeature, action: \.profileFeature) {
            ProfileFeature()
        }
        
        Scope(state: \.sellerProfileFeature, action: \.sellerProfileFeature) {
            SellerProfileFeature()
        }
        
        Scope(state: \.ticketDetailFeature, action: \.ticketDetailFeature) {
            TicketDetailFeature()
        }
        
        Reduce { state, action in
            switch action {
                
            // MARK: - App Lifecycle
            case .onAppear:
                return .send(.auth(.onAppear))
                
            case .signOut:
                return .send(.auth(.signOut))
                
            // MARK: - Auth Actions
            case .auth(.authResponse(.success)):
                // Quando o usuário se autentica, carrega os dados iniciais e sincroniza o perfil
                if let currentUser = state.currentUser {
                    state.profileFeature.user = currentUser
                }
                return .merge(
                    .send(.homeFeature(.loadContent)),
                    .send(.ticketsListFeature(.loadAvailableTickets))
                )
                
            case .auth(.signOut):
                // Quando o usuário sai, limpa todos os dados do app social
                state.selectedTab = .home
                state.homeFeature = HomeFeature.State()
                state.ticketsListFeature = TicketsListFeature.State()
                state.addTicket = AddTicketFeature.State()
                state.favoritesFeature = FavoritesFeature.State()
                state.profileFeature = ProfileFeature.State()
                state.sellerProfileFeature = SellerProfileFeature.State()
                state.ticketDetailFeature = TicketDetailFeature.State()
                state.navigationPath = NavigationPath()
                state.selectedEventId = nil
                state.selectedTicketId = nil
                state.selectedSellerId = nil
                state.showingAddTicket = false
                return .none
                
            case .auth:
                return .none
                
            // MARK: - Tab Navigation
            case let .tabSelected(tab):
                state.selectedTab = tab
                
                // Carrega dados específicos para cada aba quando selecionada
                switch tab {
                case .home:
                    return .send(.homeFeature(.refreshRequested))
                case .tickets:
                    return .send(.ticketsListFeature(.loadAvailableTickets))
                case .favorites:
                    return .send(.favoritesFeature(.loadFavoriteTickets))
                case .addTicket:
                    return .none
                case .profile:
                    // Sincroniza dados do usuário quando acessa o perfil
                    if let currentUser = state.currentUser {
                        state.profileFeature.user = currentUser
                    }
                    return .send(.profileFeature(.onAppear))
                }
                
            // MARK: - Add Ticket Modal
            case .addTicketTapped:
                state.showingAddTicket = true
                return .none
                
            case let .setShowingAddTicket(isShowing):
                state.showingAddTicket = isShowing
                return .none
                
            // MARK: - Navigation Actions
            case let .navigateToEventDetail(eventId):
                state.selectedEventId = eventId
                state.eventDetailFeature = EventDetailFeature.State(eventId: eventId)
                return .none
                
            case let .navigateToTicketDetail(ticketId):
                state.selectedTicketId = ticketId
                return .none
                
            case let .navigateToSellerProfile(sellerId):
                state.selectedSellerId = sellerId
                return .none
                
            case .dismissEventNavigation:
                state.selectedEventId = nil
                state.eventDetailFeature = nil
                return .none
                
            case .dismissTicketNavigation:
                state.selectedTicketId = nil
                return .none
                
            case .dismissSellerNavigation:
                state.selectedSellerId = nil
                return .none
                
            // MARK: - Child Feature Navigation
            case let .homeFeature(.eventSelected(eventIdString)):
                // Converte String para UUID para EventDetailFeature
                if let eventId = UUID(uuidString: eventIdString) {
                    return .send(.navigateToEventDetail(eventId))
                } else {
                    print("❌ Erro: Não foi possível converter eventId String para UUID: \(eventIdString)")
                    return .none
                }
                
            case let .homeFeature(.ticketSelected(ticketIdString)):
                // Converte String para UUID para TicketDetailFeature
                if let ticketId = UUID(uuidString: ticketIdString) {
                    return .send(.navigateToTicketDetail(ticketId))
                } else {
                    print("❌ Erro: Não foi possível converter ticketId String para UUID: \(ticketIdString)")
                    return .none
                }
                
            case let .ticketsListFeature(.ticketSelected(ticketId)):
                return .send(.navigateToTicketDetail(ticketId))
                
            case let .favoritesFeature(.eventSelected(eventId)):
                return .send(.navigateToEventDetail(eventId))
                
            // MARK: - Add Ticket Completion
            case .addTicket(.publishTicketResponse(.success)):
                // Fecha o modal após sucesso
                state.showingAddTicket = false
                // Recarrega a lista de tickets
                return .send(.ticketsListFeature(.loadAvailableTickets))
                
            // MARK: - Other Feature Actions
            // Outras actions das features são tratadas pelos seus próprios reducers
            case .homeFeature:
                return .none
                
            case .ticketsListFeature:
                return .none
                
            case .addTicket:
                return .none
                
            case .favoritesFeature:
                return .none
                
            case .profileFeature(.updateProfileResponse(.success(let user))):
                // Quando o perfil é atualizado com sucesso, atualiza também o auth state
                return .send(.auth(.updateCurrentUser(user)))
                
            case .profileFeature(.signOutTapped):
                return .send(.signOut)
                
            case .profileFeature:
                return .none
                
            case .sellerProfileFeature:
                return .none
                
            case .ticketDetailFeature:
                return .none
                
            case .eventDetailFeature:
                // Event detail actions são tratadas internamente
                return .none
            }
        }
    }
}
