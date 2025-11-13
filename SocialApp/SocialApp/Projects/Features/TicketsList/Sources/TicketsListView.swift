import SwiftUI
import ComposableArchitecture

public struct TicketsListView: View {
    @Bindable var store: StoreOf<TicketsListFeature>
    
    public init(store: StoreOf<TicketsListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Ingressos")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            // Filtros de categoria
            categoryFilters
            
            // Conteúdo
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
        .navigationBarHidden(true)
        .onAppear {
            store.send(.onAppear)
        }
        .refreshable {
            store.send(.refreshRequested)
        }
        .alert("Erro", isPresented: .constant(store.errorMessage != nil)) {
            Button("OK") { 
                store.send(.refreshRequested)
            }
        } message: {
            Text(store.errorMessage ?? "Erro ao processar a solicitação")
        }
    }
    
    // MARK: - Category Filters
    
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                categoryFilterButton(title: "All Tickets", isSelected: store.selectedFilter.ticketType == nil) {
                    var filter = store.selectedFilter
                    filter.ticketType = nil
                    store.send(.filterChanged(filter))
                }
                
                categoryFilterButton(title: "VIP", isSelected: store.selectedFilter.ticketType == .vip) {
                    var filter = store.selectedFilter
                    filter.ticketType = .vip
                    store.send(.filterChanged(filter))
                }
                
                categoryFilterButton(title: "General", isSelected: store.selectedFilter.ticketType == .general) {
                    var filter = store.selectedFilter
                    filter.ticketType = .general
                    store.send(.filterChanged(filter))
                }
                
                categoryFilterButton(title: "Early Bird", isSelected: store.selectedFilter.ticketType == .earlyBird) {
                    var filter = store.selectedFilter
                    filter.ticketType = .earlyBird
                    store.send(.filterChanged(filter))
                }
                
                categoryFilterButton(title: "Group", isSelected: store.selectedFilter.ticketType == .group) {
                    var filter = store.selectedFilter
                    filter.ticketType = .group
                    store.send(.filterChanged(filter))
                }
                
                categoryFilterButton(title: "Student", isSelected: store.selectedFilter.ticketType == .student) {
                    var filter = store.selectedFilter
                    filter.ticketType = .student
                    store.send(.filterChanged(filter))
                }
                
                categoryFilterButton(title: "Senior", isSelected: store.selectedFilter.ticketType == .senior) {
                    var filter = store.selectedFilter
                    filter.ticketType = .senior
                    store.send(.filterChanged(filter))
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private func categoryFilterButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.primary : Color(.systemGray6))
                .cornerRadius(20)
        }
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
            LazyVStack(spacing: 16) {
                ForEach(store.displayTickets) { ticket in
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
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
}
