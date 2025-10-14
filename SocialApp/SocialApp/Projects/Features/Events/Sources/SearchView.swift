import ComposableArchitecture
import SwiftUI

public struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>
    @Environment(\.dismiss) var dismiss
    
    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Buscar eventos...", text: $store.searchText.sending(\.searchTextChanged))
                        .textFieldStyle(.plain)
                    
                    if !store.searchText.isEmpty {
                        Button("Limpar") {
                            store.send(.clearSearch)
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Results
                if store.isLoading {
                    ProgressView("Buscando...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if store.searchResults.isEmpty && !store.searchText.isEmpty {
                    ContentUnavailableView {
                        Label("Nenhum resultado", systemImage: "magnifyingglass")
                    } description: {
                        Text("Tente usar palavras-chave diferentes")
                    }
                } else if store.searchResults.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        
                        Text("Buscar Eventos")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Digite o nome do evento que você está procurando")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(store.searchResults) { event in
                                EventSearchResultCard(event: event) {
                                    if let eventId = UUID(uuidString: event.id) {
                                        store.send(.eventSelected(eventId))
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Busca")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct EventSearchResultCard: View {
    let event: Event
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(event.location.city)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let eventDate = event.eventDate {
                    Text(eventDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("R$ \(event.startPrice, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("a partir de")
                    .font(.caption)
                    .foregroundColor(.secondary)
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

#Preview {
    SearchView(
        store: Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}