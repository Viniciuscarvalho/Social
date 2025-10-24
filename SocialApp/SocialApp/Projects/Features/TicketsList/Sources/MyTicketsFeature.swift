import ComposableArchitecture
import Foundation

@Reducer
struct MyTicketsFeature {
    @ObservableState
    struct State: Equatable {
        var myTickets: [Ticket] = []
        var isLoading = false
        var isDeletingTicket = false
        var errorMessage: String?
        var ticketToDelete: String?
        var currentUserId: String? // Adiciona ID do usuário atual
        
        init(currentUserId: String? = nil) {
            self.currentUserId = currentUserId ?? UserDefaults.standard.string(forKey: "currentUserId")
            print("📱 MyTicketsFeature.State inicializado com currentUserId: \(self.currentUserId ?? "nil")")
        }
    }
    
    enum Action {
        case onAppear
        case refresh
        case loadMyTickets
        case loadMyTicketsResponse(Result<[Ticket], NetworkError>)
        
        // Ticket management
        case ticketSelected(String)
        
        // Delete actions
        case deleteTicket(String)
        case cancelDelete
        case confirmDelete
        case deleteTicketResponse(Result<Bool, NetworkError>)
        
        // Error handling
        case dismissError
    }
    
    @Dependency(\.ticketsClient) var ticketsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Atualiza o ID do usuário atual se não estiver definido
                if state.currentUserId == nil {
                    state.currentUserId = UserDefaults.standard.string(forKey: "currentUserId")
                    print("📱 MyTicketsFeature.onAppear: currentUserId atualizado para: \(state.currentUserId ?? "nil")")
                }
                
                return .run { send in
                    await send(.loadMyTickets)
                }
                
            case .refresh:
                return .run { send in
                    await send(.loadMyTickets)
                }
                
            case .loadMyTickets:
                state.isLoading = true
                state.errorMessage = nil
                
                print("📱 MyTicketsFeature.loadMyTickets iniciado")
                print("   currentUserId: \(state.currentUserId ?? "nil")")
                
                return .run { send in
                    do {
                        let tickets = try await ticketsClient.fetchMyTickets()
                        print("📱 TicketsClient retornou \(tickets.count) tickets")
                        for (index, ticket) in tickets.enumerated() {
                            print("   [\(index)] \(ticket.name) - Seller: \(ticket.sellerId)")
                        }
                        await send(.loadMyTicketsResponse(.success(tickets)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.loadMyTicketsResponse(.failure(networkError)))
                    }
                }
                
            case let .loadMyTicketsResponse(.success(tickets)):
                state.isLoading = false
                
                // Filtra tickets para garantir que são apenas do usuário logado
                if let currentUserId = state.currentUserId {
                    let userTickets = tickets.filter { ticket in
                        return ticket.sellerId == currentUserId
                    }
                    print("📱 MyTicketsFeature: Filtrados \(userTickets.count) tickets do usuário \(currentUserId) de \(tickets.count) tickets totais")
                    state.myTickets = userTickets
                } else {
                    print("⚠️ MyTicketsFeature: currentUserId é nil, usando todos os tickets retornados")
                    state.myTickets = tickets
                }
                
                state.errorMessage = nil
                return .none
                
            case let .loadMyTicketsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.userFriendlyMessage
                return .none
                
            case .ticketSelected:
                // Navigate to ticket detail
                return .none
                
            case let .deleteTicket(ticketId):
                // Verifica se o ticket existe e pertence ao usuário
                let ticket = state.myTickets.first { $0.id == ticketId }
                
                if let ticket = ticket {
                    print("🗑️ Tentando deletar ticket: \(ticket.name)")
                    print("   Ticket ID: \(ticketId)")
                    print("   Seller ID: \(ticket.sellerId)")
                    print("   Current User ID: \(state.currentUserId ?? "nil")")
                    
                    if let currentUserId = state.currentUserId, ticket.sellerId == currentUserId {
                        print("✅ Ticket pertence ao usuário - permitindo exclusão")
                        state.ticketToDelete = ticketId
                    } else {
                        print("❌ Ticket não pertence ao usuário - bloqueando exclusão")
                        state.errorMessage = "Você só pode excluir seus próprios ingressos."
                    }
                } else {
                    print("❌ Ticket não encontrado na lista de meus tickets")
                    state.errorMessage = "Ingresso não encontrado."
                }
                
                return .none
                
            case .cancelDelete:
                state.ticketToDelete = nil
                return .none
                
            case .confirmDelete:
                guard let ticketId = state.ticketToDelete else { return .none }
                
                // Verifica se o ticket pertence ao usuário antes de deletar
                let ticket = state.myTickets.first { $0.id == ticketId }
                
                if let currentUserId = state.currentUserId,
                   let ticket = ticket,
                   ticket.sellerId != currentUserId {
                    state.errorMessage = "Você só pode excluir seus próprios ingressos."
                    state.ticketToDelete = nil
                    return .none
                }
                
                state.ticketToDelete = nil
                state.isDeletingTicket = true
                state.errorMessage = nil
                
                return .run { send in
                    do {
                        try await ticketsClient.deleteTicket(ticketId)
                        await send(.deleteTicketResponse(.success(true)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.deleteTicketResponse(.failure(networkError)))
                    }
                }
                
            case .deleteTicketResponse(.success):
                state.isDeletingTicket = false
                // Reload tickets after successful deletion
                return .run { send in
                    await send(.loadMyTickets)
                    // TODO: Notificar ProfileFeature para atualizar a contagem
                }
                
            case let .deleteTicketResponse(.failure(error)):
                state.isDeletingTicket = false
                state.errorMessage = "Erro ao excluir ingresso: \(error.userFriendlyMessage)"
                return .none
                
            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}

// MARK: - Action Equatable Conformance
extension MyTicketsFeature.Action: Equatable {
    static func == (lhs: MyTicketsFeature.Action, rhs: MyTicketsFeature.Action) -> Bool {
        switch (lhs, rhs) {
        case (.onAppear, .onAppear),
             (.refresh, .refresh),
             (.loadMyTickets, .loadMyTickets),
             (.cancelDelete, .cancelDelete),
             (.confirmDelete, .confirmDelete),
             (.dismissError, .dismissError):
            return true
            
        case let (.ticketSelected(lhsId), .ticketSelected(rhsId)):
            return lhsId == rhsId
            
        case let (.deleteTicket(lhsId), .deleteTicket(rhsId)):
            return lhsId == rhsId
            
        case let (.loadMyTicketsResponse(lhsResult), .loadMyTicketsResponse(rhsResult)):
            switch (lhsResult, rhsResult) {
            case let (.success(lhsTickets), .success(rhsTickets)):
                return lhsTickets == rhsTickets
            case let (.failure(lhsError), .failure(rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
            
        case let (.deleteTicketResponse(lhsResult), .deleteTicketResponse(rhsResult)):
            switch (lhsResult, rhsResult) {
            case let (.success(lhsBool), .success(rhsBool)):
                return lhsBool == rhsBool
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