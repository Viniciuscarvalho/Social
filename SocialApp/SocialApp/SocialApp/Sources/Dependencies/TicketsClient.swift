import ComposableArchitecture
import Foundation

public struct TicketsClient {
    public var fetchTickets: () async throws -> [Ticket]
    public var fetchAvailableTickets: () async throws -> [Ticket]
    public var fetchTicketsByEvent: (UUID) async throws -> [Ticket]
    public var fetchTicketDetail: (UUID) async throws -> TicketDetail
    public var purchaseTicket: (UUID) async throws -> Ticket
    public var toggleFavorite: (UUID) async throws -> Void
    public var createTicket: (Ticket) async throws -> Ticket
}

extension TicketsClient: DependencyKey {
    public static var liveValue: TicketsClient {
        TicketsClient(
            fetchTickets: {
                do {
                    let apiTickets: [Ticket] = try await NetworkService.shared.request(
                        endpoint: "/tickets",
                        method: .GET
                    )
                    return apiTickets
                } catch {
                    // Fallback para JSON local
                    print("API call failed, falling back to local JSON: \(error)")
                    return try await loadTicketsFromJSON()
                }
            },
            fetchAvailableTickets: {
                do {
                    let queryItems = [URLQueryItem(name: "status", value: "available")]
                    let apiTickets: [Ticket] = try await NetworkService.shared.request(
                        endpoint: "/tickets",
                        method: .GET,
                        queryItems: queryItems
                    )
                    return apiTickets
                } catch {
                    // Fallback para JSON local
                    print("API call failed, falling back to local JSON: \(error)")
                    let tickets = try await loadTicketsFromJSON()
                    return tickets.filter { $0.status == .available }
                }
            },
            fetchTicketsByEvent: { eventId in
                do {
                    let queryItems = [URLQueryItem(name: "eventId", value: eventId.uuidString)]
                    let apiTickets: [Ticket] = try await NetworkService.shared.request(
                        endpoint: "/tickets",
                        method: .GET,
                        queryItems: queryItems
                    )
                    return apiTickets
                } catch {
                    // Fallback para JSON local filtrado por evento
                    print("API call failed, falling back to local JSON: \(error)")
                    let tickets = try await loadTicketsFromJSON()
                    return tickets.filter { ticket in
                        if let ticketEventId = UUID(uuidString: ticket.eventId) {
                            return ticketEventId == eventId
                        }
                        return false
                    }
                }
            },
            fetchTicketDetail: { ticketId in
                do {
                    let ticketDetail: TicketDetail = try await NetworkService.shared.request(
                        endpoint: "/tickets/\(ticketId.uuidString)",
                        method: .GET
                    )
                    return ticketDetail
                } catch {
                    // Fallback para JSON local
                    print("API call failed, falling back to local JSON: \(error)")
                    // Aqui você precisaria ter uma função para carregar detalhes do JSON
                    throw NetworkError.notFound
                }
            },
            purchaseTicket: { ticketId in
                do {
                    let purchaseRequest = PurchaseTicketRequest(ticketId: ticketId.uuidString)
                    let purchasedTicket: Ticket = try await NetworkService.shared.request(
                        endpoint: "/tickets/\(ticketId.uuidString)/purchase",
                        method: .POST,
                        body: purchaseRequest
                    )
                    return purchasedTicket
                } catch {
                    print("Purchase ticket failed: \(error)")
                    throw error
                }
            },
            toggleFavorite: { ticketId in
                do {
                    let request = FavoriteTicketRequest(ticketId: ticketId.uuidString)
                    let _: APIResponse<String> = try await NetworkService.shared.request(
                        endpoint: "/tickets/\(ticketId.uuidString)/favorite",
                        method: .POST,
                        body: request
                    )
                } catch {
                    print("Toggle favorite failed: \(error)")
                    throw error
                }
            },
            createTicket: { request in
                return try await NetworkService.shared.request(
                    endpoint: "/tickets",
                    method: .POST,
                    body: request
                )
            }
        )
    }
    
    public static let testValue = TicketsClient(
        fetchTickets: { SharedMockData.sampleTickets },
        fetchAvailableTickets: { SharedMockData.sampleTickets },
        fetchTicketsByEvent: { _ in SharedMockData.sampleTickets },
        fetchTicketDetail: { ticketId in SharedMockData.sampleTicketDetail(for: ticketId.uuidString) },
        purchaseTicket: { _ in SharedMockData.sampleTickets[0] },
        toggleFavorite: { _ in },
        createTicket: { ticket in ticket }
    )
}

extension DependencyValues {
    public var ticketsClient: TicketsClient {
        get { self[TicketsClient.self] }
        set { self[TicketsClient.self] = newValue }
    }
}
