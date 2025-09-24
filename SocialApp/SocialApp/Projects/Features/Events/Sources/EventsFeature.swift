import ComposableArchitecture
import Foundation
import SharedModels

@Reducer
public struct EventsFeature {
    @ObservableState
    public struct State: Equatable {
        public var events: [Event] = []
        public var filteredEvents: [Event] = []
        public var recommendedEvents: [Event] = []
        public var popularCategories: [EventCategory] = []
        public var searchText: String = ""
        public var selectedFilter: SearchFilter = SearchFilter()
        public var isLoading: Bool = false
        public var errorMessage: String?
        public var user: User?
        
        public init() {
            self.popularCategories = Array(EventCategory.allCases.prefix(4))
            self.user = User(name: "João Silva", profileImageURL: "https://via.placeholder.com/40")
        }
        
        public var displayEvents: [Event] {
            filteredEvents.isEmpty ? events : filteredEvents
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadEvents
        case eventsResponse(Result<[Event], APIError>)
        case searchTextChanged(String)
        case categorySelected(EventCategory?)
        case eventSelected(UUID)
        case refreshRequested
        case favoriteToggled(UUID)
        case showAllCategoriesPressed
    }
    
    @Dependency(\.eventsClient) var eventsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadEvents)
                
            case .loadEvents:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    await send(.eventsResponse(
                        Result { try await eventsClient.fetchEvents() }
                    ))
                }
                
            case let .eventsResponse(.success(events)):
                state.isLoading = false
                state.events = events
                state.recommendedEvents = events.filter(\.isRecommended)
                state.filteredEvents = filterEvents(events, with: state.selectedFilter, searchText: state.searchText)
                return .none
                
            case let .eventsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.message
                return .none
                
            case let .searchTextChanged(text):
                state.searchText = text
                if !text.isEmpty {
                    return .run { send in
                        await send(.eventsResponse(
                            Result { try await eventsClient.searchEvents(text) }
                        ))
                    }
                } else {
                    return .send(.loadEvents)
                }
                
            case let .categorySelected(category):
                state.selectedFilter.category = category
                if let category = category {
                    return .run { send in
                        await send(.eventsResponse(
                            Result { try await eventsClient.fetchEventsByCategory(category) }
                        ))
                    }
                } else {
                    return .send(.loadEvents)
                }
                
            case .eventSelected:
                return .none
                
            case .favoriteToggled:
                return .none
                
            case .showAllCategoriesPressed:
                return .none
                
            case .refreshRequested:
                return .send(.loadEvents)
            }
        }
    }
    
    private func filterEvents(_ events: [Event], with filter: SearchFilter, searchText: String) -> [Event] {
        var filtered = events
        
        if let category = filter.category {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { event in
                event.name.localizedCaseInsensitiveContains(searchText) ||
                event.description?.localizedCaseInsensitiveContains(searchText) == true ||
                event.location.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if filter.isRecommendedOnly {
            filtered = filtered.filter(\.isRecommended)
        }
        
        return filtered
    }
}
