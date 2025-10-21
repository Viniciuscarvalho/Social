import ComposableArchitecture
import Foundation

public struct TicketsClient {
    public var fetchTickets: () async throws -> [Ticket]
    public var fetchAvailableTickets: () async throws -> [Ticket]
    public var fetchTicketsByEvent: (UUID) async throws -> [Ticket]
    public var fetchTicketDetail: (UUID) async throws -> TicketDetail
    public var purchaseTicket: (UUID) async throws -> Ticket
    public var toggleFavorite: (UUID) async throws -> Void
    public var createTicket: (CreateTicketRequest) async throws -> Ticket
}

extension TicketsClient: DependencyKey {
    public static var liveValue: TicketsClient {
        TicketsClient(
            fetchTickets: {
                do {
                    print("🎫 Fetching tickets from API...")
                    let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                        endpoint: "/tickets",
                        method: .GET
                    )
                    print("✅ Successfully fetched \(apiTickets.count) tickets from API")
                    let tickets = apiTickets.map { $0.toTicket() }
                    return tickets
                } catch {
                    print("❌ API call failed for fetchTickets: \(error)")
                    print("🔄 Falling back to local JSON")
                    return try await loadTicketsFromJSON()
                }
            },
            fetchAvailableTickets: {
                do {
                    print("🎫 Fetching available tickets from API...")
                    let queryItems = [URLQueryItem(name: "status", value: "available")]
                    let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                        endpoint: "/tickets",
                        method: .GET,
                        queryItems: queryItems
                    )
                    print("✅ Successfully fetched \(apiTickets.count) available tickets from API")
                    let tickets = apiTickets.map { $0.toTicket() }
                    return tickets
                } catch {
                    print("❌ API call failed for fetchAvailableTickets: \(error)")
                    print("🔄 Falling back to local JSON")
                    let tickets = try await loadTicketsFromJSON()
                    return tickets.filter { $0.status == .available }
                }
            },
            fetchTicketsByEvent: { eventId in
                do {
                    print("🎫 Fetching tickets for event: \(eventId)")
                    let queryItems = [URLQueryItem(name: "eventId", value: eventId.uuidString)]
                    let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                        endpoint: "/tickets",
                        method: .GET,
                        queryItems: queryItems
                    )
                    print("✅ Successfully fetched \(apiTickets.count) tickets for event from API")
                    let tickets = apiTickets.map { $0.toTicket() }
                    return tickets
                } catch {
                    print("❌ API call failed for fetchTicketsByEvent: \(error)")
                    print("🔄 Falling back to local JSON")
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
                    print("📋 Fetching ticket detail for ID: \(ticketId)")
                    let apiResponse: APITicketDetailResponse = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/\(ticketId.uuidString)",
                        method: .GET
                    )
                    print("✅ Successfully fetched ticket detail from API")
                    return apiResponse.toTicketDetail()
                } catch {
                    print("❌ API call failed for fetchTicketDetail: \(error)")
                    print("🔄 Falling back to mock data for development")
                    return SharedMockData.sampleTicketDetail(for: ticketId.uuidString)
                }
            },
            purchaseTicket: { ticketId in
                do {
                    print("💰 Purchasing ticket: \(ticketId)")
                    let purchaseRequest = PurchaseTicketRequest(ticketId: ticketId.uuidString)
                    let purchasedTicket: Ticket = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/\(ticketId.uuidString)/purchase",
                        method: .POST,
                        body: purchaseRequest
                    )
                    print("✅ Successfully purchased ticket")
                    return purchasedTicket
                } catch {
                    print("❌ Purchase ticket failed: \(error)")
                    throw error
                }
            },
            toggleFavorite: { ticketId in
                do {
                    print("❤️ Toggling favorite for ticket: \(ticketId)")
                    let request = FavoriteTicketRequest(ticketId: ticketId.uuidString)
                    let _: APISingleResponse<String> = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/\(ticketId.uuidString)/favorite",
                        method: .POST,
                        body: request
                    )
                    print("✅ Successfully toggled favorite")
                } catch {
                    print("❌ Toggle favorite failed: \(error)")
                    throw error
                }
            },
            createTicket: { request in
                do {
                    print("🎫 Creating ticket: \(request.name)")
                    
                    // Estratégia principal: usar NetworkService que já tem fallback para wrapper
                    let apiResponse: CreateTicketResponse = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets",
                        method: .POST,
                        body: request
                    )
                    
                    let ticket = apiResponse.toTicket()
                    print("✅ Ticket created successfully via API: \(ticket.id)")
                    return ticket
                    
                } catch {
                    print("⚠️ API call failed: \(error.localizedDescription)")
                    print("🔄 Creating ticket locally as fallback...")
                    
                    // Estratégia de fallback: criar ticket localmente
                    let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") ?? "local-user"
                    
                    let localTicket = Ticket(
                        eventId: request.eventId,
                        sellerId: currentUserId,
                        name: request.name,
                        price: request.price,
                        ticketType: request.ticketType,
                        validUntil: request.validUntil
                    )
                    
                    print("✅ Ticket created locally: \(localTicket.id)")
                    return localTicket
                }
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
        createTicket: { request in 
            // Criar um ticket com os dados da request
            let ticket = Ticket(
                eventId: request.eventId,
                sellerId: "test-seller-id", // ID padrão para testes
                name: request.name,
                price: request.price,
                ticketType: request.ticketType,
                validUntil: request.validUntil
            )
            return ticket
        }
    )
}

extension DependencyValues {
    public var ticketsClient: TicketsClient {
        get { self[TicketsClient.self] }
        set { self[TicketsClient.self] = newValue }
    }
}
