import SwiftUI
import ComposableArchitecture

struct MyTicketsView: View {
    @Bindable var store: StoreOf<MyTicketsFeature>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if store.isLoading {
                    loadingView
                } else if store.myTickets.isEmpty {
                    emptyStateView
                } else {
                    ticketsList
                }
                
                // Overlay para mostrar estado de exclusão
                if store.isDeletingTicket {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text("Excluindo ingresso...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(24)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
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
            .refreshable {
                store.send(.refresh)
            }
            .alert("Excluir Ingresso", isPresented: .constant(store.ticketToDelete != nil)) {
                Button("Cancelar", role: .cancel) {
                    store.send(.cancelDelete)
                }
                Button("Excluir", role: .destructive) {
                    store.send(.confirmDelete)
                }
            } message: {
                Text("Tem certeza que deseja excluir este ingresso? Esta ação não pode ser desfeita.")
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
            Image(systemName: "ticket.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.accentGreen)
            
            Text("Nenhum Ingresso Publicado")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
            
            Text("Você ainda não possui ingressos para vender.\nVisite a aba principal para criar seus ingressos!")
                .font(.body)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var ticketsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.myTickets) { ticket in
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
                        
                        // Só mostra o botão de excluir se o ticket pertencer ao usuário
                        if canDeleteTicket(ticket) {
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
                                .foregroundColor(AppColors.primaryText)
                                .multilineTextAlignment(.leading)
                            
                            // Ownership indicator
                            if isOwner {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(AppColors.accentGreen)
                            } else {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundColor(AppColors.warning)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(statusColor(ticket.status))
                                .frame(width: 8, height: 8)
                            Text(ticket.status.displayName)
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
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
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                // Event info
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("Válido até: \(ticket.validUntil, style: .date)")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("Criado em: \(ticket.createdAt, style: .date)")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
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