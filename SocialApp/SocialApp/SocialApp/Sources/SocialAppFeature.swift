import ComposableArchitecture
import Events
import SharedModels
import SwiftUI
import TicketsList
import SellerProfile
import TicketDetail

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
        case dismissEventNavigation
        case dismissTicketNavigation
        case dismissSellerNavigation
    }
    
    // Services injetados
    private let eventsService: EventsService
    private let ticketsService: TicketsService
    private let sellerProfileService: SellerProfileService
    private let ticketDetailService: TicketDetailService
    
    public init(
        eventsService: EventsService = EventsServiceImpl(),
        ticketsService: TicketsService = TicketsServiceImpl(),
        sellerProfileService: SellerProfileService = SellerProfileServiceImpl(),
        ticketDetailService: TicketDetailService = TicketDetailServiceImpl()
    ) {
        self.eventsService = eventsService
        self.ticketsService = ticketsService
        self.sellerProfileService = sellerProfileService
        self.ticketDetailService = ticketDetailService
    }
    
    public var body: some ReducerOf<Self> {
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
                
            // Forward actions para features usando dependency injection
            case let .eventsFeature(eventsAction):
                let eventsFeature = EventsFeature(eventsService: eventsService)
                let effect = eventsFeature.reduce(into: &state.eventsFeature, action: eventsAction)
                return effect.map(Action.eventsFeature)
                
            case let .ticketsListFeature(ticketsAction):
                let ticketsFeature = TicketsListFeature(ticketsService: ticketsService)
                let effect = ticketsFeature.reduce(into: &state.ticketsListFeature, action: ticketsAction)
                return effect.map(Action.ticketsListFeature)
                
            case let .sellerProfileFeature(sellerAction):
                let sellerFeature = SellerProfileFeature(sellerProfileService: sellerProfileService)
                let effect = sellerFeature.reduce(into: &state.sellerProfileFeature, action: sellerAction)
                return effect.map(Action.sellerProfileFeature)
                
            case let .ticketDetailFeature(ticketAction):
                let ticketFeature = TicketDetailFeature(ticketDetailService: ticketDetailService)
                let effect = ticketFeature.reduce(into: &state.ticketDetailFeature, action: ticketAction)
                return effect.map(Action.ticketDetailFeature)
            }
        }
    }
}
