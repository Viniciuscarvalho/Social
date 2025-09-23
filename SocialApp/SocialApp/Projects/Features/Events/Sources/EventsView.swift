import SwiftUI
import SharedModels

public struct EventsView: View {
    @Binding var state: EventsFeature.State
    
    let sendAction: (EventsFeature.Action) -> Void
    
    public init(
        state: Binding<EventsFeature.State>,
        sendAction: @escaping (EventsFeature.Action) -> Void
    ) {
        self._state = state
        self.sendAction = sendAction
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
                sendAction(.refreshRequested)
            }
            .onAppear {
                sendAction(.onAppear)
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            AsyncImage(url: URL(string: state.user?.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            Text(state.user?.name ?? "Nome Usuário")
                .font(.headline)
            
            Spacer()
        }
        .padding(.top, 8)
    }
    
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Campo de busca", text: Binding(
                get: { state.searchText },
                set: { sendAction(.searchTextChanged($0)) }
            ))
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
                    sendAction(.showAllCategoriesPressed)
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(state.popularCategories, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: state.selectedFilter.category == category
                    ) {
                        sendAction(.categorySelected(category))
                    }
                }
            }
        }
    }
    
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended")
                .font(.headline)
            
            if !state.recommendedEvents.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(state.recommendedEvents) { event in
                            RecommendedEventCard(event: event) {
                                sendAction(.eventSelected(event.id))
                            } onFavorite: {
                                sendAction(.favoriteToggled(event.id))
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
            ForEach(state.displayEvents) { event in
                EventCard(event: event) {
                    sendAction(.eventSelected(event.id))
                } onFavorite: {
                    sendAction(.favoriteToggled(event.id))
                }
            }
        }
    }
}
