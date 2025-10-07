import ComposableArchitecture
import Foundation

@DependencyClient
struct TicketsClient {
    var fetchTickets: @Sendable (_ eventId: UUID?) async throws -> [Ticket]
    var fetchAvailableTickets: @Sendable () async throws -> [Ticket]
    var createTicket: @Sendable (_ request: CreateTicketRequest) async throws -> Ticket
    var favoriteTicket: @Sendable (_ ticketId: UUID) async throws -> Void
    var unfavoriteTicket: @Sendable (_ ticketId: UUID) async throws -> Void
}

extension TicketsClient: DependencyKey {
    static let liveValue = Self(
        fetchTickets: { eventId in
            do {
                var queryItems: [URLQueryItem] = []
                if let eventId = eventId {
                    queryItems.append(URLQueryItem(name: "eventId", value: eventId.uuidString))
                }
                
                let apiTickets: [Ticket] = try await NetworkService.shared.request(
                    endpoint: "/tickets",
                    method: .GET,
                    queryItems: queryItems.isEmpty ? nil : queryItems
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
        createTicket: { request in
            return try await NetworkService.shared.request(
                endpoint: "/tickets",
                method: .POST,
                body: request
            )
        },
        favoriteTicket: { ticketId in
            let request = FavoriteTicketRequest(ticketId: ticketId)
            let _: APIResponse<String> = try await NetworkService.shared.request(
                endpoint: "/tickets/\(ticketId.uuidString)/favorite",
                method: .POST,
                body: request
            )
        },
        unfavoriteTicket: { ticketId in
            let _: APIResponse<String> = try await NetworkService.shared.request(
                endpoint: "/tickets/\(ticketId.uuidString)/favorite",
                method: .DELETE
            )
        }
    )
    
    static let testValue = Self(
        fetchTickets: unimplemented("TicketsClient.fetchTickets"),
        fetchAvailableTickets: unimplemented("TicketsClient.fetchAvailableTickets"),
        createTicket: unimplemented("TicketsClient.createTicket"),
        favoriteTicket: unimplemented("TicketsClient.favoriteTicket"),
        unfavoriteTicket: unimplemented("TicketsClient.unfavoriteTicket")
    )
}

extension DependencyValues {
    var ticketsClient: TicketsClient {
        get { self[TicketsClient.self] }
        set { self[TicketsClient.self] = newValue }
    }
}
