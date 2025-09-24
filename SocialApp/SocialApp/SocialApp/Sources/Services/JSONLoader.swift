import Foundation

enum JSONLoaderError: Error {
    case fileNotFound(String)
    case decodingFailed(String)
}

func loadEventsFromJSON() async throws -> [Event] {
    guard let url = Bundle.main.url(forResource: "events", withExtension: "json") else {
        throw JSONLoaderError.fileNotFound("events.json not found")
    }
    
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    do {
        let events = try decoder.decode([Event].self, from: data)
        return events
    } catch {
        throw JSONLoaderError.decodingFailed("Failed to decode events: \(error.localizedDescription)")
    }
}

func loadTicketsFromJSON() async throws -> [Ticket] {
    print("📁 Tentando carregar tickets.json...")
    guard let url = Bundle.main.url(forResource: "tickets", withExtension: "json") else {
        print("❌ tickets.json não encontrado no bundle")
        throw APIError(message: "tickets.json not found", code: 404)
    }
    
    print("✅ Arquivo encontrado: \(url.path)")
    let data = try Data(contentsOf: url)
    print("📊 Tamanho dos dados: \(data.count) bytes")
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    do {
        let tickets = try decoder.decode([Ticket].self, from: data)
        print("✅ Tickets decodificados com sucesso: \(tickets.count) tickets")
        return tickets
    } catch {
        print("❌ Erro ao decodificar tickets: \(error.localizedDescription)")
        if let decodingError = error as? DecodingError {
            print("🔍 Detalhes do erro de decodificação: \(decodingError)")
        }
        throw APIError(message: "Failed to decode tickets: \(error.localizedDescription)", code: 500)
    }
}

func loadCurrentUserFromJSON() async throws -> User {
    guard let url = Bundle.main.url(forResource: "user", withExtension: "json") else {
        throw JSONLoaderError.fileNotFound("user.json not found")
    }
    
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    do {
        let user = try decoder.decode(User.self, from: data)
        return user
    } catch {
        throw JSONLoaderError.decodingFailed("Failed to decode user: \(error.localizedDescription)")
    }
}
