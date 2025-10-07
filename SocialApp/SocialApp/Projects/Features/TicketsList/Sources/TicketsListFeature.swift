import ComposableArchitecture
import Foundation

@Reducer
public struct TicketsListFeature {
    @ObservableState
    struct State: Equatable {
        var tickets: [Ticket] = []
        var favoriteTickets: [Ticket] = []
        var isLoading = false
        var errorMessage: String?
        var filter = TicketsListFilter()
        
        @Presents var destination: Destination.State?
    }
    
    enum Action: Equatable {
        case onAppear
        case loadAvailableTickets
        case loadFavoriteTickets
        case loadTicketsForEvent(String)
        case ticketSelected(String)
        case ticketsResponse(Result<[Ticket], NetworkError>)
        case favoriteTicket(String)
        case unfavoriteTicket(String)
        case favoriteResponse(Result<Void, NetworkError>)
        case createTicket(CreateTicketRequest)
        case createTicketResponse(Result<Ticket, NetworkError>)
        case filterChanged(TicketsListFilter)
        case setTicketTypeFilter(TicketType?)
        case setStatusFilter(TicketStatus?)
        case setSortOption(TicketSortOption)
        
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer
    enum Destination {
        case ticketDetail(TicketDetailFeature)
    }
    
    @Dependency(\.ticketsClient) var ticketsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadAvailableTickets)
                
            case .loadAvailableTickets:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let tickets = try await ticketsClient.fetchAvailableTickets()
                        await send(.ticketsResponse(.success(tickets)))
                    } catch let error as NetworkError {
                        await send(.ticketsResponse(.failure(error)))
                    } catch {
                        await send(.ticketsResponse(.failure(.unknown(error))))
                    }
                }
                
            case .loadFavoriteTickets:
                state.isLoading = true
                state.errorMessage = nil
                return .run { [tickets = state.tickets] send in
                    let favoriteTickets = tickets.filter { $0.isFavorited }
                    await send(.ticketsResponse(.success(favoriteTickets)))
                }
                
            case let .loadTicketsForEvent(eventId):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let tickets = try await ticketsClient.fetchTickets(eventId)
                        await send(.ticketsResponse(.success(tickets)))
                    } catch let error as NetworkError {
                        await send(.ticketsResponse(.failure(error)))
                    } catch {
                        await send(.ticketsResponse(.failure(.unknown(error))))
                    }
                }
                
            case let .ticketSelected(tickedId):
                guard let ticket = state.tickets.first(where: { $0.id == ticketId }) else {
                    return .none
                }
                
                state.destination = .ticketDetail(
                    TicketDetailFeature.State(ticket: ticket)
                )
                return .none
                
            case let .ticketsResponse(.success(tickets)):
                state.tickets = tickets
                state.isLoading = false
                state.errorMessage = nil
                return .none
                
            case let .ticketsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.errorDescription
                return .none
                
            case let .favoriteTicket(ticketId):
                return .run { send in
                    do {
                        try await ticketsClient.favoriteTicket(ticketId)
                        await send(.favoriteResponse(.success(())))
                    } catch let error as NetworkError {
                        await send(.favoriteResponse(.failure(error)))
                    } catch {
                        await send(.favoriteResponse(.failure(.unknown(error))))
                    }
                }
                
            case let .unfavoriteTicket(ticketId):
                return .run { send in
                    do {
                        try await ticketsClient.unfavoriteTicket(ticketId)
                        await send(.favoriteResponse(.success(())))
                    } catch let error as NetworkError {
                        await send(.favoriteResponse(.failure(error)))
                    } catch {
                        await send(.favoriteResponse(.failure(.unknown(error))))
                    }
                }
                
            case .favoriteResponse(.success):
                // Recarrega os tickets para refletir mudanças
                return .send(.loadAvailableTickets)
                
            case let .favoriteResponse(.failure(error)):
                state.errorMessage = error.errorDescription
                return .none
                
            case let .createTicket(request):
                state.isLoading = true
                return .run { send in
                    do {
                        let ticket = try await ticketsClient.createTicket(request)
                        await send(.createTicketResponse(.success(ticket)))
                    } catch let error as NetworkError {
                        await send(.createTicketResponse(.failure(error)))
                    } catch {
                        await send(.createTicketResponse(.failure(.unknown(error))))
                    }
                }
                
            case let .createTicketResponse(.success(apiTicket)):
                state.isLoading = false
                let newTicket = apiTicket.toDomainModel()
                state.tickets.append(newTicket)
                return .none
                
            case let .createTicketResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.errorDescription
                return .none
                
            case let .filterChanged(filter):
                state.filter = filter
                return .send(.loadAvailableTickets)
                
            case let .setTicketTypeFilter(type):
                state.filter.ticketType = type
                return .none
                
            case let .setStatusFilter(status):
                state.filter.status = status
                return .none
                
            case let .setSortOption(sortOption):
                state.filter.sortBy = sortOption
                return .none
            }
        }
    }
}
