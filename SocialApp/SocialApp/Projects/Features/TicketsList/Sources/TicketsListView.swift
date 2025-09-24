import SwiftUI
import ComposableArchitecture
import SharedModels

public struct TicketsListView: View {
    @Bindable var store: StoreOf<TicketsListFeature>
    
    public init(store: StoreOf<TicketsListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                if store.isLoading {
                    loadingView
                } else if store.tickets.isEmpty {
                    emptyStateView
                } else {
                    ticketsContentView
                }
            }
            .navigationTitle("Ingressos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        filterMenu
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .refreshable {
                store.send(.refreshRequested)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Carregando ingressos...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Lista de Ingressos")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Nenhum ingresso encontrado")
                .foregroundColor(.secondary)
            
            Button("Buscar Eventos") {
                // Could trigger tab change to events
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var ticketsContentView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.displayTickets) { ticket in
                    TicketCard(
                        ticket: ticket,
                        onTap: { store.send(.ticketSelected(ticket.id)) },
                        onFavorite: { store.send(.favoriteToggled(ticket.id)) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var filterMenu: some View {
        VStack {
            Menu("Tipo de Ingresso") {
                Button("Todos") {
                    var filter = store.selectedFilter
                    filter.ticketType = nil
                    store.send(.filterChanged(filter))
                }
                
                ForEach(TicketType.allCases, id: \.self) { type in
                    Button(type.displayName) {
                        var filter = store.selectedFilter
                        filter.ticketType = type
                        store.send(.filterChanged(filter))
                    }
                }
            }
            
            Menu("Status") {
                Button("Todos") {
                    var filter = store.selectedFilter
                    filter.status = nil
                    store.send(.filterChanged(filter))
                }
                
                ForEach(TicketStatus.allCases, id: \.self) { status in
                    Button(status.displayName) {
                        var filter = store.selectedFilter
                        filter.status = status
                        store.send(.filterChanged(filter))
                    }
                }
            }
            
            Menu("Ordenar Por") {
                ForEach(TicketSortOption.allCases, id: \.self) { sortOption in
                    Button(sortOption.displayName) {
                        var filter = store.selectedFilter
                        filter.sortBy = sortOption
                        store.send(.filterChanged(filter))
                    }
                }
            }
            
            Toggle("Apenas Favoritos", isOn: Binding(
                get: { store.selectedFilter.showFavoritesOnly },
                set: { newValue in
                    var filter = store.selectedFilter
                    filter.showFavoritesOnly = newValue
                    store.send(.filterChanged(filter))
                }
            ))
        }
    }
}
