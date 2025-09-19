import Foundation

public struct User: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var profileImageURL: String?
    public var email: String?
    public let createdAt: Date
    
    public init(name: String, profileImageURL: String? = nil, email: String? = nil) {
        self.id = UUID()
        self.name = name
        self.profileImageURL = profileImageURL
        self.email = email
        self.createdAt = Date()
    }
}