import Foundation

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

public struct Location: Codable, Equatable, Sendable {
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

public struct Coordinate: Codable, Equatable, Sendable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Event Domain Models

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

// MARK: - Filter State (usado por Home e Events com FilterSheet)

public struct FilterState: Equatable {
    public var selectedCategories: Set<EventCategory> = []
    public var minPrice: Double = 50
    public var maxPrice: Double = 90
    public var location: String = ""
    public var useCurrentLocation: Bool = false
    
    public init() {}
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
    public var description: String?
    public var price: Double
    public var originalPrice: Double?
    public var ticketType: TicketType
    public var status: TicketStatus
    public var validUntil: Date
    public var createdAt: Date
    public var isFavorited: Bool
    public var quantity: Int
    public var currencyCode: String
    public var imageUrls: [String]?
    
    public init(eventId: String, sellerId: String, name: String, description: String? = nil,
                price: Double, ticketType: TicketType, validUntil: Date, quantity: Int = 1,
                currencyCode: String = "BRL", imageUrls: [String]? = nil) {
        self.id = UUID().uuidString
        self.eventId = eventId
        self.sellerId = sellerId
        self.name = name
        self.description = description
        self.price = price
        self.originalPrice = nil
        self.ticketType = ticketType
        self.status = .available
        self.validUntil = validUntil
        self.createdAt = Date()
        self.isFavorited = false
        self.quantity = quantity
        self.currencyCode = currencyCode
        self.imageUrls = imageUrls
    }
    
    // Custom init para decodificação flexível
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        eventId = (try? container.decode(String.self, forKey: .eventId)) ?? ""
        sellerId = (try? container.decode(String.self, forKey: .sellerId)) ?? ""
        name = (try? container.decode(String.self, forKey: .name)) ?? ""
        description = try? container.decode(String.self, forKey: .description)
        price = (try? container.decode(Double.self, forKey: .price)) ?? 0.0
        originalPrice = try? container.decode(Double.self, forKey: .originalPrice)
        ticketType = TicketType(rawValue: (try? container.decode(String.self, forKey: .ticketType)) ?? "general") ?? .general
        status = TicketStatus(rawValue: (try? container.decode(String.self, forKey: .status)) ?? "available") ?? .available
        isFavorited = (try? container.decode(Bool.self, forKey: .isFavorited)) ?? false
        quantity = (try? container.decode(Int.self, forKey: .quantity)) ?? 1
        currencyCode = (try? container.decode(String.self, forKey: .currencyCode)) ?? "BRL"
        imageUrls = try? container.decode([String].self, forKey: .imageUrls)
        
        // Parse validUntil
        validUntil = Date()
        if let validUntilString = try? container.decode(String.self, forKey: .validUntil) {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            let dateFormats = ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd'T'HH:mm:ss'Z'", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd"]
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: validUntilString) {
                    validUntil = date
                    break
                }
            }
        }
        
        // Parse createdAt
        createdAt = Date()
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            let dateFormats = ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd'T'HH:mm:ss'Z'", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd"]
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: createdAtString) {
                    createdAt = date
                    break
                }
            }
        }
    }
    
    public var discountPercentage: Double? {
        guard let originalPrice = originalPrice, originalPrice > price else { return nil }
        return ((originalPrice - price) / originalPrice) * 100
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, price, status, quantity
        case eventId = "event_id"
        case sellerId = "seller_id"
        case originalPrice = "original_price"
        case ticketType = "ticket_type"
        case validUntil = "valid_until"
        case createdAt = "created_at"
        case isFavorited = "is_favorited"
        case currencyCode = "currency_code"
        case imageUrls = "image_urls"
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
    public var name: String?
    public var description: String?
    public var price: Double
    public var quantity: Int
    public var currencyCode: String
    public var ticketType: TicketType
    public var validUntil: Date
    public var isTransferable: Bool
    public var qrCode: String?
    public var purchaseDate: Date?
    public var imageUrls: [String]?
    public var status: TicketStatus
    
    public init(ticketId: String, event: Event, seller: User, name: String? = nil,
                description: String? = nil, price: Double, quantity: Int, currencyCode: String = "BRL",
                ticketType: TicketType, validUntil: Date, imageUrls: [String]? = nil) {
        self.id = UUID().uuidString
        self.ticketId = ticketId
        self.event = event
        self.seller = seller
        self.name = name
        self.description = description
        self.price = price
        self.quantity = quantity
        self.currencyCode = currencyCode
        self.ticketType = ticketType
        self.validUntil = validUntil
        self.isTransferable = true
        self.qrCode = nil
        self.purchaseDate = nil
        self.imageUrls = imageUrls
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
    public var eventId: String? // Novo: filtro por evento específico
    
    public init() {
        self.category = nil
        self.priceRange = nil
        self.ticketType = nil
        self.status = nil
        self.sortBy = .dateCreated
        self.showFavoritesOnly = false
        self.eventId = nil
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
    case negotiations
    case profile
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .tickets: return "ticket.fill"
        case .addTicket: return "plus"
        case .negotiations: return "message.fill"
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

// MARK: - API Error Response Models

public struct APIErrorResponse: Codable {
    public let error: String?
    public let message: String?
    public let details: String?
    public let code: Int?
    public let success: Bool?
    
    public var finalMessage: String {
        return error ?? message ?? details ?? "Erro desconhecido"
    }
    
    public var finalCode: Int {
        return code ?? 400
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

public struct TicketsListResponse: Codable {
    public let tickets: [APITicketResponse]
    public let pagination: PaginationInfo
    
    public init(tickets: [APITicketResponse], pagination: PaginationInfo) {
        self.tickets = tickets
        self.pagination = pagination
    }
    
    // Custom init para decodificação resiliente
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Tenta decodificar tickets de diferentes formatos
        var ticketsArray: [APITicketResponse]?
        
        // Primeiro tenta o formato esperado "tickets"
        ticketsArray = try? container.decode([APITicketResponse].self, forKey: .tickets)
        
        // Se falhar, tenta dentro de um objeto "data"
        if ticketsArray == nil {
            if let dataContainer = try? container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data) {
                ticketsArray = try? dataContainer.decode([APITicketResponse].self, forKey: .tickets)
            }
        }
        
        // Se falhar, tenta data como array direto
        if ticketsArray == nil {
            ticketsArray = try? container.decode([APITicketResponse].self, forKey: .data)
        }
        
        self.tickets = ticketsArray ?? []
        
        // Decodifica pagination
        do {
            self.pagination = try container.decode(PaginationInfo.self, forKey: .pagination)
        } catch {
            // Fallback para paginação padrão se não encontrada
            self.pagination = PaginationInfo(total: self.tickets.count, page: 1, limit: 20, totalPages: 1)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tickets, forKey: .tickets)
        try container.encode(pagination, forKey: .pagination)
    }
    
    enum CodingKeys: String, CodingKey {
        case tickets, pagination, data
    }
    
    enum DataCodingKeys: String, CodingKey {
        case tickets
    }
}

public struct PaginationInfo: Codable, Equatable {
    public let total: Int
    public let page: Int
    public let limit: Int
    public let totalPages: Int
    
    public init(total: Int, page: Int = 1, limit: Int = 20, totalPages: Int = 1) {
        self.total = total
        self.page = page
        self.limit = limit
        self.totalPages = totalPages
    }
    
    enum CodingKeys: String, CodingKey {
        case total, page, limit
        case totalPages = "total_pages"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        total = (try? container.decode(Int.self, forKey: .total)) ?? 0
        page = (try? container.decode(Int.self, forKey: .page)) ?? 1
        limit = (try? container.decode(Int.self, forKey: .limit)) ?? 20
        totalPages = (try? container.decode(Int.self, forKey: .totalPages)) ?? 1
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(total, forKey: .total)
        try container.encode(page, forKey: .page)
        try container.encode(limit, forKey: .limit)
        try container.encode(totalPages, forKey: .totalPages)
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

// MARK: - Ticket API Models

public struct CreateTicketRequest: Codable {
    public let eventId: String
    public let name: String
    public let description: String?
    public let price: Double
    public let originalPrice: Double?
    public let ticketType: TicketType
    public let validUntil: Date
    public let quantity: Int
    public let currencyCode: String
    
    public init(
        eventId: String,
        name: String,
        description: String? = nil,
        price: Double,
        originalPrice: Double? = nil,
        ticketType: TicketType,
        validUntil: Date,
        quantity: Int,
        currencyCode: String
    ) {
        self.eventId = eventId
        self.name = name
        self.description = description
        self.price = price
        self.originalPrice = originalPrice
        self.ticketType = ticketType
        self.validUntil = validUntil
        self.quantity = quantity
        self.currencyCode = currencyCode
    }
    
    enum CodingKeys: String, CodingKey {
        case eventId = "eventId"
        case name
        case description
        case price
        case originalPrice = "originalPrice"
        case ticketType = "ticketType"
        case validUntil = "validUntil"
        case quantity = "quantity"
        case currencyCode = "currencyCode"
    }
}


// MARK: - API Wrapper Response Models
// A API pode retornar dados envolvidos em estruturas wrapper

public struct APIListResponse<T: Codable>: Codable {
    let data: [T]?
    let items: [T]?
    let results: [T]?
    let tickets: [T]? // Para endpoint específico de tickets
    let events: [T]?  // Para endpoint específico de events
    let users: [T]?   // Para endpoint específico de users
    let success: Bool?
    let message: String?
    
    // Computed property para obter os dados independente da estrutura
    var finalData: [T] {
        if let data = data { return data }
        if let items = items { return items }
        if let results = results { return results }
        if let tickets = tickets { return tickets }
        if let events = events { return events }
        if let users = users { return users }
        return []
    }
    
    // Custom init para lidar com diferentes estruturas
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        data = try? container.decode([T].self, forKey: .data)
        items = try? container.decode([T].self, forKey: .items)
        results = try? container.decode([T].self, forKey: .results)
        tickets = try? container.decode([T].self, forKey: .tickets)
        events = try? container.decode([T].self, forKey: .events)
        users = try? container.decode([T].self, forKey: .users)
        success = try? container.decode(Bool.self, forKey: .success)
        message = try? container.decode(String.self, forKey: .message)
    }
    
    enum CodingKeys: String, CodingKey {
        case data, items, results, tickets, events, users, success, message
    }
}

public struct APISingleResponse<T: Codable>: Codable {
    let data: T?
    let item: T?
    let result: T?
    let ticket: T?  // Para endpoint específico de ticket
    let event: T?   // Para endpoint específico de event
    let user: T?    // Para endpoint específico de user
    let success: Bool?
    let message: String?
    
    // Computed property para obter o dado independente da estrutura
    var finalData: T? {
        return data ?? item ?? result ?? ticket ?? event ?? user
    }
}

// MARK: - API Response Models
// Estes modelos representam exatamente a estrutura que a API retorna

public struct APIEventResponse: Codable {
    let id: String
    let name: String
    let description: String?
    let imageURL: String?
    let image_url: String? // Para compatibilidade com snake_case
    let startPrice: Double?
    let start_price: Double? // Para compatibilidade com snake_case  
    let location: APILocationResponse
    let category: String
    let isRecommended: Bool?
    let is_recommended: Bool? // Para compatibilidade com snake_case
    let rating: Double?
    let reviewCount: Int?
    let review_count: Int? // Para compatibilidade com snake_case
    let createdAt: String?
    let created_at: String? // Para compatibilidade com snake_case
    let eventDate: String?
    let event_date: String? // Para compatibilidade com snake_case
    
    // Custom init para decodificação flexível
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
    
    // Computed properties para conversão
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

public struct APILocationResponse: Codable {
    let name: String
    let address: String?
    let city: String
    let state: String
    let country: String
    let coordinate: APICoordinateResponse?
    let coordinates: APICoordinateResponse? // Para compatibilidade
    
    var finalCoordinate: APICoordinateResponse {
        return coordinate ?? coordinates ?? APICoordinateResponse(latitude: 0.0, longitude: 0.0)
    }
}

public struct APICoordinateResponse: Codable {
    let latitude: Double
    let longitude: Double
}

public struct APITicketResponse: Codable {
    let id: String
    let eventId: String?
    let event_id: String? // Para compatibilidade com snake_case
    let sellerId: String?
    let seller_id: String? // Para compatibilidade com snake_case
    let name: String
    let description: String?
    let price: Double
    let originalPrice: Double?
    let original_price: Double? // Para compatibilidade com snake_case
    let ticketType: String?
    let ticket_type: String? // Para compatibilidade com snake_case
    let status: String
    let validUntil: String?
    let valid_until: String? // Para compatibilidade com snake_Case
    let createdAt: String?
    let created_at: String? // Para compatibilidade com snake_case
    let isFavorited: Bool?
    let is_favorited: Bool? // Para compatibilidade com snake_case
    let quantity: Int?
    let currencyCode: String?
    let currency_code: String? // Para compatibilidade com snake_case
    let imageUrls: [String]?
    let image_urls: [String]? // Para compatibilidade com snake_case
    
    // Custom init para decodificação flexível
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        eventId = try? container.decode(String.self, forKey: .eventId)
        event_id = try? container.decode(String.self, forKey: .event_id)
        sellerId = try? container.decode(String.self, forKey: .sellerId)
        seller_id = try? container.decode(String.self, forKey: .seller_id)
        name = try container.decode(String.self, forKey: .name)
        description = try? container.decode(String.self, forKey: .description)
        price = try container.decode(Double.self, forKey: .price)
        originalPrice = try? container.decode(Double.self, forKey: .originalPrice)
        original_price = try? container.decode(Double.self, forKey: .original_price)
        ticketType = try? container.decode(String.self, forKey: .ticketType)
        ticket_type = try? container.decode(String.self, forKey: .ticket_type)
        status = (try? container.decode(String.self, forKey: .status)) ?? "available"
        validUntil = try? container.decode(String.self, forKey: .validUntil)
        valid_until = try? container.decode(String.self, forKey: .valid_until)
        createdAt = try? container.decode(String.self, forKey: .createdAt)
        created_at = try? container.decode(String.self, forKey: .created_at)
        isFavorited = try? container.decode(Bool.self, forKey: .isFavorited)
        is_favorited = try? container.decode(Bool.self, forKey: .is_favorited)
        quantity = try? container.decode(Int.self, forKey: .quantity)
        currencyCode = try? container.decode(String.self, forKey: .currencyCode)
        currency_code = try? container.decode(String.self, forKey: .currency_code)
        imageUrls = try? container.decode([String].self, forKey: .imageUrls)
        image_urls = try? container.decode([String].self, forKey: .image_urls)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, eventId, event_id, sellerId, seller_id, name, description, price
        case originalPrice, original_price, ticketType, ticket_type, status
        case validUntil, valid_until, createdAt, created_at
        case isFavorited, is_favorited, quantity
        case currencyCode, currency_code, imageUrls, image_urls
    }
    
    // Computed properties para conversão
    var finalEventId: String {
        return eventId ?? event_id ?? ""
    }
    
    var finalSellerId: String {
        // Se não vier seller_id na resposta, usa um fallback
        // Isso é normal quando o seller é determinado pelo JWT no backend
        return sellerId ?? seller_id ?? "UNKNOWN_SELLER"
    }
    
    var finalOriginalPrice: Double? {
        return originalPrice ?? original_price
    }
    
    var finalTicketType: String {
        return ticketType ?? ticket_type ?? "general"
    }
    
    var finalValidUntil: String {
        return validUntil ?? valid_until ?? ""
    }
    
    var finalCreatedAt: String {
        return createdAt ?? created_at ?? ""
    }
    
    var finalIsFavorited: Bool {
        return isFavorited ?? is_favorited ?? false
    }
    
    var finalQuantity: Int {
        return quantity ?? 1
    }
    
    var finalCurrencyCode: String {
        return currencyCode ?? currency_code ?? "BRL"
    }
    
    var finalImageUrls: [String]? {
        return imageUrls ?? image_urls
    }
}

// MARK: - TicketDetail API Response Model


public struct APIUserResponse: Codable {
    let id: String
    let name: String
    let title: String?
    let profileImageURL: String?
    let profile_image_url: String? // Para compatibilidade com snake_case
    let email: String?
    let followersCount: Int?
    let followers_count: Int? // Para compatibilidade com snake_case
    let followingCount: Int?
    let following_count: Int? // Para compatibilidade com snake_case
    let ticketsCount: Int?
    let tickets_count: Int? // Para compatibilidade com snake_case
    let isVerified: Bool?
    let is_verified: Bool? // Para compatibilidade com snake_case
    let tickets: [APITicketResponse]?
    let createdAt: String?
    let created_at: String? // Para compatibilidade com snake_case
    let verification: APIUserVerificationResponse?
    
    // Computed properties para conversão
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


// MARK: - Seller with Tickets Info

/// Modelo de domínio que agrupa um vendedor com seus ingressos
public struct SellerWithTickets: Identifiable, Equatable {
    public let id: String
    public let seller: User
    public let tickets: [Ticket]
    public let minPrice: Double
    public let maxPrice: Double
    public let ticketsCount: Int
    
    public init(seller: User, tickets: [Ticket]) {
        self.id = seller.id
        self.seller = seller
        self.tickets = tickets
        self.ticketsCount = tickets.count
        
        let prices = tickets.map { $0.price }
        self.minPrice = prices.min() ?? 0.0
        self.maxPrice = prices.max() ?? 0.0
    }
}

// MARK: - Request Models

// Purchase Ticket Request - apenas precisa do ID na URL, sem body
public struct PurchaseTicketRequest: Codable {
    // Empty body - ticketId vai na URL e userId é extraído do JWT
    public init() {}
}

// Favorite Ticket Request - apenas precisa do ID na URL, sem body  
public struct FavoriteTicketRequest: Codable {
    // Empty body - ticketId vai na URL e userId é extraído do JWT
    public init() {}
}

public struct UserUpdateRequest: Codable {
    let name: String?
    let title: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case title
        case email
    }
}

// MARK: - Mappers para conversão dos modelos da API para os modelos de domínio

extension APIEventResponse {
    func toEvent() -> Event {
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
        
        // Tenta diferentes formatos de data
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ", // ISO 8601 com milissegundos
            "yyyy-MM-dd'T'HH:mm:ssZ",     // ISO 8601 sem milissegundos
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", // ISO 8601 com milissegundos e Z literal
            "yyyy-MM-dd'T'HH:mm:ss'Z'",   // ISO 8601 sem milissegundos e Z literal
            "yyyy-MM-dd HH:mm:ss",        // Formato simples
            "yyyy-MM-dd"                  // Apenas data
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

extension APILocationResponse {
    func toLocation() -> Location {
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

extension APICoordinateResponse {
    func toCoordinate() -> Coordinate {
        return Coordinate(latitude: self.latitude, longitude: self.longitude)
    }
}

extension APITicketResponse {
    func toTicket() -> Ticket {
        var ticket = Ticket(
            eventId: self.finalEventId,
            sellerId: self.finalSellerId,
            name: self.name,
            description: self.description,
            price: self.price,
            ticketType: TicketType(rawValue: self.finalTicketType) ?? .general,
            validUntil: Date(), // Placeholder, será substituído abaixo
            quantity: self.finalQuantity,
            currencyCode: self.finalCurrencyCode,
            imageUrls: self.finalImageUrls
        )
        
        ticket.id = self.id
        ticket.originalPrice = self.finalOriginalPrice
        ticket.status = TicketStatus(rawValue: self.status) ?? .available
        ticket.isFavorited = self.finalIsFavorited
        
        // Parse das datas
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        if !self.finalValidUntil.isEmpty {
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: self.finalValidUntil) {
                    ticket.validUntil = date
                    break
                }
            }
        }
        
        if !self.finalCreatedAt.isEmpty {
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: self.finalCreatedAt) {
                    ticket.createdAt = date
                    break
                }
            }
        }
        
        return ticket
    }
}

extension APIUserResponse {
    func toUser() -> User {
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
                "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
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

// MARK: - APITicketDetailResponse Extension

extension APITicketDetailResponse {
    func toTicketDetail() -> TicketDetail {
        var ticketDetail = TicketDetail(
            ticketId: self.finalTicketId,
            event: self.event.toEvent(),
            seller: self.seller.toUser(),
            name: self.name,
            description: self.description,
            price: self.price,
            quantity: self.quantity,
            currencyCode: self.finalCurrencyCode,
            ticketType: TicketType(rawValue: self.finalTicketType) ?? .general,
            validUntil: Date(), // Placeholder, será substituído abaixo
            imageUrls: self.finalImageUrls
        )
        
        ticketDetail.id = self.id
        ticketDetail.isTransferable = self.finalIsTransferable
        ticketDetail.qrCode = self.finalQrCode
        ticketDetail.status = TicketStatus(rawValue: self.status) ?? .available
        
        // Parse das datas
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        if !self.finalValidUntil.isEmpty {
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: self.finalValidUntil) {
                    ticketDetail.validUntil = date
                    break
                }
            }
        }
        
        if let purchaseDateString = self.finalPurchaseDate, !purchaseDateString.isEmpty {
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: purchaseDateString) {
                    ticketDetail.purchaseDate = date
                    break
                }
            }
        }
        
        return ticketDetail
    }
}

// MARK: - Negotiation Models (Task5 - Phase 1)

public enum VerificationLevel: String, Codable, Equatable {
    case unverified = "unverified"
    case emailVerified = "email_verified"
    case phoneVerified = "phone_verified"
    case documentVerified = "document_verified"
    case fullyVerified = "fully_verified"
    
    public var displayName: String {
        switch self {
        case .unverified: return "Não Verificado"
        case .emailVerified: return "E-mail Verificado"
        case .phoneVerified: return "Telefone Verificado"
        case .documentVerified: return "Documento Verificado"
        case .fullyVerified: return "Totalmente Verificado"
        }
    }
    
    public var level: Int {
        switch self {
        case .unverified: return 0
        case .emailVerified: return 1
        case .phoneVerified: return 2
        case .documentVerified: return 3
        case .fullyVerified: return 4
        }
    }
    
    public var canNegotiate: Bool {
        return level >= 1 // Precisa ter pelo menos e-mail verificado
    }
}

public enum NegotiationStatus: String, Codable, Equatable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
    case cancelled = "cancelled"
    case inProgress = "in_progress"
    case completed = "completed"
    case disputed = "disputed"
    
    public var displayName: String {
        switch self {
        case .pending: return "Aguardando Resposta"
        case .approved: return "Aprovada"
        case .rejected: return "Recusada"
        case .cancelled: return "Cancelada"
        case .inProgress: return "Em Andamento"
        case .completed: return "Concluída"
        case .disputed: return "Em Disputa"
        }
    }
    
    public var iconName: String {
        switch self {
        case .pending: return "clock.fill"
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .cancelled: return "slash.circle.fill"
        case .inProgress: return "arrow.triangle.2.circlepath"
        case .completed: return "checkmark.seal.fill"
        case .disputed: return "exclamationmark.triangle.fill"
        }
    }
}

public struct Negotiation: Codable, Identifiable, Equatable {
    public var id: String
    public var ticketId: String
    public var buyerId: String
    public var sellerId: String
    public var status: NegotiationStatus
    public var proposedPrice: Double?
    public var escrowCode: String?
    public var accessToken: String?
    public var validUntil: Date?
    public var rejectionReason: String?
    public var adminNotes: String?
    public var createdAt: Date
    public var approvedAt: Date?
    public var completedAt: Date?
    public var cancelledAt: Date?
    public var updatedAt: Date?
    public var questionsCount: Int?
    public var answeredQuestionsCount: Int?
    public var hasUnreadUpdates: Bool?
    public var lastViewedAt: Date?
    
    // Informações expandidas (podem vir da API)
    public var ticket: Ticket?
    public var buyer: User?
    public var seller: User?
    
    // Perguntas e documentos da negociação
    public var questions: [NegotiationQuestion]?
    public var documents: [NegotiationDocument]?
    
    public init(
        id: String = UUID().uuidString,
        ticketId: String,
        buyerId: String,
        sellerId: String,
        status: NegotiationStatus = .pending,
        proposedPrice: Double? = nil,
        escrowCode: String? = nil,
        accessToken: String? = nil,
        validUntil: Date? = nil,
        rejectionReason: String? = nil,
        adminNotes: String? = nil,
        createdAt: Date = Date(),
        approvedAt: Date? = nil,
        completedAt: Date? = nil,
        cancelledAt: Date? = nil,
        updatedAt: Date? = nil,
        questionsCount: Int? = nil,
        answeredQuestionsCount: Int? = nil,
        hasUnreadUpdates: Bool? = nil,
        lastViewedAt: Date? = nil
    ) {
        self.id = id
        self.ticketId = ticketId
        self.buyerId = buyerId
        self.sellerId = sellerId
        self.status = status
        self.proposedPrice = proposedPrice
        self.escrowCode = escrowCode
        self.accessToken = accessToken
        self.validUntil = validUntil
        self.rejectionReason = rejectionReason
        self.adminNotes = adminNotes
        self.createdAt = createdAt
        self.approvedAt = approvedAt
        self.completedAt = completedAt
        self.cancelledAt = cancelledAt
        self.updatedAt = updatedAt
        self.questionsCount = questionsCount
        self.answeredQuestionsCount = answeredQuestionsCount
        self.hasUnreadUpdates = hasUnreadUpdates
        self.lastViewedAt = lastViewedAt
    }
    
    public var isExpired: Bool {
        guard let validUntil = validUntil else { return false }
        return Date() > validUntil
    }
    
    public var canRevealContact: Bool {
        return status == .approved && !isExpired
    }
    
    enum CodingKeys: String, CodingKey {
        case id, status, ticket, buyer, seller
        case ticketId = "ticket_id"
        case buyerId = "buyer_id"
        case sellerId = "seller_id"
        case proposedPrice = "proposed_price"
        case escrowCode = "escrow_code"
        case accessToken = "access_token"
        case validUntil = "valid_until"
        case rejectionReason = "rejection_reason"
        case adminNotes = "admin_notes"
        case createdAt = "created_at"
        case approvedAt = "approved_at"
        case completedAt = "completed_at"
        case cancelledAt = "cancelled_at"
        case updatedAt = "updated_at"
        case questionsCount = "questions_count"
        case answeredQuestionsCount = "answered_questions_count"
        case hasUnreadUpdates = "has_unread_updates"
        case lastViewedAt = "last_viewed_at"
    }
    
    // Computed properties para perguntas e documentos
    public var hasUnreadQuestions: Bool {
        guard let questions = questions else { return false }
        return questions.contains { !$0.isRead && $0.isAnswered }
    }
    
    public var unreadQuestionsCount: Int {
        guard let questions = questions else { return 0 }
        return questions.filter { !$0.isRead && $0.isAnswered }.count
    }
    
    public var unansweredQuestionsCount: Int {
        guard let questions = questions else { return 0 }
        return questions.filter { !$0.isAnswered }.count
    }
    
    public var lastMessagePreview: String? {
        guard let questions = questions, !questions.isEmpty else { return nil }
        // Retorna a última pergunta ou resposta
        let sortedQuestions = questions.sorted { $0.createdAt > $1.createdAt }
        if let lastQuestion = sortedQuestions.first {
            if let answer = lastQuestion.answer {
                return answer.answerText
            }
            return lastQuestion.questionText
        }
        return nil
    }
    
    public var lastMessageDate: Date? {
        guard let questions = questions, !questions.isEmpty else { return createdAt }
        let sortedQuestions = questions.sorted { $0.createdAt > $1.createdAt }
        if let lastQuestion = sortedQuestions.first {
            if let answer = lastQuestion.answer {
                return answer.createdAt
            }
            return lastQuestion.createdAt
        }
        return createdAt
    }
}

// MARK: - Negotiation Questions and Answers

public enum QuestionCategory: String, Codable, CaseIterable, Equatable {
    case authenticity = "authenticity"
    case conditions = "conditions"
    case delivery = "delivery"
    case payment = "payment"
    case other = "other"
    
    public var displayName: String {
        switch self {
        case .authenticity: return "Autenticidade"
        case .conditions: return "Condições"
        case .delivery: return "Entrega"
        case .payment: return "Pagamento"
        case .other: return "Outros"
        }
    }
    
    public var icon: String {
        switch self {
        case .authenticity: return "checkmark.seal.fill"
        case .conditions: return "doc.text.fill"
        case .delivery: return "shippingbox.fill"
        case .payment: return "creditcard.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension QuestionCategory {
    public var color: Color {
        switch self {
        case .authenticity: return .blue
        case .conditions: return .purple
        case .delivery: return .orange
        case .payment: return .green
        case .other: return .gray
        }
    }
}
#endif

public struct NegotiationQuestion: Codable, Identifiable, Equatable {
    public var id: String
    public var negotiationId: String
    public var askedBy: String
    public var questionText: String
    public var category: QuestionCategory
    public var isAnswered: Bool
    public var answer: NegotiationAnswer?
    public var createdAt: Date
    public var answeredAt: Date?
    public var isRead: Bool
    
    public init(
        id: String = UUID().uuidString,
        negotiationId: String,
        askedBy: String = "", // Vem do backend via JWT, valor padrão para compatibilidade
        questionText: String,
        category: QuestionCategory,
        isAnswered: Bool = false,
        answer: NegotiationAnswer? = nil,
        createdAt: Date = Date(),
        answeredAt: Date? = nil,
        isRead: Bool = false
    ) {
        self.id = id
        self.negotiationId = negotiationId
        self.askedBy = askedBy
        self.questionText = questionText
        self.category = category
        self.isAnswered = isAnswered
        self.answer = answer
        self.createdAt = createdAt
        self.answeredAt = answeredAt
        self.isRead = isRead
    }
    
    enum CodingKeys: String, CodingKey {
        case id, category, answer
        case negotiationId = "negotiation_id"
        case askedBy = "asked_by"
        case questionText = "question_text"
        case isAnswered = "is_answered"
        case createdAt = "created_at"
        case answeredAt = "answered_at"
        case isRead = "is_read"
    }
}

public struct NegotiationAnswer: Codable, Identifiable, Equatable {
    public var id: String
    public var questionId: String
    public var negotiationId: String
    public var answerText: String
    public var answeredBy: String
    public var createdAt: Date
    public var updatedAt: Date?
    
    public init(
        id: String = UUID().uuidString,
        questionId: String,
        negotiationId: String,
        answerText: String,
        answeredBy: String,
        createdAt: Date = Date(),
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.questionId = questionId
        self.negotiationId = negotiationId
        self.answerText = answerText
        self.answeredBy = answeredBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id, createdAt
        case questionId = "question_id"
        case negotiationId = "negotiation_id"
        case answerText = "answer_text"
        case answeredBy = "answered_by"
        case updatedAt = "updated_at"
    }
}

// MARK: - Negotiation Documents

public enum DocumentType: String, Codable, Equatable {
    case ticketPhoto = "ticket_photo"
    case idDocument = "id_document"
    
    public var displayName: String {
        switch self {
        case .ticketPhoto: return "Foto do Ingresso"
        case .idDocument: return "Documento de Identidade"
        }
    }
    
    public var icon: String {
        switch self {
        case .ticketPhoto: return "ticket.fill"
        case .idDocument: return "person.text.rectangle.fill"
        }
    }
}

public struct NegotiationDocument: Codable, Identifiable, Equatable {
    public var id: String
    public var negotiationId: String
    public var uploadedBy: String
    public var documentType: DocumentType
    public var fileUrl: String
    public var thumbnailUrl: String?
    public var status: ValidationStatus
    public var uploadedAt: Date
    public var validatedAt: Date?
    public var updatedAt: Date?
    public var isVerified: Bool?
    
    public init(
        id: String = UUID().uuidString,
        negotiationId: String,
        uploadedBy: String = "", // Vem do backend via JWT, valor padrão para compatibilidade
        documentType: DocumentType,
        fileUrl: String,
        thumbnailUrl: String? = nil,
        status: ValidationStatus = .pending,
        uploadedAt: Date = Date(),
        validatedAt: Date? = nil,
        updatedAt: Date? = nil,
        isVerified: Bool? = nil
    ) {
        self.id = id
        self.negotiationId = negotiationId
        self.uploadedBy = uploadedBy
        self.documentType = documentType
        self.fileUrl = fileUrl
        self.thumbnailUrl = thumbnailUrl
        self.status = status
        self.uploadedAt = uploadedAt
        self.validatedAt = validatedAt
        self.updatedAt = updatedAt
        self.isVerified = isVerified
    }
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case negotiationId = "negotiation_id"
        case uploadedBy = "uploaded_by"
        case documentType = "document_type"
        case fileUrl = "file_url"
        case thumbnailUrl = "thumbnail_url"
        case uploadedAt = "uploaded_at"
        case validatedAt = "validated_at"
        case updatedAt = "updated_at"
        case isVerified = "is_verified"
    }
}

// MARK: - Request Models for Questions and Documents

// MARK: - API Response Models for Questions and Documents
// NOTE: All negotiation-related DTOs have been migrated to Data/Sources/APINegotiation.swift
// The following structs are deprecated and should not be used.
// Use the ones in Data/Sources/APINegotiation.swift instead.

// Removed: APINegotiationQuestionResponse - migrated to Data layer
// Removed: APINegotiationAnswerResponse - migrated to Data layer
// Removed: APINegotiationDocumentResponse - migrated to Data layer
// Removed: APINegotiationResponse - migrated to Data layer
// Removed: APIUserVerificationResponse - migrated to Data layer (APIUser.swift)
// Removed: CreateNegotiationRequest, UpdateNegotiationRequest - migrated to Data layer
// Removed: CreateReviewRequest - migrated to Data layer (APIReview.swift)

public struct UserVerification: Codable, Identifiable, Equatable {
    public var id: String
    public var emailVerified: Bool
    public var emailVerifiedAt: Date?
    public var phoneVerified: Bool
    public var phoneVerifiedAt: Date?
    public var phoneNumber: String?
    public var documentType: String?
    public var documentFileUrl: String?
    public var documentVerified: Bool
    public var documentVerifiedAt: Date?
    public var documentVerifiedBy: String?
    public var verificationLevel: VerificationLevel
    public var trustScore: Int
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        emailVerified: Bool = false,
        emailVerifiedAt: Date? = nil,
        phoneVerified: Bool = false,
        phoneVerifiedAt: Date? = nil,
        phoneNumber: String? = nil,
        documentType: String? = nil,
        documentFileUrl: String? = nil,
        documentVerified: Bool = false,
        documentVerifiedAt: Date? = nil,
        documentVerifiedBy: String? = nil,
        verificationLevel: VerificationLevel = .unverified,
        trustScore: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.emailVerified = emailVerified
        self.emailVerifiedAt = emailVerifiedAt
        self.phoneVerified = phoneVerified
        self.phoneVerifiedAt = phoneVerifiedAt
        self.phoneNumber = phoneNumber
        self.documentType = documentType
        self.documentFileUrl = documentFileUrl
        self.documentVerified = documentVerified
        self.documentVerifiedAt = documentVerifiedAt
        self.documentVerifiedBy = documentVerifiedBy
        self.verificationLevel = verificationLevel
        self.trustScore = trustScore
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public var canNegotiate: Bool {
        return verificationLevel.canNegotiate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case emailVerified = "email_verified"
        case emailVerifiedAt = "email_verified_at"
        case phoneVerified = "phone_verified"
        case phoneVerifiedAt = "phone_verified_at"
        case phoneNumber = "phone_number"
        case documentType = "document_type"
        case documentFileUrl = "document_file_url"
        case documentVerified = "document_verified"
        case documentVerifiedAt = "document_verified_at"
        case documentVerifiedBy = "document_verified_by"
        case verificationLevel = "verification_level"
        case trustScore = "trust_score"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Ticket Validation Models (Task5 - Phase 4)

public enum ValidationStatus: String, Codable, Equatable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
    case inReview = "in_review"
    
    public var displayName: String {
        switch self {
        case .pending: return "Aguardando Envio"
        case .approved: return "Aprovado"
        case .rejected: return "Rejeitado"
        case .inReview: return "Em Análise"
        }
    }
    
    public var iconName: String {
        switch self {
        case .pending: return "clock.fill"
        case .approved: return "checkmark.seal.fill"
        case .rejected: return "xmark.seal.fill"
        case .inReview: return "magnifyingglass"
        }
    }
}

public struct TicketValidation: Codable, Identifiable, Equatable {
    public var id: String
    public var ticketId: String
    public var sellerId: String
    public var status: ValidationStatus
    public var submittedAt: Date?
    public var validatedAt: Date?
    public var validatedBy: String?
    public var autoValidationScore: Int?
    public var rejectionReason: String?
    public var adminNotes: String?
    public var createdAt: Date
    public var updatedAt: Date
    
    public var proofs: [ValidationProof]?
    
    public init(
        id: String = UUID().uuidString,
        ticketId: String,
        sellerId: String,
        status: ValidationStatus = .pending,
        submittedAt: Date? = nil,
        validatedAt: Date? = nil,
        validatedBy: String? = nil,
        autoValidationScore: Int? = nil,
        rejectionReason: String? = nil,
        adminNotes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.ticketId = ticketId
        self.sellerId = sellerId
        self.status = status
        self.submittedAt = submittedAt
        self.validatedAt = validatedAt
        self.validatedBy = validatedBy
        self.autoValidationScore = autoValidationScore
        self.rejectionReason = rejectionReason
        self.adminNotes = adminNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case ticketId = "ticket_id"
        case sellerId = "seller_id"
        case submittedAt = "submitted_at"
        case validatedAt = "validated_at"
        case validatedBy = "validated_by"
        case autoValidationScore = "auto_validation_score"
        case rejectionReason = "rejection_reason"
        case adminNotes = "admin_notes"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case proofs
    }
}

public struct ValidationProof: Codable, Identifiable, Equatable {
    public var id: String
    public var validationId: String
    public var proofType: String
    public var fileUrl: String
    public var uploadedAt: Date
    public var isVerified: Bool
    public var moderatedAt: Date?
    public var moderatedBy: String?
    public var moderationNotes: String?
    
    public init(
        id: String = UUID().uuidString,
        validationId: String,
        proofType: String,
        fileUrl: String,
        uploadedAt: Date = Date(),
        isVerified: Bool = false,
        moderatedAt: Date? = nil,
        moderatedBy: String? = nil,
        moderationNotes: String? = nil
    ) {
        self.id = id
        self.validationId = validationId
        self.proofType = proofType
        self.fileUrl = fileUrl
        self.uploadedAt = uploadedAt
        self.isVerified = isVerified
        self.moderatedAt = moderatedAt
        self.moderatedBy = moderatedBy
        self.moderationNotes = moderationNotes
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case validationId = "validation_id"
        case proofType = "proof_type"
        case fileUrl = "file_url"
        case uploadedAt = "uploaded_at"
        case isVerified = "is_verified"
        case moderatedAt = "moderated_at"
        case moderatedBy = "moderated_by"
        case moderationNotes = "moderation_notes"
    }
}

// MARK: - Review Models (Task5 - Phase 5)

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

// MARK: - API Response Models for Negotiations
// NOTE: All negotiation-related DTOs have been migrated to Data layer:
// - APINegotiationResponse -> Data/Sources/APINegotiation.swift
// - APIUserVerificationResponse -> Data/Sources/APIUser.swift
// - CreateNegotiationRequest, UpdateNegotiationRequest -> Data/Sources/APINegotiation.swift
// - CreateReviewRequest -> Data/Sources/APIReview.swift
