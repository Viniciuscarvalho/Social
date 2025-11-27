import Foundation
import Domain

// MARK: - Auth Request Models

public struct LoginRequest: Codable {
  public let email: String
  public let password: String
  
  public init(email: String, password: String) {
    self.email = email
    self.password = password
  }
}

public struct RegisterRequest: Codable {
  public let name: String
  public let email: String
  public let password: String
  
  public init(name: String, email: String, password: String) {
    self.name = name
    self.email = email
    self.password = password
  }
}

public struct UserUpdateRequest: Codable {
  public let name: String?
  public let title: String?
  public let bio: String?
  public let profileImageURL: String?
  public let interests: [String]?
  
  public init(
    name: String? = nil,
    title: String? = nil,
    bio: String? = nil,
    profileImageURL: String? = nil,
    interests: [String]? = nil
  ) {
    self.name = name
    self.title = title
    self.bio = bio
    self.profileImageURL = profileImageURL
    self.interests = interests
  }
  
  enum CodingKeys: String, CodingKey {
    case name, title, bio, interests
    case profileImageURL = "profile_image_url"
  }
}

// MARK: - Auth Response Models

public struct AuthResponse: Codable, Equatable {
  public let user: User
  public let token: String
  public let refreshToken: String?
  
  public init(user: User, token: String, refreshToken: String? = nil) {
    self.user = user
    self.token = token
    self.refreshToken = refreshToken
  }
}

// MARK: - User Response Models

public struct UserResponse: Codable, Equatable {
  public let user: User
  public let tickets: [Ticket]
  
  public init(user: User, tickets: [Ticket] = []) {
    self.user = user
    self.tickets = tickets
  }
  
  public func toUser() -> User {
    return user
  }
}

public struct UsersListResponse: Codable, Equatable {
  public let users: [User]
  public let total: Int
  
  public init(users: [User], total: Int) {
    self.users = users
    self.total = total
  }
}

public struct FollowResponse: Codable, Equatable {
  public let isFollowing: Bool
  public let followersCount: Int
  
  public init(isFollowing: Bool, followersCount: Int) {
    self.isFollowing = isFollowing
    self.followersCount = followersCount
  }
}

// MARK: - API User DTO

public struct APIUserResponse: Codable {
  let id: String
  let name: String
  let title: String?
  let profileImageURL: String?
  let profile_image_url: String?
  let email: String?
  let followersCount: Int?
  let followers_count: Int?
  let followingCount: Int?
  let following_count: Int?
  let ticketsCount: Int?
  let tickets_count: Int?
  let isVerified: Bool?
  let is_verified: Bool?
  let tickets: [APITicketResponse]?
  let createdAt: String?
  let created_at: String?
  let verification: APIUserVerificationResponse?
  
  var finalProfileImageURL: String? {
    return profileImageURL ?? profile_image_url
  }
  
  var finalFollowersCount: Int {
    return followersCount ?? followers_count ?? 0
  }
  
  var finalFollowingCount: Int {
    return followingCount ?? following_count ?? 0
  }
  
  var finalTicketsCount: Int {
    return ticketsCount ?? tickets_count ?? 0
  }
  
  var finalIsVerified: Bool {
    return isVerified ?? is_verified ?? false
  }
  
  var finalCreatedAt: String? {
    return createdAt ?? created_at
  }
}

// MARK: - Mapper: APIUserResponse -> User

extension APIUserResponse {
  public func toUser() -> User {
    var user = User(
      name: self.name,
      title: self.title,
      profileImageURL: self.finalProfileImageURL,
      email: self.email
    )
    
    user.id = self.id
    user.followersCount = self.finalFollowersCount
    user.followingCount = self.finalFollowingCount
    user.ticketsCount = self.finalTicketsCount
    user.isVerified = self.finalIsVerified
    
    // Converte os tickets se existirem
    if let apiTickets = self.tickets {
      user.tickets = apiTickets.map { $0.toTicket() }
    }
    
    // Converte a verificação se existir
    if let apiVerification = self.verification {
      user.verification = apiVerification.toUserVerification()
    }
    
    // Parse da data de criação
    if let createdAtString = self.finalCreatedAt, !createdAtString.isEmpty {
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      
      let dateFormats = [
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
        "yyyy-MM-dd HH:mm:ss",
        "yyyy-MM-dd"
      ]
      
      for format in dateFormats {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: createdAtString) {
          user.createdAt = date
          break
        }
      }
    }
    
    return user
  }
}

// MARK: - API User Verification DTO

public struct APIUserVerificationResponse: Codable {
  let id: String?
  let emailVerified: Bool?
  let email_verified: Bool?
  let emailVerifiedAt: String?
  let email_verified_at: String?
  let phoneVerified: Bool?
  let phone_verified: Bool?
  let phoneVerifiedAt: String?
  let phone_verified_at: String?
  let phoneNumber: String?
  let phone_number: String?
  let documentType: String?
  let document_type: String?
  let documentFileUrl: String?
  let document_file_url: String?
  let documentVerified: Bool?
  let document_verified: Bool?
  let documentVerifiedAt: String?
  let document_verified_at: String?
  let documentVerifiedBy: String?
  let document_verified_by: String?
  let verificationLevel: String?
  let verification_level: String?
  let trustScore: Int?
  let trust_score: Int?
  let createdAt: String?
  let created_at: String?
  let updatedAt: String?
  let updated_at: String?
}

// MARK: - Mapper: APIUserVerificationResponse -> UserVerification

extension APIUserVerificationResponse {
  public func toUserVerification() -> UserVerification {
    let parseDate: (String?) -> Date? = { dateString in
      guard let dateString = dateString, !dateString.isEmpty else { return nil }
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      let formats = [
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
        "yyyy-MM-dd"
      ]
      for format in formats {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: dateString) {
          return date
        }
      }
      return nil
    }
    
    let level = VerificationLevel(rawValue: verificationLevel ?? verification_level ?? "unverified") ?? .unverified
    
    return UserVerification(
      id: id ?? UUID().uuidString,
      emailVerified: emailVerified ?? email_verified ?? false,
      emailVerifiedAt: parseDate(emailVerifiedAt ?? email_verified_at),
      phoneVerified: phoneVerified ?? phone_verified ?? false,
      phoneVerifiedAt: parseDate(phoneVerifiedAt ?? phone_verified_at),
      phoneNumber: phoneNumber ?? phone_number,
      documentType: documentType ?? document_type,
      documentFileUrl: documentFileUrl ?? document_file_url,
      documentVerified: documentVerified ?? document_verified ?? false,
      documentVerifiedAt: parseDate(documentVerifiedAt ?? document_verified_at),
      documentVerifiedBy: documentVerifiedBy ?? document_verified_by,
      verificationLevel: level,
      trustScore: trustScore ?? trust_score ?? 0,
      createdAt: parseDate(createdAt ?? created_at) ?? Date(),
      updatedAt: parseDate(updatedAt ?? updated_at) ?? Date()
    )
  }
}

