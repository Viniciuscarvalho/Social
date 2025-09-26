import ComposableArchitecture
import Foundation

@Reducer
public struct EventsFeature {
    @ObservableState
    public struct State: Equatable {
        public var events: [Event] = []
        public var searchText: String = ""
        public var selectedCategory: EventCategory?
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public var todayEvent: Event? {
            return events.first { event in
                guard let eventDate = event.eventDate else { return false }
                return Calendar.current.isDate(eventDate, inSameDayAs: Date())
            }
        }

        public var upcomingEvents: [Event] {
            let today = Date()
            return events.filter { event in
                guard let eventDate = event.eventDate else { return false }
                return eventDate > Calendar.current.startOfDay(for: today.addingTimeInterval(24*60*60))
            }.sorted {
                ($0.eventDate ?? Date.distantFuture) < ($1.eventDate ?? Date.distantFuture)
            }
        }
        
        public var user: User? {
            // This would be loaded from UserClient in a real implementation
            return nil
        }
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadEvents
        case eventsResponse(Result<[Event], APIError>)
        case searchTextChanged(String)
        case searchTapped
        case categorySelected(EventCategory?)
        case eventSelected(UUID)
        case refreshRequested
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
                    do {
                        let events = try await eventsClient.fetchEvents()
                        await send(.eventsResponse(.success(events)))
                    } catch {
                        await send(.eventsResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                    }
                }
                
            case let .eventsResponse(.success(events)):
                state.events = events
                state.isLoading = false
                state.errorMessage = nil
                return .none
                
            case let .eventsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.message
                return .none
                
            case let .searchTextChanged(text):
                state.searchText = text
                if !text.isEmpty {
                    return .run { send in
                        do {
                            let events = try await eventsClient.searchEvents(text)
                            await send(.eventsResponse(.success(events)))
                        } catch {
                            await send(.eventsResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                        }
                    }
                } else {
                    return .send(.loadEvents)
                }
                
            case let .categorySelected(category):
                state.selectedCategory = category
                if let category = category {
                    return .run { send in
                        do {
                            let events = try await eventsClient.fetchEventsByCategory(category)
                            await send(.eventsResponse(.success(events)))
                        } catch {
                            await send(.eventsResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                        }
                    }
                } else {
                    return .send(.loadEvents)
                }
                
            case .searchTapped:
                return .none
                
            case .eventSelected:
                return .none
                
            case .refreshRequested:
                return .send(.loadEvents)
            }
        }
    }
}
