import Foundation

public struct Location: Codable, Equatable {
    public var name: String
    public var address: String?
    public var city: String
    public var state: String
    public var country: String
    public var coordinate: Coordinate
}

public struct Event: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var imageURL: String?
    public var startPrice: Double
    public var location: Location
    public var category: EventCategory
    public var isRecommended: Bool
    public var rating: Double?
    public var reviewCount: Int?
    public let createdAt: Date
    public var eventDate: Date?
    
    public init(name: String, description: String? = nil, imageURL: String? = nil, 
         startPrice: Double, location: Location, category: EventCategory, 
         isRecommended: Bool = false, eventDate: Date? = nil) {
        self.id = UUID()
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
}

public enum EventCategory: String, CaseIterable, Codable, Equatable {
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