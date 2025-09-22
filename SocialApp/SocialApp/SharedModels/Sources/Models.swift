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

public struct Location: Codable, Equatable {
    public var name: String
    public var address: String?
    public var city: String
    public var state: String
    public var country: String
    public var coordinate: Coordinate
    
    public init(name: String, address: String? = nil, city: String,
         state: String, country: String, coordinate: Coordinate) {
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.country = country
        self.coordinate = coordinate
    }
}

public struct Coordinate: Codable, Equatable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Event Domain Models
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

// MARK: - Filter Models (usados por Events)
public struct SearchFilter: Codable, Equatable {
    public var category: EventCategory?
    public var priceRange: PriceRange?
    public var location: String?
    public var dateRange: DateRange?
    public var isRecommendedOnly: Bool
    
    public init() {
        self.category = nil
        self.priceRange = nil
        self.location = nil
        self.dateRange = nil
        self.isRecommendedOnly = false
    }
}

public struct PriceRange: Codable, Equatable {
    public let min: Double
    public let max: Double
    
    public init(min: Double, max: Double) {
        self.min = min
        self.max = max
    }
}

public struct DateRange: Codable, Equatable {
    public let startDate: Date
    public let endDate: Date
    
    public init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
}

// MARK: - Ticket Domain Models
public struct Ticket: Codable, Identifiable, Equatable {
    public let id: UUID
    public var eventId: UUID
    public var sellerId: UUID
    public var name: String
    public var price: Double
    public var originalPrice: Double?
    public var ticketType: TicketType
    public var status: TicketStatus
    public var validUntil: Date
    public let createdAt: Date
    public var isFavorited: Bool
    
    public init(eventId: UUID, sellerId: UUID, name: String, price: Double,
         ticketType: TicketType, validUntil: Date) {
        self.id = UUID()
        self.eventId = eventId
        self.sellerId = sellerId
        self.name = name
        self.price = price
        self.originalPrice = nil
        self.ticketType = ticketType
        self.status = .available
        self.validUntil = validUntil
        self.createdAt = Date()
        self.isFavorited = false
    }
    
    public var discountPercentage: Double? {
        guard let originalPrice = originalPrice, originalPrice > price else { return nil }
        return ((originalPrice - price) / originalPrice) * 100
    }
}

public enum TicketType: String, CaseIterable, Codable, Equatable {
    case general = "general"
    case vip = "vip"
    case earlyBird = "early_bird"
    case group = "group"
    case student = "student"
    case senior = "senior"
    
    public var displayName: String {
        switch self {
        case .general: return "Geral"
        case .vip: return "VIP"
        case .earlyBird: return "Early Bird"
        case .group: return "Grupo"
        case .student: return "Estudante"
        case .senior: return "Terceira Idade"
        }
    }
}

public enum TicketStatus: String, CaseIterable, Codable, Equatable {
    case available = "available"
    case reserved = "reserved"
    case sold = "sold"
    case expired = "expired"
    case cancelled = "cancelled"
    
    public var displayName: String {
        switch self {
        case .available: return "Disponível"
        case .reserved: return "Reservado"
        case .sold: return "Vendido"
        case .expired: return "Expirado"
        case .cancelled: return "Cancelado"
        }
    }
    
    public var color: String {
        switch self {
        case .available: return "green"
        case .reserved: return "orange"
        case .sold: return "blue"
        case .expired: return "red"
        case .cancelled: return "gray"
        }
    }
}

// MARK: - TicketDetail Domain Models
public struct TicketDetail: Codable, Identifiable, Equatable {
    public let id: UUID
    public var ticketId: UUID
    public var event: Event
    public var seller: SellerProfile
    public var price: Double
    public var quantity: Int
    public var ticketType: TicketType
    public var validUntil: Date
    public var isTransferable: Bool
    public var qrCode: String?
    public var purchaseDate: Date?
    public var status: TicketStatus
    
    public init(ticketId: UUID, event: Event, seller: SellerProfile, price: Double,
         quantity: Int, ticketType: TicketType, validUntil: Date) {
        self.id = UUID()
        self.ticketId = ticketId
        self.event = event
        self.seller = seller
        self.price = price
        self.quantity = quantity
        self.ticketType = ticketType
        self.validUntil = validUntil
        self.isTransferable = true
        self.qrCode = nil
        self.purchaseDate = nil
        self.status = .available
    }
}

// MARK: - TicketsList Filter Models
public struct TicketsListFilter: Codable, Equatable {
    public var category: EventCategory?
    public var priceRange: PriceRange?
    public var ticketType: TicketType?
    public var status: TicketStatus?
    public var sortBy: TicketSortOption
    public var showFavoritesOnly: Bool
    
    public init() {
        self.category = nil
        self.priceRange = nil
        self.ticketType = nil
        self.status = nil
        self.sortBy = .dateCreated
        self.showFavoritesOnly = false
    }
}

public enum TicketSortOption: String, CaseIterable, Codable, Equatable {
    case dateCreated = "date_created"
    case priceAsc = "price_asc"
    case priceDesc = "price_desc"
    case eventDate = "event_date"
    case popularity = "popularity"
    
    public var displayName: String {
        switch self {
        case .dateCreated: return "Mais Recentes"
        case .priceAsc: return "Menor Preço"
        case .priceDesc: return "Maior Preço"
        case .eventDate: return "Data do Evento"
        case .popularity: return "Popularidade"
        }
    }
}

// MARK: - SellerProfile Domain Models
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

// MARK: - Navigation Models
public enum AppTab: String, CaseIterable, Equatable {
    case events = "events"
    case tickets = "tickets"
    case favorites = "favorites"
    case profile = "profile"
    
    public var displayName: String {
        switch self {
        case .events: return "Eventos"
        case .tickets: return "Ingressos"
        case .favorites: return "Favoritos"
        case .profile: return "Perfil"
        }
    }
    
    public var icon: String {
        switch self {
        case .events: return "calendar"
        case .tickets: return "ticket"
        case .favorites: return "heart"
        case .profile: return "person"
        }
    }
}

// MARK: - API Models
public struct APIError: Error, Codable, Equatable {
    public let message: String
    public let code: Int
    
    public init(message: String, code: Int) {
        self.message = message
        self.code = code
    }
}

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
