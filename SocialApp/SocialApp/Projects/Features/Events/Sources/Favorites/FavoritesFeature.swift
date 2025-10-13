import ComposableArchitecture
import SwiftData
import Foundation

@Reducer
public struct FavoritesFeature {
    @ObservableState
    public struct State: Equatable {
        public var favoriteEvents: [FavoriteEvent] = []
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadFavorites
        case favoritesLoaded([FavoriteEvent])
        case addToFavorites(Event)
        case removeFromFavorites(String) // eventId
        case favoriteToggled(Event)
        case eventSelected(UUID)
    }
    
    @Dependency(\.favoritesClient) var favoritesClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.loadFavorites)
                }
                
            case .loadFavorites:
                state.isLoading = true
                return .run { send in
                    let favorites = await favoritesClient.loadFavorites()
                    await send(.favoritesLoaded(favorites))
                }
                
            case let .favoritesLoaded(favorites):
                state.favoriteEvents = favorites
                state.isLoading = false
                return .none
                
            case let .addToFavorites(event):
                return .run { send in
                    await favoritesClient.addToFavorites(event)
                    await send(.loadFavorites)
                }
                
            case let .removeFromFavorites(eventId):
                return .run { send in
                    await favoritesClient.removeFromFavorites(eventId)
                    await send(.loadFavorites)
                }
                
            case let .favoriteToggled(event):
                let eventIdString = event.id
                let isFavorited = state.favoriteEvents.contains { $0.eventId == eventIdString }
                
                if isFavorited {
                    return .run { send in
                        await send(.removeFromFavorites(eventIdString))
                    }
                } else {
                    return .run { send in
                        await send(.addToFavorites(event))
                    }
                }
                
            case .eventSelected:
                return .none
            }
        }
    }
}