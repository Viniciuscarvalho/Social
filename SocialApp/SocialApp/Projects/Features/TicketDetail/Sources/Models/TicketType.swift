import Foundation

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