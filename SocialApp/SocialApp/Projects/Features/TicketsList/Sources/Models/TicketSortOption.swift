import Foundation

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