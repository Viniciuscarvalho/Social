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
                        Label {
                            Text("Nenhum favorito")
                        } icon: {
                            Image("unfavorited", bundle: Bundle.main)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 48, height: 48)
                        }
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
                    .fill(AppColors.tertiaryBackground)
            }
            .frame(width: 80, height: 80)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(favorite.eventName)
                    .adaptiveHeadline()
                    .lineLimit(2)
                
                Text(favorite.eventLocation)
                    .adaptiveSubheadline()
                
                if let eventDate = favorite.eventDate {
                    Text(eventDate, style: .date)
                        .font(.caption)
                        .foregroundColor(AppColors.primary)
                } else {
                    Text("Data a definir")
                        .adaptiveCaption()
                }
                
                Text("Favoritado em \(favorite.favoriteDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundColor(AppColors.tertiaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("R$ \(favorite.eventPrice, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
                
                Button(action: onRemove) {
                    Image("favorited", bundle: Bundle.main)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(AppColors.favoriteRed)
                        .padding(8)
                        .background(AppColors.favoriteRed.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .adaptiveCardStyle()
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    FavoritesView(
        store: Store(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        }
    )
}
