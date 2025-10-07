import ComposableArchitecture
import Foundation

@Reducer
public struct EventDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var eventId: String
        public var event: Event?
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init(eventId: String) {
            self.eventId = eventId
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadEvent
        case eventResponse(Result<Event, APIError>)
    }
    
    @Dependency(\.eventsClient) var eventsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadEvent)
                
            case .loadEvent:
                state.isLoading = true
                state.errorMessage = nil
                let id = state.eventId
                return .run { send in
                    do {
                        let event = try await eventsClient.fetchEvent(id)
                        await send(.eventResponse(.success(event)))
                    } catch {
                        let apiError = error as? APIError ?? APIError(message: error.localizedDescription, code: 500)
                        await send(.eventResponse(.failure(apiError)))
                    }
                }
                
            case let .eventResponse(.success(event)):
                state.isLoading = false
                state.event = event
                return .none
                
            case let .eventResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.message
                return .none
            }
        }
    }
}
