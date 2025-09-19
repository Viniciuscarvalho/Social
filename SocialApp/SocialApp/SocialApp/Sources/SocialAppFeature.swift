import ComposableArchitecture
import Events
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
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case tabSelected(AppTab)
        case eventsFeature(EventsFeature.Action)
        case ticketsListFeature(TicketsListFeature.Action)
        // case favoritesFeature(FavoritesFeature.Action)
        // case profileFeature(ProfileFeature.Action)
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
                
            case .eventsFeature:
                return .none
                
            case .ticketsListFeature:
                return .none
            }
        }
    }
}