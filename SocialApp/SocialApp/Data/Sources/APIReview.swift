import Foundation
import Domain

// MARK: - Review Request Models

public struct CreateReviewRequest: Codable {
  public let negotiationId: String
  public let reviewedId: String
  public let rating: Int
  public let comment: String?
  
  public init(
    negotiationId: String,
    reviewedId: String,
    rating: Int,
    comment: String? = nil
  ) {
    self.negotiationId = negotiationId
    self.reviewedId = reviewedId
    self.rating = rating
    self.comment = comment
  }
  
  enum CodingKeys: String, CodingKey {
    case rating, comment
    case negotiationId = "negotiation_id"
    case reviewedId = "reviewed_id"
  }
}

