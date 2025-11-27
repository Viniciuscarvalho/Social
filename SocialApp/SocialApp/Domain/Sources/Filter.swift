import Foundation

// MARK: - Search Filter Models

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

// MARK: - Tickets List Filter Models

public struct TicketsListFilter: Codable, Equatable {
  public var category: EventCategory?
  public var priceRange: PriceRange?
  public var ticketType: TicketType?
  public var status: TicketStatus?
  public var sortBy: TicketSortOption
  public var showFavoritesOnly: Bool
  public var eventId: String?
  
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

