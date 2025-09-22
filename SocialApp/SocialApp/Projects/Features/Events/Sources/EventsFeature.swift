import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct EventsFeature {
    @ObservableState
    public struct State: Equatable {
        public var user: User?
        public var events: [Event] = []
        public var filteredEvents: [Event] = []
        public var recommendedEvents: [Event] = []
        public var popularCategories: [EventCategory] = []
        public var searchText: String = ""
        public var selectedFilter: SearchFilter = SearchFilter()
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init() {
            self.popularCategories = Array(EventCategory.allCases.prefix(4))
        }
        
        // Computed property para eventos filtrados
        public var displayEvents: [Event] {
            filteredEvents.isEmpty ? events : filteredEvents
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadEvents
        case loadUser
        case eventsResponse(Result<[Event], APIError>)
        case userResponse(Result<User, APIError>)
        case searchTextChanged(String)
        case categorySelected(EventCategory?)
        case showAllCategoriesPressed
        case eventSelected(Event.ID)
        case favoriteToggled(Event.ID)
        case refreshRequested
    }
    
    @Dependency(\.eventsClient) var eventsClient
    @Dependency(\.userClient) var userClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.loadUser),
                    .send(.loadEvents)
                )
                
            case .loadEvents:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    await send(.eventsResponse(
                        Result { try await eventsClient.fetchEvents() }
                    ))
                }
                
            case .loadUser:
                return .run { send in
                    await send(.userResponse(
                        Result { try await userClient.fetchCurrentUser() }
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
                
            case let .userResponse(.success(user)):
                state.user = user
                return .none
                
            case let .userResponse(.failure(error)):
                state.errorMessage = error.message
                return .none
                
            case let .searchTextChanged(text):
                state.searchText = text
                state.filteredEvents = filterEvents(state.events, with: state.selectedFilter, searchText: text)
                return .none
                
            case let .categorySelected(category):
                state.selectedFilter.category = category
                state.filteredEvents = filterEvents(state.events, with: state.selectedFilter, searchText: state.searchText)
                return .none
                
            case .showAllCategoriesPressed:
                // Navigate to categories screen
                return .none
                
            case let .eventSelected(eventID):
                // Navigate to event detail
                return .none
                
            case let .favoriteToggled(eventID):
                if let index = state.events.firstIndex(where: { $0.id == eventID }) {
                    // Toggle favorite logic would be handled by a favorites client
                }
                return .none
                
            case .refreshRequested:
                return .send(.loadEvents)
            }
        }
    }
    
    private func filterEvents(_ events: [Event], with filter: SearchFilter, searchText: String) -> [Event] {
        var filtered = events
        
        // Filter by category
        if let category = filter.category {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { event in
                event.name.localizedCaseInsensitiveContains(searchText) ||
                event.description?.localizedCaseInsensitiveContains(searchText) == true ||
                event.location.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by recommended only
        if filter.isRecommendedOnly {
            filtered = filtered.filter(\.isRecommended)
        }
        
        return filtered
    }
}