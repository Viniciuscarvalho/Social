import Foundation
import Domain

// MARK: - API Event DTO

public struct APIEventResponse: Codable {
  let id: String
  let name: String
  let description: String?
  let imageURL: String?
  let image_url: String?
  let startPrice: Double?
  let start_price: Double?
  let location: APILocationResponse
  let category: String
  let isRecommended: Bool?
  let is_recommended: Bool?
  let rating: Double?
  let reviewCount: Int?
  let review_count: Int?
  let createdAt: String?
  let created_at: String?
  let eventDate: String?
  let event_date: String?
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try container.decode(String.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    description = try? container.decode(String.self, forKey: .description)
    imageURL = try? container.decode(String.self, forKey: .imageURL)
    image_url = try? container.decode(String.self, forKey: .image_url)
    startPrice = try? container.decode(Double.self, forKey: .startPrice)
    start_price = try? container.decode(Double.self, forKey: .start_price)
    location = try container.decode(APILocationResponse.self, forKey: .location)
    category = (try? container.decode(String.self, forKey: .category)) ?? "culture"
    isRecommended = try? container.decode(Bool.self, forKey: .isRecommended)
    is_recommended = try? container.decode(Bool.self, forKey: .is_recommended)
    rating = try? container.decode(Double.self, forKey: .rating)
    reviewCount = try? container.decode(Int.self, forKey: .reviewCount)
    review_count = try? container.decode(Int.self, forKey: .review_count)
    createdAt = try? container.decode(String.self, forKey: .createdAt)
    created_at = try? container.decode(String.self, forKey: .created_at)
    eventDate = try? container.decode(String.self, forKey: .eventDate)
    event_date = try? container.decode(String.self, forKey: .event_date)
  }
  
  enum CodingKeys: String, CodingKey {
    case id, name, description, rating, location, category
    case imageURL = "imageUrl"
    case image_url
    case startPrice
    case start_price
    case isRecommended
    case is_recommended
    case reviewCount
    case review_count
    case createdAt
    case created_at
    case eventDate
    case event_date
  }
  
  var finalImageURL: String? {
    return imageURL ?? image_url
  }
  
  var finalStartPrice: Double {
    return startPrice ?? start_price ?? 0.0
  }
  
  var finalIsRecommended: Bool {
    return isRecommended ?? is_recommended ?? false
  }
  
  var finalReviewCount: Int? {
    return reviewCount ?? review_count
  }
  
  var finalCreatedAt: String? {
    return createdAt ?? created_at
  }
  
  var finalEventDate: String? {
    return eventDate ?? event_date
  }
}

// MARK: - Mapper: APIEventResponse -> Event

extension APIEventResponse {
  public func toEvent() -> Event {
    var event = Event(
      name: self.name,
      description: self.description,
      imageURL: self.finalImageURL,
      startPrice: self.finalStartPrice,
      location: self.location.toLocation(),
      category: EventCategory(rawValue: self.category) ?? .culture,
      isRecommended: self.finalIsRecommended
    )
    
    event.id = self.id
    event.rating = self.rating
    event.reviewCount = self.finalReviewCount
    
    // Parse das datas
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    let dateFormats = [
      "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
      "yyyy-MM-dd'T'HH:mm:ssZ",
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy-MM-dd"
    ]
    
    if let createdAtString = self.finalCreatedAt {
      for format in dateFormats {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: createdAtString) {
          event.createdAt = date
          break
        }
      }
    }
    
    if let eventDateString = self.finalEventDate {
      for format in dateFormats {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: eventDateString) {
          event.eventDate = date
          break
        }
      }
    }
    
    return event
  }
}

// MARK: - API Location DTO

public struct APILocationResponse: Codable {
  let name: String
  let address: String?
  let city: String
  let state: String
  let country: String
  let coordinate: APICoordinateResponse?
  let coordinates: APICoordinateResponse?
  
  var finalCoordinate: APICoordinateResponse {
    return coordinate ?? coordinates ?? APICoordinateResponse(latitude: 0.0, longitude: 0.0)
  }
}

// MARK: - Mapper: APILocationResponse -> Location

extension APILocationResponse {
  public func toLocation() -> Location {
    return Location(
      name: self.name,
      address: self.address,
      city: self.city,
      state: self.state,
      country: self.country,
      coordinate: self.finalCoordinate.toCoordinate()
    )
  }
}

// MARK: - API Coordinate DTO

public struct APICoordinateResponse: Codable {
  let latitude: Double
  let longitude: Double
}

// MARK: - Mapper: APICoordinateResponse -> Coordinate

extension APICoordinateResponse {
  public func toCoordinate() -> Coordinate {
    return Coordinate(latitude: self.latitude, longitude: self.longitude)
  }
}

