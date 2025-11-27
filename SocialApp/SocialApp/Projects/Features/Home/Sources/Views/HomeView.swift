import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    let searchStore: StoreOf<SearchFeature>?
    
    @State private var favoriteStores: [String: StoreOf<EventFavoriteFeature>] = [:]
    
    public init(store: StoreOf<HomeFeature>, searchStore: StoreOf<SearchFeature>? = nil) {
        self.store = store
        self.searchStore = searchStore
    }
    
    private func favoriteStore(for event: Event) -> StoreOf<EventFavoriteFeature> {
        if let existingStore = favoriteStores[event.id] {
            return existingStore
        }
        
        let newStore = Store(initialState: EventFavoriteFeature.State(event: event)) {
            EventFavoriteFeature()
        }
        favoriteStores[event.id] = newStore
        return newStore
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header integrado à página (não fixo)
                headerSection
                    .padding(.horizontal, DSSpacing.m)
                    .padding(.top, DSSpacing.xs)
                
                // Time Filters
                timeFiltersSection
                
                // Recommended Events Section
                if !store.recommendedEvents.isEmpty {
                    recommendedEventsSection
                }
                
                // Popular Events Section
                popularEventsSection
            }
            .padding(.bottom, 100)
        }
        .navigationBarHidden(true)
        .refreshable {
            store.send(.refreshHome)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
        .sheet(isPresented: $store.showSearchSheet.sending(\.showSearchSheetChanged)) {
            if let searchStore = searchStore {
                SearchView(store: searchStore)
                    .onDisappear {
                        store.send(.dismissSearch)
                    }
            } else {
                SearchView(store: Store(initialState: SearchFeature.State()) {
                    SearchFeature()
                })
                .onDisappear {
                    store.send(.dismissSearch)
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // User greeting and profile
            HStack(spacing: 12) {
                // Profile image
                AsyncImage(url: URL(string: store.homeContent.user?.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(DSGradients.primary)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text("Hey! \(store.homeContent.user?.name ?? "User")")
                        .font(DSTypography.body(weight: .semibold))
                        .foregroundColor(DSColors.textPrimary)
                    
                    Text("Let's make your day eventful")
                        .font(DSTypography.footnote())
                        .foregroundColor(DSColors.textSecondary)
                }
                
                Spacer()
                
                // Notification button
                Button {
                    // Notification action
                } label: {
                    ZStack {
                        Circle()
                            .fill(DSColors.backgroundSecondary)
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18))
                            .foregroundColor(DSColors.textPrimary)
                    }
                    .dsTapFeedback()
                }
            }
            
            // Search bar
            Button {
                store.send(.showSearchSheetChanged(true))
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    Text("Search...")
                        .font(DSTypography.body())
                        .foregroundColor(DSColors.textSecondary)
                    
                    Spacer()
                }
                .padding(.horizontal, DSSpacing.m)
                .padding(.vertical, DSSpacing.sm)
                .background(DSColors.backgroundSecondary)
                .dsCornerRadius(DSRadius.medium)
            }
        }
    }
    
    // MARK: - Time Filters Section
    
    private var timeFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(HomeFeature.State.TimeFilter.allCases, id: \.self) { filter in
                    TimeFilterChip(
                        title: filter.rawValue,
                        isSelected: store.selectedTimeFilter == filter
                    ) {
                        store.send(.timeFilterSelected(filter))
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Recommended Events Section
    
    private var recommendedEventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recommended Events")
                    .font(DSTypography.title3(weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
                
                Spacer()
                
                Button {
                    store.send(.viewAllRecommended)
                } label: {
                    Text("View all")
                        .font(DSTypography.footnote(weight: .medium))
                        .foregroundColor(DSColors.primary)
                }
                .dsTapFeedback()
            }
            .padding(.horizontal, DSSpacing.m)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.recommendedEvents.prefix(5)) { event in
                        RecommendedEventCard(event: event, favoriteStore: favoriteStore(for: event)) {
                            store.send(.eventSelected(event.id))
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.m)
            }
        }
    }
    
    // MARK: - Popular Events Section
    
    private var popularEventsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            HStack {
                Text("Popular Event")
                    .font(DSTypography.title3(weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
                
                Spacer()
                
                Button {
                    store.send(.viewAllPopular)
                } label: {
                    Text("View all")
                        .font(DSTypography.footnote(weight: .medium))
                        .foregroundColor(DSColors.primary)
                }
                .dsTapFeedback()
            }
            .padding(.horizontal, DSSpacing.m)
            
            // Category filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryFilterChip(
                        icon: nil,
                        title: "All",
                        isSelected: store.selectedCategory == nil
                    ) {
                        store.send(.categorySelected(nil))
                    }
                    
                    ForEach([EventCategory.music, EventCategory.culture, EventCategory.business], id: \.self) { category in
                        CategoryFilterChip(
                            icon: getCategoryIcon(category),
                            title: getCategoryTitle(category),
                            isSelected: store.selectedCategory == category
                        ) {
                            store.send(.categorySelected(category))
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.m)
            }
            
            // Events list
            VStack(spacing: DSSpacing.m) {
                ForEach(Array(store.filteredEvents.prefix(10).enumerated()), id: \.element.id) { index, event in
                    PopularEventListCard(event: event, favoriteStore: favoriteStore(for: event)) {
                        store.send(.eventSelected(event.id))
                    }
                    .padding(.horizontal, DSSpacing.m)
                    .dsEnterAnimation(isVisible: true, delay: Double(index) * 0.05)
                }
            }
        }
    }
    
    private func getCategoryIcon(_ category: EventCategory) -> String {
        switch category {
        case .music: return "music.note"
        case .culture: return "paintpalette"
        case .business: return "briefcase.fill"
        default: return "star.fill"
        }
    }
    
    private func getCategoryTitle(_ category: EventCategory) -> String {
        switch category {
        case .music: return "Music"
        case .culture: return "Arts"
        case .business: return "Business"
        default: return category.displayName
        }
    }
}

// MARK: - Time Filter Chip

struct TimeFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : DSColors.textPrimary)
                .padding(.horizontal, DSSpacing.m)
                .padding(.vertical, DSSpacing.sm)
                .background(
                    isSelected
                        ? DSGradients.primary
                        : DSColors.backgroundSecondary
                )
                .dsCornerRadius(DSRadius.large)
        }
        .buttonStyle(.plain)
        .dsTapFeedback()
    }
}

// MARK: - Category Filter Chip

struct CategoryFilterChip: View {
    let icon: String?
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                
                Text(title)
                    .font(DSTypography.footnote(weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : DSColors.textPrimary)
            .padding(.horizontal, DSSpacing.m)
            .padding(.vertical, DSSpacing.sm)
            .background(
                isSelected
                    ? DSGradients.primary
                    : DSColors.backgroundSecondary
            )
            .dsCornerRadius(DSRadius.large)
        }
        .buttonStyle(.plain)
        .dsTapFeedback()
    }
}

// MARK: - Recommended Event Card

struct RecommendedEventCard: View {
    let event: Event
    @Bindable var favoriteStore: StoreOf<EventFavoriteFeature>
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Event image with price badge
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .frame(width: 220, height: 160)
                    .clipped()
                    
                    // Price badge
                    Text("$\(Int(event.startPrice))")
                        .font(DSTypography.footnote(weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .background(
                            Capsule()
                                .fill(DSColors.primary)
                        )
                        .padding(DSSpacing.sm)
                }
                .frame(width: 220, height: 160)
                
                // Event info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(event.name)
                            .font(DSTypography.body(weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        FavoriteButton(
                            event: event,
                            isFavorite: favoriteStore.isFavorite,
                            onTap: {
                                favoriteStore.send(.toggleFavorite)
                            }
                        )
                        .onAppear {
                            favoriteStore.send(.onAppear)
                        }
                    }
                    
                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                            .foregroundColor(DSColors.textSecondary)
                        
                        Text(event.dateFormatted)
                            .font(DSTypography.caption1())
                            .foregroundColor(DSColors.textSecondary)
                        
                        Text("•")
                            .font(DSTypography.caption1())
                            .foregroundColor(DSColors.textSecondary)
                        
                        Text(event.timeRange.components(separatedBy: " - ").first ?? "")
                            .font(DSTypography.caption1())
                            .foregroundColor(DSColors.textSecondary)
                    }
                    
                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                            .foregroundColor(DSColors.textSecondary)
                        
                        Text(event.location.name)
                            .font(DSTypography.caption1())
                            .foregroundColor(DSColors.textSecondary)
                            .lineLimit(1)
                    }
                }
                .padding(DSSpacing.sm)
            }
            .frame(width: 220)
            .background(DSColors.cardBackground)
            .dsCornerRadius(DSRadius.large)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Popular Event List Card

struct PopularEventListCard: View {
    let event: Event
    @Bindable var favoriteStore: StoreOf<EventFavoriteFeature>
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Event image with price badge
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(12)
                    
                    // Price badge
                    Text("$\(Int(event.startPrice))")
                        .font(DSTypography.caption1(weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, DSSpacing.xs)
                        .padding(.vertical, DSSpacing.xxs)
                        .background(
                            Capsule()
                                .fill(DSColors.primary)
                        )
                        .padding(DSSpacing.xs)
                }
                
                // Event info
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(event.name)
                        .font(DSTypography.body(weight: .semibold))
                        .foregroundColor(DSColors.textPrimary)
                        .lineLimit(2)
                    
                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                            .foregroundColor(DSColors.textSecondary)
                        
                        Text(event.dateFormatted)
                            .font(DSTypography.caption1())
                            .foregroundColor(DSColors.textSecondary)
                        
                        Text("•")
                            .font(DSTypography.caption1())
                            .foregroundColor(DSColors.textSecondary)
                        
                        Text(event.timeRange.components(separatedBy: " - ").first ?? "")
                            .font(DSTypography.caption1())
                            .foregroundColor(DSColors.textSecondary)
                    }
                    
                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(DSColors.textSecondary)
                        
                        Text(event.location.name)
                            .font(DSTypography.caption1())
                            .foregroundColor(DSColors.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Favorite button
                FavoriteButton(
                    event: event,
                    isFavorite: favoriteStore.isFavorite,
                    onTap: {
                        favoriteStore.send(.toggleFavorite)
                    }
                )
                .onAppear {
                    favoriteStore.send(.onAppear)
                }
            }
            .padding(DSSpacing.sm)
            .background(DSColors.cardBackground)
            .dsCornerRadius(DSRadius.medium)
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(
        store: Store(
            initialState: HomeFeature.State(),
            reducer: { HomeFeature() }
        )
    )
}
