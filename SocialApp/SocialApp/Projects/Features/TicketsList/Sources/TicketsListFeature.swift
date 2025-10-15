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
        
        public init() {}
        
        public var displayTickets: [Ticket] {
            filteredTickets.isEmpty ? tickets : filteredTickets
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadTickets
        case ticketsResponse(Result<[Ticket], NetworkError>)
        case ticketSelected(UUID)
        case favoriteToggled(UUID)
        case filterChanged(TicketsListFilter)
        case filterByEvent(String?) // Nova action para filtrar por evento específico
        case refreshRequested
    }
    
    @Dependency(\.ticketsClient) var ticketsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
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
                        await send(.ticketsResponse(.failure(NetworkError.unknown(error))))
                    }
                }
                
            case let .ticketsResponse(.success(tickets)):
                state.isLoading = false
                state.tickets = tickets
                state.filteredTickets = filterTickets(tickets, with: state.selectedFilter)
                return .none
                
            case let .ticketsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .ticketSelected:
                return .none
                
            case let .favoriteToggled(ticketId):
                return .run { send in
                    do {
                        try await ticketsClient.toggleFavorite(ticketId)
                        await send(.loadTickets)
                    } catch {
                        await send(.ticketsResponse(.failure(NetworkError.unknown(error))))
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
