import Foundation

// MARK: - Review Domain Model

public struct Review: Codable, Identifiable, Equatable {
  public var id: String
  public var negotiationId: String
  public var reviewerId: String
  public var reviewedId: String
  public var rating: Int
  public var comment: String?
  public var status: String
  public var moderatedAt: Date?
  public var moderatedBy: String?
  public var moderationNotes: String?
  public var createdAt: Date
  public var updatedAt: Date
  public var reviewer: User?
  public var reviewed: User?
  
  public init(
    id: String = UUID().uuidString,
    negotiationId: String,
    reviewerId: String,
    reviewedId: String,
    rating: Int,
    comment: String? = nil,
    status: String = "active",
    moderatedAt: Date? = nil,
    moderatedBy: String? = nil,
    moderationNotes: String? = nil,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.id = id
    self.negotiationId = negotiationId
    self.reviewerId = reviewerId
    self.reviewedId = reviewedId
    self.rating = rating
    self.comment = comment
    self.status = status
    self.moderatedAt = moderatedAt
    self.moderatedBy = moderatedBy
    self.moderationNotes = moderationNotes
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
  
  enum CodingKeys: String, CodingKey {
    case id, rating, comment, status, reviewer, reviewed
    case negotiationId = "negotiation_id"
    case reviewerId = "reviewer_id"
    case reviewedId = "reviewed_id"
    case moderatedAt = "moderated_at"
    case moderatedBy = "moderated_by"
    case moderationNotes = "moderation_notes"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
}

