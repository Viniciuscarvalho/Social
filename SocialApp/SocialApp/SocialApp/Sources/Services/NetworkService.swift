import Foundation

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
        // Remove a estratégia de decodificação fixa - vamos tratar manualmente
        
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
                print("❌ Decoding error for endpoint \(endpoint): \(error)")
                
                if let decodingError = error as? DecodingError {
                    print("🔍 Detailed decoding error:")
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("   Type mismatch: expected \(type), context: \(context)")
                    case .valueNotFound(let type, let context):
                        print("   Value not found: \(type), context: \(context)")
                    case .keyNotFound(let key, let context):
                        print("   Key not found: \(key), context: \(context)")
                    case .dataCorrupted(let context):
                        print("   Data corrupted: \(context)")
                    @unknown default:
                        print("   Unknown decoding error")
                    }
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Raw JSON response:")
                    print(jsonString)
                    
                    // Tenta identificar se é uma resposta de erro da API
                    if jsonString.contains("error") || jsonString.contains("message") {
                        print("⚠️  This appears to be an API error response")
                    }
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
    
    // MARK: - Specialized Request for Single Objects (handles both direct object and wrapper object)
    
    func requestSingle<T: Codable>(
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
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Raw response for \(endpoint): \(String(jsonString.prefix(300)))...")
            }
            
            // Primeiro, tenta decodificar como objeto direto
            do {
                let result = try decoder.decode(T.self, from: data)
                print("✅ Successfully decoded as direct object")
                return result
            } catch {
                print("⚠️ Failed to decode as direct object, trying wrapper object...")
                
                // Se falhar, tenta decodificar como objeto wrapper
                do {
                    let wrapper = try decoder.decode(APISingleResponse<T>.self, from: data)
                    
                    if let result = wrapper.finalData {
                        print("✅ Successfully decoded as wrapper object")
                        return result
                    } else {
                        print("❌ Wrapper object decoded but no data found")
                        throw NetworkError.noData
                    }
                } catch {
                    print("❌ Failed to decode both as direct object and wrapper object")
                    print("❌ Direct decode error: \(error)")
                    
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📄 Full JSON response:")
                        print(jsonString)
                    }
                    
                    throw NetworkError.decodingError
                }
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
    
    // MARK: - Specialized Request for Arrays (handles both direct array and wrapper object)
    func requestArray<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: (any Codable)? = nil,
        queryItems: [URLQueryItem]? = nil,
        requiresAuth: Bool = true
    ) async throws -> [T] {
        
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
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Raw response for \(endpoint): \(String(jsonString.prefix(200)))...")
            }
            
            // Primeiro, tenta decodificar como array direto
            do {
                let result = try decoder.decode([T].self, from: data)
                print("✅ Successfully decoded as direct array: \(result.count) items")
                return result
            } catch let arrayError {
                print("⚠️ Failed to decode as direct array, trying wrapper object...")
                
                // Se falhar, tenta decodificar como objeto wrapper
                do {
                    let wrapper = try decoder.decode(APIListResponse<T>.self, from: data)
                    print("✅ Successfully decoded as wrapper object: \(wrapper.finalData.count) items")
                    return wrapper.finalData
                } catch let wrapperError {
                    print("❌ Failed to decode both as array and wrapper object")
                    print("❌ Array decode error: \(arrayError)")
                    print("❌ Wrapper decode error: \(wrapperError)")
                    
                    if let decodingError = wrapperError as? DecodingError {
                        print("🔍 Detailed wrapper decoding error:")
                        switch decodingError {
                        case .typeMismatch(let type, let context):
                            print("   Type mismatch: expected \(type)")
                            print("   Context: \(context.debugDescription)")
                            print("   Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                        case .valueNotFound(let type, let context):
                            print("   Value not found: \(type)")
                            print("   Context: \(context.debugDescription)")
                            print("   Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                        case .keyNotFound(let key, let context):
                            print("   Key not found: \(key.stringValue)")
                            print("   Context: \(context.debugDescription)")
                            print("   Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                        case .dataCorrupted(let context):
                            print("   Data corrupted")
                            print("   Context: \(context.debugDescription)")
                            print("   Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                        @unknown default:
                            print("   Unknown decoding error")
                        }
                    }
                    
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📄 Full JSON response:")
                        print(jsonString)
                    }
                    
                    throw NetworkError.decodingError
                }
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
