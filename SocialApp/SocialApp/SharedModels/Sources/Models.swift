import Foundation

public struct User: Codable, Identifiable, Equatable {
    public var id: String
    public var name: String
    public var title: String?
    public var profileImageURL: String?
    public var email: String?
    public var followersCount: Int
    public var followingCount: Int
    public var ticketsCount: Int
    public var isVerified: Bool
    public var tickets: [Ticket]
    public var createdAt: Date
    
    public init(
        name: String,
        title: String? = nil,
        profileImageURL: String? = nil,
        email: String? = nil
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.title = title
        self.profileImageURL = profileImageURL
        self.email = email
        self.followersCount = 0
        self.followingCount = 0
        self.ticketsCount = 0
        self.isVerified = false
        self.tickets = []
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
    
    public init(name: String, description: String? = nil, imageURL: String? = nil,
         startPrice: Double, location: Location, category: EventCategory,
         isRecommended: Bool = false, eventDate: Date? = nil) {
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
}

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
    public var id: String
    public var eventId: String
    public var sellerId: String
    public var name: String
    public var price: Double
    public var originalPrice: Double?
    public var ticketType: TicketType
    public var status: TicketStatus
    public var validUntil: Date
    public var createdAt: Date
    public var isFavorited: Bool
    
    public init(eventId: String, sellerId: String, name: String, price: Double,
         ticketType: TicketType, validUntil: Date) {
        self.id = UUID().uuidString
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
    public var id: String
    public var ticketId: String
    public var event: Event
    public var seller: User
    public var price: Double
    public var quantity: Int
    public var ticketType: TicketType
    public var validUntil: Date
    public var isTransferable: Bool
    public var qrCode: String?
    public var purchaseDate: Date?
    public var status: TicketStatus
    
    public init(ticketId: String, event: Event, seller: User, price: Double,
         quantity: Int, ticketType: TicketType, validUntil: Date) {
        self.id = UUID().uuidString
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

// MARK: - Navigation Models

public enum AppTab: Hashable, CaseIterable {
    case home
    case tickets
    case addTicket
    case favorites
    case profile
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .tickets: return "ticket.fill"
        case .addTicket: return "plus"
        case .favorites: return "heart.fill"
        case .profile: return "person.fill"
        }
    }
}

// MARK: - Home Models

public struct HomeContent: Codable, Equatable {
    public var curatedEvents: [Event]
    public var trendingEvents: [Event]
    public var availableTickets: [Ticket]
    public var user: User?
    
    public init(
        curatedEvents: [Event] = [],
        trendingEvents: [Event] = [],
        availableTickets: [Ticket] = [],
        user: User? = nil
    ) {
        self.curatedEvents = curatedEvents
        self.trendingEvents = trendingEvents
        self.availableTickets = availableTickets
        self.user = user
    }
}

public enum EventSection: String, CaseIterable, Equatable {
    case curated = "curated"
    case trending = "trending"
    
    public var displayName: String {
        switch self {
        case .curated: return "Curated"
        case .trending: return "Trending"
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

// MARK: - Auth API Models

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

public struct AuthResponse: Codable {
    public let user: User
    public let token: String
    public let refreshToken: String?
    
    public init(user: User, token: String, refreshToken: String? = nil) {
        self.user = user
        self.token = token
        self.refreshToken = refreshToken
    }
}

// MARK: - User API Models

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

public struct UserUpdateRequest: Codable {
    public let name: String?
    public let title: String?
    public let profileImageURL: String?
    public let email: String?
    
    public init(
        name: String? = nil,
        title: String? = nil,
        profileImageURL: String? = nil,
        email: String? = nil
    ) {
        self.name = name
        self.title = title
        self.profileImageURL = profileImageURL
        self.email = email
    }
}


// MARK: - Ticket API Models

public struct CreateTicketRequest: Codable {
    public let eventId: UUID
    public let name: String
    public let price: Double
    public let originalPrice: Double?
    public let ticketType: TicketType
    public let validUntil: Date
    
    public init(
        eventId: UUID,
        name: String,
        price: Double,
        originalPrice: Double? = nil,
        ticketType: TicketType,
        validUntil: Date
    ) {
        self.eventId = eventId
        self.name = name
        self.price = price
        self.originalPrice = originalPrice
        self.ticketType = ticketType
        self.validUntil = validUntil
    }
}

public struct FavoriteTicketRequest: Codable {
    public let ticketId: UUID
    
    public init(ticketId: UUID) {
        self.ticketId = ticketId
    }
}

// MARK: - Custom Coding Strategies for API Compatibility

extension User {
    private enum CodingKeys: String, CodingKey {
        case id, name, title, profileImageURL, email
        case followersCount, followingCount, ticketsCount
        case isVerified, tickets, createdAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle UUID from string
        let idString = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: idString) ?? String
        
        self.name = try container.decode(String.self, forKey: .name)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.followersCount = try container.decodeIfPresent(Int.self, forKey: .followersCount) ?? 0
        self.followingCount = try container.decodeIfPresent(Int.self, forKey: .followingCount) ?? 0
        self.ticketsCount = try container.decodeIfPresent(Int.self, forKey: .ticketsCount) ?? 0
        self.isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified) ?? false
        self.tickets = try container.decodeIfPresent([Ticket].self, forKey: .tickets) ?? []
        
        // Handle Date from ISO8601 string
        if let dateString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            self.createdAt = formatter.date(from: dateString) ?? Date()
        } else {
            self.createdAt = Date()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(profileImageURL, forKey: .profileImageURL)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encode(followersCount, forKey: .followersCount)
        try container.encode(followingCount, forKey: .followingCount)
        try container.encode(ticketsCount, forKey: .ticketsCount)
        try container.encode(isVerified, forKey: .isVerified)
        try container.encode(tickets, forKey: .tickets)
        
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
    }
}

extension Event {
    private enum CodingKeys: String, CodingKey {
        case id, name, description, imageURL, startPrice
        case location, category, isRecommended, rating
        case reviewCount, createdAt, eventDate
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let idString = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: idString) ?? String
        
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.startPrice = try container.decode(Double.self, forKey: .startPrice)
        self.location = try container.decode(Location.self, forKey: .location)
        
        let categoryString = try container.decode(String.self, forKey: .category)
        self.category = EventCategory(rawValue: categoryString) ?? .culture
        
        self.isRecommended = try container.decodeIfPresent(Bool.self, forKey: .isRecommended) ?? false
        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        self.reviewCount = try container.decodeIfPresent(Int.self, forKey: .reviewCount)
        
        let formatter = ISO8601DateFormatter()
        if let dateString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            self.createdAt = formatter.date(from: dateString) ?? Date()
        } else {
            self.createdAt = Date()
        }
        
        if let eventDateString = try container.decodeIfPresent(String.self, forKey: .eventDate) {
            self.eventDate = formatter.date(from: eventDateString)
        } else {
            self.eventDate = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encode(startPrice, forKey: .startPrice)
        try container.encode(location, forKey: .location)
        try container.encode(category.rawValue, forKey: .category)
        try container.encode(isRecommended, forKey: .isRecommended)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(reviewCount, forKey: .reviewCount)
        
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        
        if let eventDate = eventDate {
            try container.encode(formatter.string(from: eventDate), forKey: .eventDate)
        }
    }
}

extension Ticket {
    private enum CodingKeys: String, CodingKey {
        case id, eventId, sellerId, name, price, originalPrice
        case ticketType, status, validUntil, createdAt, isFavorited
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let idString = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: idString) ?? String
        
        let eventIdString = try container.decode(String.self, forKey: .eventId)
        self.eventId = UUID(uuidString: eventIdString) ?? String
        
        let sellerIdString = try container.decode(String.self, forKey: .sellerId)
        self.sellerId = UUID(uuidString: sellerIdString) ?? String
        
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decode(Double.self, forKey: .price)
        self.originalPrice = try container.decodeIfPresent(Double.self, forKey: .originalPrice)
        
        let ticketTypeString = try container.decode(String.self, forKey: .ticketType)
        self.ticketType = TicketType(rawValue: ticketTypeString) ?? .general
        
        let statusString = try container.decode(String.self, forKey: .status)
        self.status = TicketStatus(rawValue: statusString) ?? .available
        
        self.isFavorited = try container.decodeIfPresent(Bool.self, forKey: .isFavorited) ?? false
        
        let formatter = ISO8601DateFormatter()
        
        let validUntilString = try container.decode(String.self, forKey: .validUntil)
        self.validUntil = formatter.date(from: validUntilString) ?? Date()
        
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            self.createdAt = formatter.date(from: createdAtString) ?? Date()
        } else {
            self.createdAt = Date()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(eventId, forKey: .eventId)
        try container.encode(sellerId, forKey: .sellerId)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encodeIfPresent(originalPrice, forKey: .originalPrice)
        try container.encode(ticketType.rawValue, forKey: .ticketType)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(isFavorited, forKey: .isFavorited)
        
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: validUntil), forKey: .validUntil)
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
    }
}

extension Location {
    private enum CodingKeys: String, CodingKey {
        case name, address, city, state, country, coordinate
        case latitude, longitude  // For flat structure from API
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.city = try container.decode(String.self, forKey: .city)
        self.state = try container.decode(String.self, forKey: .state)
        self.country = try container.decode(String.self, forKey: .country)
        
        // Try to decode coordinate as nested object first, then as flat structure
        if let coordinate = try? container.decodeIfPresent(Coordinate.self, forKey: .coordinate) {
            self.coordinate = coordinate
        } else {
            // Handle flat structure from API
            let lat = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 0.0
            let lon = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 0.0
            self.coordinate = Coordinate(latitude: lat, longitude: lon)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(country, forKey: .country)
        try container.encode(coordinate, forKey: .coordinate)
    }
}
