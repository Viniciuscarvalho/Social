import ComposableArchitecture
import Foundation
import SwiftUI

Reducer
public struct EventsFeature {
    @ObservableState
    public struct State: Equatable {
        public var events: [Event] = []
        public var searchText: String = ""
        public var selectedCategory: EventCategory?
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadEvents
        case eventsResponse(Result<[Event], APIError>)
        case searchTextChanged(String)
        case categorySelected(EventCategory?)
        case eventSelected(UUID) // Comunica com parent via action
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
                    await send(.eventsResponse(
                        Result { try await eventsClient.fetchEvents() }
                    ))
                }
                
            case let .eventsResponse(.success(events)):
                state.isLoading = false
                state.events = events
                return .none
                
            case let .eventsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.message
                return .none
                
            case let .searchTextChanged(text):
                state.searchText = text
                // Perform search logic
                return .none
                
            case let .categorySelected(category):
                state.selectedCategory = category
                return .none
                
            case .eventSelected:
                // Action será capturada pelo parent (SocialAppFeature)
                return .none
                
            case .refreshRequested:
                return .send(.loadEvents)
            }
        }
    }
}