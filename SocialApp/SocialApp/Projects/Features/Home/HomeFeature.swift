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
        
        // Implementação manual de Equatable para cases com parâmetros
        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.onAppear, .onAppear),
                 (.loadHomeContent, .loadHomeContent),
                 (.searchButtonTapped, .searchButtonTapped),
                 (.dismissSearch, .dismissSearch),
                 (.refreshHome, .refreshHome):
                return true
                
            case let (.homeContentLoaded(content1), .homeContentLoaded(content2)):
                return content1 == content2
                
            case let (.eventSectionSelected(section1), .eventSectionSelected(section2)):
                return section1 == section2
                
            case let (.eventSelected(id1), .eventSelected(id2)):
                return id1 == id2
                
            case let (.ticketSelected(id1), .ticketSelected(id2)):
                return id1 == id2
                
            case let (.searchTextChanged(text1), .searchTextChanged(text2)):
                return text1 == text2
                
            case let (.showSearchSheetChanged(bool1), .showSearchSheetChanged(bool2)):
                return bool1 == bool2
                
            default:
                return false
            }
        }
    }
    
    public init() {}
    
    @Dependency(\.homeClient) var homeClient
    @Dependency(\.eventsClient) var eventsClient
    @Dependency(\.ticketsClient) var ticketsClient
    @Dependency(\.userClient) var userClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .loadHomeContent:
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
