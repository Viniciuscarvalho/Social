import ComposableArchitecture
import Foundation

@Reducer
public struct SellerProfileFeature {
    @ObservableState
    public struct State: Equatable {
        public var sellerId: String?
        public var seller: User?
        public var sellerTickets: [TicketWithEvent] = []
        public var isLoading: Bool = false
        public var isLoadingTickets: Bool = false
        public var isRefreshing: Bool = false
        public var errorMessage: String?
        public var isFollowing: Bool = false
        public var selectedTab: Tab = .tickets
        public var loadState: LoadState = .idle
        
        public enum Tab: String, CaseIterable {
            case about = "Sobre"
            case tickets = "Ingressos"
        }
        
        public enum LoadState: Equatable {
            case idle
            case loading
            case loaded
            case cached
            case refreshing
            case error(String)
        }
        
        public init(sellerId: String? = nil) {
            self.sellerId = sellerId
            print("📍 SellerProfileFeature.State inicializado com sellerId: \(sellerId ?? "nil")")
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadSeller(String)
        case sellerResponse(Result<User, NetworkError>)
        case loadSellerTickets
        case sellerTicketsResponse(Result<[TicketWithEvent], NetworkError>)
        case toggleFollow
        case tabSelected(State.Tab)
        case ticketTapped(String)
        case negotiateTapped
        case refresh
        case loadFromCache
        case cacheLoaded(User, [TicketWithEvent])
        case syncTicketDeleted(String) // Sincronização: ticket foi deletado
        case syncTicketUpdated(Ticket) // Sincronização: ticket foi atualizado
    }
    
    @Dependency(\.userClient) var userClient
    @Dependency(\.ticketsClient) var ticketsClient
    @Dependency(\.eventsClient) var eventsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Validação crítica do sellerId
                guard let sellerId = state.sellerId, !sellerId.isEmpty else {
                    print("❌ ERRO CRÍTICO: sellerId não fornecido ou vazio")
                    state.errorMessage = "ID do vendedor não fornecido"
                    state.loadState = .error("ID inválido")
                    return .none
                }
                
                print("🚀 SellerProfileFeature.onAppear - sellerId: \(sellerId)")
                
                // Verificar cache primeiro
                return .run { send in
                    let hasCache = await SellerProfileCache.shared.hasValidCache(for: sellerId)
                    
                    if hasCache {
                        print("✅ Cache válido encontrado para sellerId: \(sellerId)")
                        await send(.loadFromCache)
                    } else {
                        print("⚠️ Cache não encontrado ou inválido. Fazendo request...")
                        await send(.loadSeller(sellerId))
                    }
                }
                
            case .loadFromCache:
                guard let sellerId = state.sellerId else { return .none }
                
                return .run { send in
                    // Tentar buscar cache válido primeiro
                    if let cached = await SellerProfileCache.shared.getCachedProfile(for: sellerId) {
                        print("📦 Carregando dados do cache válido (idade: \(Int(cached.age))s)")
                        await send(.cacheLoaded(cached.seller, cached.tickets))
                    } else {
                        // Se não há cache válido, tentar carregar da API
                        // Mas ao invés de esperar, já mostra o que temos (se houver)
                        print("⚠️ Cache não válido, fazendo novo request")
                        await send(.loadSeller(sellerId))
                    }
                }
                
            case let .cacheLoaded(seller, tickets):
                print("✅ Dados carregados do cache: \(seller.name), \(tickets.count) tickets")
                state.seller = seller
                state.sellerTickets = tickets
                state.loadState = .cached
                state.isLoading = false
                state.isLoadingTickets = false
                
                // Atualizar contagem
                if var updatedSeller = state.seller {
                    updatedSeller.ticketsCount = tickets.count
                    state.seller = updatedSeller
                }
                
                return .none
                
            case let .loadSeller(userId):
                // Validação adicional
                guard !userId.isEmpty else {
                    print("❌ ERRO: Tentativa de carregar vendedor com ID vazio")
                    state.errorMessage = "ID do vendedor inválido"
                    state.loadState = .error("ID vazio")
                    return .none
                }
                
                state.isLoading = true
                state.errorMessage = nil
                state.sellerId = userId
                state.loadState = .loading
                
                print("📡 Iniciando request para vendedor: \(userId)")
                
                return .run { send in
                    do {
                        print("🔄 Buscando perfil do vendedor...")
                        let user = try await userClient.getUserProfile(userId)
                        print("✅ Perfil do vendedor carregado: \(user.name)")
                        await send(.sellerResponse(.success(user)))
                        await send(.loadSellerTickets)
                    } catch let error as NetworkError {
                        print("❌ Erro NetworkError ao carregar vendedor: \(error.userFriendlyMessage)")
                        await send(.sellerResponse(.failure(error)))
                    } catch {
                        print("❌ Erro desconhecido ao carregar vendedor: \(error.localizedDescription)")
                        await send(.sellerResponse(.failure(NetworkError.unknown(error.localizedDescription))))
                    }
                }
                
            case let .sellerResponse(.success(user)):
                state.isLoading = false
                state.seller = user
                print("✅ Dados do vendedor armazenados no state: \(user.name)")
                return .none
                
            case let .sellerResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.userFriendlyMessage
                state.loadState = .error(error.userFriendlyMessage)
                print("❌ Falha ao carregar vendedor: \(error.userFriendlyMessage)")
                return .none
                
            case .loadSellerTickets:
                guard let sellerId = state.sellerId else {
                    print("⚠️ Tentativa de carregar tickets sem sellerId")
                    return .none
                }
                
                state.isLoadingTickets = true
                print("🎫 Iniciando busca de tickets para sellerId: \(sellerId)")
                
                return .run { send in
                    do {
                        print("📡 Request para fetchTicketsBySeller...")
                        let tickets = try await ticketsClient.fetchTicketsBySeller(sellerId)
                        print("✅ Tickets recebidos: \(tickets.count)")
                        
                        var ticketsWithEvents: [TicketWithEvent] = []
                        
                        // Buscar informações dos eventos apenas para os tickets encontrados
                        print("🔄 Buscando informações dos eventos...")
                        for (index, ticket) in tickets.enumerated() {
                            do {
                                if let eventUUID = UUID(uuidString: ticket.eventId) {
                                    let event = try await eventsClient.fetchEventById(eventUUID)
                                    ticketsWithEvents.append(TicketWithEvent(ticket: ticket, event: event))
                                    print("  [\(index + 1)/\(tickets.count)] Evento carregado: \(event.name)")
                                }
                            } catch {
                                print("  ⚠️ Erro ao carregar evento \(ticket.eventId): \(error.localizedDescription)")
                                continue
                            }
                        }
                        
                        // Ordenar por data do evento
                        ticketsWithEvents.sort { ($0.event.eventDate ?? Date.distantFuture) < ($1.event.eventDate ?? Date.distantFuture) }
                        
                        print("✅ Total de tickets com eventos: \(ticketsWithEvents.count)")
                        await send(.sellerTicketsResponse(.success(ticketsWithEvents)))
                    } catch let error as NetworkError {
                        print("❌ NetworkError ao buscar tickets: \(error.userFriendlyMessage)")
                        await send(.sellerTicketsResponse(.failure(error)))
                    } catch {
                        print("❌ Erro desconhecido ao buscar tickets: \(error.localizedDescription)")
                        await send(.sellerTicketsResponse(.failure(NetworkError.unknown(error.localizedDescription))))
                    }
                }
                
            case let .sellerTicketsResponse(.success(tickets)):
                state.isLoadingTickets = false
                state.isRefreshing = false
                state.sellerTickets = tickets
                state.loadState = .loaded
                
                // Atualizar contagem de tickets no seller
                if var seller = state.seller {
                    seller.ticketsCount = tickets.count
                    state.seller = seller
                }
                
                // Salvar no cache
                if let seller = state.seller, let sellerId = state.sellerId {
                    Task {
                        await SellerProfileCache.shared.cacheProfile(
                            sellerId: sellerId,
                            seller: seller,
                            tickets: tickets
                        )
                        print("💾 Dados salvos no cache para sellerId: \(sellerId)")
                    }
                }
                
                print("✅ Estado atualizado com \(tickets.count) tickets")
                return .none
                
            case let .sellerTicketsResponse(.failure(error)):
                state.isLoadingTickets = false
                state.isRefreshing = false
                state.errorMessage = error.userFriendlyMessage
                print("❌ Falha ao carregar tickets: \(error.userFriendlyMessage)")
                return .none
                
            case .refresh:
                guard let sellerId = state.sellerId else {
                    print("⚠️ Pull-to-refresh sem sellerId")
                    return .none
                }
                
                print("🔄 Pull-to-refresh iniciado para sellerId: \(sellerId)")
                state.isRefreshing = true
                state.loadState = .refreshing
                
                // Invalidar cache
                Task {
                    await SellerProfileCache.shared.invalidateCache(for: sellerId)
                    print("🗑️ Cache invalidado para sellerId: \(sellerId)")
                }
                
                // Recarregar dados
                return .run { send in
                    await send(.loadSeller(sellerId))
                }
                
            case .toggleFollow:
                // Verificar se é o próprio usuário
                let currentUserId = UserDefaults.standard.string(forKey: "currentUserId")
                if currentUserId == state.sellerId {
                    state.errorMessage = "Você não pode seguir a si mesmo"
                    print("⚠️ Tentativa de auto-seguimento bloqueada")
                    return .none
                }
                
                state.isFollowing.toggle()
                print("👥 Follow toggled: \(state.isFollowing)")
                
                if var seller = state.seller {
                    if state.isFollowing {
                        seller.followersCount += 1
                    } else {
                        seller.followersCount = max(0, seller.followersCount - 1)
                    }
                    state.seller = seller
                }
                return .none
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                print("📑 Tab selecionada: \(tab.rawValue)")
                return .none
                
            case .ticketTapped:
                return .none
                
            case .negotiateTapped:
                print("💬 Negociar tapped")
                return .none
                
            case let .syncTicketDeleted(ticketId):
                // SINCRONIZAÇÃO: Remove ticket quando deletado em outra feature
                print("🔄 SellerProfile: Sincronizando deleção de ticket: \(ticketId)")
                state.sellerTickets.removeAll { $0.ticket.id == ticketId }
                
                // Atualizar contador de tickets do vendedor
                if var seller = state.seller {
                    seller.ticketsCount = max(0, seller.ticketsCount - 1)
                    state.seller = seller
                }
                
                // Invalidar cache
                if let sellerId = state.sellerId {
                    Task {
                        await SellerProfileCache.shared.invalidateCache(for: sellerId)
                        print("🗑️ Cache invalidado após deleção de ticket")
                    }
                }
                
                print("✅ Ticket removido do perfil do vendedor")
                return .none
                
            case let .syncTicketUpdated(updatedTicket):
                // SINCRONIZAÇÃO: Atualiza ticket quando editado em outra feature
                print("🔄 SellerProfile: Sincronizando atualização de ticket: \(updatedTicket.id)")
                
                // Atualizar ticket na lista se existir
                if let index = state.sellerTickets.firstIndex(where: { $0.ticket.id == updatedTicket.id }) {
                    // Precisa buscar o evento associado, por enquanto apenas atualiza o ticket
                    // O ideal seria recarregar o TicketWithEvent completo
                    print("⚠️ Atualização parcial - ticket existe mas precisa recarregar evento")
                }
                
                // Invalidar cache para forçar recarga
                if let sellerId = state.sellerId {
                    Task {
                        await SellerProfileCache.shared.invalidateCache(for: sellerId)
                        print("🗑️ Cache invalidado após atualização de ticket")
                    }
                }
                
                return .run { send in
                    // Recarregar tickets para garantir dados atualizados
                    await send(.loadSellerTickets)
                }
            }
        }
    }
}

// Modelo auxiliar para ticket com informações do evento
public struct TicketWithEvent: Identifiable, Equatable {
    public let id: String
    public let ticket: Ticket
    public let event: Event
    
    public init(ticket: Ticket, event: Event) {
        self.id = ticket.id
        self.ticket = ticket
        self.event = event
    }
}
