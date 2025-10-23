import ComposableArchitecture
import Foundation

@Reducer
struct MyTicketsFeature {
    @ObservableState
    struct State: Equatable {
        var myTickets: [Ticket] = []
        var isLoading = false
        var errorMessage: String?
        var ticketToDelete: String?
        
        init() {}
    }
    
    enum Action {
        case onAppear
        case refresh
        case loadMyTickets
        case loadMyTicketsResponse(Result<[Ticket], NetworkError>)
        
        // Ticket management
        case ticketSelected(String)
        case addNewTicketTapped
        
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
                
                return .run { send in
                    do {
                        let tickets = try await ticketsClient.fetchMyTickets()
                        await send(.loadMyTicketsResponse(.success(tickets)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.loadMyTicketsResponse(.failure(networkError)))
                    }
                }
                
            case let .loadMyTicketsResponse(.success(tickets)):
                state.isLoading = false
                state.myTickets = tickets
                state.errorMessage = nil
                return .none
                
            case let .loadMyTicketsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .ticketSelected:
                // Navigate to ticket detail
                return .none
                
            case .addNewTicketTapped:
                // Navigate to add ticket view
                return .none
                
            case let .deleteTicket(ticketId):
                state.ticketToDelete = ticketId
                return .none
                
            case .cancelDelete:
                state.ticketToDelete = nil
                return .none
                
            case .confirmDelete:
                guard let ticketId = state.ticketToDelete else { return .none }
                state.ticketToDelete = nil
                state.isLoading = true
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
                state.isLoading = false
                // Reload tickets after successful deletion
                return .run { send in
                    await send(.loadMyTickets)
                }
                
            case let .deleteTicketResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
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
             (.addNewTicketTapped, .addNewTicketTapped),
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