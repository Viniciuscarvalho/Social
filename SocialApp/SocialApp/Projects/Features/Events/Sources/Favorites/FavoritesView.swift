import ComposableArchitecture
import SwiftUI

public struct FavoritesView: View {
    @Bindable var store: StoreOf<FavoritesFeature>
    
    public init(store: StoreOf<FavoritesFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if store.isLoading {
                    ProgressView("Carregando favoritos...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if store.favoriteEvents.isEmpty {
                    ContentUnavailableView {
                        Label("Nenhum favorito", systemImage: "heart")
                    } description: {
                        Text("Os eventos que você favoritar aparecerão aqui")
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(store.favoriteEvents, id: \.eventId) { favorite in
                                FavoriteEventCard(favorite: favorite) {
                                    if let eventId = UUID(uuidString: favorite.eventId) {
                                        store.send(.eventSelected(eventId))
                                    }
                                } onRemove: {
                                    store.send(.removeFromFavorites(favorite.eventId))
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                store.send(.loadFavorites)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct FavoriteEventCard: View {
    let favorite: FavoriteEvent
    let action: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: favorite.eventImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 80, height: 80)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(favorite.eventName)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(favorite.eventLocation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let eventDate = favorite.eventDate {
                    Text(eventDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.blue)
                } else {
                    Text("Data a definir")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text("Favoritado em \(favorite.favoriteDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("R$ \(favorite.eventPrice, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}

// Placeholder view para ser removida depois
public struct FavoritesPlaceholderView: View {
    public init() {}
    
    public var body: some View {
        FavoritesView(
            store: Store(initialState: FavoritesFeature.State()) {
                FavoritesFeature()
            }
        )
    }
}

#Preview {
    FavoritesView(
        store: Store(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        }
    )
}