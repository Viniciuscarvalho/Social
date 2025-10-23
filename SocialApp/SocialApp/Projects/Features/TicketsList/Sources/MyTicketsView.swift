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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Adicionar") {
                        store.send(.addNewTicketTapped)
                    }
                    .foregroundColor(AppColors.primary)
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
            
            Text("Você ainda não possui ingressos para vender.\nComece publicando seu primeiro ingresso!")
                .font(.body)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Button("Adicionar Primeiro Ingresso") {
                store.send(.addNewTicketTapped)
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.accentGreen.gradient)
            .cornerRadius(12)
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var ticketsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.myTickets) { ticket in
                    MyTicketCard(ticket: ticket) {
                        store.send(.ticketSelected(ticket.id))
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Excluir") {
                            store.send(.deleteTicket(ticket.id))
                        }
                        .tint(.red)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

struct MyTicketCard: View {
    let ticket: Ticket
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Header with ticket status
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ticket.name)
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                            .multilineTextAlignment(.leading)
                        
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
                
                // Actions based on status
                HStack(spacing: 12) {
                    if ticket.status == .available {
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
}