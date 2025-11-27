import Foundation

// MARK: - Location Domain Model

public struct Location: Codable, Equatable, Sendable {
  public var name: String
  public var address: String?
  public var city: String
  public var state: String
  public var country: String
  public var coordinate: Coordinate
  
  public init(
    name: String,
    address: String? = nil,
    city: String,
    state: String,
    country: String,
    coordinate: Coordinate
  ) {
    self.name = name
    self.address = address
    self.city = city
    self.state = state
    self.country = country
    self.coordinate = coordinate
  }
}

// MARK: - Coordinate Domain Model

public struct Coordinate: Codable, Equatable, Sendable {
  public let latitude: Double
  public let longitude: Double
  
  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
}

// MARK: - Event Domain Model

public struct Event: Codable, Identifiable, Equatable, Sendable {
  public var id: String
  public var name: String
  public var description: String?
  public var imageURL: String?
  public var startPrice: Double
  public var location: Location
  public var category: EventCategory
  public var isRecommended: Bool
  public var rating: Double?
  public var reviewCount: Int?
  public var createdAt: Date
  public var eventDate: Date?
  
  public init(
    name: String,
    description: String? = nil,
    imageURL: String? = nil,
    startPrice: Double,
    location: Location,
    category: EventCategory,
    isRecommended: Bool = false,
    eventDate: Date? = nil
  ) {
    self.id = UUID().uuidString
    self.name = name
    self.description = description
    self.imageURL = imageURL
    self.startPrice = startPrice
    self.location = location
    self.category = category
    self.isRecommended = isRecommended
    self.rating = nil
    self.reviewCount = nil
    self.createdAt = Date()
    self.eventDate = eventDate
  }
  
  enum CodingKeys: String, CodingKey {
    case id, name, description, location, category, rating
    case imageURL = "imageUrl"
    case startPrice = "startPrice"
    case isRecommended = "isRecommended"
    case reviewCount = "reviewCount"
    case createdAt = "createdAt"
    case eventDate = "eventDate"
  }
}

// MARK: - Event Extensions

extension Event {
  var dateFormatted: String {
    guard let eventDate = eventDate else {
      return "TBD"
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: eventDate).uppercased()
  }
  
  var timeRange: String {
    guard let eventDate = eventDate else {
      return "Horário a definir"
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    let startTime = formatter.string(from: eventDate)
    
    let endDate = Calendar.current.date(byAdding: .hour, value: 3, to: eventDate) ?? eventDate
    let endTime = formatter.string(from: endDate)
    
    return "\(startTime) - \(endTime)"
  }
}

// MARK: - EventCategory Domain Model

public enum EventCategory: String, CaseIterable, Codable, Equatable, Sendable {
  case adventure = "adventure"
  case culture = "culture"
  case food = "food"
  case music = "music"
  case sports = "sports"
  case nature = "nature"
  case technology = "technology"
  case business = "business"
  
  public var displayName: String {
    switch self {
    case .adventure: return "Aventura"
    case .culture: return "Cultura"
    case .food: return "Gastronomia"
    case .music: return "Música"
    case .sports: return "Esportes"
    case .nature: return "Natureza"
    case .technology: return "Tecnologia"
    case .business: return "Negócios"
    }
  }
  
  public var icon: String {
    switch self {
    case .adventure: return "🏔️"
    case .culture: return "🎭"
    case .food: return "🍽️"
    case .music: return "🎵"
    case .sports: return "⚽"
    case .nature: return "🌿"
    case .technology: return "💻"
    case .business: return "💼"
    }
  }
}

