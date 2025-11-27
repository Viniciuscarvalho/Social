import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct FavoritesView: View {
    @Bindable var store: StoreOf<FavoritesFeature>
    
    public init(store: StoreOf<FavoritesFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if store.isLoading {
                    DSFullScreenLoading(message: "Carregando favoritos...")
                } else if !store.hasFavorites {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: DSSpacing.m) {
                            ForEach(Array(store.favoriteEvents.enumerated()), id: \.element.eventId) { index, favorite in
                                FavoriteEventCard(favorite: favorite) {
                                    if let eventId = UUID(uuidString: favorite.eventId) {
                                        store.send(.eventSelected(eventId))
                                    }
                                } onRemove: {
                                    store.send(.removeFromFavorites(favorite.eventId))
                                }
                                .dsEnterAnimation(isVisible: true, delay: Double(index) * 0.05)
                            }
                        }
                        .padding(DSSpacing.m)
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
        .onDisappear {
            store.send(.onDisappear)
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        DSEmptyState(
            icon: "heart.fill",
            title: String(localized: "empty_state.favorites.title"),
            message: String(localized: "empty_state.favorites.message"),
            actionTitle: String(localized: "empty_state.favorites.add_button"),
            action: {
                store.send(.navigateToEvents)
            }
        )
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
                    .fill(DSColors.backgroundTertiary)
            }
            .frame(width: 80, height: 80)
            .dsCornerRadius(DSRadius.medium)
            
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(favorite.eventName)
                    .font(DSTypography.headline())
                    .foregroundColor(DSColors.textPrimary)
                    .lineLimit(2)
                
                Text(favorite.eventLocation)
                    .font(DSTypography.subheadline())
                    .foregroundColor(DSColors.textSecondary)
                
                if let eventDate = favorite.eventDate {
                    Text(eventDate, style: .date)
                        .font(DSTypography.caption1())
                        .foregroundColor(DSColors.primary)
                } else {
                    Text("Data a definir")
                        .font(DSTypography.caption1())
                        .foregroundColor(DSColors.textTertiary)
                }
                
                Text("Favoritado em \(favorite.favoriteDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(DSTypography.caption2())
                    .foregroundColor(DSColors.textTertiary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: DSSpacing.xs) {
                Text("R$ \(favorite.eventPrice, specifier: "%.2f")")
                    .font(DSTypography.headline())
                    .foregroundColor(DSColors.primary)
                
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16))
                        .foregroundColor(DSColors.error)
                        .padding(DSSpacing.xs)
                        .background(DSColors.error.opacity(0.1))
                        .clipShape(Circle())
                }
                .dsTapFeedback()
            }
        }
        .padding(DSSpacing.m)
        .background(DSColors.cardBackground)
        .dsCornerRadius(DSRadius.medium)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
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
