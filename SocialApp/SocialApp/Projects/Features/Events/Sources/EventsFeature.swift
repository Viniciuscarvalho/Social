import Foundation
import SharedModels

// Protocolo para dependency injection
public protocol EventsService {
    func fetchEvents() async throws -> [Event]
    func searchEvents(_ query: String) async throws -> [Event]
    func fetchEventsByCategory(_ category: EventCategory) async throws -> [Event]
}

public struct EventsFeature {
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
    
    // Service injetado
    private let eventsService: EventsService
    
    public init(eventsService: EventsService) {
        self.eventsService = eventsService
    }
    
    // Reducer manual sem macro
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return Effect.send(.loadEvents)
            
        case .loadEvents:
            state.isLoading = true
            state.errorMessage = nil
            return Effect.run { send in
                do {
                    let events = try await eventsService.fetchEvents()
                    await send(.eventsResponse(.success(events)))
                } catch {
                    await send(.eventsResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                }
            }
            
        case let .eventsResponse(.success(events)):
            state.isLoading = false
            state.events = events
            state.recommendedEvents = events.filter(\.isRecommended)
            state.filteredEvents = filterEvents(events, with: state.selectedFilter, searchText: state.searchText)
            return Effect.none
            
        case let .eventsResponse(.failure(error)):
            state.isLoading = false
            state.errorMessage = error.message
            return Effect.none
            
        case let .searchTextChanged(text):
            state.searchText = text
            if !text.isEmpty {
                return Effect.run { send in
                    do {
                        let events = try await eventsService.searchEvents(text)
                        await send(.eventsResponse(.success(events)))
                    } catch {
                        await send(.eventsResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                    }
                }
            } else {
                return Effect.send(.loadEvents)
            }
            
        case let .categorySelected(category):
            state.selectedFilter.category = category
            if let category = category {
                return Effect.run { send in
                    do {
                        let events = try await eventsService.fetchEventsByCategory(category)
                        await send(.eventsResponse(.success(events)))
                    } catch {
                        await send(.eventsResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                    }
                }
            } else {
                return Effect.send(.loadEvents)
            }
            
        case .eventSelected:
            return Effect.none
            
        case .favoriteToggled:
            return Effect.none
            
        case .showAllCategoriesPressed:
            return Effect.none
            
        case .refreshRequested:
            return Effect.send(.loadEvents)
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
