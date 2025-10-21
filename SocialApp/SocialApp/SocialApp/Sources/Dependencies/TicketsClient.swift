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
                    print("➕ Creating ticket: \(request.name)")
                    print("📋 Ticket details:")
                    print("   Name: \(request.name)")
                    print("   Price: \(request.price)")
                    print("   Event ID: \(request.eventId)")
                    print("   Type: \(request.ticketType)")
                    print("   Valid Until: \(request.validUntil)")
                    
                    // Primeira tentativa: tentar criar via API usando uma abordagem manual
                    print("🌐 Tentando criar ticket via API com captura manual...")
                    
                    // Construir URL e request manualmente para ter controle total
                    guard let url = URL(string: "\(NetworkConfig.baseURL)\(NetworkConfig.apiPath)/tickets") else {
                        throw NetworkError.invalidURL
                    }
                    
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                    
                    // Adicionar token de autenticação
                    if let token = UserDefaults.standard.string(forKey: "authToken") {
                        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    }
                    
                    // Codificar corpo da requisição
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .iso8601
                    let bodyData = try encoder.encode(request)
                    urlRequest.httpBody = bodyData
                    
                    // Fazer a requisição
                    let (data, response) = try await URLSession.shared.data(for: urlRequest)
                    
                    // Verificar status HTTP
                    if let httpResponse = response as? HTTPURLResponse {
                        print("📡 HTTP Status: \(httpResponse.statusCode)")
                        print("📡 HTTP Headers: \(httpResponse.allHeaderFields)")
                        
                        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                            print("❌ HTTP Error: \(httpResponse.statusCode)")
                            
                            // Para erros 400, vamos analisar a resposta de erro
                            if httpResponse.statusCode == 400 {
                                if let errorJsonString = String(data: data, encoding: .utf8) {
                                    print("📄 Error Response Body:")
                                    print(errorJsonString)
                                    
                                    // Tentar analisar o erro estruturado
                                    do {
                                        if let errorJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                            print("📊 Error JSON Structure:")
                                            for (key, value) in errorJson {
                                                print("   \(key): \(value)")
                                            }
                                            
                                            // Verificar se há mensagens de validação específicas
                                            if let message = errorJson["message"] as? String {
                                                print("🚨 API Error Message: \(message)")
                                            }
                                            if let errors = errorJson["errors"] as? [String: Any] {
                                                print("🚨 Validation Errors:")
                                                for (field, error) in errors {
                                                    print("   \(field): \(error)")
                                                }
                                            }
                                        }
                                    } catch {
                                        print("⚠️ Could not parse error JSON: \(error)")
                                    }
                                }
                                
                                // Vamos tentar diferentes formatos de corpo da requisição
                                print("🔄 Tentando formato alternativo da requisição...")
                                
                                // Formato 1: Tentar com diferentes nomes de campos
                                let alternativeRequest1 = [
                                    "eventId": request.eventId,  // camelCase
                                    "name": request.name,
                                    "price": request.price,
                                    "ticketType": request.ticketType.rawValue,  // camelCase
                                    "validUntil": ISO8601DateFormatter().string(from: request.validUntil)  // camelCase
                                ] as [String : Any]
                                
                                print("🔄 Tentativa com camelCase...")
                                print("   Body: \(alternativeRequest1)")
                                
                                if let alternativeData1 = try? JSONSerialization.data(withJSONObject: alternativeRequest1) {
                                    var alternativeUrlRequest1 = urlRequest
                                    alternativeUrlRequest1.httpBody = alternativeData1
                                    
                                    let (altData1, altResponse1) = try await URLSession.shared.data(for: alternativeUrlRequest1)
                                    
                                    if let altHttpResponse1 = altResponse1 as? HTTPURLResponse {
                                        print("📡 Alternative 1 HTTP Status: \(altHttpResponse1.statusCode)")
                                        
                                        if altHttpResponse1.statusCode >= 200 && altHttpResponse1.statusCode < 300 {
                                            print("✅ Alternative 1 worked! Processing response...")
                                            data = altData1
                                            // Continue com o processamento normal abaixo
                                        } else {
                                            if let altErrorString = String(data: altData1, encoding: .utf8) {
                                                print("📄 Alternative 1 Error: \(altErrorString)")
                                            }
                                            
                                            // Formato 2: Tentar sem campos opcionais
                                            print("🔄 Tentativa sem campos opcionais...")
                                            let alternativeRequest2 = [
                                                "event_id": request.eventId,
                                                "name": request.name,
                                                "price": request.price,
                                                "ticket_type": request.ticketType.rawValue
                                                // Removemos validUntil para ver se é obrigatório
                                            ] as [String : Any]
                                            
                                            print("   Body: \(alternativeRequest2)")
                                            
                                            if let alternativeData2 = try? JSONSerialization.data(withJSONObject: alternativeRequest2) {
                                                var alternativeUrlRequest2 = urlRequest
                                                alternativeUrlRequest2.httpBody = alternativeData2
                                                
                                                let (altData2, altResponse2) = try await URLSession.shared.data(for: alternativeUrlRequest2)
                                                
                                                if let altHttpResponse2 = altResponse2 as? HTTPURLResponse {
                                                    print("📡 Alternative 2 HTTP Status: \(altHttpResponse2.statusCode)")
                                                    
                                                    if altHttpResponse2.statusCode >= 200 && altHttpResponse2.statusCode < 300 {
                                                        print("✅ Alternative 2 worked! Processing response...")
                                                        data = altData2
                                                        // Continue com o processamento normal
                                                    } else {
                                                        if let altErrorString = String(data: altData2, encoding: .utf8) {
                                                            print("📄 Alternative 2 Error: \(altErrorString)")
                                                        }
                                                        throw NetworkError.serverError(httpResponse.statusCode)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                throw NetworkError.serverError(httpResponse.statusCode)
                            }
                        }
                    }
                    
                    // Analisar resposta bruta (só se chegamos aqui, significa que a requisição foi bem-sucedida)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📄 Raw API Response:")
                        print(jsonString)
                        
                        // Tentar identificar a estrutura da resposta
                        if jsonString.contains("\"id\"") {
                            print("✅ Response contains ID field")
                        }
                        if jsonString.contains("\"name\"") {
                            print("✅ Response contains name field")
                        }
                        if jsonString.contains("\"price\"") {
                            print("✅ Response contains price field")
                        }
                        if jsonString.contains("\"data\"") {
                            print("⚠️ Response appears to be wrapped in 'data' field")
                        }
                        if jsonString.contains("\"ticket\"") {
                            print("⚠️ Response appears to be wrapped in 'ticket' field")
                        }
                        if jsonString.contains("\"success\"") {
                            print("⚠️ Response contains success field")
                        }
                        if jsonString.contains("\"message\"") {
                            print("⚠️ Response contains message field")
                        }
                    } else {
                        print("⚠️ Could not convert response data to string")
                    }
                    
                    // Estratégia 1: Tentar decodificar como CreateTicketResponse
                    print("🔄 Tentativa 1: Decodificar como CreateTicketResponse...")
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let createResponse = try decoder.decode(CreateTicketResponse.self, from: data)
                        let ticket = createResponse.toTicket()
                        print("✅ Sucesso com CreateTicketResponse!")
                        return ticket
                    } catch let error1 {
                        print("❌ CreateTicketResponse failed: \(error1)")
                        if let decodingError = error1 as? DecodingError {
                            print("   Detailed error: \(decodingError)")
                        }
                    }
                    
                    // Estratégia 2: Tentar decodificar como Ticket direto
                    print("🔄 Tentativa 2: Decodificar como Ticket direto...")
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let ticket = try decoder.decode(Ticket.self, from: data)
                        print("✅ Sucesso com Ticket direto!")
                        return ticket
                    } catch let error2 {
                        print("❌ Ticket direto failed: \(error2)")
                        if let decodingError = error2 as? DecodingError {
                            print("   Detailed error: \(decodingError)")
                        }
                    }
                    
                    // Estratégia 3: Tentar decodificar como wrapper genérico
                    print("🔄 Tentativa 3: Decodificar como wrapper genérico...")
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let wrapper = try decoder.decode(APISingleResponse<CreateTicketResponse>.self, from: data)
                        if let createResponse = wrapper.finalData {
                            let ticket = createResponse.toTicket()
                            print("✅ Sucesso com wrapper CreateTicketResponse!")
                            return ticket
                        }
                    } catch let error3 {
                        print("❌ Wrapper CreateTicketResponse failed: \(error3)")
                    }
                    
                    // Estratégia 4: Tentar decodificar como wrapper de Ticket
                    print("🔄 Tentativa 4: Decodificar como wrapper de Ticket...")
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let wrapper = try decoder.decode(APISingleResponse<Ticket>.self, from: data)
                        if let ticket = wrapper.finalData {
                            print("✅ Sucesso com wrapper Ticket!")
                            return ticket
                        }
                    } catch let error4 {
                        print("❌ Wrapper Ticket failed: \(error4)")
                    }
                    
                    // Estratégia 5: Tentar decodificar como JSON genérico para debug
                    print("🔄 Tentativa 5: Analisar como JSON genérico...")
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                        print("📊 JSON Structure Analysis:")
                        
                        if let dict = jsonObject as? [String: Any] {
                            print("   Root is dictionary with keys: \(dict.keys.sorted())")
                            
                            for (key, value) in dict {
                                print("   \(key): \(type(of: value))")
                                if let stringValue = value as? String {
                                    print("     String value: \(stringValue)")
                                } else if let numberValue = value as? NSNumber {
                                    print("     Number value: \(numberValue)")
                                } else if let boolValue = value as? Bool {
                                    print("     Bool value: \(boolValue)")
                                } else if let nestedDict = value as? [String: Any] {
                                    print("     Nested dict keys: \(nestedDict.keys.sorted())")
                                }
                            }
                            
                            // Tentar criar ticket manualmente baseado no que encontramos
                            print("🔄 Tentativa 6: Criar ticket manualmente...")
                            let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") ?? "api-user"
                            
                            var ticket = Ticket(
                                eventId: request.eventId,
                                sellerId: currentUserId,
                                name: request.name,
                                price: request.price,
                                ticketType: request.ticketType,
                                validUntil: request.validUntil
                            )
                            
                            // Tentar extrair ID da resposta se disponível
                            if let responseId = dict["id"] as? String {
                                ticket.id = responseId
                                print("   ✅ Extracted ID from response: \(responseId)")
                            }
                            
                            print("✅ Ticket criado manualmente com dados da API!")
                            return ticket
                        }
                    } catch {
                        print("❌ JSON generic analysis failed: \(error)")
                    }
                    
                    // Se tudo falhar, lançar erro
                    throw NetworkError.decodingError
                    
                } catch let networkError as NetworkError {
                    print("❌ API falhou com NetworkError: \(networkError)")
                    print("   Error description: \(networkError.errorDescription ?? "Unknown")")
                    
                    // Como último recurso, criar ticket localmente
                    print("🔄 Criando ticket localmente como fallback...")
                    
                    let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") ?? "local-user"
                    
                    let localTicket = Ticket(
                        eventId: request.eventId,
                        sellerId: currentUserId,
                        name: request.name,
                        price: request.price,
                        ticketType: request.ticketType,
                        validUntil: request.validUntil
                    )
                    
                    print("✅ Ticket criado localmente:")
                    print("   ID: \(localTicket.id)")
                    print("   Nome: \(localTicket.name)")
                    print("   Preço: \(localTicket.price)")
                    
                    return localTicket
                    
                } catch {
                    print("❌ Create ticket failed with unexpected error: \(error)")
                    print("   Error type: \(type(of: error))")
                    print("   Error description: \(error.localizedDescription)")
                    
                    // Como último recurso, criar ticket local
                    print("🔄 Criando ticket localmente devido a erro inesperado...")
                    
                    let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") ?? "local-user"
                    
                    let localTicket = Ticket(
                        eventId: request.eventId,
                        sellerId: currentUserId,
                        name: request.name,
                        price: request.price,
                        ticketType: request.ticketType,
                        validUntil: request.validUntil
                    )
                    
                    print("✅ Ticket criado localmente como backup")
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
