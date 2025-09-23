import ComposableArchitecture
import Foundation

// Protocolos para injeção de dependência
public protocol EventsService {
    func fetchEvents() async throws -> [Event]
    func searchEvents(_ query: String) async throws -> [Event]
}

public protocol TicketsService {
    func fetchTickets() async throws -> [Ticket]
    func fetchTicketsByEvent(_ eventId: UUID) async throws -> [Ticket]
    func toggleFavorite(_ ticketId: UUID) async throws -> Void
}

public class EventsServiceImpl: EventsService {
    @Dependency(\.eventsClient) var eventsClient
    
    public init() {}
    
    public func fetchEvents() async throws -> [Event] {
        try await eventsClient.fetchEvents()
    }
    
    public func searchEvents(_ query: String) async throws -> [Event] {
        try await eventsClient.searchEvents(query)
    }
}

public class TicketsServiceImpl: TicketsService {
    @Dependency(\.ticketsClient) var ticketsClient
    
    public init() {}
    
    public func fetchTickets() async throws -> [Ticket] {
        try await ticketsClient.fetchTickets()
    }
    
    public func fetchTicketsByEvent(_ eventId: UUID) async throws -> [Ticket] {
        try await ticketsClient.fetchTicketsByEvent(eventId)
    }
    
    public func toggleFavorite(_ ticketId: UUID) async throws -> Void {
        try await ticketsClient.toggleFavorite(ticketId)
    }
}