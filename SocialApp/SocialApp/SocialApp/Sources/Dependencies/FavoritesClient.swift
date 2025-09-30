import ComposableArchitecture
import SwiftData
import Foundation

// Client para gerenciar favoritos com SwiftData
public struct FavoritesClient {
    public var loadFavorites: @Sendable () async -> [FavoriteEvent]
    public var addToFavorites: @Sendable (Event) async -> Void
    public var removeFromFavorites: @Sendable (String) async -> Void
    public var isFavorite: @Sendable (String) async -> Bool
}

extension FavoritesClient: DependencyKey {
    public static let liveValue = FavoritesClient(
        loadFavorites: {
            return await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    let modelContainer = DataManager.shared.modelContainer
                    let context = ModelContext(modelContainer)
                    
                    let descriptor = FetchDescriptor<FavoriteEvent>(
                        sortBy: [SortDescriptor(\.favoriteDate, order: .reverse)]
                    )
                    
                    do {
                        let favorites = try context.fetch(descriptor)
                        continuation.resume(returning: favorites)
                    } catch {
                        print("Error loading favorites: \(error)")
                        continuation.resume(returning: [])
                    }
                }
            }
        },
        addToFavorites: { event in
            return await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    let modelContainer = DataManager.shared.modelContainer
                    let context = ModelContext(modelContainer)
                    
                    // Verificar se já existe
                    let eventIdString = event.id.uuidString
                    let descriptor = FetchDescriptor<FavoriteEvent>(
                        predicate: #Predicate { $0.eventId == eventIdString }
                    )
                    
                    do {
                        let existing = try context.fetch(descriptor)
                        if existing.isEmpty {
                            let favorite = FavoriteEvent(from: event)
                            context.insert(favorite)
                            try context.save()
                        }
                        continuation.resume(returning: ())
                    } catch {
                        print("Error adding to favorites: \(error)")
                        continuation.resume(returning: ())
                    }
                }
            }
        },
        removeFromFavorites: { eventId in
            return await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    let modelContainer = DataManager.shared.modelContainer
                    let context = ModelContext(modelContainer)
                    
                    let descriptor = FetchDescriptor<FavoriteEvent>(
                        predicate: #Predicate { $0.eventId == eventId }
                    )
                    
                    do {
                        let favorites = try context.fetch(descriptor)
                        for favorite in favorites {
                            context.delete(favorite)
                        }
                        try context.save()
                        continuation.resume(returning: ())
                    } catch {
                        print("Error removing from favorites: \(error)")
                        continuation.resume(returning: ())
                    }
                }
            }
        },
        isFavorite: { eventId in
            return await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    let modelContainer = DataManager.shared.modelContainer
                    let context = ModelContext(modelContainer)
                    
                    let descriptor = FetchDescriptor<FavoriteEvent>(
                        predicate: #Predicate { $0.eventId == eventId }
                    )
                    
                    do {
                        let favorites = try context.fetch(descriptor)
                        continuation.resume(returning: !favorites.isEmpty)
                    } catch {
                        print("Error checking if favorite: \(error)")
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    )
    
    public static let testValue = FavoritesClient(
        loadFavorites: { [] },
        addToFavorites: { _ in },
        removeFromFavorites: { _ in },
        isFavorite: { _ in false }
    )
}

extension DependencyValues {
    public var favoritesClient: FavoritesClient {
        get { self[FavoritesClient.self] }
        set { self[FavoritesClient.self] = newValue }
    }
}

// Manager para SwiftData
public class DataManager {
    public static let shared = DataManager()
    
    public let modelContainer: ModelContainer
    
    private init() {
        do {
            modelContainer = try ModelContainer(
                for: FavoriteEvent.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}