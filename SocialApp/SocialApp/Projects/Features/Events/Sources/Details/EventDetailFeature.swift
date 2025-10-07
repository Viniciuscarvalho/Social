import ComposableArchitecture
import Foundation

@Reducer
public struct EventDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var eventId: UUID
        public var event: Event?
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init(eventId: UUID) {
            self.eventId = eventId
        }
    }
    
    public enum Action: Equatable {
        case onAppear(UUID)
        case loadEvent(UUID)
        case eventResponse(Result<Event, APIError>)
    }
    
    @Dependency(\.eventsClient) var eventsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .onAppear(eventId):
                state.eventId = eventId
                return .send(.loadEvent(eventId))
                
            case let .loadEvent(eventId):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        print("🎪 Carregando detalhes do evento: \(eventId)")
                        let event = try await eventsClient.fetchEventDetail(eventId)
                        print("✅ Detalhes do evento carregados: \(event.name)")
                        await send(.eventResponse(.success(event)))
                    } catch {
                        print("❌ Erro ao carregar detalhes do evento: \(error.localizedDescription)")
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
