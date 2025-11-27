import Foundation

// MARK: - Ticket Domain Model

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
  
  public init(
    eventId: String,
    sellerId: String,
    name: String,
    description: String? = nil,
    price: Double,
    ticketType: TicketType,
    validUntil: Date,
    quantity: Int = 1,
    currencyCode: String = "BRL",
    imageUrls: [String]? = nil
  ) {
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

// MARK: - TicketType Domain Model

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

// MARK: - TicketStatus Domain Model

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

// MARK: - TicketDetail Domain Model

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
  
  public init(
    ticketId: String,
    event: Event,
    seller: User,
    name: String? = nil,
    description: String? = nil,
    price: Double,
    quantity: Int,
    currencyCode: String = "BRL",
    ticketType: TicketType,
    validUntil: Date,
    imageUrls: [String]? = nil
  ) {
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

