import Foundation

public struct APIError: Error, Codable, Equatable {
    public let message: String
    public let code: Int
    
    public init(message: String, code: Int) {
        self.message = message
        self.code = code
    }
}