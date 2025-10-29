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
        case id, name, title, email, bio, tickets, interests
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
    
    // Custom init para decodificação flexível
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        eventId = (try? container.decode(String.self, forKey: .eventId)) ?? ""
        sellerId = (try? container.decode(String.self, forKey: .sellerId)) ?? ""
        name = (try? container.decode(String.self, forKey: .name)) ?? ""
        price = (try? container.decode(Double.self, forKey: .price)) ?? 0.0
        originalPrice = try? container.decode(Double.self, forKey: .originalPrice)
        ticketType = TicketType(rawValue: (try? container.decode(String.self, forKey: .ticketType)) ?? "general") ?? .general
        status = TicketStatus(rawValue: (try? container.decode(String.self, forKey: .status)) ?? "available") ?? .available
        isFavorited = (try? container.decode(Bool.self, forKey: .isFavorited)) ?? false
        
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
        case id, name, price, status
        case eventId = "event_id"
        case sellerId = "seller_id"
        case originalPrice = "original_price"
        case ticketType = "ticket_type"
        case validUntil = "valid_until"
        case createdAt = "created_at"
        case isFavorited = "is_favorited"
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
    public let price: Double
    public let originalPrice: Double?
    public let ticketType: TicketType
    public let validUntil: Date
    
    public init(
        eventId: String,
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
    
    enum CodingKeys: String, CodingKey {
        case eventId = "eventId"  // Mudou para camelCase conforme exemplo
        case name
        case price
        case originalPrice = "originalPrice"
        case ticketType = "ticketType" 
        case validUntil = "validUntil"
    }
}

public struct UpdateTicketRequest: Codable {
    public let name: String
    public let price: Double
    public let originalPrice: Double?
    public let ticketType: TicketType
    
    public init(
        name: String,
        price: Double,
        originalPrice: Double? = nil,
        ticketType: TicketType
    ) {
        self.name = name
        self.price = price
        self.originalPrice = originalPrice
        self.ticketType = ticketType
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case price
        case originalPrice = "originalPrice"
        case ticketType = "ticketType"
    }
}

public struct CreateTicketResponse: Codable {
    public let id: String
    public let eventId: String?
    public let sellerId: String?  // OPCIONAL - não é mais retornado pela API por segurança
                                  // O sellerId é injetado automaticamente no backend via JWT
    public let name: String
    public let price: Double
    public let originalPrice: Double?
    public let ticketType: String?
    public let status: String?
    public let validUntil: String?
    public let createdAt: String?
    public let isFavorited: Bool?
    public let message: String?
    public let success: Bool?
    
    // Custom init para decodificação flexível
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        eventId = try? container.decode(String.self, forKey: .eventId)
        
        // sellerId é completamente opcional pois é injetado no backend via JWT
        // Usa decodeIfPresent para não falhar se a chave não existir
        sellerId = try? container.decodeIfPresent(String.self, forKey: .sellerId)
                  
        name = (try? container.decode(String.self, forKey: .name)) ?? ""
        price = (try? container.decode(Double.self, forKey: .price)) ?? 0.0
        originalPrice = try? container.decodeIfPresent(Double.self, forKey: .originalPrice)
        ticketType = try? container.decodeIfPresent(String.self, forKey: .ticketType)
        status = try? container.decodeIfPresent(String.self, forKey: .status)
        validUntil = try? container.decodeIfPresent(String.self, forKey: .validUntil)
        createdAt = try? container.decodeIfPresent(String.self, forKey: .createdAt)
        isFavorited = try? container.decodeIfPresent(Bool.self, forKey: .isFavorited)
        message = try? container.decodeIfPresent(String.self, forKey: .message)
        success = try? container.decodeIfPresent(Bool.self, forKey: .success)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case sellerId = "seller_id"
        case name
        case price
        case originalPrice = "original_price"
        case ticketType = "ticket_type"
        case status
        case validUntil = "valid_until"
        case createdAt = "created_at"
        case isFavorited = "is_favorited"
        case message
        case success
    }
    
    // Converte para Ticket
    public func toTicket() -> Ticket {
        var ticket = Ticket(
            eventId: eventId ?? "",
            // sellerId pode não existir na resposta pois vem do JWT no backend
            // Usar um ID padrão ou vazio quando não fornecido
            sellerId: sellerId ?? "", // String vazia quando não fornecido pelo backend
            name: name,
            price: price,
            ticketType: TicketType(rawValue: ticketType ?? "general") ?? .general,
            validUntil: Date() // Será parseado abaixo
        )
        
        ticket.id = id
        ticket.originalPrice = originalPrice
        ticket.status = TicketStatus(rawValue: status ?? "available") ?? .available
        ticket.isFavorited = isFavorited ?? false
        
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
        
        let validUntilString = validUntil ?? ""
        if !validUntilString.isEmpty {
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: validUntilString) {
                    ticket.validUntil = date
                    break
                }
            }
        }
        
        let createdAtString = createdAt ?? ""
        if !createdAtString.isEmpty {
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: createdAtString) {
                    ticket.createdAt = date
                    break
                }
            }
        }
        
        return ticket
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
    
    // Custom init para decodificação flexível
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        eventId = try? container.decode(String.self, forKey: .eventId)
        event_id = try? container.decode(String.self, forKey: .event_id)
        sellerId = try? container.decode(String.self, forKey: .sellerId)
        seller_id = try? container.decode(String.self, forKey: .seller_id)
        name = try container.decode(String.self, forKey: .name)
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
    }
    
    enum CodingKeys: String, CodingKey {
        case id, eventId, event_id, sellerId, seller_id, name, price
        case originalPrice, original_price, ticketType, ticket_type, status
        case validUntil, valid_until, createdAt, created_at
        case isFavorited, is_favorited
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
}

// MARK: - TicketDetail API Response Model

public struct APITicketDetailResponse: Codable {
    let id: String
    let ticketId: String? // Agora opcional pois nem sempre a API retorna
    let ticket_id: String? // Para compatibilidade com snake_case
    let event: APIEventResponse
    let seller: APIUserResponse
    let price: Double
    let quantity: Int
    let ticketType: String?
    let ticket_type: String? // Para compatibilidade com snake_case
    let validUntil: String?
    let valid_until: String? // Para compatibilidade com snake_case
    let isTransferable: Bool?
    let is_transferable: Bool? // Para compatibilidade com snake_case
    let qrCode: String?
    let qr_code: String? // Para compatibilidade com snake_case
    let purchaseDate: String?
    let purchase_date: String? // Para compatibilidade com snake_case
    let status: String
    
    // Custom init para decodificação flexível
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        ticketId = try? container.decode(String.self, forKey: .ticketId)
        ticket_id = try? container.decode(String.self, forKey: .ticket_id)
        event = try container.decode(APIEventResponse.self, forKey: .event)
        seller = try container.decode(APIUserResponse.self, forKey: .seller)
        price = try container.decode(Double.self, forKey: .price)
        quantity = (try? container.decode(Int.self, forKey: .quantity)) ?? 1
        ticketType = try? container.decode(String.self, forKey: .ticketType)
        ticket_type = try? container.decode(String.self, forKey: .ticket_type)
        validUntil = try? container.decode(String.self, forKey: .validUntil)
        valid_until = try? container.decode(String.self, forKey: .valid_until)
        isTransferable = try? container.decode(Bool.self, forKey: .isTransferable)
        is_transferable = try? container.decode(Bool.self, forKey: .is_transferable)
        qrCode = try? container.decode(String.self, forKey: .qrCode)
        qr_code = try? container.decode(String.self, forKey: .qr_code)
        purchaseDate = try? container.decode(String.self, forKey: .purchaseDate)
        purchase_date = try? container.decode(String.self, forKey: .purchase_date)
        status = (try? container.decode(String.self, forKey: .status)) ?? "available"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, ticketId, ticket_id, event, seller, price, quantity
        case ticketType, ticket_type, validUntil, valid_until
        case isTransferable, is_transferable, qrCode, qr_code
        case purchaseDate, purchase_date, status
    }
    
    // Computed properties para conversão
    var finalTicketId: String {
        // Usa ticketId, depois ticket_id, depois id como fallback
        return ticketId ?? ticket_id ?? id
    }
    
    var finalTicketType: String {
        return ticketType ?? ticket_type ?? "general"
    }
    
    var finalValidUntil: String {
        return validUntil ?? valid_until ?? ""
    }
    
    var finalIsTransferable: Bool {
        return isTransferable ?? is_transferable ?? true
    }
    
    var finalQrCode: String? {
        return qrCode ?? qr_code
    }
    
    var finalPurchaseDate: String? {
        return purchaseDate ?? purchase_date
    }
}

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
            price: self.price,
            ticketType: TicketType(rawValue: self.finalTicketType) ?? .general,
            validUntil: Date() // Placeholder, será substituído abaixo
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
            price: self.price,
            quantity: self.quantity,
            ticketType: TicketType(rawValue: self.finalTicketType) ?? .general,
            validUntil: Date() // Placeholder, será substituído abaixo
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
