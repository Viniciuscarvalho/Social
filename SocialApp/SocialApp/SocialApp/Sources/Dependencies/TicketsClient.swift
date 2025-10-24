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
    public var fetchMyTicketsCount: () async throws -> Int
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
                    
                    // Log do token de autenticação (mascarado por segurança)
                    if let token = UserDefaults.standard.string(forKey: "authToken") {
                        let maskedToken = String(token.prefix(20)) + "..." + String(token.suffix(10))
                        print("🔑 Using auth token: \(maskedToken)")
                    } else {
                        print("⚠️ No auth token found in UserDefaults")
                    }
                    
                    // Log do usuário atual
                    if let userId = UserDefaults.standard.string(forKey: "currentUserId") {
                        print("👤 Current user ID: \(userId)")
                    } else {
                        print("⚠️ No current user ID found in UserDefaults")
                    }
                    
                    let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                        endpoint: "/tickets/my",
                        method: .GET,
                        requiresAuth: true
                    )
                    print("✅ Successfully fetched \(apiTickets.count) my tickets from API")
                    let allTickets = apiTickets.map { $0.toTicket() }
                    
                    // Filtra apenas tickets sendo vendidos (available)
                    let sellingTickets = allTickets.filter { $0.status == .available }
                    print("📱 Filtered to \(sellingTickets.count) tickets currently being sold")
                    
                    // Log dos tickets retornados
                    for (index, ticket) in sellingTickets.enumerated() {
                        print("   📋 Ticket \(index + 1): \(ticket.name) (ID: \(ticket.id), Status: \(ticket.status), Seller: \(ticket.sellerId))")
                    }
                    
                    return sellingTickets
                } catch let networkError as NetworkError {
                    print("❌ NetworkError for fetchMyTickets: \(networkError)")
                    
                    // Log específico para diferentes tipos de erro
                    switch networkError {
                    case .serverError(let statusCode):
                        print("🚨 Server Error \(statusCode): Provável problema no backend")
                        print("   - Verifique se a API está funcionando")
                        print("   - Verifique se o endpoint /tickets/my existe")
                        print("   - Verifique se o JWT está sendo validado corretamente")
                    case .unauthorized:
                        print("🚨 Unauthorized: Token inválido ou expirado")
                    case .notFound:
                        print("🚨 Not Found: Endpoint /tickets/my não encontrado")
                    default:
                        print("🚨 Other NetworkError: \(networkError)")
                    }
                    
                    print("🔄 Falling back to local filtered mock data")
                    return try await Self.fallbackMySellingTickets()
                } catch {
                    print("❌ Unexpected error for fetchMyTickets: \(error)")
                    print("   Error type: \(type(of: error))")
                    print("   Error description: \(error.localizedDescription)")
                    print("🔄 Falling back to local filtered mock data")
                    return try await Self.fallbackMySellingTickets()
                }
            },
            fetchMyTicketsCount: {
                do {
                    print("🔢 Fetching my tickets count from API...")
                    
                    // Primeiro tenta buscar o count direto da API (se disponível)
                    let countResponse: APISingleResponse<Int> = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/my/count",
                        method: .GET,
                        requiresAuth: true
                    )
                    
                    if let count = countResponse.finalData {
                        print("✅ Successfully fetched tickets count: \(count)")
                        return count
                    } else {
                        throw NetworkError.noData
                    }
                    
                } catch {
                    print("⚠️ Count endpoint not available, falling back to fetching all tickets...")
                    
                    // Fallback: busca todos os tickets e conta
                    do {
                        let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                            endpoint: "/tickets/my",
                            method: .GET,
                            requiresAuth: true
                        )
                        let allTickets = apiTickets.map { $0.toTicket() }
                        let count = allTickets.count // Conta todos os tickets do usuário
                        print("✅ Counted \(count) total tickets from full list")
                        return count
                    } catch let networkError as NetworkError {
                        print("❌ NetworkError for fetchMyTicketsCount: \(networkError)")
                        
                        // Fallback para mock
                        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
                            print("⚠️ No currentUserId for count fallback")
                            return 0
                        }
                        
                        // Mock: retorna contagem dos tickets simulados
                        let mockCount = min(3, SharedMockData.sampleTickets.count)
                        print("📱 Mock: Returning count of \(mockCount) tickets")
                        return mockCount
                    } catch {
                        print("❌ Unexpected error for fetchMyTicketsCount: \(error)")
                        return 0
                    }
                }
            },
            deleteTicket: { ticketId in
                do {
                    print("🗑️ Deleting ticket: \(ticketId)")
                    
                    // Verifica se o usuário está autenticado
                    guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
                        print("❌ Usuário não autenticado para deletar ticket")
                        throw NetworkError.unauthorized
                    }
                    
                    // Verifica se o token de auth existe
                    guard UserDefaults.standard.string(forKey: "authToken") != nil else {
                        print("❌ Token de autenticação não encontrado")
                        throw NetworkError.unauthorized
                    }
                    
                    print("👤 Usuário atual: \(currentUserId)")
                    print("🔑 Enviando request DELETE para /tickets/\(ticketId)")
                    
                    let _: APISingleResponse<String> = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/\(ticketId)",
                        method: .DELETE,
                        requiresAuth: true
                    )
                    print("✅ Ticket deleted successfully")
                } catch let networkError as NetworkError {
                    print("❌ NetworkError deleting ticket: \(networkError)")
                    
                    // Tratamento específico para diferentes erros
                    switch networkError {
                    case .serverError(let statusCode):
                        print("🚨 Server Error \(statusCode) ao deletar ticket")
                        if statusCode == 404 {
                            throw NetworkError.notFound
                        } else if statusCode == 403 {
                            throw NetworkError.forbidden
                        } else {
                            throw NetworkError.serverError(statusCode)
                        }
                    case .unauthorized:
                        throw NetworkError.unauthorized
                    case .forbidden:
                        throw NetworkError.forbidden
                    case .notFound:
                        throw NetworkError.notFound
                    default:
                        throw networkError
                    }
                } catch {
                    print("❌ Unexpected error deleting ticket: \(error)")
                    throw NetworkError.unknown("Erro inesperado ao deletar ingresso: \(error.localizedDescription)")
                }
            }
        )
    }
    
    // MARK: - Helper Functions
    
    private static func fallbackMySellingTickets() async throws -> [Ticket] {
        print("🔄 Using fallback mock data for my selling tickets...")
        
        // Para desenvolvimento, filtra tickets baseado no usuário atual
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
            print("⚠️ currentUserId não encontrado no UserDefaults, retornando array vazio")
            return []
        }
        
        // Retorna apenas tickets do mock que pertencem ao usuário atual E estão sendo vendidos
        let filteredTickets = SharedMockData.sampleTickets.compactMap { ticket -> Ticket? in
            // Simula alguns tickets como sendo do usuário atual
            var userTicket = ticket
            
            // Para mock, considera os 3 primeiros tickets como do usuário atual
            if let ticketIndex = SharedMockData.sampleTickets.firstIndex(where: { $0.id == ticket.id }),
               ticketIndex < 3 {
                userTicket.sellerId = currentUserId
                userTicket.status = .available // Garante que estão sendo vendidos (available)
                print("   📋 Mock selling ticket: \(userTicket.name) (Seller: \(currentUserId), Status: available)")
                return userTicket
            }
            
            return nil
        }
        
        print("📱 Mock: Retornando \(filteredTickets.count) tickets sendo vendidos para o usuário \(currentUserId)")
        return filteredTickets
    }
    
    private static func fallbackMyTickets() async throws -> [Ticket] {
        print("🔄 Using fallback mock data for all my tickets...")
        
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
            print("⚠️ currentUserId não encontrado no UserDefaults, retornando array vazio")
            return []
        }
        
        // Retorna todos os tickets do mock que pertencem ao usuário atual (todos os status)
        let filteredTickets = SharedMockData.sampleTickets.compactMap { ticket -> Ticket? in
            var userTicket = ticket
            
            if let ticketIndex = SharedMockData.sampleTickets.firstIndex(where: { $0.id == ticket.id }),
               ticketIndex < 3 {
                userTicket.sellerId = currentUserId
                // Varia o status para simular diferentes estados
                switch ticketIndex {
                case 0: userTicket.status = .available
                case 1: userTicket.status = .sold
                case 2: userTicket.status = .available
                default: userTicket.status = .available
                }
                print("   📋 Mock ticket: \(userTicket.name) (Seller: \(currentUserId), Status: \(userTicket.status))")
                return userTicket
            }
            
            return nil
        }
        
        print("📱 Mock: Retornando \(filteredTickets.count) tickets totais para o usuário \(currentUserId)")
        return filteredTickets
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
        fetchMyTickets: { Array(SharedMockData.sampleTickets.prefix(2)).map { var ticket = $0; ticket.status = .available; return ticket } },
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
