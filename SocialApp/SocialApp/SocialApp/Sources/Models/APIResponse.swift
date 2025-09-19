import Foundation

public struct APIResponse<T: Codable>: Codable {
    public let data: T
    public let message: String?
    public let success: Bool
    
    public init(data: T, message: String? = nil, success: Bool = true) {
        self.data = data
        self.message = message
        self.success = success
    }
}