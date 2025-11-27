import ComposableArchitecture
import Foundation

@Reducer
public struct TicketsListFeature {
    @ObservableState
    public struct State: Equatable {
        public var tickets: [Ticket] = []
        public var filteredTickets: [Ticket] = []
        public var selectedFilter = TicketsListFilter()
        public var isLoading: Bool = false
        public var errorMessage: String?
        public var deletedTicketIds: Set<String> = [] // ✅ Track de tickets deletados localmente
        
        public init() {}
        
        // MARK: - Derived State
        public var displayTickets: [Ticket] {
            filteredTickets.isEmpty ? tickets : filteredTickets
        }
        
        public var hasTickets: Bool {
            !tickets.isEmpty
        }
        
        public var hasFilteredTickets: Bool {
            !displayTickets.isEmpty
        }
        
        public var isFiltered: Bool {
            selectedFilter.eventId != nil || 
            selectedFilter.ticketType != nil ||
            selectedFilter.priceRange != nil ||
            selectedFilter.status != nil ||
            selectedFilter.showFavoritesOnly
        }
    }
    
    public enum Action: Equatable {
        // MARK: - Lifecycle
        case onAppear
        case onDisappear
        
        // MARK: - Data Loading
        case loadTickets
        case ticketsResponse(Result<[Ticket], NetworkError>)
        case refreshRequested
        
        // MARK: - User Interactions
        case ticketSelected(UUID)
        case favoriteToggled(UUID)
        
        // MARK: - Filtering
        case filterChanged(TicketsListFilter)
        case filterByEvent(String?)
        
        // MARK: - Ticket Management
        case addNewTicket(Ticket)
        case deleteTicket(String)
        case deleteTicketSuccess
        case deleteTicketFailure(String)
        
        // MARK: - Synchronization
        case syncTicketDeleted(String)
        case syncTicketUpdated(Ticket)
        case syncTicketCreated(Ticket)
        
        // MARK: - Navigation
        case delegate(Delegate)
        
        // MARK: - Error Handling
        case dismissError
        
        // MARK: - Delegate
        public enum Delegate: Equatable {
            case navigateToTicketDetail(UUID)
        }
    }
    
    @Dependency(\.ticketsClient) var ticketsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // ✅ CRÍTICO: Carregar IDs deletados do UserDefaults para manter consistência
                if let deletedIdsData = UserDefaults.standard.data(forKey: "deletedTicketIds"),
                   let deletedIdsArray = try? JSONDecoder().decode([String].self, from: deletedIdsData) {
                    state.deletedTicketIds = Set(deletedIdsArray)
                    print("📦 TicketsList: Carregados \(state.deletedTicketIds.count) IDs deletados do UserDefaults")
                }
                
                // Só carrega se não tiver dados ainda
                guard state.tickets.isEmpty else {
                    return .none
                }
                return .run { send in
                    await send(.loadTickets)
                }
                
            case .loadTickets:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let tickets = try await ticketsClient.fetchTickets()
                        await send(.ticketsResponse(.success(tickets)))
                    } catch {
                        print("❌ Erro ao carregar tickets: \(error.localizedDescription)")
                        await send(.ticketsResponse(.failure(NetworkError.unknown(error.localizedDescription))))
                    }
                }
                
            case let .ticketsResponse(.success(tickets)):
                state.isLoading = false
                
                // ✅ CRÍTICO: Recarregar IDs deletados do UserDefaults ANTES de filtrar
                if let deletedIdsData = UserDefaults.standard.data(forKey: "deletedTicketIds"),
                   let deletedIdsArray = try? JSONDecoder().decode([String].self, from: deletedIdsData) {
                    state.deletedTicketIds = Set(deletedIdsArray)
                }
                
                // ✅ CRÍTICO: Filtrar tickets cancelados/deletados e IDs deletados localmente
                let activeTickets = tickets.filter { ticket in
                    // Remover se status é cancelled OU se foi deletado localmente
                    ticket.status != .cancelled && !state.deletedTicketIds.contains(ticket.id)
                }
                print("🔄 TicketsList: Recebidos \(tickets.count) tickets, \(activeTickets.count) após filtrar (deletados: \(state.deletedTicketIds.count))")
                
                state.tickets = activeTickets
                state.filteredTickets = filterTickets(activeTickets, with: state.selectedFilter)
                return .none
                
            case let .ticketsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .ticketSelected(ticketId):
                return .run { send in
                    await send(.delegate(.navigateToTicketDetail(ticketId)))
                }
            
            case .onDisappear:
                return .none
            
            case .delegate:
                return .none
            
            case .dismissError:
                state.errorMessage = nil
                return .none
                
            case let .favoriteToggled(ticketId):
                return .run { send in
                    do {
                        try await ticketsClient.toggleFavorite(ticketId)
                        await send(.loadTickets)
                    } catch {
                        await send(.ticketsResponse(.failure(NetworkError.unknown(error.localizedDescription))))
                    }
                }
                
            case let .filterChanged(filter):
                state.selectedFilter = filter
                state.filteredTickets = filterTickets(state.tickets, with: filter)
                return .none
                
            case let .filterByEvent(eventId):
                // Atualiza o filtro para mostrar apenas tickets do evento específico
                state.selectedFilter.eventId = eventId
                state.filteredTickets = filterTickets(state.tickets, with: state.selectedFilter)
                return .none
                
            case .refreshRequested:
                return .run { send in
                    await send(.loadTickets)
                }
                
            case let .addNewTicket(ticket):
                // Adiciona o novo ticket no início da lista
                state.tickets.insert(ticket, at: 0)
                state.filteredTickets = filterTickets(state.tickets, with: state.selectedFilter)
                print("✅ Novo ticket adicionado à lista: \(ticket.name)")
                return .none
                
            case let .deleteTicket(ticketId):
                print("🗑️ Iniciando deletação do ticket: \(ticketId)")
                
                // ✅ CRÍTICO: Remover imediatamente (otimistic) e trackear
                state.deletedTicketIds.insert(ticketId)
                
                // ✅ PERSISTIR: Salvar lista de deletados no UserDefaults
                if let deletedIdsData = try? JSONEncoder().encode(Array(state.deletedTicketIds)) {
                    UserDefaults.standard.set(deletedIdsData, forKey: "deletedTicketIds")
                    print("💾 TicketsList: Salvos \(state.deletedTicketIds.count) IDs deletados no UserDefaults (delete)")
                }
                
                state.tickets.removeAll { $0.id == ticketId }
                state.filteredTickets.removeAll { $0.id == ticketId }
                
                return .run { send in
                    do {
                        try await ticketsClient.deleteTicket(ticketId)
                        await send(.deleteTicketSuccess)
                    } catch {
                        print("❌ Erro ao deletar ticket: \(error.localizedDescription)")
                        // Reverter se falhar
                        await send(.deleteTicketFailure(error.localizedDescription))
                    }
                }
                
            case .deleteTicketSuccess:
                print("✅ Ticket deletado com sucesso (já removido do estado)")
                // Não precisa recarregar, já removemos otimisticamente
                // Mas podemos recarregar para garantir sincronização com outros dados
                return .run { send in
                    await send(.loadTickets)
                }
                
            case let .deleteTicketFailure(errorMessage):
                // Se falhou, manter na lista de deletados mas mostrar erro
                print("❌ Erro na resposta de delete: \(errorMessage)")
                state.errorMessage = errorMessage
                return .none
                
            case let .syncTicketDeleted(ticketId):
                // SINCRONIZAÇÃO: Remove ticket quando deletado em outra feature (UPDATE OTIMISTA)
                print("🔄 Sincronizando deleção de ticket: \(ticketId)")
                
                // Adicionar à lista de deletados para prevenir re-adição
                state.deletedTicketIds.insert(ticketId)
                
                // ✅ PERSISTIR: Salvar lista de deletados no UserDefaults
                if let deletedIdsData = try? JSONEncoder().encode(Array(state.deletedTicketIds)) {
                    UserDefaults.standard.set(deletedIdsData, forKey: "deletedTicketIds")
                    print("💾 TicketsList: Salvos \(state.deletedTicketIds.count) IDs deletados no UserDefaults (sync)")
                }
                
                // Remover do estado atual
                state.tickets.removeAll { $0.id == ticketId }
                state.filteredTickets.removeAll { $0.id == ticketId }
                
                print("✅ Ticket \(ticketId) removido da lista completa (tracked: \(state.deletedTicketIds.count) deletados)")
                return .none
                
            case let .syncTicketUpdated(updatedTicket):
                // SINCRONIZAÇÃO: Atualiza ticket quando editado em outra feature
                print("🔄 Sincronizando atualização de ticket: \(updatedTicket.id)")
                if let index = state.tickets.firstIndex(where: { $0.id == updatedTicket.id }) {
                    state.tickets[index] = updatedTicket
                    // Reaplicar filtros
                    state.filteredTickets = filterTickets(state.tickets, with: state.selectedFilter)
                    print("✅ Ticket atualizado na lista completa")
                }
                return .none
                
            case let .syncTicketCreated(newTicket):
                // SINCRONIZAÇÃO: Adiciona ticket quando criado em outra feature
                print("🔄 Sincronizando criação de ticket: \(newTicket.id)")
                state.tickets.insert(newTicket, at: 0)
                state.filteredTickets = filterTickets(state.tickets, with: state.selectedFilter)
                print("✅ Ticket adicionado à lista completa")
                return .none
            }
        }
    }
    
    private func filterTickets(_ tickets: [Ticket], with filter: TicketsListFilter) -> [Ticket] {
        var filtered = tickets
        
        // Filtro por evento específico (prioridade alta)
        if let eventId = filter.eventId {
            filtered = filtered.filter { ticket in
                ticket.eventId.lowercased() == eventId.lowercased()
            }
        }
        
        if let priceRange = filter.priceRange {
            filtered = filtered.filter { ticket in
                ticket.price >= priceRange.min && ticket.price <= priceRange.max
            }
        }
        
        if let ticketType = filter.ticketType {
            filtered = filtered.filter { $0.ticketType == ticketType }
        }
        
        if let status = filter.status {
            filtered = filtered.filter { $0.status == status }
        }
        
        if filter.showFavoritesOnly {
            filtered = filtered.filter(\.isFavorited)
        }
        
        switch filter.sortBy {
        case .dateCreated:
            filtered = filtered.sorted { $0.createdAt > $1.createdAt }
        case .priceAsc:
            filtered = filtered.sorted { $0.price < $1.price }
        case .priceDesc:
            filtered = filtered.sorted { $0.price > $1.price }
        case .eventDate, .popularity:
            break
        }
        
        return filtered
    }
}
