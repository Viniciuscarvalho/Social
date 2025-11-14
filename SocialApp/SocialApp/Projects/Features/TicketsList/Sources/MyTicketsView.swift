import SwiftUI
import ComposableArchitecture

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
                    AppColors.background
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
                    .foregroundColor(AppColors.primaryText)
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
                .foregroundColor(AppColors.secondaryText)
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
                    .foregroundColor(AppColors.primaryText)
                
                Text(store.selectedTab == .upcoming
                     ? String(localized: "empty_state.tickets.no_upcoming.message")
                     : String(localized: "empty_state.tickets.no_past.message"))
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.secondaryText)
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
                    .background(AppColors.primary)
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
    
    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM, EEE dd, yyyy"
        return formatter
    }()
    
    private var isOwner: Bool {
        guard let currentUserId = currentUserId else { return false }
        return ticket.sellerId == currentUserId
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(ticket.name)
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        Text(formattedDate(ticket.validUntil))
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("Ticket : \(ticketNumberFormatted)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    HStack(spacing: 8) {
                        priceTag
                        ticketTypeTag
                        statusTag
                    }
                    
                    ownershipInfo
                }
                
                Spacer(minLength: 16)
                
                VStack(spacing: 10) {
                    QRCodeView(data: qrPayload, size: 96, cornerRadius: 16)
                        .accessibilityLabel("QR Code do ingresso \(ticket.name)")
                        .accessibilityHint("Escaneie para validar o ingresso")
                    
                    Text("\(ticket.id.prefix(8))…")
                        .font(.caption2)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.cardBackground)
                    .shadow(color: AppColors.cardShadow.opacity(0.08), radius: 6, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var qrPayload: String {
        "ticket:\(ticket.id)|event:\(ticket.eventId)|seller:\(ticket.sellerId)"
    }
    
    private var ticketNumberFormatted: String {
        String(format: "%02d", max(ticket.quantity, 1))
    }
    
    private var priceTag: some View {
        Text("R$ \(ticket.price, specifier: "%.2f")")
            .font(.caption.weight(.bold))
            .foregroundColor(AppColors.accentGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppColors.accentGreen.opacity(0.15))
            .clipShape(Capsule())
    }
    
    private var ticketTypeTag: some View {
        Text(ticket.ticketType.displayName)
            .font(.caption)
            .foregroundColor(AppColors.secondaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppColors.secondaryBackground)
            .clipShape(Capsule())
    }
    
    private var statusTag: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor(ticket.status))
                .frame(width: 7, height: 7)
            Text(ticket.status.displayName)
                .font(.caption)
        }
        .foregroundColor(AppColors.secondaryText)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppColors.secondaryBackground)
        .clipShape(Capsule())
    }
    
    @ViewBuilder
    private var ownershipInfo: some View {
        HStack(spacing: 6) {
            switch ticket.status {
            case .available where isOwner:
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(AppColors.accentGreen)
                Text("Disponível para compradores")
                    .foregroundColor(AppColors.accentGreen)
            case .sold:
                Image(systemName: "ticket.fill")
                    .foregroundColor(AppColors.secondary)
                Text("Vendido com sucesso")
                    .foregroundColor(AppColors.secondary)
            case .expired:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(AppColors.warning)
                Text("Ingresso expirado")
                    .foregroundColor(AppColors.warning)
            default:
                if isOwner {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .foregroundColor(AppColors.primary)
                    Text("Seu ingresso")
                        .foregroundColor(AppColors.primary)
                } else {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(AppColors.warning)
                    Text("Não pertence a você")
                        .foregroundColor(AppColors.warning)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.tertiaryText)
        }
        .font(.caption)
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
    
    private func formattedDate(_ date: Date) -> String {
        Self.displayDateFormatter.string(from: date)
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
