import ComposableArchitecture
import Foundation

@DependencyClient
public struct TicketsClient {
    public var fetchTickets: () async throws -> [Ticket]
    public var fetchTicketsByEvent: (UUID) async throws -> [Ticket]
    public var fetchTicketDetail: (UUID) async throws -> TicketDetail
    public var purchaseTicket: (UUID) async throws -> Ticket
    public var toggleFavorite: (UUID) async throws -> Void
}

extension TicketsClient: DependencyKey {
    public static let liveValue = TicketsClient(
        fetchTickets: {
            try await Task.sleep(for: .seconds(1))
            return try await loadTicketsFromJSON()
        },
        fetchTicketsByEvent: { eventId in
            let allTickets = try await loadTicketsFromJSON()
            return allTickets.filter { $0.eventId == eventId }
        },
        fetchTicketDetail: { ticketId in
            // Simulate network delay
            try await Task.sleep(for: .milliseconds(600))
            
            let tickets = try await loadTicketsFromJSON()
            guard let ticket = tickets.first(where: { $0.id == ticketId }) else {
                throw APIError(message: "Ticket not found", code: 404)
            }
            
            let events = try await loadEventsFromJSON()
            guard let event = events.first(where: { $0.id == ticket.eventId }) else {
                throw APIError(message: "Event not found for ticket", code: 404)
            }
            // Create a lightweight seller profile (no sellers JSON available in live)
            var seller = SellerProfile(name: "Seller \(ticket.sellerId.uuidString.prefix(8))", title: "Vendedor")
            seller.tickets = [ticket]
            seller.ticketsCount = 1
            // Build the TicketDetail mirroring the ticket information
            var detail = TicketDetail(
                ticketId: ticket.id,
                event: event,
                seller: seller,
                price: ticket.price,
                quantity: 1,
                ticketType: ticket.ticketType,
                validUntil: ticket.validUntil
            )
            detail.status = ticket.status
            return detail
        },
        purchaseTicket: { ticketId in
            var tickets = try await loadTicketsFromJSON()
            guard let index = tickets.firstIndex(where: { $0.id == ticketId }) else {
                throw APIError(message: "Ticket not found", code: 404)
            }
            tickets[index].status = .sold
            return tickets[index]
        },
        toggleFavorite: { ticketId in
            // Logic to toggle favorite
        }
    )
    
    public static let testValue = TicketsClient(
        fetchTickets: { SharedMockData.sampleTickets },
        fetchTicketsByEvent: { _ in SharedMockData.sampleTickets },
        fetchTicketDetail: { ticketId in SharedMockData.sampleTicketDetail(for: ticketId) },
        purchaseTicket: { _ in SharedMockData.sampleTickets[0] },
        toggleFavorite: { _ in }
    )
}

extension DependencyValues {
    public var ticketsClient: TicketsClient {
        get { self[TicketsClient.self] }
        set { self[TicketsClient.self] = newValue }
    }
}
