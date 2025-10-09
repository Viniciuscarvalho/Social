import Foundation

import Foundation

enum JSONLoaderError: Error {
    case fileNotFound(String)
    case decodingFailed(String)
}

func loadEventsFromJSON() async throws -> [Event] {
    print("📁 === Carregando events.json (fallback) ===")
    
    guard let url = Bundle.main.url(forResource: "events", withExtension: "json") else {
        print("❌ events.json não encontrado no bundle principal")
        
        // Lista todos os arquivos .json no bundle para debug
        let allJSONFiles = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        print("📄 Arquivos .json disponíveis no bundle:")
        for jsonFile in allJSONFiles {
            print("   - \(jsonFile.lastPathComponent)")
        }
        
        throw JSONLoaderError.fileNotFound("events.json not found in main bundle")
    }
    
    print("✅ Arquivo encontrado: \(url.path)")
    
    do {
        let data = try Data(contentsOf: url)
        print("📊 Dados carregados: \(data.count) bytes")
        
        // Mostra uma prévia do JSON para debug
        if let jsonString = String(data: data, encoding: .utf8) {
            let preview = String(jsonString.prefix(300))
            print("📄 Prévia do JSON: \(preview)...")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let events = try decoder.decode([Event].self, from: data)
        print("✅ Events decodificados com sucesso: \(events.count) events")
        
        // Log dos primeiros eventos para verificação
        for (index, event) in events.prefix(3).enumerated() {
            print("  [\(index)] \(event.name) - \(event.category.rawValue)")
        }
        
        return events
        
    } catch let decodingError as DecodingError {
        print("❌ Erro específico de decodificação:")
        switch decodingError {
        case .keyNotFound(let key, let context):
            print("   Chave não encontrada: \(key.stringValue)")
            print("   Contexto: \(context.debugDescription)")
        case .typeMismatch(let type, let context):
            print("   Tipo incorreto: esperado \(type)")
            print("   Contexto: \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            print("   Valor não encontrado para tipo: \(type)")
            print("   Contexto: \(context.debugDescription)")
        case .dataCorrupted(let context):
            print("   Dados corrompidos: \(context.debugDescription)")
        @unknown default:
            print("   Erro de decodificação desconhecido: \(decodingError)")
        }
        throw JSONLoaderError.decodingFailed("Failed to decode events: \(decodingError.localizedDescription)")
        
    } catch {
        print("❌ Erro geral ao carregar events.json: \(error)")
        throw JSONLoaderError.decodingFailed("Failed to load events: \(error.localizedDescription)")
    }
}

func loadTicketsFromJSON() async throws -> [Ticket] {
    print("📁 === Carregando tickets.json (fallback) ===")
    
    guard let url = Bundle.main.url(forResource: "tickets", withExtension: "json") else {
        print("❌ tickets.json não encontrado no bundle principal")
        
        // Lista todos os arquivos .json no bundle para debug
        let allJSONFiles = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        print("📄 Arquivos .json disponíveis no bundle:")
        for jsonFile in allJSONFiles {
            print("   - \(jsonFile.lastPathComponent)")
        }
        
        throw NetworkError.notFound
    }
    
    print("✅ Arquivo encontrado: \(url.path)")
    
    do {
        let data = try Data(contentsOf: url)
        print("📊 Dados carregados: \(data.count) bytes")
        
        // Mostra uma prévia do JSON para debug
        if let jsonString = String(data: data, encoding: .utf8) {
            let preview = String(jsonString.prefix(300))
            print("📄 Prévia do JSON: \(preview)...")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let tickets = try decoder.decode([Ticket].self, from: data)
        print("✅ Tickets decodificados com sucesso: \(tickets.count) tickets")
        
        // Log dos primeiros tickets para verificação
        for (index, ticket) in tickets.prefix(3).enumerated() {
            print("  [\(index)] \(ticket.name) - R$ \(ticket.price)")
        }
        
        return tickets
        
    } catch let decodingError as DecodingError {
        print("❌ Erro específico de decodificação:")
        switch decodingError {
        case .keyNotFound(let key, let context):
            print("   Chave não encontrada: \(key.stringValue)")
            print("   Contexto: \(context.debugDescription)")
        case .typeMismatch(let type, let context):
            print("   Tipo incorreto: esperado \(type)")
            print("   Contexto: \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            print("   Valor não encontrado para tipo: \(type)")
            print("   Contexto: \(context.debugDescription)")
        case .dataCorrupted(let context):
            print("   Dados corrompidos: \(context.debugDescription)")
        @unknown default:
            print("   Erro de decodificação desconhecido: \(decodingError)")
        }
        throw NetworkError.decodingError
        
    } catch {
        print("❌ Erro geral ao carregar tickets.json: \(error)")
        throw NetworkError.decodingError
    }
}

func loadCurrentUserFromJSON() async throws -> User {
    print("📁 === Carregando user.json (fallback) ===")
    
    guard let url = Bundle.main.url(forResource: "user", withExtension: "json") else {
        print("❌ user.json não encontrado no bundle principal")
        throw JSONLoaderError.fileNotFound("user.json not found in main bundle")
    }
    
    print("✅ Arquivo encontrado: \(url.path)")
    
    do {
        let data = try Data(contentsOf: url)
        print("📊 Dados carregados: \(data.count) bytes")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let user = try decoder.decode(User.self, from: data)
        print("✅ User decodificado com sucesso: \(user.name)")
        return user
        
    } catch {
        print("❌ Erro ao carregar user.json: \(error)")
        throw JSONLoaderError.decodingFailed("Failed to decode user: \(error.localizedDescription)")
    }
}
