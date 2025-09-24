import SwiftUI
import ComposableArchitecture

public struct EventsView: View {
    @Bindable var store: StoreOf<EventsFeature>
    
    public init(store: StoreOf<EventsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    headerSection
                    searchSection
                    popularCategoriesSection
                    recommendedSection
                    eventsListSection
                }
                .padding(.horizontal, 16)
            }
            .navigationBarHidden(true)
            .refreshable {
                store.send(.refreshRequested)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            AsyncImage(url: URL(string: store.user?.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            Text(store.user?.name ?? "Nome Usuário")
                .font(.headline)
            
            Spacer()
        }
        .padding(.top, 8)
    }
    
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Campo de busca", text: $store.searchText.sending(\.searchTextChanged))
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var popularCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Popular")
                    .font(.headline)
                
                Spacer()
                
                Button("show all") {
                    store.send(.showAllCategoriesPressed)
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(store.popularCategories, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: store.selectedFilter.category == category
                    ) {
                        store.send(.categorySelected(category))
                    }
                }
            }
        }
    }
    
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended")
                .font(.headline)
            
            if !store.recommendedEvents.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(store.recommendedEvents) { event in
                            RecommendedEventCard(event: event) {
                                store.send(.eventSelected(event.id))
                            } onFavorite: {
                                store.send(.favoriteToggled(event.id))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    private var eventsListSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(store.displayEvents) { event in
                EventCard(event: event) {
                    store.send(.eventSelected(event.id))
                } onFavorite: {
                    store.send(.favoriteToggled(event.id))
                }
            }
        }
    }
}
