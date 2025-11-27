import Foundation

// MARK: - User Domain Model

public struct User: Codable, Identifiable, Equatable {
  public var id: String
  public var name: String
  public var title: String?
  public var profileImageURL: String?
  public var email: String
  public var bio: String?
  public var followersCount: Int
  public var followingCount: Int
  public var ticketsCount: Int
  public var isVerified: Bool
  public var isCertified: Bool
  public var tickets: [Ticket]
  public var createdAt: Date
  public var interests: [String]?
  public var verification: UserVerification?
  
  public init(
    name: String,
    title: String? = nil,
    profileImageURL: String? = nil,
    email: String? = nil,
    bio: String? = nil,
    interests: [String]? = nil
  ) {
    self.id = UUID().uuidString
    self.name = name
    self.title = title
    self.profileImageURL = profileImageURL
    self.email = email ?? ""
    self.bio = bio
    self.followersCount = 0
    self.followingCount = 0
    self.ticketsCount = 0
    self.isVerified = false
    self.isCertified = false
    self.tickets = []
    self.createdAt = Date()
    self.interests = interests
  }
  
  enum CodingKeys: String, CodingKey {
    case id, name, title, email, bio, tickets, interests, verification
    case profileImageURL = "profileImageUrl"
    case followersCount = "followersCount"
    case followingCount = "followingCount"
    case ticketsCount = "ticketsCount"
    case isVerified = "isVerified"
    case isCertified = "isCertified"
    case createdAt = "createdAt"
  }
}

// MARK: - Profile Domain Model

public struct Profile: Codable, Identifiable, Equatable {
  public var id: String
  public var email: String
  public var name: String
  public var avatarUrl: String?
  public var bio: String?
  public var phone: String?
  public var createdAt: Date
  public var updatedAt: Date
  public var totalSpent: Double
  public var eventsAttended: Int
  public var notificationsEnabled: Bool
  public var emailNotifications: Bool
  public var language: String
  
  public init(
    email: String,
    name: String,
    avatarUrl: String? = nil,
    bio: String? = nil,
    phone: String? = nil,
    totalSpent: Double = 0,
    eventsAttended: Int = 0,
    notificationsEnabled: Bool = true,
    emailNotifications: Bool = true,
    language: String = "pt-BR"
  ) {
    self.id = UUID().uuidString
    self.email = email
    self.name = name
    self.avatarUrl = avatarUrl
    self.bio = bio
    self.phone = phone
    self.createdAt = Date()
    self.updatedAt = Date()
    self.totalSpent = totalSpent
    self.eventsAttended = eventsAttended
    self.notificationsEnabled = notificationsEnabled
    self.emailNotifications = emailNotifications
    self.language = language
  }
  
  enum CodingKeys: String, CodingKey {
    case id, email, name, bio, phone, language
    case avatarUrl = "avatar_url"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case totalSpent = "total_spent"
    case eventsAttended = "events_attended"
    case notificationsEnabled = "notifications_enabled"
    case emailNotifications = "email_notifications"
  }
}

