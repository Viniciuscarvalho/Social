import ComposableArchitecture
import Events
import SharedModels
import SwiftUI
import TicketsList

@Reducer
public struct SocialAppFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedTab: AppTab = .events
        public var eventsFeature = EventsFeature.State()
        public var ticketsListFeature = TicketsListFeature.State()
        // public var favoritesFeature = FavoritesFeature.State()
        // public var profileFeature = ProfileFeature.State()
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
        // case favoritesFeature(FavoritesFeature.Action)
        // case profileFeature(ProfileFeature.Action)

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
                
            case .eventsFeature:
                return .none
                
            case .ticketsListFeature:
                return .none
            }
        }
    }
}
