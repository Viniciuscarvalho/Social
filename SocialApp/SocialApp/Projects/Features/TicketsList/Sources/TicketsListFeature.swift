import ComposableArchitecture
import Foundation
import SharedModels

@Reducer
public struct TicketsListFeature {
    @ObservableState
    public struct State: Equatable {
        public var tickets: [Ticket] = []
        public var filteredTickets: [Ticket] = []
        public var selectedFilter = TicketsListFilter()
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadTickets
        case ticketsResponse(Result<[Ticket], APIError>)
        case ticketSelected(UUID)
        case favoriteToggled(UUID)
        case filterChanged(TicketsListFilter)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .onAppear:
                return .send(.loadTickets)
                
            case .loadTickets:
                state.isLoading = true
                return .run { send in
                    do {
                        try await Task.sleep(for: .seconds(1))
                        let tickets: [Ticket] = [] // Mock data aqui
                        await send(.ticketsResponse(.success(tickets)))
                    } catch {
                        await send(
                            .ticketsResponse(
                                .failure(
                                    APIError(
                                        message: error.localizedDescription,
                                        code: 500
                                    )
                                )
                            )
                        )
                    }
                }
                
            case let .ticketsResponse(.success(tickets)):
                state.isLoading = false
                state.tickets = tickets
                state.filteredTickets = tickets
                return .none
                
            case let .ticketsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.message
                return .none
                
            case .ticketSelected:
                return .none
                
            case .favoriteToggled:
                return .none
                
            case let .filterChanged(filter):
                state.selectedFilter = filter
                return .none
            }
        }
    }
}
