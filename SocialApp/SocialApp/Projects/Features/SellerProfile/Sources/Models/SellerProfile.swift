import Foundation

public struct SellerProfile: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var title: String?
    public var profileImageURL: String?
    public var followersCount: Int
    public var followingCount: Int
    public var ticketsCount: Int
    public var isVerified: Bool
    public var tickets: [Ticket]
    
    public init(name: String, title: String? = nil, profileImageURL: String? = nil) {
        self.id = UUID()
        self.name = name
        self.title = title
        self.profileImageURL = profileImageURL
        self.followersCount = 0
        self.followingCount = 0
        self.ticketsCount = 0
        self.isVerified = false
        self.tickets = []
    }
}