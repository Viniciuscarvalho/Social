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
        public var showFilterSheet: Bool = false
        public var selectedCategory: EventCategory?
        public var filterState: FilterState = FilterState()
        public var selectedTimeFilter: TimeFilter = .all
        
        // Time filter options
        public enum TimeFilter: String, CaseIterable {
            case all = "All"
            case today = "Today"
            case tomorrow = "Tomorrow"
            case thisWeek = "This Week"
        }
        
        // Computed: eventos recomendados
        public var recommendedEvents: [Event] {
            homeContent.curatedEvents.filter { $0.isRecommended }
        }
        
        // Computed: eventos populares (curated ou com maior rating)
        public var popularEvents: [Event] {
            homeContent.curatedEvents.prefix(5).map { $0 }
        }
        
        // Computed: eventos filtrados por tempo
        public var filteredEvents: [Event] {
            let allEvents = homeContent.curatedEvents
            
            switch selectedTimeFilter {
            case .all:
                return allEvents
            case .today:
                return allEvents.filter { event in
                    guard let eventDate = event.eventDate else { return false }
                    return Calendar.current.isDateInToday(eventDate)
                }
            case .tomorrow:
                return allEvents.filter { event in
                    guard let eventDate = event.eventDate else { return false }
                    return Calendar.current.isDateInTomorrow(eventDate)
                }
            case .thisWeek:
                return allEvents.filter { event in
                    guard let eventDate = event.eventDate else { return false }
                    let calendar = Calendar.current
                    return calendar.isDate(eventDate, equalTo: Date(), toGranularity: .weekOfYear)
                }
            }
        }
        
        // Computed: eventos por categoria
        public var eventsByCategory: [EventCategory: [Event]] {
            var dict: [EventCategory: [Event]] = [:]
            let allEvents = homeContent.curatedEvents + homeContent.trendingEvents
            
            for event in allEvents {
                dict[event.category, default: []].append(event)
            }
            
            return dict
        }
        
        // Computed: contagem de eventos por categoria
        public var categoryCounts: [EventCategory: Int] {
            eventsByCategory.mapValues { $0.count }
        }
        
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
        case showFilterSheetChanged(Bool)
        case categorySelected(EventCategory?)
        case filterApplied(FilterState)
        case timeFilterSelected(State.TimeFilter)
        case viewAllRecommended
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
                
            case let .showFilterSheetChanged(isShown):
                state.showFilterSheet = isShown
                return .none
                
            case let .categorySelected(category):
                state.selectedCategory = category
                // Aqui você pode adicionar lógica para filtrar eventos por categoria
                return .none
                
            case let .filterApplied(filterState):
                state.filterState = filterState
                state.showFilterSheet = false
                // Aqui você pode adicionar lógica para aplicar os filtros
                // Por exemplo, recarregar eventos com os filtros aplicados
                return .none
                
            case let .timeFilterSelected(filter):
                state.selectedTimeFilter = filter
                return .none
                
            case .viewAllRecommended:
                return .none // Handled by parent
            }
        }
    }
}
