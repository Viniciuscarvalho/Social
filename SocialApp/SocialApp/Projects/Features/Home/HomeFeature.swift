import ComposableArchitecture
import Foundation

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var homeContent: HomeContent = HomeContent()
        public var isLoading: Bool = false
        public var selectedEventSection: EventSection = .curated
        public var searchText: String = ""
        public var showSearchSheet: Bool = false
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadHomeContent
        case homeContentLoaded(HomeContent)
        case eventSectionSelected(EventSection)
        case eventSelected(String)
        case ticketSelected(String)
        case searchButtonTapped
        case searchTextChanged(String)
        case dismissSearch
        case refreshHome
        case showSearchSheetChanged(Bool)
    }
    
    public init() {}
    
    @Dependency(\.homeClient) var homeClient
    @Dependency(\.eventsClient) var eventsClient
    @Dependency(\.ticketsClient) var ticketsClient
    @Dependency(\.userClient) var userClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Só carrega se não tiver dados ainda
                guard state.homeContent.curatedEvents.isEmpty && state.homeContent.trendingEvents.isEmpty else {
                    return .none
                }
                state.isLoading = true
                return .run { send in
                    do {
                        let homeContent = try await homeClient.loadHomeContent()
                        await send(.homeContentLoaded(homeContent))
                    } catch {
                        // Handle error
                        await send(.homeContentLoaded(HomeContent()))
                    }
                }
                
            case .loadHomeContent:
                state.isLoading = true
                return .run { send in
                    do {
                        let homeContent = try await homeClient.loadHomeContent()
                        await send(.homeContentLoaded(homeContent))
                    } catch {
                        // Handle error
                        await send(.homeContentLoaded(HomeContent()))
                    }
                }
                
            case let .homeContentLoaded(homeContent):
                state.homeContent = homeContent
                state.isLoading = false
                return .none
                
            case let .eventSectionSelected(section):
                state.selectedEventSection = section
                return .none
                
            case .eventSelected:
                return .none // Handled by parent
                
            case .ticketSelected:
                return .none // Handled by parent
                
            case .searchButtonTapped:
                state.showSearchSheet = true
                return .none
                
            case let .searchTextChanged(text):
                state.searchText = text
                return .none
                
            case .dismissSearch:
                state.showSearchSheet = false
                state.searchText = ""
                return .none
                
            case .refreshHome:
                return .run { send in
                    await send(.loadHomeContent)
                }
                
            case let .showSearchSheetChanged(isShown):
                state.showSearchSheet = isShown
                return .none
            }
        }
    }
}
