import ComposableArchitecture
import Foundation

public struct TicketsClient {
    public var fetchTickets: () async throws -> [Ticket]
    public var fetchAvailableTickets: () async throws -> [Ticket]
    public var fetchTicketsByEvent: (UUID) async throws -> [Ticket]
    public var fetchTicketsBySeller: (String) async throws -> [Ticket]
    public var fetchTicketDetail: (UUID) async throws -> TicketDetail
    public var purchaseTicket: (UUID) async throws -> Ticket
    public var toggleFavorite: (UUID) async throws -> Void
    public var createTicket: (CreateTicketRequest) async throws -> Ticket
    public var fetchMyTickets: () async throws -> [Ticket]
    public var fetchMyTicketsWithPagination: () async throws -> (tickets: [Ticket], total: Int)
    public var fetchMyTicketsCount: () async throws -> Int
    public var deleteTicket: (String) async throws -> Void
}

extension TicketsClient: DependencyKey {
    public static var liveValue: TicketsClient {
        TicketsClient(
            fetchTickets: {
                do {
                    let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                        endpoint: "/tickets",
                        method: .GET
                    )
                    let tickets = apiTickets.map { $0.toTicket() }
                    return tickets
                } catch {
                    return try await loadTicketsFromJSON()
                }
            },
            fetchAvailableTickets: {
                do {
                    let queryItems = [URLQueryItem(name: "status", value: "available")]
                    let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                        endpoint: "/tickets",
                        method: .GET,
                        queryItems: queryItems
                    )
                    let tickets = apiTickets.map { $0.toTicket() }
                    return tickets
                } catch {
                    let tickets = try await loadTicketsFromJSON()
                    return tickets.filter { $0.status == .available }
                }
            },
            fetchTicketsByEvent: { eventId in
                do {
                    let queryItems = [URLQueryItem(name: "eventId", value: eventId.uuidString)]
                    let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                        endpoint: "/tickets",
                        method: .GET,
                        queryItems: queryItems
                    )
                    let tickets = apiTickets.map { $0.toTicket() }
                    return tickets
                } catch {
                    let tickets = try await loadTicketsFromJSON()
                    return tickets.filter { ticket in
                        if let ticketEventId = UUID(uuidString: ticket.eventId) {
                            return ticketEventId == eventId
                        }
                        return false
                    }
                }
            },
            fetchTicketsBySeller: { sellerId in
                print("🎫 fetchTicketsBySeller - Iniciando busca para sellerId: \(sellerId)")
                do {
                    // Nível 1: Tentar com query parameter sellerId
                    print("📡 Nível 1: Tentando GET /tickets?sellerId=\(sellerId)")
                    let queryItems = [URLQueryItem(name: "sellerId", value: sellerId)]
                    let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                        endpoint: "/tickets",
                        method: .GET,
                        queryItems: queryItems
                    )
                    let allTickets = apiTickets.map { $0.toTicket() }
                    print("📦 Nível 1: Recebidos \(allTickets.count) tickets da API")
                    
                    // CRÍTICO: Filtrar por sellerId E status disponível
                    let sellerTickets = allTickets.filter { 
                        $0.sellerId == sellerId && $0.status == .available 
                    }
                    print("✅ Nível 1: \(sellerTickets.count) tickets disponíveis do vendedor \(sellerId)")
                    
                    if !sellerTickets.isEmpty {
                        return sellerTickets
                    }
                    
                    print("⚠️ Nível 1: Nenhum ticket encontrado com filtro, tentando próximo nível...")
                    throw NetworkError.notFound
                    
                } catch {
                    print("❌ Nível 1 falhou: \(error)")
                    // Nível 2: Se falhar, busca todos e filtra localmente
                    do {
                        print("📡 Nível 2: Tentando GET /tickets (todos) e filtrando localmente")
                        let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                            endpoint: "/tickets",
                            method: .GET
                        )
                        let allTickets = apiTickets.map { $0.toTicket() }
                        print("📦 Nível 2: Recebidos \(allTickets.count) tickets totais")
                        
                        let sellerTickets = allTickets.filter { 
                            $0.sellerId == sellerId && $0.status == .available 
                        }
                        print("✅ Nível 2: \(sellerTickets.count) tickets disponíveis do vendedor \(sellerId)")
                        
                        if !sellerTickets.isEmpty {
                            return sellerTickets
                        }
                        
                        print("⚠️ Nível 2: Nenhum ticket encontrado, tentando fallback JSON...")
                        throw NetworkError.notFound
                        
                    } catch {
                        print("❌ Nível 2 falhou: \(error)")
                        // Nível 3: Fallback final para JSON local
                        print("📁 Nível 3: Carregando tickets.json e filtrando")
                        let tickets = try await loadTicketsFromJSON()
                        let sellerTickets = tickets.filter { 
                            $0.sellerId == sellerId && $0.status == .available 
                        }
                        print("✅ Nível 3: \(sellerTickets.count) tickets disponíveis do vendedor no JSON local")
                        return sellerTickets
                    }
                }
            },
            fetchTicketDetail: { ticketId in
                do {
                    let apiResponse: APITicketDetailResponse = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/\(ticketId.uuidString)",
                        method: .GET
                    )
                    return apiResponse.toTicketDetail()
                } catch {
                    return SharedMockData.sampleTicketDetail(for: ticketId.uuidString)
                }
            },
            purchaseTicket: { ticketId in
                do {
                    let purchasedTicket: Ticket = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/\(ticketId.uuidString)/purchase",
                        method: .POST,
                        body: PurchaseTicketRequest(),
                        requiresAuth: true
                    )
                    return purchasedTicket
                } catch {
                    throw error
                }
            },
            toggleFavorite: { ticketId in
                do {
                    let _: APISingleResponse<String> = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/\(ticketId.uuidString)/favorite",
                        method: .POST,
                        body: FavoriteTicketRequest(),
                        requiresAuth: true
                    )
                } catch {
                    throw error
                }
            },
            createTicket: { request in
                do {
                    let createdTicket: CreateTicketResponse = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets",
                        method: .POST,
                        body: request,
                        requiresAuth: true
                    )
                    return createdTicket.toTicket()
                } catch let networkError as NetworkError {
                    throw networkError
                } catch {
                    throw NetworkError.unknown("Erro ao criar ticket: \(error.localizedDescription)")
                }
            },
            fetchMyTickets: {
                do {
                    if let token = UserDefaults.standard.string(forKey: "authToken"),
                       let userId = UserDefaults.standard.string(forKey: "currentUserId") {
                        
                        let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                            endpoint: "/tickets/my",
                            method: .GET,
                            requiresAuth: true
                        )
                        let allTickets = apiTickets.map { $0.toTicket() }
                        // Filtrar tickets cancelados
                        return allTickets.filter { $0.status != .cancelled }
                    }
                    return []
                } catch let networkError as NetworkError {
                    return try await Self.fallbackMySellingTickets()
                } catch {
                    return try await Self.fallbackMySellingTickets()
                }
            },
            fetchMyTicketsWithPagination: {
                do {
                    let paginatedResponse: TicketsListResponse = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/my",
                        method: .GET,
                        requiresAuth: true
                    )
                    
                    let allTickets = paginatedResponse.tickets.map { $0.toTicket() }
                    
                    // Filtrar tickets cancelados (deletados)
                    let activeTickets = allTickets.filter { $0.status != .cancelled }
                    
                    let total = paginatedResponse.pagination.total
                    
                    return (tickets: activeTickets, total: total)
                } catch {
                    do {
                        let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                            endpoint: "/tickets/my",
                            method: .GET,
                            requiresAuth: true
                        )
                        
                        let allTickets = apiTickets.map { $0.toTicket() }
                    let sellingTickets = allTickets
                        
                        return (tickets: sellingTickets, total: allTickets.count)
                    } catch {
                        let mockTickets = try await Self.fallbackMyTickets()
                        return (tickets: mockTickets, total: mockTickets.count)
                    }
                }
            },
            fetchMyTicketsCount: {
                do {
                    let result = try await TicketsClient.liveValue.fetchMyTicketsWithPagination()
                    return result.total
                } catch {
                    guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
                        return 0
                    }
                    let mockCount = min(3, SharedMockData.sampleTickets.count)
                    return mockCount
                }
            },
            deleteTicket: { ticketId in
                do {
                    guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
                        throw NetworkError.unauthorized
                    }
                    
                    guard UserDefaults.standard.string(forKey: "authToken") != nil else {
                        throw NetworkError.unauthorized
                    }
                    
                    let _: APISingleResponse<String> = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/\(ticketId)",
                        method: .DELETE,
                        requiresAuth: true
                    )
                } catch let networkError as NetworkError {
                    switch networkError {
                    case .serverError(let statusCode):
                        if statusCode == 404 {
                            throw NetworkError.notFound
                        } else if statusCode == 403 {
                            throw NetworkError.forbidden
                        } else {
                            throw NetworkError.serverError(statusCode)
                        }
                    default:
                        throw networkError
                    }
                } catch {
                    throw NetworkError.unknown("Erro inesperado ao deletar ingresso: \(error.localizedDescription)")
                }
            }
        )
    }
    
    // MARK: - Helper Functions
    
    private static func fallbackMySellingTickets() async throws -> [Ticket] {
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
            return []
        }
        
        let filteredTickets = SharedMockData.sampleTickets.compactMap { ticket -> Ticket? in
            var userTicket = ticket
            
            if let ticketIndex = SharedMockData.sampleTickets.firstIndex(where: { $0.id == ticket.id }),
               ticketIndex < 3 {
                userTicket.sellerId = currentUserId
                return userTicket
            }
            
            return nil
        }
        
        return filteredTickets
    }
    
    private static func fallbackMyTickets() async throws -> [Ticket] {
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
            return []
        }
        
        let filteredTickets = SharedMockData.sampleTickets.compactMap { ticket -> Ticket? in
            var userTicket = ticket
            
            if let ticketIndex = SharedMockData.sampleTickets.firstIndex(where: { $0.id == ticket.id }),
               ticketIndex < 3 {
                userTicket.sellerId = currentUserId
                switch ticketIndex {
                case 0: userTicket.status = .available
                case 1: userTicket.status = .sold
                case 2: userTicket.status = .available
                default: userTicket.status = .available
                }
                return userTicket
            }
            
            return nil
        }
        
        return filteredTickets
    }
    
    public static let testValue = TicketsClient(
        fetchTickets: { SharedMockData.sampleTickets },
        fetchAvailableTickets: { SharedMockData.sampleTickets },
        fetchTicketsByEvent: { _ in SharedMockData.sampleTickets },
        fetchTicketsBySeller: { sellerId in SharedMockData.sampleTickets},
        fetchTicketDetail: { ticketId in SharedMockData.sampleTicketDetail(for: ticketId.uuidString) },
        purchaseTicket: { _ in SharedMockData.sampleTickets[0] },
        toggleFavorite: { _ in },
        createTicket: { request in 
            let ticket = Ticket(
                eventId: request.eventId,
                sellerId: "TEST_SELLER_ID",
                name: request.name,
                price: request.price,
                ticketType: request.ticketType,
                validUntil: request.validUntil
            )
            return ticket
        },
        fetchMyTickets: { Array(SharedMockData.sampleTickets.prefix(2)).map { var ticket = $0; ticket.status = .available; return ticket } },
        fetchMyTicketsWithPagination: { 
            let tickets = Array(SharedMockData.sampleTickets.prefix(2)).map { var ticket = $0; ticket.status = .available; return ticket }
            return (tickets: tickets, total: 3)
        },
        fetchMyTicketsCount: { 3 },
        deleteTicket: { _ in }
    )
}

extension DependencyValues {
    public var ticketsClient: TicketsClient {
        get { self[TicketsClient.self] }
        set { self[TicketsClient.self] = newValue }
    }
}

// MARK: - NetworkError Extensions for User-Friendly Messages

extension NetworkError {
    var userFriendlyMessage: String {
        switch self {
        case .unauthorized:
            return "Sessão expirada. Faça login novamente."
        case .forbidden:
            return "Você não tem permissão para realizar esta ação."
        case .notFound:
            return "Item não encontrado."
        case .serverError(let code):
            if code == 500 {
                return "Problema no servidor. Tente novamente em alguns minutos."
            } else {
                return "Erro do servidor (\(code)). Tente novamente."
            }
        case .networkUnavailable:
            return "Sem conexão com a internet. Verifique sua conexão."
        case .decodingError:
            return "Erro ao processar dados do servidor."
        case .unknown(let message):
            return message
        case .invalidCredentials(let message):
            return message
        case .emailNotConfirmed(let message):
            return message
        case .userNotFound(let message):
            return message
        case .weakPassword(let message):
            return message
        case .emailAlreadyExists(let message):
            return message
        case .authError(let message):
            return message
        case .httpError(let code, let message):
            return "Erro HTTP \(code): \(message)"
        default:
            return self.errorDescription ?? "Erro desconhecido"
        }
    }
}
