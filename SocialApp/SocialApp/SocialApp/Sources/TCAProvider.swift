import ComposableArchitecture
import Foundation
import SharedModels

// Protocolos para injeção de dependência
public protocol EventsService {
    func fetchEvents() async throws -> [Event]
    func searchEvents(_ query: String) async throws -> [Event]
    func fetchEventsByCategory(_ category: EventCategory) async throws -> [Event]
}

public protocol TicketsService {
    func fetchTickets() async throws -> [Ticket]
    func fetchTicketsByEvent(_ eventId: UUID) async throws -> [Ticket]
    func toggleFavorite(_ ticketId: UUID) async throws -> Void
}

public protocol SellerProfileService {
    func fetchProfile() async throws -> SellerProfile
    func fetchProfileById(_ id: UUID) async throws -> SellerProfile
}

public protocol TicketDetailService {
    func fetchTicketDetail(_ ticketId: UUID) async throws -> TicketDetail
    func purchaseTicket(_ ticketId: UUID) async throws -> TicketDetail
}
