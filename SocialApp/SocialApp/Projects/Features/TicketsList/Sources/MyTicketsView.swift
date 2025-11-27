import SwiftUI
import ComposableArchitecture
import DesignSystem

struct MyTicketsView: View {
    @Bindable var store: StoreOf<MyTicketsFeature>
    @Environment(\.dismiss) var dismiss
    let onNavigateToEvents: (() -> Void)?
    
    init(store: StoreOf<MyTicketsFeature>, onNavigateToEvents: (() -> Void)? = nil) {
        self.store = store
        self.onNavigateToEvents = onNavigateToEvents
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tabs
                tabsView
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                
                ZStack {
                    DSGradients.backgroundMain
                        .ignoresSafeArea()
                    
                    if store.isLoading {
                        loadingView
                    } else if filteredTickets.isEmpty {
                        emptyStateView
                    } else {
                        ticketsList
                    }
                }
            }
            .navigationTitle("Meus Ingressos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fechar") {
                        dismiss()
                    }
                    .foregroundColor(DSColors.textPrimary)
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .onDisappear {
                store.send(.onDisappear)
            }
            .refreshable {
                store.send(.refresh)
            }
            .alert("Erro", isPresented: .constant(store.errorMessage != nil)) {
                Button("OK") {
                    store.send(.dismissError)
                }
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Carregando seus ingressos...")
                .font(.headline)
                .foregroundColor(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Ícone de ingresso em círculo amarelo/preto conforme design
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "ticket.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                Text(store.selectedTab == .upcoming 
                     ? String(localized: "empty_state.tickets.no_upcoming.title")
                     : String(localized: "empty_state.tickets.no_past.title"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
                
                Text(store.selectedTab == .upcoming
                     ? String(localized: "empty_state.tickets.no_upcoming.message")
                     : String(localized: "empty_state.tickets.no_past.message"))
                    .font(.system(size: 15))
                    .foregroundColor(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                if let onNavigateToEvents = onNavigateToEvents {
                    onNavigateToEvents()
                } else {
                    store.send(.navigateToEvents)
                }
            }) {
                Text(String(localized: "empty_state.tickets.browse_events"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DSColors.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    // MARK: - Tabs View
    
    private var tabsView: some View {
        HStack(spacing: 12) {
            tabButton(
                title: String(localized: "empty_state.tickets.tab.upcoming"),
                isSelected: store.selectedTab == .upcoming
            ) {
                store.send(.tabChanged(.upcoming))
            }
            
            tabButton(
                title: String(localized: "empty_state.tickets.tab.past"),
                isSelected: store.selectedTab == .past
            ) {
                store.send(.tabChanged(.past))
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func tabButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : AppColors.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.primary : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
    
    // MARK: - Filtered Tickets
    
    private var filteredTickets: [Ticket] {
        let now = Date()
        switch store.selectedTab {
        case .upcoming:
            return store.myTickets.filter { $0.validUntil > now }
        case .past:
            return store.myTickets.filter { $0.validUntil <= now }
        }
    }
    
    private var ticketsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredTickets) { ticket in
                    MyTicketCard(
                        ticket: ticket,
                        currentUserId: store.currentUserId
                    ) {
                        store.send(.ticketSelected(ticket.id))
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        // Só mostra o botão de excluir se o ticket pertencer ao usuário
                        if canDeleteTicket(ticket) {
                            Button("Excluir") {
                                store.send(.deleteTicket(ticket.id))
                            }
                            .tint(.red)
                        }
                    }
                    .contextMenu {
                        Button("Ver Detalhes") {
                            store.send(.ticketSelected(ticket.id))
                        }
                        
                        // Só mostra opções de edição/exclusão se o ticket pertencer ao usuário
                        if canDeleteTicket(ticket) {
                            Divider()
                            Button {
                                // TODO: Implementar edição
                                print("✏️ Editar ticket \(ticket.id)")
                            } label: {
                                Label("Editar Ingresso", systemImage: "pencil")
                            }
                            
                            Button("Excluir Ingresso", role: .destructive) {
                                store.send(.deleteTicket(ticket.id))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Helper Methods
    
    private func canDeleteTicket(_ ticket: Ticket) -> Bool {
        guard let currentUserId = store.currentUserId else {
            return false
        }
        return ticket.sellerId == currentUserId
    }
}

struct MyTicketCard: View {
    let ticket: Ticket
    let currentUserId: String?
    let onTap: () -> Void
    
    private var isOwner: Bool {
        guard let currentUserId = currentUserId else { return false }
        return ticket.sellerId == currentUserId
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Header with ticket status and ownership indicator
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(ticket.name)
                                .font(.headline)
                                .foregroundColor(DSColors.textPrimary)
                                .multilineTextAlignment(.leading)
                            
                            // Ownership indicator
                            if isOwner {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(DSColors.success)
                            } else {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundColor(DSColors.warning)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(statusColor(ticket.status))
                                .frame(width: 8, height: 8)
                            Text(ticket.status.displayName)
                                .font(.caption)
                                .foregroundColor(DSColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("R$ \(ticket.price, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.accentGreen)
                        
                        Text(ticket.ticketType.displayName)
                            .font(.caption)
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
                
                // Event info
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(DSColors.textSecondary)
                    
                    Text("Válido até: \(ticket.validUntil, style: .date)")
                        .font(.caption)
                        .foregroundColor(DSColors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(DSColors.textSecondary)
                    
                    Text("Criado em: \(ticket.createdAt, style: .date)")
                        .font(.caption)
                        .foregroundColor(DSColors.textSecondary)
                }
                
                // Actions based on status and ownership
                HStack(spacing: 12) {
                    if !isOwner {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundColor(AppColors.warning)
                        Text("Não é seu ingresso")
                            .font(.caption)
                            .foregroundColor(AppColors.warning)
                    } else if ticket.status == .available {
                        Image(systemName: "eye")
                            .font(.caption)
                            .foregroundColor(AppColors.secondary)
                        Text("Visível para compradores")
                            .font(.caption)
                            .foregroundColor(AppColors.secondary)
                    } else if ticket.status == .sold {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.accentGreen)
                        Text("Vendido com sucesso!")
                            .font(.caption)
                            .foregroundColor(AppColors.accentGreen)
                    } else if ticket.status == .expired {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundColor(AppColors.warning)
                        Text("Ingresso expirado")
                            .font(.caption)
                            .foregroundColor(AppColors.warning)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.cardBackground)
                    .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func statusColor(_ status: TicketStatus) -> Color {
        switch status {
        case .available:
            return AppColors.accentGreen
        case .reserved:
            return AppColors.warning
        case .sold:
            return AppColors.secondary
        case .expired:
            return AppColors.error
        case .cancelled:
            return AppColors.secondaryText
        }
    }
}

#Preview {
    MyTicketsView(
        store: Store(
            initialState: MyTicketsFeature.State(),
            reducer: { MyTicketsFeature() }
        )
    )
    .onAppear {
        // Mock do usuário atual para preview
        UserDefaults.standard.set("test_user_id", forKey: "currentUserId")
    }
}
