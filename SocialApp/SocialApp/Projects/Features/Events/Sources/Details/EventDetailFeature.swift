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
        
        public init(eventId: UUID, event: Event? = nil) {
            self.eventId = eventId
            self.event = event
        }
    }
    
    public enum Action: Equatable {
        case onAppear(UUID, Event?) // ✅ Agora recebe o evento opcional
        case loadEvent(UUID)
        case eventResponse(Result<Event, NetworkError>)
    }
    
    @Dependency(\.eventsClient) var eventsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .onAppear(eventId, event):
                state.eventId = eventId
                
                // ✅ Se já temos o evento, não faz chamada API
                if let existingEvent = event {
                    print("✅ Usando evento já carregado: \(existingEvent.name)")
                    state.event = existingEvent
                    return .none
                } else {
                    print("🔄 Evento não fornecido, fazendo chamada API")
                    return .send(.loadEvent(eventId))
                }
                
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
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error)
                        await send(.eventResponse(.failure(networkError)))
                    }
                }
                
            case let .eventResponse(.success(event)):
                state.isLoading = false
                state.event = event
                return .none
                
            case let .eventResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}
