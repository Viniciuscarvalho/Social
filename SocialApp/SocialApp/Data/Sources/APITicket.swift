import Foundation
import Domain

// MARK: - API Ticket DTO

public struct APITicketResponse: Codable {
  let id: String
  let eventId: String?
  let event_id: String?
  let sellerId: String?
  let seller_id: String?
  let name: String
  let description: String?
  let price: Double
  let originalPrice: Double?
  let original_price: Double?
  let ticketType: String?
  let ticket_type: String?
  let status: String
  let validUntil: String?
  let valid_until: String?
  let createdAt: String?
  let created_at: String?
  let isFavorited: Bool?
  let is_favorited: Bool?
  let quantity: Int?
  let currencyCode: String?
  let currency_code: String?
  let imageUrls: [String]?
  let image_urls: [String]?
  
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
  
  var finalEventId: String {
    return eventId ?? event_id ?? ""
  }
  
  var finalSellerId: String {
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

// MARK: - Mapper: APITicketResponse -> Ticket

extension APITicketResponse {
  public func toTicket() -> Ticket {
    let parseDate: (String) -> Date = { dateString in
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      let dateFormats = [
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
        "yyyy-MM-dd HH:mm:ss",
        "yyyy-MM-dd"
      ]
      for format in dateFormats {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: dateString) {
          return date
        }
      }
      return Date()
    }
    
    var ticket = Ticket(
      eventId: self.finalEventId,
      sellerId: self.finalSellerId,
      name: self.name,
      description: self.description,
      price: self.price,
      ticketType: TicketType(rawValue: self.finalTicketType) ?? .general,
      validUntil: parseDate(self.finalValidUntil),
      quantity: self.finalQuantity,
      currencyCode: self.finalCurrencyCode,
      imageUrls: self.finalImageUrls
    )
    
    ticket.id = self.id
    ticket.originalPrice = self.finalOriginalPrice
    ticket.status = TicketStatus(rawValue: self.status) ?? .available
    ticket.isFavorited = self.finalIsFavorited
    ticket.createdAt = parseDate(self.finalCreatedAt)
    
    return ticket
  }
}

// MARK: - Tickets List Response

public struct TicketsListResponse: Codable {
  public let tickets: [APITicketResponse]
  public let pagination: PaginationInfo
  
  public init(tickets: [APITicketResponse], pagination: PaginationInfo) {
    self.tickets = tickets
    self.pagination = pagination
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    var ticketsArray: [APITicketResponse]?
    
    ticketsArray = try? container.decode([APITicketResponse].self, forKey: .tickets)
    
    if ticketsArray == nil {
      if let dataContainer = try? container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data) {
        ticketsArray = try? dataContainer.decode([APITicketResponse].self, forKey: .tickets)
      }
    }
    
    if ticketsArray == nil {
      ticketsArray = try? container.decode([APITicketResponse].self, forKey: .data)
    }
    
    self.tickets = ticketsArray ?? []
    
    do {
      self.pagination = try container.decode(PaginationInfo.self, forKey: .pagination)
    } catch {
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

// MARK: - Ticket Request Models

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
    case name, description, price, quantity
    case eventId = "event_id"
    case originalPrice = "original_price"
    case ticketType = "ticket_type"
    case validUntil = "valid_until"
    case currencyCode = "currency_code"
  }
}

public struct PurchaseTicketRequest: Codable {
  public let ticketId: String
  
  public init(ticketId: String) {
    self.ticketId = ticketId
  }
  
  enum CodingKeys: String, CodingKey {
    case ticketId = "ticket_id"
  }
}

public struct FavoriteTicketRequest: Codable {
  public let ticketId: String
  
  public init(ticketId: String) {
    self.ticketId = ticketId
  }
  
  enum CodingKeys: String, CodingKey {
    case ticketId = "ticket_id"
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

// MARK: - Create Ticket Response

public struct CreateTicketResponse: Codable {
  public let id: String
  public let eventId: String?
  public let sellerId: String?  // OPCIONAL - não é mais retornado pela API por segurança
                                // O sellerId é injetado automaticamente no backend via JWT
  public let name: String
  public let description: String?
  public let price: Double
  public let originalPrice: Double?
  public let ticketType: String?
  public let status: String?
  public let validUntil: String?
  public let createdAt: String?
  public let isFavorited: Bool?
  public let quantity: Int?
  public let currencyCode: String?
  public let imageUrls: [String]?
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
    description = try? container.decodeIfPresent(String.self, forKey: .description)
    price = (try? container.decode(Double.self, forKey: .price)) ?? 0.0
    originalPrice = try? container.decodeIfPresent(Double.self, forKey: .originalPrice)
    ticketType = try? container.decodeIfPresent(String.self, forKey: .ticketType)
    status = try? container.decodeIfPresent(String.self, forKey: .status)
    validUntil = try? container.decodeIfPresent(String.self, forKey: .validUntil)
    createdAt = try? container.decodeIfPresent(String.self, forKey: .createdAt)
    isFavorited = try? container.decodeIfPresent(Bool.self, forKey: .isFavorited)
    quantity = try? container.decodeIfPresent(Int.self, forKey: .quantity)
    currencyCode = try? container.decodeIfPresent(String.self, forKey: .currencyCode)
    imageUrls = try? container.decodeIfPresent([String].self, forKey: .imageUrls)
    message = try? container.decodeIfPresent(String.self, forKey: .message)
    success = try? container.decodeIfPresent(Bool.self, forKey: .success)
  }
  
  enum CodingKeys: String, CodingKey {
    case id
    case eventId = "event_id"
    case sellerId = "seller_id"
    case name
    case description
    case price
    case originalPrice = "original_price"
    case ticketType = "ticket_type"
    case status
    case validUntil = "valid_until"
    case createdAt = "created_at"
    case isFavorited = "is_favorited"
    case quantity
    case currencyCode = "currency_code"
    case imageUrls = "image_urls"
    case message
    case success
  }
}

// MARK: - Mapper: CreateTicketResponse -> Ticket

extension CreateTicketResponse {
  public func toTicket() -> Ticket {
    var ticket = Ticket(
      eventId: eventId ?? "",
      // sellerId pode não existir na resposta pois vem do JWT no backend
      // Usar um ID padrão ou vazio quando não fornecido
      sellerId: sellerId ?? "", // String vazia quando não fornecido pelo backend
      name: name,
      description: description,
      price: price,
      ticketType: TicketType(rawValue: ticketType ?? "general") ?? .general,
      validUntil: Date(), // Será parseado abaixo
      quantity: quantity ?? 1,
      currencyCode: currencyCode ?? "BRL",
      imageUrls: imageUrls
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

