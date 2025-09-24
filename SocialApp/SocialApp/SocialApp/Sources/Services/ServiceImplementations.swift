import ComposableArchitecture
import Foundation
import SharedModels

public class EventsServiceImpl: EventsService {
    @Dependency(\.eventsClient) var eventsClient
    
    public init() {}
    
    public func fetchEvents() async throws -> [Event] {
        try await eventsClient.fetchEvents()
    }
    
    public func searchEvents(_ query: String) async throws -> [Event] {
        try await eventsClient.searchEvents(query)
    }
    
    public func fetchEventsByCategory(_ category: EventCategory) async throws -> [Event] {
        try await eventsClient.fetchEventsByCategory(category)
    }
}

public class SellerProfileServiceImpl: SellerProfileService {
    public init() {}
    
    public func fetchProfile() async throws -> SellerProfile {
        try await Task.sleep(for: .seconds(1))
        return SellerProfile(name: "Richard A. Bachmann", title: "UX/UX Designer")
    }
    
    public func fetchProfileById(_ id: UUID) async throws -> SellerProfile {
        try await Task.sleep(for: .seconds(1))
        return SellerProfile(name: "Profile \(id.uuidString.prefix(8))", title: "Designer")
    }
}

public class TicketDetailServiceImpl: TicketDetailService {
    public init() {}
    
    public func fetchTicketDetail(_ ticketId: UUID) async throws -> TicketDetail {
        try await Task.sleep(for: .seconds(1))
        return SharedMockData.sampleTicketDetail(for: ticketId)
    }
    
    public func purchaseTicket(_ ticketId: UUID) async throws -> TicketDetail {
        try await Task.sleep(for: .seconds(2))
        var ticketDetail = SharedMockData.sampleTicketDetail(for: ticketId)
        ticketDetail.status = .sold
        return ticketDetail
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
