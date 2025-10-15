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
        case navigateToEventTickets(UUID) // Nova action para navegar para tickets de um evento
        
        case dismissEventNavigation(UUID?)
        case dismissTicketNavigation(UUID?)
        case dismissSellerNavigation(UUID?)
        
        // Add ticket modal actions
        case addTicketTapped
        case setShowingAddTicket(Bool)
        
        // Implementação manual de Equatable para cases com parâmetros
        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.onAppear, .onAppear),
                (.signOut, .signOut),
                (.addTicketTapped, .addTicketTapped):
                return true
                
            case let (.auth(action1), .auth(action2)):
                return action1 == action2
                
            case let (.tabSelected(tab1), .tabSelected(tab2)):
                return tab1 == tab2
                
            case let (.homeFeature(action1), .homeFeature(action2)):
                return action1 == action2
                
            case let (.ticketsListFeature(action1), .ticketsListFeature(action2)):
                return action1 == action2
                
            case let (.addTicket(action1), .addTicket(action2)):
                return action1 == action2
                
            case let (.favoritesFeature(action1), .favoritesFeature(action2)):
                return action1 == action2
                
            case let (.profileFeature(action1), .profileFeature(action2)):
                return action1 == action2
                
            case let (.sellerProfileFeature(action1), .sellerProfileFeature(action2)):
                return action1 == action2
                
            case let (.ticketDetailFeature(action1), .ticketDetailFeature(action2)):
                return action1 == action2
                
            case let (.eventDetailFeature(action1), .eventDetailFeature(action2)):
                return action1 == action2
                
            case let (.navigateToEventDetail(uuid1), .navigateToEventDetail(uuid2)):
                return uuid1 == uuid2
                
            case let (.navigateToTicketDetail(uuid1), .navigateToTicketDetail(uuid2)):
                return uuid1 == uuid2
                
            case let (.navigateToSellerProfile(uuid1), .navigateToSellerProfile(uuid2)):
                return uuid1 == uuid2
                
            case let (.navigateToEventTickets(uuid1), .navigateToEventTickets(uuid2)):
                return uuid1 == uuid2
                
            case let (.dismissEventNavigation(uuid1), .dismissEventNavigation(uuid2)):
                return uuid1 == uuid2
                
            case let (.dismissTicketNavigation(uuid1), .dismissTicketNavigation(uuid2)):
                return uuid1 == uuid2
                
            case let (.dismissSellerNavigation(uuid1), .dismissSellerNavigation(uuid2)):
                return uuid1 == uuid2
                
            case let (.setShowingAddTicket(bool1), .setShowingAddTicket(bool2)):
                return bool1 == bool2
                
            default:
                return false
            }
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce(core)
        
        // Depois, os Scopes das features filhas
        Scope(state: \.auth, action: \.auth) {
            AuthFeature()
        }
        
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
        
        // Por último, o .ifLet para features opcionais
        .ifLet(\.eventDetailFeature, action: \.eventDetailFeature) {
            EventDetailFeature()
        }
    }
    
    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
            // MARK: - App Lifecycle
        case .onAppear:
            // O AuthFeature já faz checkAuthStatus() no init do State
            // Então não precisa disparar onAppear novamente
            return .none
            
        case .signOut:
            // Envia a action para o AuthFeature via Scope
            state.auth.isAuthenticated = false
            state.auth.currentUser = nil
            state.auth.authToken = nil
            state.auth.currentUserId = nil
            state.auth.errorMessage = nil
            
            // Limpa os dados do app social
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
            
            // MARK: - Auth Actions
        case .auth(.authResponse(.success)):
            // Quando o usuário se autentica, carrega os dados iniciais e sincroniza o perfil
            if let currentUser = state.auth.currentUser {
                state.profileFeature.user = currentUser
            }
            return .run { send in
                await send(.homeFeature(.loadHomeContent))
                await send(.ticketsListFeature(.loadTickets))
            }
            
        case .auth(.signOut):
            // O signOut do auth já é tratado pelo AuthFeature
            // Aqui apenas observamos e limpamos o estado do app social
            return .none
            
        case .auth:
            return .none
            
            // MARK: - Tab Navigation
        case let .tabSelected(tab):
            state.selectedTab = tab
            
            // Carrega dados específicos para cada aba quando selecionada
            switch tab {
            case .home:
                return .run { send in
                    await send(.homeFeature(.refreshHome))
                }
            case .tickets:
                return .run { send in
                    await send(.ticketsListFeature(.loadTickets))
                }
            case .favorites:
                return .run { send in
                    await send(.favoritesFeature(.loadFavorites))
                }
            case .addTicket:
                return .none
            case .profile:
                // Sincroniza dados do usuário quando acessa o perfil
                if let currentUser = state.currentUser {
                    state.profileFeature.user = currentUser
                }
                return .run { send in
                    await send(.profileFeature(.onAppear))
                }
            }
            
            // MARK: - Add Ticket Modal
        case .addTicketTapped:
            state.showingAddTicket = true
            return .none
            
        case let .setShowingAddTicket(isShowing):
            state.showingAddTicket = isShowing
            return .none
            
            // MARK: - Navigation Actions
        case .navigateToEventDetail:
            // Handled in .homeFeature(.eventSelected) and .favoritesFeature(.eventSelected)
            return .none
            
        case let .navigateToTicketDetail(ticketId):
            // Note: Este é chamado pelos handlers específicos abaixo
            // que já configuram o ticketDetailFeature.State com o ticket
            state.selectedTicketId = ticketId
            return .none
            
        case let .navigateToSellerProfile(sellerId):
            state.selectedSellerId = sellerId
            return .none
            
        case let .navigateToEventTickets(eventId):
            // Muda para a aba de tickets e fecha o modal de detalhes
            state.selectedTab = .tickets
            state.selectedEventId = nil // Fecha o modal de evento
            return .run { send in
                // Primeiro carrega os tickets, depois filtra pelo evento específico
                await send(.ticketsListFeature(.loadTickets))
                await send(.ticketsListFeature(.filterByEvent(eventId.uuidString.lowercased())))
            }
            
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
            // Converte String para UUID e busca o evento do state
            if let eventId = UUID(uuidString: eventIdString) {
                // Normaliza o ID para lowercase para consistência
                let normalizedIdString = eventIdString.lowercased()
                
                // Busca o evento nos arrays do HomeContent (comparação case-insensitive)
                let event = state.homeFeature.homeContent.curatedEvents.first { $0.id.lowercased() == normalizedIdString }
                ?? state.homeFeature.homeContent.trendingEvents.first { $0.id.lowercased() == normalizedIdString }
                
                // Se encontrou o evento, normaliza o ID dele
                var normalizedEvent = event
                normalizedEvent?.id = normalizedIdString
                
                // Cria o EventDetailFeature.State com o evento (se encontrado)
                state.selectedEventId = eventId
                state.eventDetailFeature = EventDetailFeature.State(eventId: eventId, event: normalizedEvent)
                
                if event != nil {
                    print("✅ Navegando para evento com dados pré-carregados")
                } else {
                    print("⚠️ Evento não encontrado no state, fará chamada API")
                }
                
                return .none
            } else {
                print("❌ Erro: Não foi possível converter eventId String para UUID: \(eventIdString)")
                return .none
            }
            
        case let .homeFeature(.ticketSelected(ticketIdString)):
            // Converte String para UUID e busca o ticket do state
            if let ticketId = UUID(uuidString: ticketIdString) {
                // Busca o ticket nos availableTickets do HomeContent
                let ticket = state.homeFeature.homeContent.availableTickets.first { $0.id == ticketIdString }
                
                // Atualiza o ticketDetailFeature.State com o ticket (se encontrado)
                state.ticketDetailFeature = TicketDetailFeature.State(ticket: ticket)
                
                if ticket != nil {
                    print("✅ Navegando para ticket com dados pré-carregados")
                } else {
                    print("⚠️ Ticket não encontrado no state, fará chamada API")
                }
                
                // Navega para o detalhe do ticket
                state.selectedTicketId = ticketId
                return .none
            } else {
                print("❌ Erro: Não foi possível converter ticketId String para UUID: \(ticketIdString)")
                return .none
            }
            
        case let .ticketsListFeature(.ticketSelected(ticketId)):
            // Busca o ticket no TicketsListFeature.State
            let ticket = state.ticketsListFeature.tickets.first {
                UUID(uuidString: $0.id) == ticketId
            }
            
            // Atualiza o ticketDetailFeature.State com o ticket (se encontrado)
            state.ticketDetailFeature = TicketDetailFeature.State(ticket: ticket)
            
            if ticket != nil {
                print("✅ Navegando para ticket com dados pré-carregados")
            } else {
                print("⚠️ Ticket não encontrado no state, fará chamada API")
            }
            
            // Navega para o detalhe do ticket
            state.selectedTicketId = ticketId
            return .none
            
        case let .favoritesFeature(.eventSelected(eventId)):
            // Busca o evento favorito correspondente (comparação case-insensitive)
            let favoriteEvent = state.favoritesFeature.favoriteEvents.first {
                $0.eventId.lowercased() == eventId.uuidString.lowercased()
            }
            
            // Reconstrói o Event a partir do FavoriteEvent usando a extensão asEvent
            // (o ID já vem normalizado em lowercase do FavoriteEvent)
            let reconstructedEvent: Event? = favoriteEvent?.asEvent
            
            // Cria o EventDetailFeature.State com o evento reconstruído
            state.selectedEventId = eventId
            state.eventDetailFeature = EventDetailFeature.State(eventId: eventId, event: reconstructedEvent)
            
            if reconstructedEvent != nil {
                print("✅ Navegando para evento favorito com dados pré-carregados")
            } else {
                print("⚠️ Evento favorito não encontrado, fará chamada API")
            }
            
            return .none
            
            // MARK: - Add Ticket Completion
        case .addTicket(.publishTicketResponse(.success)):
            // Fecha o modal após sucesso
            state.showingAddTicket = false
            // Recarrega a lista de tickets
            return .run { send in
                await send(.ticketsListFeature(.loadTickets))
            }
            
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
            return .run { send in
                await send(.auth(.updateCurrentUser(user)))
            }
            
        case .profileFeature(.signOutTapped):
            return .run { send in
                await send(.signOut)
            }
            
        case .profileFeature:
            return .none
            
        case .sellerProfileFeature:
            return .none
            
        case .ticketDetailFeature:
            return .none
            
        case .eventDetailFeature(.viewAvailableTickets):
            // Quando o usuário clica em "Ver Tickets Disponíveis" no detalhe do evento
            if let eventId = state.selectedEventId {
                return .run { send in
                    await send(.navigateToEventTickets(eventId))
                }
            }
            return .none
            
        case .eventDetailFeature:
            // Outras event detail actions são tratadas internamente
            return .none
        }
    }
}
