import Foundation

/// Utilitário para testar e debugar a conectividade e parsing da API
public actor APITester {
    
    /// Testa a conectividade básica da API
    public static func testAPIConnection() async {
        print("🧪 === Iniciando Teste de Conectividade da API ===")
        
        // Testa conectividade básica
        await testBasicConnectivity()
        
        // Testa endpoints específicos
        await testEventsEndpoint()
        await testTicketsEndpoint()
        
        print("🧪 === Teste de Conectividade Finalizado ===")
    }
    
    private static func testBasicConnectivity() async {
        print("\n🌐 Testando conectividade básica...")
        
        guard let url = URL(string: NetworkConfig.baseURL) else {
            print("❌ URL base inválida: \(NetworkConfig.baseURL)")
            return
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Servidor respondeu com status: \(httpResponse.statusCode)")
            } else {
                print("❌ Resposta inválida do servidor")
            }
        } catch {
            print("❌ Erro de conectividade: \(error.localizedDescription)")
        }
    }
    
    private static func testEventsEndpoint() async {
        print("\n📅 Testando endpoint de eventos...")
        
        let fullURL = "\(NetworkConfig.baseURL)\(NetworkConfig.apiPath)/events"
        print("🔗 URL: \(fullURL)")
        
        guard let url = URL(string: fullURL) else {
            print("❌ URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Status HTTP: \(httpResponse.statusCode)")
                print("📋 Headers: \(httpResponse.allHeaderFields)")
            }
            
            print("📦 Tamanho da resposta: \(data.count) bytes")
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Primeiros 500 caracteres da resposta:")
                let preview = String(jsonString.prefix(500))
                print(preview)
                
                if jsonString.count > 500 {
                    print("... (truncado)")
                }
                
                // Tenta fazer parsing básico
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("✅ JSON válido (objeto)")
                        print("🔑 Chaves principais: \(Array(jsonObject.keys))")
                    } else if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        print("✅ JSON válido (array com \(jsonArray.count) items)")
                        if let firstItem = jsonArray.first {
                            print("🔑 Chaves do primeiro item: \(Array(firstItem.keys))")
                        }
                    }
                } catch {
                    print("❌ Erro no parsing básico do JSON: \(error)")
                }
                
                // Tenta fazer parsing com APIEventResponse
                do {
                    let decoder = JSONDecoder()
                    let apiEvents = try decoder.decode([APIEventResponse].self, from: data)
                    print("✅ Parsing com APIEventResponse bem-sucedido: \(apiEvents.count) eventos")
                } catch {
                    print("❌ Erro no parsing com APIEventResponse: \(error)")
                    if let decodingError = error as? DecodingError {
                        printDecodingError(decodingError)
                    }
                }
                
            } else {
                print("❌ Não foi possível converter resposta para string")
            }
            
        } catch {
            print("❌ Erro na requisição: \(error.localizedDescription)")
        }
    }
    
    private static func testTicketsEndpoint() async {
        print("\n🎫 Testando endpoint de tickets...")
        
        let fullURL = "\(NetworkConfig.baseURL)\(NetworkConfig.apiPath)/tickets"
        print("🔗 URL: \(fullURL)")
        
        guard let url = URL(string: fullURL) else {
            print("❌ URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Status HTTP: \(httpResponse.statusCode)")
            }
            
            print("📦 Tamanho da resposta: \(data.count) bytes")
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Primeiros 500 caracteres da resposta:")
                let preview = String(jsonString.prefix(500))
                print(preview)
                
                // Tenta fazer parsing com APITicketResponse
                do {
                    let decoder = JSONDecoder()
                    let apiTickets = try decoder.decode([APITicketResponse].self, from: data)
                    print("✅ Parsing com APITicketResponse bem-sucedido: \(apiTickets.count) tickets")
                } catch {
                    print("❌ Erro no parsing com APITicketResponse: \(error)")
                    if let decodingError = error as? DecodingError {
                        printDecodingError(decodingError)
                    }
                }
            }
            
        } catch {
            print("❌ Erro na requisição: \(error.localizedDescription)")
        }
    }
    
    private static func printDecodingError(_ error: DecodingError) {
        print("🔍 Detalhes do erro de decodificação:")
        
        switch error {
        case .typeMismatch(let type, let context):
            print("   • Type mismatch: esperado \(type)")
            print("   • Context: \(context)")
            print("   • Caminho: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            
        case .valueNotFound(let type, let context):
            print("   • Value not found: \(type)")
            print("   • Context: \(context)")
            print("   • Caminho: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            
        case .keyNotFound(let key, let context):
            print("   • Key not found: \(key.stringValue)")
            print("   • Context: \(context)")
            print("   • Caminho: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            print("   • Chaves disponíveis: \(context.codingPath)")
            
        case .dataCorrupted(let context):
            print("   • Data corrupted")
            print("   • Context: \(context)")
            print("   • Caminho: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            
        @unknown default:
            print("   • Unknown decoding error: \(error)")
        }
    }
    
    /// Testa o parsing de um JSON específico
    public static func testJSONParsing<T: Codable>(
        jsonString: String,
        type: T.Type,
        description: String
    ) {
        print("\n🧪 Testando parsing de \(description)...")
        
        guard let data = jsonString.data(using: .utf8) else {
            print("❌ Não foi possível converter string para Data")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(type, from: data)
            print("✅ Parsing bem-sucedido para \(description)")
            print("📊 Resultado: \(result)")
        } catch {
            print("❌ Erro no parsing de \(description): \(error)")
            if let decodingError = error as? DecodingError {
                printDecodingError(decodingError)
            }
        }
    }
}

// MARK: - Extensão para facilitar o uso nos testes

extension APITester {
    
    /// Executa um teste completo da API
    public static func runFullAPITest() async {
        print("🧪 === TESTE COMPLETO DA API ===")
        print("Timestamp: \(Date())")
        print("Base URL: \(NetworkConfig.baseURL)")
        print("API Path: \(NetworkConfig.apiPath)")
        print("=====================================")
        
        await testAPIConnection()
        
        // Testa os clients reais
        await testEventsClient()
        await testTicketsClient()
        
        print("\n🧪 === TESTE COMPLETO FINALIZADO ===")
    }
    
    private static func testEventsClient() async {
        print("\n📅 Testando EventsClient...")
        
        do {
            let apiEvents: [APIEventResponse] = try await NetworkService.shared.request(
                endpoint: "/events",
                method: .GET
            )
            print("✅ EventsClient: \(apiEvents.count) eventos obtidos via API")
            
            let events = apiEvents.map { $0.toEvent() }
            print("✅ EventsClient: Conversão para Event bem-sucedida")
            
        } catch {
            print("❌ EventsClient falhou: \(error)")
        }
    }
    
    private static func testTicketsClient() async {
        print("\n🎫 Testando TicketsClient...")
        
        do {
            let apiTickets: [APITicketResponse] = try await NetworkService.shared.request(
                endpoint: "/tickets",
                method: .GET
            )
            print("✅ TicketsClient: \(apiTickets.count) tickets obtidos via API")
            
            let tickets = apiTickets.map { $0.toTicket() }
            print("✅ TicketsClient: Conversão para Ticket bem-sucedida")
            
        } catch {
            print("❌ TicketsClient falhou: \(error)")
        }
    }
}