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
            } else {
                ticketsContentView
            }
        }
        .navigationTitle("Ingressos")
        .navigationBarTitleDisplayMode(.large)
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
            store.send(.loadAvailableTickets)
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
                ForEach(store.tickets) { ticket in
                    TicketCard(
                        ticket: ticket,
                        onTap: { store.send(.ticketSelected(ticket.id)) }
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
                    store.send(.setTicketTypeFilter(nil))
                }
                
                ForEach(TicketType.allCases, id: \.self) { type in
                    Button(type.displayName) {
                        store.send(.setTicketTypeFilter(type))
                    }
                }
            }
            
            Menu("Status") {
                Button("Todos") {
                    store.send(.setStatusFilter(nil))
                }
                
                ForEach(TicketStatus.allCases, id: \.self) { status in
                    Button(status.displayName) {
                        store.send(.setStatusFilter(status))
                    }
                }
            }
            
            Menu("Ordenar Por") {
                ForEach(TicketSortOption.allCases, id: \.self) { sortOption in
                    Button(sortOption.displayName) {
                        store.send(.setSortOption(sortOption))
                    }
                }
            }
        }
    }
}
