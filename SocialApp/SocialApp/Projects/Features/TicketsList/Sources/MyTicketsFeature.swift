import ComposableArchitecture
import Foundation

public enum TicketTab: Equatable {
    case upcoming
    case past
}

@Reducer
struct MyTicketsFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: TicketTab = .upcoming
        var myTickets: [Ticket] = []
        var deletedTicketId: String? // Para remover localmente após delete
        var deletedTicketIds: Set<String> = [] // ✅ CRÍTICO: Track de tickets deletados para prevenir re-adição
        var isLoading = false
        var errorMessage: String?
        var currentUserId: String?
        var totalTicketsCount: Int = 0
        
        init(currentUserId: String? = nil) {
            self.currentUserId = currentUserId ?? UserDefaults.standard.string(forKey: "currentUserId")
        }
    }
    
    enum Action: Equatable {
        // MARK: - Lifecycle
        case onAppear
        case onDisappear
        
        // MARK: - Data Loading
        case refresh
        case loadMyTickets
        case loadMyTicketsResponse(Result<(tickets: [Ticket], total: Int), NetworkError>)
        
        // MARK: - User Interactions
        case ticketSelected(String)
        case deleteTicket(String)
        case deleteTicketResponse(Result<Void, NetworkError>)
        case notifyTicketDeleted
        case updateTicket(String, UpdateTicketRequest)
        case updateTicketResponse(Result<Ticket, NetworkError>)
        case ticketUpdated(Ticket)
        case tabChanged(TicketTab)
        
        // MARK: - Sync
        case syncFromGlobal([Ticket])
        case syncTicketDeleted(String)
        
        // MARK: - Navigation
        case navigateToEvents
        
        // MARK: - Error Handling
        case dismissError
    }
    
    @Dependency(\.ticketsClient) var ticketsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.currentUserId == nil {
                    state.currentUserId = UserDefaults.standard.string(forKey: "currentUserId")
                }
                
                // ✅ CRÍTICO: Recarregar lista de deletados do UserDefaults para manter persistência
                // Usar Array ao invés de Set para codificação
                if let deletedIdsData = UserDefaults.standard.data(forKey: "deletedTicketIds"),
                   let deletedIdsArray = try? JSONDecoder().decode([String].self, from: deletedIdsData) {
                    state.deletedTicketIds = Set(deletedIdsArray)
                    print("📦 MyTickets: Carregados \(state.deletedTicketIds.count) IDs deletados do UserDefaults")
                }
                
                return .run { send in
                    await send(.loadMyTickets)
                }
                
            case .onDisappear:
                return .none
                
            case .refresh:
                return .run { send in
                    await send(.loadMyTickets)
                }
                
            case .loadMyTickets:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    do {
                        let result = try await ticketsClient.fetchMyTicketsWithPagination()
                        await send(.loadMyTicketsResponse(.success(result)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.loadMyTicketsResponse(.failure(networkError)))
                    }
                }
                
            case let .loadMyTicketsResponse(.success((tickets, _))):
                state.isLoading = false
                
                // ✅ CRÍTICO: Recarregar lista de deletados do UserDefaults ANTES de filtrar
                // Isso garante que mesmo se o store foi recriado, os IDs deletados são preservados
                if let deletedIdsData = UserDefaults.standard.data(forKey: "deletedTicketIds"),
                   let deletedIdsArray = try? JSONDecoder().decode([String].self, from: deletedIdsData) {
                    let loadedIds = Set(deletedIdsArray)
                    state.deletedTicketIds = loadedIds
                    print("📦 MyTickets: Carregados \(loadedIds.count) IDs deletados do UserDefaults (antes de filtrar)")
                }
                
                // ✅ CRÍTICO: Filtrar tickets cancelados/deletados e IDs deletados localmente
                let activeTickets = tickets.filter { ticket in
                    // Remover se status é cancelled OU se foi deletado localmente
                    ticket.status != .cancelled && !state.deletedTicketIds.contains(ticket.id)
                }
                
                if let currentUserId = state.currentUserId {
                    let userTickets = activeTickets.filter { ticket in
                        return ticket.sellerId == currentUserId
                    }
                    print("🔄 MyTickets: Recebidos \(tickets.count) tickets, \(userTickets.count) após filtrar (deletados: \(state.deletedTicketIds.count))")
                    state.myTickets = userTickets
                    state.totalTicketsCount = userTickets.count // Atualizar com quantidade filtrada
                } else {
                    print("🔄 MyTickets: Recebidos \(tickets.count) tickets, \(activeTickets.count) após filtrar (deletados: \(state.deletedTicketIds.count))")
                    state.myTickets = activeTickets
                    state.totalTicketsCount = activeTickets.count
                }
                
                state.errorMessage = nil
                return .none
                
            case let .loadMyTicketsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.userFriendlyMessage
                return .none
                
            case .ticketSelected:
                return .none
                
            case let .deleteTicket(ticketId):
                let ticket = state.myTickets.first { $0.id == ticketId }
                
                if let ticket = ticket {
                    if let currentUserId = state.currentUserId, ticket.sellerId == currentUserId {
                        state.errorMessage = nil
                        state.deletedTicketId = ticketId
                        
                        return .run { send in
                            do {
                                try await ticketsClient.deleteTicket(ticketId)
                                await send(.deleteTicketResponse(.success(())))
                            } catch {
                                let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                                await send(.deleteTicketResponse(.failure(networkError)))
                            }
                        }
                    } else {
                        state.errorMessage = "Você só pode excluir seus próprios ingressos."
                    }
                } else {
                    state.errorMessage = "Ingresso não encontrado."
                }
                
                return .none
                
            case .deleteTicketResponse(.success):
                // Remove o ticket localmente ANTES de qualquer outra coisa (UPDATE OTIMISTA)
                let deletedId = state.deletedTicketId // Salvar antes de limpar
                if let ticketId = deletedId {
                    // ✅ CRÍTICO: Buscar sellerId do ticket ANTES de remover do array
                    let ticketToDelete = state.myTickets.first(where: { $0.id == ticketId })
                    let sellerId = ticketToDelete?.sellerId ?? ""
                    
                    // ✅ CRÍTICO: Adicionar à lista de deletados para prevenir re-adição
                    state.deletedTicketIds.insert(ticketId)
                    
                    // ✅ PERSISTIR: Salvar lista de deletados no UserDefaults (como Array para codificação)
                    if let deletedIdsData = try? JSONEncoder().encode(Array(state.deletedTicketIds)) {
                        UserDefaults.standard.set(deletedIdsData, forKey: "deletedTicketIds")
                        print("💾 MyTickets: Salvos \(state.deletedTicketIds.count) IDs deletados no UserDefaults")
                    }
                    
                    // Agora remover do array
                    state.myTickets.removeAll { $0.id == ticketId }
                    state.totalTicketsCount = max(0, state.totalTicketsCount - 1)
                    state.deletedTicketId = nil
                    
                    // Notifica o parent e outras features via NotificationCenter COM sellerId
                    print("📢 Notificando deleção de ticket: \(ticketId) do vendedor: \(sellerId) (tracked: \(state.deletedTicketIds.count) deletados)")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("TicketDeleted"),
                        object: nil,
                        userInfo: [
                            "ticketId": ticketId,
                            "sellerId": sellerId
                        ]
                    )
                }
                
                return .run { send in
                    await send(.notifyTicketDeleted)
                }
                
            case .notifyTicketDeleted:
                return .none
                
            case let .updateTicket(ticketId, request):
                state.isLoading = true
                state.errorMessage = nil
                
                // UPDATE OTIMISTA: Atualiza localmente primeiro
                if let index = state.myTickets.firstIndex(where: { $0.id == ticketId }) {
                    var updatedTicket = state.myTickets[index]
                    updatedTicket.name = request.name
                    updatedTicket.price = request.price
                    updatedTicket.ticketType = request.ticketType
                    if let originalPrice = request.originalPrice {
                        updatedTicket.originalPrice = originalPrice
                    }
                    state.myTickets[index] = updatedTicket
                }
                
                return .run { send in
                    do {
                        let updated = try await ticketsClient.updateTicket(ticketId, request)
                        await send(.updateTicketResponse(.success(updated)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.updateTicketResponse(.failure(networkError)))
                    }
                }
                
            case let .updateTicketResponse(.success(updatedTicket)):
                state.isLoading = false
                // Garantir que o ticket atualizado está na lista
                if let index = state.myTickets.firstIndex(where: { $0.id == updatedTicket.id }) {
                    state.myTickets[index] = updatedTicket
                } else {
                    // Se não estiver, adicionar (não deveria acontecer)
                    state.myTickets.append(updatedTicket)
                }
                
                // Notificar outras features
                NotificationCenter.default.post(
                    name: NSNotification.Name("TicketUpdated"),
                    object: nil,
                    userInfo: ["ticket": updatedTicket]
                )
                
                return .run { send in
                    await send(.ticketUpdated(updatedTicket))
                }
                
            case let .updateTicketResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = "Erro ao atualizar ingresso: \(error.userFriendlyMessage)"
                // REVERTER: Recarregar do servidor para garantir consistência
                return .run { send in
                    await send(.loadMyTickets)
                }
                
            case .ticketUpdated:
                return .none
                
            case let .syncFromGlobal(tickets):
                // Sincronização vinda do store global
                if let currentUserId = state.currentUserId {
                    let userTickets = tickets.filter { ticket in
                        ticket.sellerId == currentUserId && !state.deletedTicketIds.contains(ticket.id)
                    }
                    state.myTickets = userTickets
                    state.totalTicketsCount = userTickets.count
                } else {
                    let filtered = tickets.filter { !state.deletedTicketIds.contains($0.id) }
                    state.myTickets = filtered
                    state.totalTicketsCount = filtered.count
                }
                return .none
                
            case let .syncTicketDeleted(ticketId):
                // SINCRONIZAÇÃO: Adicionar à lista de deletados mesmo se não estiver visível
                print("🔄 MyTickets: Sincronizando deleção de ticket: \(ticketId)")
                state.deletedTicketIds.insert(ticketId)
                
                // ✅ PERSISTIR: Salvar lista de deletados no UserDefaults (como Array para codificação)
                if let deletedIdsData = try? JSONEncoder().encode(Array(state.deletedTicketIds)) {
                    UserDefaults.standard.set(deletedIdsData, forKey: "deletedTicketIds")
                    print("💾 MyTickets: Salvos \(state.deletedTicketIds.count) IDs deletados no UserDefaults (sync)")
                }
                
                // Remover do estado atual se estiver presente
                state.myTickets.removeAll { $0.id == ticketId }
                state.totalTicketsCount = max(0, state.totalTicketsCount - 1)
                
                print("✅ MyTickets: Ticket \(ticketId) marcado como deletado (tracked: \(state.deletedTicketIds.count))")
                return .none
                
            case let .deleteTicketResponse(.failure(error)):
                state.errorMessage = "Erro ao excluir ingresso: \(error.userFriendlyMessage)"
                return .none
                
            case .dismissError:
                state.errorMessage = nil
                return .none
                
            case let .tabChanged(tab):
                state.selectedTab = tab
                return .none
                
            case .navigateToEvents:
                return .none
            }
        }
    }
}
