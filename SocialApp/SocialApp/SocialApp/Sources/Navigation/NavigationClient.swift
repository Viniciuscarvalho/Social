import ComposableArchitecture
import Foundation

@DependencyClient
public struct NavigationClient {
    public var navigateToEventDetail: (UUID) async -> Void
    public var navigateToTicketDetail: (UUID) async -> Void
    public var navigateToSellerProfile: (UUID) async -> Void
    public var navigateToTicketsList: (EventCategory?) async -> Void
    
}

extension NavigationClient: DependencyKey {
    public static let liveValue = NavigationClient(
        navigateToEventDetail: { eventId in
            // Logic handled by main app coordinator
        },
        navigateToTicketDetail: { ticketId in
            // Logic handled by main app coordinator
        },
        navigateToSellerProfile: { sellerId in
            // Logic handled by main app coordinator
        },
        navigateToTicketsList: { category in
            // Logic handled by main app coordinator
        }
    )
    
    public static let testValue = NavigationClient()
}

extension DependencyValues {
    public var navigationClient: NavigationClient {
        get { self[NavigationClient.self] }
        set { self[NavigationClient.self] = newValue }
    }
}
