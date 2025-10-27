import ComposableArchitecture
import SwiftUI

public struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    let searchStore: StoreOf<SearchFeature>?
    
    public init(store: StoreOf<HomeFeature>, searchStore: StoreOf<SearchFeature>? = nil) {
        self.store = store
        self.searchStore = searchStore
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header integrado à página (não fixo)
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
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
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hey! \(store.homeContent.user?.name ?? "User")")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Let's make your day eventful")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Notification button
                Button {
                    // Notification action
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                    }
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
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
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
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    store.send(.viewAllRecommended)
                } label: {
                    Text("View all")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.recommendedEvents.prefix(5)) { event in
                        RecommendedEventCard(event: event) {
                            store.send(.eventSelected(event.id))
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Popular Events Section
    
    private var popularEventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Popular Event")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    store.send(.viewAllPopular)
                } label: {
                    Text("View all")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            
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
                .padding(.horizontal, 20)
            }
            
            // Events list
            VStack(spacing: 16) {
                ForEach(store.filteredEvents.prefix(10)) { event in
                    PopularEventListCard(event: event) {
                        store.send(.eventSelected(event.id))
                    }
                    .padding(.horizontal, 20)
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
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    isSelected
                        ? LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        : LinearGradient(
                            colors: [Color(.systemGray6), Color(.systemGray6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
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
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        colors: [Color(.systemGray6), Color(.systemGray6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recommended Event Card

struct RecommendedEventCard: View {
    let event: Event
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
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                        .padding(12)
                }
                .frame(width: 220, height: 160)
                
                // Event info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(event.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "heart")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        
                        Text(event.dateFormatted)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(event.timeRange.components(separatedBy: " - ").first ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        
                        Text(event.location.name)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(12)
            }
            .frame(width: 220)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Popular Event List Card

struct PopularEventListCard: View {
    let event: Event
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
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                        .padding(6)
                }
                
                // Event info
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text(event.dateFormatted)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(event.timeRange.components(separatedBy: " - ").first ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text(event.location.name)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Favorite button
                Button {
                    // Toggle favorite
                } label: {
                    Image(systemName: "heart")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
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
