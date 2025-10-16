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
        public var isFavorited: Bool = false
        
        public init(eventId: UUID, event: Event? = nil) {
            self.eventId = eventId
            self.event = event
        }
    }
    
    public enum Action: Equatable {
        case onAppear(UUID, Event?) // ✅ Agora recebe o evento opcional
        case loadEvent(UUID)
        case eventResponse(Result<Event, NetworkError>)
        case viewAvailableTickets
        case sellTicketForEvent // ✅ Nova action para vender ingresso para este evento
        case toggleFavorite
        case checkFavoriteStatus
        case favoriteStatusLoaded(Bool)
    }
    
    @Dependency(\.eventsClient) var eventsClient
    @Dependency(\.favoritesClient) var favoritesClient
    
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
                    // Verifica se está favoritado
                    return .run { send in
                        await send(.checkFavoriteStatus)
                    }
                } else {
                    print("🔄 Evento não fornecido, fazendo chamada API")
                    return .run { send in
                        await send(.loadEvent(eventId))
                        await send(.checkFavoriteStatus)
                    }
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
                // Verifica status de favorito após carregar o evento
                return .run { send in
                    await send(.checkFavoriteStatus)
                }
                
            case let .eventResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .viewAvailableTickets:
                // Esta action será tratada pelo parent (SocialAppFeature)
                return .none
                
            case .sellTicketForEvent:
                // Esta action será tratada pelo parent (SocialAppFeature)
                return .none
                
            case .toggleFavorite:
                guard let event = state.event else { 
                    print("⚠️ Tentou favoritar mas evento é nil")
                    return .none 
                }
                
                if state.isFavorited {
                    // Remove dos favoritos
                    print("❌ Removendo evento dos favoritos: \(event.name)")
                    return .run { [eventId = state.eventId] send in
                        await favoritesClient.removeFromFavorites(eventId.uuidString)
                        print("✅ Evento removido dos favoritos")
                        await send(.favoriteStatusLoaded(false))
                    }
                } else {
                    // Adiciona aos favoritos
                    print("❤️ Adicionando evento aos favoritos: \(event.name)")
                    return .run { send in
                        await favoritesClient.addToFavorites(event)
                        print("✅ Evento adicionado aos favoritos")
                        await send(.favoriteStatusLoaded(true))
                    }
                }
                
            case .checkFavoriteStatus:
                return .run { [eventId = state.eventId] send in
                    print("🔍 Verificando status de favorito para evento: \(eventId)")
                    let isFavorited = await favoritesClient.isFavorite(eventId.uuidString)
                    print("💚 Status de favorito carregado: \(isFavorited)")
                    await send(.favoriteStatusLoaded(isFavorited))
                }
                
            case let .favoriteStatusLoaded(isFavorited):
                print("✅ Atualizando estado de favorito para: \(isFavorited)")
                state.isFavorited = isFavorited
                return .none
            }
        }
    }
}
