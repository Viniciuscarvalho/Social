import ComposableArchitecture
import SwiftUI

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
                        
                        TextField("Search...", text: $store.searchText.sending(\.searchTextChanged))
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
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                Divider()
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if store.isLoading {
                            loadingView
                        } else if !store.searchText.isEmpty && store.searchResults.isEmpty {
                            noResultsView
                        } else if !store.searchResults.isEmpty {
                            searchResultsView
                        } else {
                            recentSearchesView
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Search")
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
        }
    }
    
    // MARK: - Recent Searches View
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !store.recentSearches.isEmpty {
                Text("Recent Search")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    ForEach(store.recentSearches, id: \.self) { search in
                        RecentSearchRow(
                            searchText: search,
                            onTap: {
                                store.send(.selectRecentSearch(search))
                            },
                            onRemove: {
                                store.send(.removeRecentSearch(search))
                            }
                        )
                        .padding(.horizontal, 20)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("Search for events")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Find concerts, festivals, sports and more")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            }
        }
    }
    
    // MARK: - Search Results View
    
    private var searchResultsView: some View {
        VStack(spacing: 16) {
            ForEach(store.searchResults) { event in
                EventSearchResultCard(event: event) {
                    if let eventId = UUID(uuidString: event.id) {
                        store.send(.eventSelected(eventId))
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Searching...")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    // MARK: - No Results View
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No results found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Try searching with different keywords")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - Recent Search Row

struct RecentSearchRow: View {
    let searchText: String
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Text(searchText)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
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
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
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
                        
                        Image(systemName: "heart")
                            .font(.system(size: 18))
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
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func getPriceText() -> String {
        if event.startPrice == 0 {
            return "Free"
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
