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
    public var updateTicket: (String, UpdateTicketRequest) async throws -> Ticket
    public var fetchMyTickets: () async throws -> [Ticket]
    public var fetchMyTicketsWithPagination: () async throws -> (tickets: [Ticket], total: Int)
    public var fetchMyTicketsCount: () async throws -> Int
    public var deleteTicket: (String) async throws -> Void
    /// Busca vendedores que possuem ingressos disponíveis para um evento específico
    /// Endpoint otimizado: GET /api/v1/events/{eventId}/sellers
    public var fetchSellersByEvent: (UUID) async throws -> [SellerWithTickets]
}

extension TicketsClient: DependencyKey {
    @Dependency(\.authClient) static var authClient
    
    public static var liveValue: TicketsClient {
        TicketsClient(
            fetchTickets: {
                do {
                    let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                        endpoint: "/tickets",
                        method: .GET
                    )
                    let allTickets = apiTickets.map { $0.toTicket() }
                    // ✅ CRÍTICO: Filtrar tickets deletados/cancelados da resposta da API
                    let activeTickets = allTickets.filter { $0.status != .cancelled }
                    print("🎫 Tickets da API: \(allTickets.count) total, \(activeTickets.count) ativos (após filtrar deletados)")
                    return activeTickets
                } catch {
                    let tickets = try await loadTicketsFromJSON()
                    // Filtrar também do JSON fallback
                    return tickets.filter { $0.status != .cancelled }
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
                
                // Nível 1: Tentar endpoint otimizado primeiro: GET /api/v1/sellers/{sellerId}/tickets
                do {
                    print("📡 Nível 1: Tentando endpoint otimizado GET /sellers/\(sellerId)/tickets")
                    let response: APITicketsBySellerResponse = try await NetworkService.shared.requestSingle(
                        endpoint: "/sellers/\(sellerId)/tickets",
                        method: .GET,
                        requiresAuth: false
                    )
                    
                    guard let apiTickets = response.tickets, !apiTickets.isEmpty else {
                        print("⚠️ Endpoint otimizado retornou vazio, usando fallback")
                        throw NetworkError.notFound
                    }
                    
                    let allTickets = apiTickets.map { $0.toTicket() }
                    print("📦 Nível 1: Recebidos \(allTickets.count) tickets da API otimizada")
                    
                    // Filtrar apenas tickets disponíveis (o endpoint já deve retornar apenas available, mas garantimos)
                    let sellerTickets = allTickets.filter { $0.status == .available }
                    print("✅ Nível 1: \(sellerTickets.count) tickets disponíveis do vendedor \(sellerId)")
                    
                    if !sellerTickets.isEmpty {
                        return sellerTickets
                    }
                    
                    print("⚠️ Nível 1: Nenhum ticket disponível encontrado, tentando fallback...")
                    throw NetworkError.notFound
                    
                } catch {
                    print("❌ Nível 1 (endpoint otimizado) falhou: \(error.localizedDescription)")
                    
                    // Nível 2: Fallback - Tentar com query parameter sellerId
                    do {
                        print("📡 Nível 2: Tentando GET /tickets?sellerId=\(sellerId)")
                        let queryItems = [URLQueryItem(name: "sellerId", value: sellerId)]
                        let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                            endpoint: "/tickets",
                            method: .GET,
                            queryItems: queryItems
                        )
                        let allTickets = apiTickets.map { $0.toTicket() }
                        print("📦 Nível 2: Recebidos \(allTickets.count) tickets da API")
                        
                        // CRÍTICO: Filtrar por sellerId E status disponível
                        let sellerTickets = allTickets.filter { 
                            $0.sellerId == sellerId && $0.status == .available 
                        }
                        print("✅ Nível 2: \(sellerTickets.count) tickets disponíveis do vendedor \(sellerId)")
                        
                        if !sellerTickets.isEmpty {
                            return sellerTickets
                        }
                        
                        print("⚠️ Nível 2: Nenhum ticket encontrado, tentando próximo nível...")
                        throw NetworkError.notFound
                        
                    } catch {
                        print("❌ Nível 2 falhou: \(error.localizedDescription)")
                        
                        // Nível 3: Se falhar, busca todos e filtra localmente
                        do {
                            print("📡 Nível 3: Tentando GET /tickets (todos) e filtrando localmente")
                            let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                                endpoint: "/tickets",
                                method: .GET
                            )
                            let allTickets = apiTickets.map { $0.toTicket() }
                            print("📦 Nível 3: Recebidos \(allTickets.count) tickets totais")
                            
                            let sellerTickets = allTickets.filter { 
                                $0.sellerId == sellerId && $0.status == .available 
                            }
                            print("✅ Nível 3: \(sellerTickets.count) tickets disponíveis do vendedor \(sellerId)")
                            
                            if !sellerTickets.isEmpty {
                                return sellerTickets
                            }
                            
                            print("⚠️ Nível 3: Nenhum ticket encontrado, tentando fallback JSON...")
                            throw NetworkError.notFound
                            
                        } catch {
                            print("❌ Nível 3 falhou: \(error.localizedDescription)")
                            // Nível 4: Fallback final para JSON local
                            print("📁 Nível 4: Carregando tickets.json e filtrando")
                            let tickets = try await loadTicketsFromJSON()
                            let sellerTickets = tickets.filter { 
                                $0.sellerId == sellerId && $0.status == .available 
                            }
                            print("✅ Nível 4: \(sellerTickets.count) tickets disponíveis do vendedor no JSON local")
                            return sellerTickets
                        }
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
                    // 🔄 CRÍTICO: Refrescar token antes de criar ticket
                    print("🎫 TicketClient: Iniciando criação de ticket - tentando refrescar token...")
                    do {
                        let newToken = try await authClient.refreshToken()
                        print("✅ TicketClient: Token refrescado com sucesso: \(newToken.prefix(20))...")
                    } catch {
                        print("⚠️ TicketClient: Falha ao refrescar token, tentando com token atual: \(error)")
                    }
                    
                    let createdTicket: CreateTicketResponse = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets",
                        method: .POST,
                        body: request,
                        requiresAuth: true
                    )
                    print("✅ TicketClient: Ticket criado com sucesso: \(createdTicket.id)")
                    return createdTicket.toTicket()
                } catch let networkError as NetworkError {
                    print("❌ TicketClient: Erro ao criar ticket - \(networkError.errorDescription)")
                    throw networkError
                } catch {
                    print("❌ TicketClient: Erro desconhecido - \(error.localizedDescription)")
                    throw NetworkError.unknown("Erro ao criar ticket: \(error.localizedDescription)")
                }
            },
            updateTicket: { ticketId, request in
                do {
                    print("✏️ Atualizando ticket \(ticketId) via API")
                    let updatedTicket: APITicketResponse = try await NetworkService.shared.requestSingle(
                        endpoint: "/tickets/\(ticketId)",
                        method: .PUT,
                        body: request,
                        requiresAuth: true
                    )
                    print("✅ Ticket atualizado com sucesso")
                    return updatedTicket.toTicket()
                } catch let networkError as NetworkError {
                    print("❌ Erro ao atualizar ticket: \(networkError.userFriendlyMessage)")
                    throw networkError
                } catch {
                    print("❌ Erro desconhecido ao atualizar ticket: \(error.localizedDescription)")
                    throw NetworkError.unknown("Erro ao atualizar ticket: \(error.localizedDescription)")
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
                    // ✅ CRÍTICO: Buscar tickets completos e contar localmente com os mesmos filtros do MyTickets
                    let result = try await TicketsClient.liveValue.fetchMyTicketsWithPagination()
                    let tickets = result.tickets
                    
                    // Carregar IDs deletados do UserDefaults
                    var deletedTicketIds: Set<String> = []
                    if let deletedIdsData = UserDefaults.standard.data(forKey: "deletedTicketIds"),
                       let deletedIdsArray = try? JSONDecoder().decode([String].self, from: deletedIdsData) {
                        deletedTicketIds = Set(deletedIdsArray)
                    }
                    
                    // ✅ APLICAR OS MESMOS FILTROS DO MyTicketsFeature:
                    // 1. Filtrar por sellerId == currentUserId
                    // 2. Remover cancelled
                    // 3. Remover deletedTicketIds
                    guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
                        return 0
                    }
                    
                    let filteredTickets = tickets.filter { ticket in
                        ticket.sellerId == currentUserId &&
                        ticket.status != .cancelled &&
                        !deletedTicketIds.contains(ticket.id)
                    }
                    
                    print("📊 fetchMyTicketsCount: \(tickets.count) tickets brutos → \(filteredTickets.count) após filtros (deletados locais: \(deletedTicketIds.count))")
                    return filteredTickets.count
                } catch {
                    guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
                        return 0
                    }
                    
                    // Fallback: tentar contar do mock data com os mesmos filtros
                    var deletedTicketIds: Set<String> = []
                    if let deletedIdsData = UserDefaults.standard.data(forKey: "deletedTicketIds"),
                       let deletedIdsArray = try? JSONDecoder().decode([String].self, from: deletedIdsData) {
                        deletedTicketIds = Set(deletedIdsArray)
                    }
                    
                    let mockTickets = SharedMockData.sampleTickets.filter { ticket in
                        ticket.sellerId == currentUserId &&
                        ticket.status != .cancelled &&
                        !deletedTicketIds.contains(ticket.id)
                    }
                    
                    return mockTickets.count
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
            },
            fetchSellersByEvent: { eventId in
                return try await Self.fetchSellersByEventImpl(eventId: eventId)
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
    
    /// Implementação de fetchSellersByEvent que pode usar dependências
    private static func fetchSellersByEventImpl(eventId: UUID) async throws -> [SellerWithTickets] {
        print("🛒 Buscando vendedores para evento: \(eventId)")
        
        // Tentar endpoint otimizado primeiro: GET /api/v1/events/{eventId}/sellers
        do {
            let response: APISellersByEventResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/events/\(eventId.uuidString)/sellers",
                method: .GET,
                requiresAuth: false
            )
            
            guard let sellers = response.sellers, !sellers.isEmpty else {
                print("⚠️ Endpoint otimizado retornou vazio, usando fallback")
                throw NetworkError.notFound
            }
            
            print("✅ Endpoint otimizado retornou \(sellers.count) vendedores")
            
            // Converter APISellerSummary para SellerWithTickets
            // Como o endpoint otimizado não retorna tickets completos, precisamos buscar os tickets
            var sellersWithTickets: [SellerWithTickets] = []
            let ticketsClient = Self.liveValue
            let userClient = UserClient.liveValue
            
            for sellerSummary in sellers {
                // Buscar tickets do vendedor para o evento
                let sellerTickets = try await ticketsClient.fetchTicketsByEvent(eventId)
                let availableTickets = sellerTickets.filter { 
                    $0.sellerId == sellerSummary.id && $0.status == .available 
                }
                
                if !availableTickets.isEmpty {
                    // Buscar perfil completo do vendedor
                    do {
                        let seller = try await userClient.getUserProfile(sellerSummary.id)
                        let sellerWithTickets = SellerWithTickets(seller: seller, tickets: availableTickets)
                        sellersWithTickets.append(sellerWithTickets)
                    } catch {
                        // Se não conseguir buscar perfil, criar um básico
                        var basicSeller = User(
                            name: sellerSummary.name,
                            title: sellerSummary.finalIsVerified ? "Vendedor Verificado" : nil,
                            profileImageURL: sellerSummary.finalPhoto,
                            email: nil
                        )
                        basicSeller.id = sellerSummary.id
                        basicSeller.isVerified = sellerSummary.finalIsVerified
                        basicSeller.ticketsCount = sellerSummary.finalTicketsCount
                        
                        let sellerWithTickets = SellerWithTickets(seller: basicSeller, tickets: availableTickets)
                        sellersWithTickets.append(sellerWithTickets)
                    }
                }
            }
            
            // Ordenar por preço mínimo
            sellersWithTickets.sort { $0.minPrice < $1.minPrice }
            return sellersWithTickets
            
        } catch {
            // Fallback: usar método atual (buscar tickets e agrupar)
            print("⚠️ Endpoint otimizado não disponível, usando fallback: \(error.localizedDescription)")
            return try await Self.fallbackFetchSellersByEvent(eventId: eventId)
        }
    }
    
    private static func fallbackFetchSellersByEvent(eventId: UUID) async throws -> [SellerWithTickets] {
        let ticketsClient = Self.liveValue
        let userClient = UserClient.liveValue
        
        // Buscar tickets do evento
        let tickets = try await ticketsClient.fetchTicketsByEvent(eventId)
        let availableTickets = tickets.filter { $0.status == .available }
        
        // Agrupar tickets por vendedor
        var sellersMap: [String: [Ticket]] = [:]
        for ticket in availableTickets {
            if sellersMap[ticket.sellerId] == nil {
                sellersMap[ticket.sellerId] = []
            }
            sellersMap[ticket.sellerId]?.append(ticket)
        }
        
        // Buscar informações dos vendedores
        var sellersWithTickets: [SellerWithTickets] = []
        for (sellerId, sellerTickets) in sellersMap {
            do {
                let seller = try await userClient.getUserProfile(sellerId)
                let sellerWithTickets = SellerWithTickets(seller: seller, tickets: sellerTickets)
                sellersWithTickets.append(sellerWithTickets)
            } catch {
                // Continuar mesmo se um vendedor falhar
                continue
            }
        }
        
        // Ordenar por preço mínimo
        sellersWithTickets.sort { $0.minPrice < $1.minPrice }
        return sellersWithTickets
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
                description: request.description,
                price: request.price,
                ticketType: request.ticketType,
                validUntil: request.validUntil,
                quantity: request.quantity,
                currencyCode: request.currencyCode
            )
            return ticket
        },
        updateTicket: { ticketId, request in
            var ticket = SharedMockData.sampleTickets.first { $0.id == ticketId } ?? SharedMockData.sampleTickets[0]
            ticket.name = request.name
            ticket.price = request.price
            ticket.ticketType = request.ticketType
            return ticket
        },
        fetchMyTickets: { Array(SharedMockData.sampleTickets.prefix(2)).map { var ticket = $0; ticket.status = .available; return ticket } },
        fetchMyTicketsWithPagination: { 
            let tickets = Array(SharedMockData.sampleTickets.prefix(2)).map { var ticket = $0; ticket.status = .available; return ticket }
            return (tickets: tickets, total: 3)
        },
        fetchMyTicketsCount: { 3 },
        deleteTicket: { _ in },
        fetchSellersByEvent: { _ in
            // Mock para testes
            var mockSeller = User(
                name: "Vendedor Teste",
                title: "Vendedor Verificado",
                profileImageURL: "https://via.placeholder.com/120",
                email: "vendedor@teste.com"
            )
            mockSeller.id = "TEST_SELLER_ID"
            mockSeller.isVerified = true
            let mockTickets = Array(SharedMockData.sampleTickets.prefix(2))
            return [SellerWithTickets(seller: mockSeller, tickets: mockTickets)]
        }
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
