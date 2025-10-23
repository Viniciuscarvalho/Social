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
    public var fetchMyTickets: () async throws -> [Ticket]
    public var deleteTicket: (String) async throws -> Void
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
                    print("💰 Comprando ticket: \(ticketId)")
                    
                    // Usar NetworkService com autenticação obrigatória
                    let purchasedTicket: Ticket = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/\(ticketId.uuidString)/purchase",
                        method: .POST,
                        body: PurchaseTicketRequest(), // Body vazio - dados vêm do JWT e URL
                        requiresAuth: true
                    )
                    
                    print("✅ Ticket comprado com sucesso: \(purchasedTicket.id)")
                    return purchasedTicket
                } catch {
                    print("❌ Erro ao comprar ticket: \(error)")
                    throw error
                }
            },
            toggleFavorite: { ticketId in
                do {
                    print("❤️ Alterando favorito para ticket: \(ticketId)")
                    
                    // Usar NetworkService com autenticação obrigatória
                    let _: APISingleResponse<String> = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/\(ticketId.uuidString)/favorite",
                        method: .POST,
                        body: FavoriteTicketRequest(), // Body vazio - dados vêm do JWT e URL
                        requiresAuth: true
                    )
                    
                    print("✅ Favorito alterado com sucesso")
                } catch {
                    print("❌ Erro ao alterar favorito: \(error)")
                    throw error
                }
            },
            createTicket: { request in
                do {
                    print("🎫 Criando ticket: \(request.name)")
                    print("   Event ID: \(request.eventId)")
                    print("   Price: \(request.price)")
                    print("   Ticket Type: \(request.ticketType)")
                    print("   Valid Until: \(request.validUntil)")
                    print("   ℹ️ Seller ID será injetado automaticamente do JWT")
                    
                    // Usar NetworkService que já inclui autenticação
                    let createdTicket: CreateTicketResponse = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets",
                        method: .POST,
                        body: request,
                        requiresAuth: true
                    )
                    
                    print("✅ Ticket criado com sucesso: \(createdTicket.id)")
                    return createdTicket.toTicket()
                    
                } catch let networkError as NetworkError {
                    print("❌ Erro de rede ao criar ticket: \(networkError)")
                    throw networkError
                } catch {
                    print("❌ Erro inesperado ao criar ticket: \(error)")
                    throw NetworkError.unknown("Erro ao criar ticket: \(error.localizedDescription)")
                }
            },
            fetchMyTickets: {
                do {
                    print("📱 Fetching my tickets from API...")
                    let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                        endpoint: "/tickets/my",
                        method: .GET,
                        requiresAuth: true
                    )
                    print("✅ Successfully fetched \(apiTickets.count) my tickets from API")
                    let tickets = apiTickets.map { $0.toTicket() }
                    return tickets
                } catch {
                    print("❌ API call failed for fetchMyTickets: \(error)")
                    print("🔄 Falling back to local mock data")
                    // Para desenvolvimento, retorna alguns tickets de exemplo
                    return SharedMockData.sampleTickets.prefix(3).map { ticket in
                        var myTicket = ticket
                        myTicket.sellerId = "current_user_id" // Simula os tickets do usuário atual
                        return myTicket
                    }
                }
            },
            deleteTicket: { ticketId in
                do {
                    print("🗑️ Deleting ticket: \(ticketId)")
                    let _: APISingleResponse<String> = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/\(ticketId)",
                        method: .DELETE,
                        requiresAuth: true
                    )
                    print("✅ Ticket deleted successfully")
                } catch {
                    print("❌ Error deleting ticket: \(error)")
                    throw error
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
            // Criar um ticket de teste sem precisar do sellerId
            let ticket = Ticket(
                eventId: request.eventId,
                sellerId: "TEST_SELLER_ID", // ID fixo para testes
                name: request.name,
                price: request.price,
                ticketType: request.ticketType,
                validUntil: request.validUntil
            )
            return ticket
        },
        fetchMyTickets: { Array(SharedMockData.sampleTickets.prefix(3)) },
        deleteTicket: { _ in }
    )
}

extension DependencyValues {
    public var ticketsClient: TicketsClient {
        get { self[TicketsClient.self] }
        set { self[TicketsClient.self] = newValue }
    }
}
