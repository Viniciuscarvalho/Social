import Foundation

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