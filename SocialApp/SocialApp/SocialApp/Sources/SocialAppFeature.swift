import ComposableArchitecture
import SwiftUI

// Importing all required features explicitly
// (This ensures all features are available for the app state)

@Reducer
public struct SocialAppFeature {
    @ObservableState
    public struct State: Equatable {
        // Auth state
        public var auth = AuthFeature.State()
        
        // Verification state (opcional - mostrado apenas durante signup)
        public var verification: VerificationFeature.State?
        
        // App state
        public var selectedTab: AppTab = .home
        public var homeFeature = HomeFeature.State()
        public var ticketsListFeature = TicketsListFeature.State()
        public var addTicket = AddTicketFeature.State()
        public var negotiationsListFeature = NegotiationsListFeature.State()
        public var profileFeature = ProfileFeature.State()
        public var sellerProfileFeature = SellerProfileFeature.State()
        public var ticketDetailFeature = TicketDetailFeature.State()
        public var eventDetailFeature: EventDetailFeature.State?
        public var searchFeature = SearchFeature.State()
        public var navigationPath = NavigationPath()
        
        public var selectedEventId: UUID?
        public var selectedTicketId: UUID?
        public var selectedSellerId: UUID?
        public var selectedNegotiationId: String?
        public var showingAddTicket = false
        public var showingRecommendedEvents = false
        public var showingPopularEvents = false
        
        // Badge state
        public var unreadQuestionsCount: Int = 0
        public var lastBadgeUpdate: Date?
        
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
        
        public init() {
            print("🚀 SocialAppFeature.State inicializado")
        }
    }
    
    public enum Action {
        // App lifecycle actions
        case onAppear
        case signOut
        case syncAuthData // Nova action para sincronizar dados
        
        // Badge actions
        case updateBadgeCount
        case badgeCountUpdated(Int)
        case startBadgePolling
        case stopBadgePolling
        
        // Auth actions
        case auth(AuthFeature.Action)
        
        // Verification actions (delegated to child feature)
        case verification(VerificationFeature.Action)
        
        // Tab navigation actions
        case tabSelected(AppTab)
        
        // Feature actions
        case homeFeature(HomeFeature.Action)
        case ticketsListFeature(TicketsListFeature.Action)
        case addTicket(AddTicketFeature.Action)
        case negotiationsListFeature(NegotiationsListFeature.Action)
        case profileFeature(ProfileFeature.Action)
        case sellerProfileFeature(SellerProfileFeature.Action)
        case ticketDetailFeature(TicketDetailFeature.Action)
        case eventDetailFeature(EventDetailFeature.Action)
        case searchFeature(SearchFeature.Action)
        
        // Navigation actions
        case navigateToEventDetail(UUID)
        case navigateToTicketDetail(UUID)
        case navigateToSellerProfile(UUID)
        case navigateToEventTickets(UUID)
        
        case dismissEventNavigation(UUID?)
        case dismissTicketNavigation(UUID?)
        case dismissSellerNavigation(UUID?)
        case dismissNegotiationNavigation(String?)
        
        // Add ticket modal actions
        case addTicketTapped
        case setShowingAddTicket(Bool)
        case setAddTicketEventId(UUID?)
        
        // Recommended events navigation
        case showRecommendedEvents
        case setShowingRecommendedEvents(Bool)
        
        // Popular events navigation
        case showPopularEvents
        case setShowingPopularEvents(Bool)
    }
    
    @Dependency(\.negotiationClient) var negotiationClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce(core)
        
        // Depois, os Scopes das features filhas
        Scope(state: \.auth, action: \.auth) {
            AuthFeature()
        }
        
        .ifLet(\.verification, action: \.verification) {
            VerificationFeature()
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
        
        Scope(state: \.negotiationsListFeature, action: \.negotiationsListFeature) {
            NegotiationsListFeature()
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
        
        Scope(state: \.searchFeature, action: \.searchFeature) {
            SearchFeature()
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
            // Atualiza badge quando app aparece
            return .run { send in
                await send(.updateBadgeCount)
                await send(.startBadgePolling)
            }
            
        case .updateBadgeCount:
            return .run { send in
                do {
                    let count = try await negotiationClient.fetchUnreadQuestionsCount()
                    await send(.badgeCountUpdated(count))
                } catch {
                    print("❌ Erro ao buscar contador de badge: \(error.localizedDescription)")
                    // Não atualiza em caso de erro para não confundir usuário
                }
            }
            
        case let .badgeCountUpdated(count):
            state.unreadQuestionsCount = count
            state.lastBadgeUpdate = Date()
            print("🔔 Badge atualizado: \(count) perguntas não respondidas")
            return .none
            
        case .startBadgePolling:
            // Inicia polling a cada 30 segundos
            return .run { send in
                while true {
                    try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 segundos
                    await send(.updateBadgeCount)
                }
            }
            
        case .stopBadgePolling:
            // Para o polling (será cancelado automaticamente quando o reducer for destruído)
            return .none
            
        case .syncAuthData:
            // Sincroniza dados de auth entre AuthFeature.State e UserDefaults
            print("🔄 Sincronizando dados de auth...")
            
            if let currentUser = state.auth.currentUser,
               let authToken = state.auth.authToken {
                
                // Salva todos os dados necessários
                UserDefaults.standard.set(authToken, forKey: "authToken")
                UserDefaults.standard.set(currentUser.id, forKey: "currentUserId")
                
                if let userData = try? JSONEncoder().encode(currentUser) {
                    UserDefaults.standard.set(userData, forKey: "currentUser")
                }
                
                print("✅ Dados de auth sincronizados:")
                print("   Token: \(authToken.prefix(20))...")
                print("   UserId: \(currentUser.id)")
                print("   User: \(currentUser.name)")
            } else {
                print("❌ Dados de auth incompletos no AuthFeature.State")
                print("   currentUser: \(state.auth.currentUser?.name ?? "nil")")
                print("   authToken: \(state.auth.authToken != nil ? "exists" : "nil")")
            }
            
            return .none
            
        case .signOut:
            print("🚪 Iniciando logout...")
            
            // Limpa TODOS os dados do UserDefaults relacionados ao auth
            UserDefaults.standard.removeObject(forKey: "currentUser")
            UserDefaults.standard.removeObject(forKey: "authToken")
            UserDefaults.standard.removeObject(forKey: "currentUserId")
            UserDefaults.standard.removeObject(forKey: "userInterests")
            // Mantém hasLaunchedBefore como true
            print("✅ UserDefaults limpos")
            
            // Limpa o estado do AuthFeature
            state.auth.isAuthenticated = false
            state.auth.currentUser = nil
            state.auth.authToken = nil
            state.auth.currentUserId = nil
            state.auth.errorMessage = nil
            print("✅ Auth state limpo")
            
            // Limpa os dados do app social
            state.selectedTab = .home
            state.homeFeature = HomeFeature.State()
            state.ticketsListFeature = TicketsListFeature.State()
            state.addTicket = AddTicketFeature.State()
            state.negotiationsListFeature = NegotiationsListFeature.State()
            state.profileFeature = ProfileFeature.State()
            state.sellerProfileFeature = SellerProfileFeature.State()
            state.ticketDetailFeature = TicketDetailFeature.State()
            state.searchFeature = SearchFeature.State()
            state.navigationPath = NavigationPath()
            state.selectedEventId = nil
            state.selectedTicketId = nil
            state.selectedSellerId = nil
            state.showingAddTicket = false
            print("✅ App state resetado")
            
            print("🚪 Logout completo - voltando para SignInView")
            return .none
            
            // MARK: - Verification Actions
        case let .verification(.delegate(.verificationCompleted(_))):
            print("✅ Verificação completada com sucesso!")
            state.verification = nil
            return .none
            
        case .verification(.delegate(.verificationCancelled)):
            print("❌ Verificação cancelada pelo usuário")
            state.verification = nil
            return .none
            
        case .verification:
            // Delegar todas as outras ações para VerificationFeature
            return .none
            
            // MARK: - Auth Actions
        case .auth(.authResponse(.success)):
            // Quando o usuário se autentica, sincroniza dados
            if let currentUser = state.auth.currentUser {
                state.profileFeature.user = currentUser
                
                // Sincroniza dados de auth no UserDefaults para garantir consistência
                print("🔐 Sincronizando dados de auth após autenticação bem-sucedida...")
                
                if let authToken = state.auth.authToken {
                    UserDefaults.standard.set(authToken, forKey: "authToken")
                    print("✅ Token salvo no UserDefaults")
                } else {
                    print("⚠️ AuthToken não encontrado no AuthFeature.State")
                }
                
                if let currentUserId = state.auth.currentUserId {
                    UserDefaults.standard.set(currentUserId, forKey: "currentUserId")
                    print("✅ UserId salvo no UserDefaults: \(currentUserId)")
                } else if !currentUser.id.isEmpty {
                    UserDefaults.standard.set(currentUser.id, forKey: "currentUserId")
                    print("✅ UserId salvo do currentUser.id: \(currentUser.id)")
                }
                
                if let userData = try? JSONEncoder().encode(currentUser) {
                    UserDefaults.standard.set(userData, forKey: "currentUser")
                    print("✅ User data salvo no UserDefaults")
                }
                
                // Se é primeira vez (signup), inicia verificação
                // SignIn simples não dispara verificação
                if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
                    print("📋 Iniciando fluxo de verificação para novo usuário (signup)")
                    state.verification = VerificationFeature.State(
                        userEmail: currentUser.email,
                        verificationType: .signup
                    )
                }
            }
            
            // Carrega apenas HomeContent após autenticação
            // Tickets serão carregados quando usuário acessar a aba de Tickets
            print("🎯 Carregando apenas HomeContent após autenticação (otimização)")
            return .run { send in
                await send(.homeFeature(.loadHomeContent))
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
            case .negotiations:
                return .run { send in
                    await send(.negotiationsListFeature(.loadNegotiations))
                }
            case .addTicket:
                return .none
            case .profile:
                // Sincroniza dados do usuário quando acessa o perfil
                if let currentUser = state.currentUser {
                    state.profileFeature.user = currentUser
                    
                    // Debug: verifica inconsistência de auth
                    let hasToken = UserDefaults.standard.string(forKey: "authToken") != nil
                    let hasUserId = UserDefaults.standard.string(forKey: "currentUserId") != nil
                    print("🔍 Debug Profile Access:")
                    print("   Has currentUser: \(currentUser)")
                    print("   Has authToken in UserDefaults: \(hasToken)")
                    print("   Has currentUserId in UserDefaults: \(hasUserId)")
                    print("   Auth.isAuthenticated: \(state.auth.isAuthenticated)")
                    print("   Auth.authToken: \(state.auth.authToken != nil ? "exists" : "nil")")
                    
                    if !hasToken && hasUserId {
                        print("⚠️ Inconsistência detectada: userId existe mas token não!")
                        return .run { send in
                            await send(.syncAuthData)
                            await send(.profileFeature(.onAppear))
                        }
                    }
                }
                return .run { send in
                    await send(.profileFeature(.onAppear))
                }
            }
            
            // MARK: - Add Ticket Modal
        case .addTicketTapped:
            print("🎫 AddTicketTapped - selectedEventId: \(state.selectedEventId?.uuidString ?? "nil")")
            state.showingAddTicket = true
            // Passa o selectedEventId para o AddTicketFeature se houver um evento selecionado
            if let selectedEventId = state.selectedEventId {
                print("✅ Definindo selectedEventId no AddTicket: \(selectedEventId.uuidString)")
                state.addTicket.selectedEventId = selectedEventId
            } else {
                print("⚠️ Nenhum evento selecionado - selectedEventId é nil")
            }
            return .none
            
        case let .setShowingAddTicket(isShowing):
            state.showingAddTicket = isShowing
            return .none
            
        case let .setAddTicketEventId(eventId):
            state.addTicket.selectedEventId = eventId
            return .none
            
        case .showRecommendedEvents:
            state.showingRecommendedEvents = true
            return .none
            
        case let .setShowingRecommendedEvents(isShowing):
            state.showingRecommendedEvents = isShowing
            return .none
            
        case .showPopularEvents:
            state.showingPopularEvents = true
            return .none
            
        case let .setShowingPopularEvents(isShowing):
            state.showingPopularEvents = isShowing
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
            
        case let .dismissNegotiationNavigation(negotiationId):
            state.selectedNegotiationId = negotiationId
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
                print("🎪 Definindo selectedEventId para: \(eventId.uuidString)")
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
            
        case let .negotiationsListFeature(.delegate(.negotiationSelected(negotiationId))):
            // Navega para detalhes da negociação
            state.selectedNegotiationId = negotiationId
            return .none
            
        case .negotiationsListFeature(.negotiationSelected):
            // Esta action é tratada internamente pelo NegotiationsListFeature
            return .none
            
        case let .negotiationsListFeature(.delegate(.negotiationRead(negotiationId))):
            // Quando uma negociação é marcada como lida, atualiza o badge
            // Decrementa o contador localmente (será sincronizado no próximo polling)
            if state.unreadQuestionsCount > 0 {
                state.unreadQuestionsCount = max(0, state.unreadQuestionsCount - 1)
                print("🔔 Badge decrementado após marcar negociação como lida: \(negotiationId)")
            }
            return .none
            
            // MARK: - Add Ticket Completion
        case let .addTicket(.publishTicketResponse(.success(ticket))):
            // Fecha o modal após sucesso
            state.showingAddTicket = false
            // SINCRONIZAÇÃO GLOBAL: Adiciona ticket em todas as listas
            print("🔄 Sincronizando criação de ticket: \(ticket.id)")
            return .run { send in
                // Adiciona na lista completa
                await send(.ticketsListFeature(.syncTicketCreated(ticket)))
                // Se o ticket pertence ao usuário logado, também recarrega "Meus Ingressos"
                if let userId = UserDefaults.standard.string(forKey: "currentUserId"),
                   ticket.sellerId == userId {
                    await send(.profileFeature(.refreshMyTickets))
                }
            }
            
            // MARK: - Other Feature Actions
            // Outras actions das features são tratadas pelos seus próprios reducers
        case .homeFeature(.viewAllRecommended):
            state.showingRecommendedEvents = true
            return .none
            
        case .homeFeature(.viewAllPopular):
            state.showingPopularEvents = true
            return .none
            
        case .homeFeature:
            return .none
            
        case .ticketsListFeature:
            return .none
            
        case .addTicket:
            return .none
            
        case .negotiationsListFeature:
            return .none
            
        case let .ticketDetailFeature(.delegate(.negotiationStarted(negotiationId))):
            // Navega para a tela de negociação após criar
            state.selectedNegotiationId = negotiationId
            // Muda para a tab de negociações
            state.selectedTab = .negotiations
            print("✅ Navegando para negociação criada: \(negotiationId)")
            return .none
            
        case let .ticketDetailFeature(.delegate(.navigateToExistingNegotiation(negotiationId))):
            // Navega para negociação existente
            state.selectedNegotiationId = negotiationId
            // Muda para a tab de negociações
            state.selectedTab = .negotiations
            print("✅ Navegando para negociação existente: \(negotiationId)")
            return .none
            
        case .ticketDetailFeature:
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
            
        case .profileFeature(.onAppear):
            // Verifica consistência dos dados antes de carregar tickets
            let hasToken = UserDefaults.standard.string(forKey: "authToken") != nil
            let hasUserId = UserDefaults.standard.string(forKey: "currentUserId") != nil
            
            if !hasToken && hasUserId {
                print("🔄 Detectada inconsistência de auth, sincronizando...")
                return .run { send in
                    await send(.syncAuthData)
                    // Reenviar onAppear após sincronização
                    await send(.profileFeature(.onAppear))
                }
            }
            return .none
            
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
            
        case .eventDetailFeature(.sellTicketForEvent):
            // Quando o usuário clica em "Vender Ingresso" no detalhe do evento
            print("🎫 sellTicketForEvent - selectedEventId: \(state.selectedEventId?.uuidString ?? "nil")")
            if let eventId = state.selectedEventId {
                print("✅ Abrindo modal AddTicket com eventId: \(eventId.uuidString)")
                state.showingAddTicket = true
                state.addTicket.selectedEventId = eventId
            } else {
                print("⚠️ selectedEventId é nil - não é possível abrir modal")
            }
            return .none
            
        case .eventDetailFeature:
            // Outras event detail actions são tratadas internamente
            return .none
            
            // MARK: - Search Navigation
        case let .searchFeature(.eventSelected(eventId)):
            // Quando um evento é selecionado na busca
            print("🔍 Evento selecionado na busca: \(eventId.uuidString)")
            
            // Fecha o search sheet primeiro
            state.homeFeature.showSearchSheet = false
            
            // Cria o EventDetailFeature.State
            state.selectedEventId = eventId
            state.eventDetailFeature = EventDetailFeature.State(eventId: eventId, event: nil)
            
            return .none
            
        case .searchFeature:
            return .none
        }
    }
}
