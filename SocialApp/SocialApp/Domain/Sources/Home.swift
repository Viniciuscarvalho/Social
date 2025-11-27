import Foundation

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

// MARK: - Home Content Models

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

