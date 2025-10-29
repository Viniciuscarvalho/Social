import SwiftUI
import ComposableArchitecture

public struct FavoriteButton: View {
    let event: Event
    let isFavorite: Bool
    let onTap: () -> Void
    
    public init(event: Event, isFavorite: Bool, onTap: @escaping () -> Void) {
        self.event = event
        self.isFavorite = isFavorite
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            Image(isFavorite ? "favorited" : "unfavorited", bundle: Bundle.main)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(8)
                .background(Color.white.opacity(0.9))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

@Reducer
public struct EventFavoriteFeature {
    @ObservableState
    public struct State: Equatable {
        public var event: Event
        public var isFavorite: Bool = false
        
        public init(event: Event) {
            self.event = event
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case favoriteStatusLoaded(Bool)
        case toggleFavorite
    }
    
    @Dependency(\.favoritesClient) var favoritesClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let eventId = state.event.id
                return .run { send in
                    let isFavorite = await favoritesClient.isFavorite(eventId)
                    await send(.favoriteStatusLoaded(isFavorite))
                }
                
            case let .favoriteStatusLoaded(isFavorite):
                state.isFavorite = isFavorite
                return .none
                
            case .toggleFavorite:
                let event = state.event
                let currentStatus = state.isFavorite
                
                // Optimistically update the state
                state.isFavorite.toggle()
                
                return .run { send in
                    if currentStatus {
                        await favoritesClient.removeFromFavorites(event.id)
                    } else {
                        await favoritesClient.addToFavorites(event)
                    }
                    // Reload the status to ensure consistency
                    let newStatus = await favoritesClient.isFavorite(event.id)
                    await send(.favoriteStatusLoaded(newStatus))
                }
            }
        }
    }
}

// View que encapsula o botão de favorito com seu próprio store
public struct EventFavoriteView: View {
    @Bindable var store: StoreOf<EventFavoriteFeature>
    
    public init(store: StoreOf<EventFavoriteFeature>) {
        self.store = store
    }
    
    public var body: some View {
        FavoriteButton(
            event: store.event,
            isFavorite: store.isFavorite,
            onTap: {
                store.send(.toggleFavorite)
            }
        )
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let event = Event(
        name: "Sample Event",
        startPrice: 50.0,
        location: Location(
            name: "Sample Venue",
            city: "São Paulo",
            state: "SP",
            country: "Brasil",
            coordinate: Coordinate(latitude: 0, longitude: 0)
        ),
        category: .music
    )
    
    return EventFavoriteView(
        store: Store(initialState: EventFavoriteFeature.State(event: event)) {
            EventFavoriteFeature()
        }
    )
}
