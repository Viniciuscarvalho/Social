import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct TicketsListView: View {
    @Bindable var store: StoreOf<TicketsListFeature>
    
    public init(store: StoreOf<TicketsListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            DSGradients.backgroundMain
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Filtros de categoria
                categoryFilters
                
                // Conteúdo
                contentView
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            store.send(.onAppear)
        }
        .refreshable {
            store.send(.refreshRequested)
        }
        .alert("Erro", isPresented: .constant(store.errorMessage != nil)) {
            Button("OK") { 
                store.send(.dismissError)
            }
        } message: {
            Text(store.errorMessage ?? "Erro ao processar a solicitação")
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        TicketsListHeaderView()
    }
    
    @ViewBuilder
    private var contentView: some View {
        if store.isLoading {
            loadingView
        } else if !store.hasTickets {
            emptyStateView
        } else if !store.hasFilteredTickets && store.isFiltered {
            filteredEmptyStateView
        } else {
            ticketsContentView
        }
    }
    
    @ViewBuilder
    private var categoryFilters: some View {
        TicketsListFiltersView(store: store)
    }
    
    
    // MARK: - Views
    
    private var loadingView: some View {
        DSFullScreenLoading(message: "Carregando ingressos...")
    }
    
    private var emptyStateView: some View {
        DSEmptyState(
            icon: "ticket.fill",
            title: "Lista de Ingressos",
            message: "Nenhum ingresso encontrado",
            actionTitle: "Buscar Eventos",
            action: {
                // Could trigger tab change to events
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var filteredEmptyStateView: some View {
        DSEmptyState(
            icon: "ticket.fill",
            title: "Nenhum Ingresso Encontrado",
            message: "Não há ingressos disponíveis para este evento no momento.",
            actionTitle: "Ver Todos os Ingressos",
            action: {
                store.send(.filterByEvent(nil))
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var ticketsContentView: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.m) {
                ForEach(Array(store.displayTickets.enumerated()), id: \.element.id) { index, ticket in
                    TicketCard(
                        ticket: ticket,
                        onTap: { 
                            if let ticketId = UUID(uuidString: ticket.id) {
                                store.send(.ticketSelected(ticketId))
                            }
                        },
                        onDelete: {
                            store.send(.deleteTicket(ticket.id))
                        }
                    )
                    .dsEnterAnimation(isVisible: true, delay: Double(index) * 0.05)
                }
            }
            .padding(.horizontal, DSSpacing.m)
            .padding(.top, DSSpacing.xs)
        }
    }
}

