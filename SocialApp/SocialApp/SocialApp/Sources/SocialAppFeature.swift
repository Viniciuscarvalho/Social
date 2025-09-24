import ComposableArchitecture
import SwiftUI
import SharedModels

@Reducer
public struct SocialAppFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedTab: AppTab = .events
        public var eventsFeature = EventsFeature.State()
        public var ticketsListFeature = TicketsListFeature.State()
        public var sellerProfileFeature = SellerProfileFeature.State()
        public var ticketDetailFeature = TicketDetailFeature.State()
        public var navigationPath = NavigationPath()

        public var selectedEventId: UUID?
        public var selectedTicketId: UUID?
        public var selectedSellerId: UUID?
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case tabSelected(AppTab)
        case eventsFeature(EventsFeature.Action)
        case ticketsListFeature(TicketsListFeature.Action)
        case sellerProfileFeature(SellerProfileFeature.Action)
        case ticketDetailFeature(TicketDetailFeature.Action)

        // Navigation actions
        case navigateToEventDetail(UUID)
        case navigateToTicketDetail(UUID)
        case navigateToSellerProfile(UUID)
        
        case dismissEventNavigation(UUID?)
        case dismissTicketNavigation(UUID?)
        case dismissSellerNavigation(UUID?)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.eventsFeature, action: \.eventsFeature) {
            EventsFeature()
        }
        
        Scope(state: \.ticketsListFeature, action: \.ticketsListFeature) {
            TicketsListFeature()
        }
        
        Scope(state: \.sellerProfileFeature, action: \.sellerProfileFeature) {
            SellerProfileFeature()
        }
        
        Scope(state: \.ticketDetailFeature, action: \.ticketDetailFeature) {
            TicketDetailFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case let .navigateToEventDetail(eventId):
                state.selectedEventId = eventId
                return .none
                
            case let .navigateToTicketDetail(ticketId):
                state.selectedTicketId = ticketId
                return .none
                
            case let .navigateToSellerProfile(sellerId):
                state.selectedSellerId = sellerId
                return .none
                
            case .dismissEventNavigation:
                state.selectedEventId = nil
                return .none
                
            case .dismissTicketNavigation:
                state.selectedTicketId = nil
                return .none
                
            case .dismissSellerNavigation:
                state.selectedSellerId = nil
                return .none
                
            // Handle child feature actions that need navigation
            case let .eventsFeature(.eventSelected(eventId)):
                return .send(.navigateToEventDetail(eventId))
                
            case let .ticketsListFeature(.ticketSelected(ticketId)):
                return .send(.navigateToTicketDetail(ticketId))
                
            // Outras actions das features são tratadas pelos seus próprios reducers
            case .eventsFeature:
                return .none
                
            case .ticketsListFeature:
                return .none
                
            case .sellerProfileFeature:
                return .none
                
            case .ticketDetailFeature:
                return .none
            }
        }
    }
}
