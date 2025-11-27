import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>
    @Environment(\.dismiss) var dismiss
    @FocusState private var isSearchFocused: Bool
    
    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        
                        TextField(String(localized: "events.search.placeholder"), text: $store.searchText.sending(\.searchTextChanged))
                            .textFieldStyle(.plain)
                            .font(.system(size: 15))
                            .focused($isSearchFocused)
                            .onSubmit {
                                if !store.searchText.isEmpty {
                                    store.send(.performSearch(store.searchText))
                                }
                            }
                        
                        if !store.searchText.isEmpty {
                            Button {
                                store.send(.clearSearch)
                                isSearchFocused = true
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xs)
                    .background(DSColors.backgroundSecondary)
                    .dsCornerRadius(DSRadius.small)
                }
                .padding(.horizontal, DSSpacing.m)
                .padding(.vertical, DSSpacing.sm)
                
                Divider()
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.l) {
                        if store.isSearching {
                            loadingView
                        } else if store.hasSearchText && !store.hasResults {
                            noResultsView
                        } else if store.hasResults {
                            searchResultsView
                        } else {
                            recentSearchesView
                        }
                    }
                    .padding(.top, DSSpacing.l)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle(String(localized: "events.search.title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width > 100 {
                            dismiss()
                        }
                    }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
                isSearchFocused = true
            }
            .onDisappear {
                store.send(.onDisappear)
            }
        }
    }
    
    // MARK: - Recent Searches View
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            if store.hasRecentSearches {
                Text(String(localized: "events.search.recentTitle"))
                    .font(DSTypography.body(weight: .semibold))
                    .foregroundColor(DSColors.textPrimary)
                    .padding(.horizontal, DSSpacing.m)
                
                VStack(spacing: DSSpacing.sm) {
                    ForEach(Array(store.recentSearches.enumerated()), id: \.element) { index, search in
                        RecentSearchRow(
                            searchText: search,
                            onTap: {
                                store.send(.selectRecentSearch(search))
                            },
                            onRemove: {
                                store.send(.removeRecentSearch(search))
                            }
                        )
                        .padding(.horizontal, DSSpacing.m)
                        .dsEnterAnimation(isVisible: true, delay: Double(index) * 0.05)
                    }
                }
            } else {
                DSEmptyState(
                    icon: "magnifyingglass",
                    title: String(localized: "events.search.empty.title"),
                    message: String(localized: "events.search.empty.subtitle")
                )
                .frame(maxWidth: .infinity)
                .padding(.top, DSSpacing.xxl)
            }
        }
    }
    
    // MARK: - Search Results View
    
    private var searchResultsView: some View {
        VStack(spacing: DSSpacing.m) {
            ForEach(Array(store.searchResults.enumerated()), id: \.element.id) { index, event in
                EventSearchResultCard(event: event) {
                    if let eventId = UUID(uuidString: event.id) {
                        store.send(.eventSelected(eventId))
                    }
                }
                .padding(.horizontal, DSSpacing.m)
                .dsEnterAnimation(isVisible: true, delay: Double(index) * 0.05)
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        DSFullScreenLoading(message: String(localized: "events.search.loading"))
    }
    
    // MARK: - No Results View
    
    private var noResultsView: some View {
        DSSearchEmptyState(searchTerm: store.searchText)
            .frame(maxWidth: .infinity)
            .padding(.top, DSSpacing.xxl)
    }
}

// MARK: - Recent Search Row

struct RecentSearchRow: View {
    let searchText: String
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        DSCard {
            Button(action: onTap) {
                HStack(spacing: DSSpacing.sm) {
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                        .foregroundColor(DSColors.textSecondary)
                    
                    Text(searchText)
                        .font(DSTypography.body())
                        .foregroundColor(DSColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: onRemove) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundColor(DSColors.textSecondary)
                    }
                    .dsTapFeedback()
                }
                .padding(.vertical, DSSpacing.xs)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Event Search Result Card

struct EventSearchResultCard: View {
    let event: Event
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Event image with price badge
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(DSGradients.primary.opacity(0.3))
                    }
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    
                    // Price badge
                    Text(getPriceText())
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(getPriceColor())
                        )
                        .padding(14)
                }
                .frame(height: 180)
                
                // Event info
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(event.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        Image("unfavorited", bundle: Bundle.main)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(event.dateFormatted)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        Text(event.timeRange.components(separatedBy: " - ").first ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(event.location.name)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(14)
            }
            .frame(maxWidth: .infinity)
            .background(DSColors.background)
            .dsCornerRadius(DSRadius.large)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func getPriceText() -> String {
        if event.startPrice == 0 {
            return String(localized: "events.price.free")
        }
        return "$\(Int(event.startPrice))"
    }
    
    private func getPriceColor() -> Color {
        if event.startPrice == 0 {
            return Color.green
        }
        return Color.blue
    }
}

#Preview {
    SearchView(
        store: Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}
