import ComposableArchitecture
import Foundation

@Reducer
struct MyTicketsFeature {
    @ObservableState
    struct State: Equatable {
        var myTickets: [Ticket] = []
        var deletedTicketId: String? // Para remover localmente após delete
        var isLoading = false
        var errorMessage: String?
        var currentUserId: String?
        var totalTicketsCount: Int = 0
        
        init(currentUserId: String? = nil) {
            self.currentUserId = currentUserId ?? UserDefaults.standard.string(forKey: "currentUserId")
        }
    }
    
    enum Action {
        case onAppear
        case onDisappear
        case refresh
        case loadMyTickets
        case loadMyTicketsResponse(Result<(tickets: [Ticket], total: Int), NetworkError>)
        case ticketSelected(String)
        case deleteTicket(String)
        case deleteTicketResponse(Result<Void, NetworkError>)
        case notifyTicketDeleted
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
                
            case let .loadMyTicketsResponse(.success((tickets, total))):
                state.isLoading = false
                state.totalTicketsCount = total
                

                if let currentUserId = state.currentUserId {
                    let userTickets = tickets.filter { ticket in
                        return ticket.sellerId == currentUserId
                    }
                        state.myTickets = userTickets
                } else {
                        state.myTickets = tickets
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
                        state.deletedTicketId = ticketId  // Guardar para remover localmente
                        
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
                // Remove o ticket localmente ANTES de qualquer outra coisa
                if let deletedId = state.deletedTicketId {
                    state.myTickets.removeAll { $0.id == deletedId }
                    state.totalTicketsCount = max(0, state.totalTicketsCount - 1)
                    state.deletedTicketId = nil
                }
                
                // Notifica o parent
                NotificationCenter.default.post(name: NSNotification.Name("TicketDeleted"), object: nil)
                
                return .run { send in
                    await send(.notifyTicketDeleted)
                }
                
            case .notifyTicketDeleted:
                return .none
                
            case let .deleteTicketResponse(.failure(error)):
                state.errorMessage = "Erro ao excluir ingresso: \(error.userFriendlyMessage)"
                return .none
                
            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}