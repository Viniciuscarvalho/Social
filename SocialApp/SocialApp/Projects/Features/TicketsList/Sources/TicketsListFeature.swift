import Foundation
import SharedModels

public protocol TicketsService {
    func fetchTickets() async throws -> [Ticket]
    func fetchTicketsByEvent(_ eventId: UUID) async throws -> [Ticket]
    func toggleFavorite(_ ticketId: UUID) async throws -> Void
}

public struct TicketsListFeature {
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
        case ticketsResponse(Result<[Ticket], APIError>)
        case ticketSelected(UUID)
        case favoriteToggled(UUID)
        case filterChanged(TicketsListFilter)
        case refreshRequested
    }
    
    private let ticketsService: TicketsService
    
    public init(ticketsService: TicketsService) {
        self.ticketsService = ticketsService
    }
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return Effect.send(.loadTickets)
            
        case .loadTickets:
            state.isLoading = true
            state.errorMessage = nil
            return Effect.run { send in
                do {
                    let tickets = try await ticketsService.fetchTickets()
                    await send(.ticketsResponse(.success(tickets)))
                } catch {
                    await send(.ticketsResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                }
            }
            
        case let .ticketsResponse(.success(tickets)):
            state.isLoading = false
            state.tickets = tickets
            state.filteredTickets = filterTickets(tickets, with: state.selectedFilter)
            return Effect.none
            
        case let .ticketsResponse(.failure(error)):
            state.isLoading = false
            state.errorMessage = error.message
            return Effect.none
            
        case .ticketSelected:
            return Effect.none
            
        case let .favoriteToggled(ticketId):
            return Effect.run { send in
                do {
                    try await ticketsService.toggleFavorite(ticketId)
                    await send(.loadTickets) // Refresh após toggle
                } catch {
                    await send(.ticketsResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                }
            }
            
        case let .filterChanged(filter):
            state.selectedFilter = filter
            state.filteredTickets = filterTickets(state.tickets, with: filter)
            return Effect.none
            
        case .refreshRequested:
            return Effect.send(.loadTickets)
        }
    }
    
    private func filterTickets(_ tickets: [Ticket], with filter: TicketsListFilter) -> [Ticket] {
        var filtered = tickets
        
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
        
        // Sort
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
