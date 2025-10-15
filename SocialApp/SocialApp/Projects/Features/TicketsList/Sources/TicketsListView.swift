import SwiftUI
import ComposableArchitecture

public struct TicketsListView: View {
    @Bindable var store: StoreOf<TicketsListFeature>
    
    public init(store: StoreOf<TicketsListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            if store.isLoading {
                loadingView
            } else if store.tickets.isEmpty {
                emptyStateView
            } else if store.displayTickets.isEmpty && store.selectedFilter.eventId != nil {
                filteredEmptyStateView
            } else {
                ticketsContentView
            }
        }
        .navigationTitle(navigationTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    filterMenu
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            
            // Botão para limpar filtro de evento
            if store.selectedFilter.eventId != nil {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Todos") {
                        store.send(.filterByEvent(nil))
                    }
                    .foregroundColor(.blue)
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
    
    // MARK: - Computed Properties
    
    private var navigationTitle: String {
        if store.selectedFilter.eventId != nil {
            return "Ingressos do Evento"
        }
        return "Ingressos"
    }
    
    private var shouldShowEmptyState: Bool {
        if store.selectedFilter.eventId != nil {
            return store.displayTickets.isEmpty && !store.tickets.isEmpty
        }
        return store.tickets.isEmpty
    }
    
    private var emptyStateMessage: String {
        if store.selectedFilter.eventId != nil {
            return "Não há ingressos disponíveis para este evento no momento."
        }
        return "Nenhum ingresso encontrado. Explore os eventos disponíveis para encontrar ingressos."
    }
    
    // MARK: - Views
    
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
    
    private var filteredEmptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Nenhum Ingresso Encontrado")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Não há ingressos disponíveis para este evento no momento.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Ver Todos os Ingressos") {
                store.send(.filterByEvent(nil))
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var ticketsContentView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.displayTickets) { ticket in
                    TicketCard(
                        ticket: ticket,
                        onTap: { 
                            if let ticketId = UUID(uuidString: ticket.id) {
                                store.send(.ticketSelected(ticketId))
                            }
                        }
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
