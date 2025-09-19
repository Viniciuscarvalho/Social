import Foundation

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