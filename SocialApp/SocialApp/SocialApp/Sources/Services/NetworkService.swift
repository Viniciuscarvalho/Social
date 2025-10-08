import Foundation

struct NetworkConfig {
    static let baseURL = "https://ticketplace-api.onrender.com"
    static let apiPath = "/api"
}

// MARK: - Network Error Types

public enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkUnavailable
    case unauthorized
    case forbidden
    case notFound
    case unknown(Error)
    
    // Implementação manual de Equatable para case com Error
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.decodingError, .decodingError),
             (.networkUnavailable, .networkUnavailable),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound):
            return true
            
        case let (.serverError(code1), .serverError(code2)):
            return code1 == code2
            
        case let (.unknown(error1), .unknown(error2)):
            return error1.localizedDescription == error2.localizedDescription
            
        default:
            return false
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "Nenhum dado recebido"
        case .decodingError:
            return "Erro ao processar dados"
        case .serverError(let code):
            return "Erro do servidor (\(code))"
        case .networkUnavailable:
            return "Sem conexão com a internet"
        case .unauthorized:
            return "Não autorizado"
        case .forbidden:
            return "Acesso negado"
        case .notFound:
            return "Recurso não encontrado"
        case .unknown(let error):
            return "Erro desconhecido: \(error.localizedDescription)"
        }
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Network Service

@MainActor
final class NetworkService {
    static let shared = NetworkService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Generic Request Method
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: (any Codable)? = nil,
        queryItems: [URLQueryItem]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        
        guard var urlComponents = URLComponents(string: NetworkConfig.baseURL + NetworkConfig.apiPath + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authentication token if required
        if requiresAuth, let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add request body if provided
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.unknown(error)
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "NetworkError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
            }
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 400:
                throw NetworkError.decodingError
            case 401:
                // Token expirado ou inválido - limpa dados de auth
                UserDefaults.standard.removeObject(forKey: "authToken")
                UserDefaults.standard.removeObject(forKey: "currentUser")
                UserDefaults.standard.removeObject(forKey: "currentUserId")
                throw NetworkError.unauthorized
            case 403:
                throw NetworkError.forbidden
            case 404:
                throw NetworkError.notFound
            case 500...599:
                throw NetworkError.serverError(httpResponse.statusCode)
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            do {
                let result = try decoder.decode(T.self, from: data)
                return result
            } catch {
                print("Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON: \(jsonString)")
                }
                throw NetworkError.decodingError
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.networkUnavailable
            } else {
                throw NetworkError.unknown(error)
            }
        }
    }
}
