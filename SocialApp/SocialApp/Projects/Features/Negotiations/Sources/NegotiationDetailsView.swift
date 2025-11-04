import SwiftUI
import ComposableArchitecture

public struct NegotiationDetailsView: View {
    @Bindable var store: StoreOf<NegotiationDetailsFeature>
    @Environment(\.dismiss) private var dismiss
    
    public init(store: StoreOf<NegotiationDetailsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
            } else if let negotiation = store.negotiation {
                VStack(spacing: 24) {
                    // Status Badge
                    statusBadge(negotiation)
                    
                    // Informações do ingresso
                    if let ticket = negotiation.ticket {
                        ticketInfoSection(ticket, negotiation: negotiation)
                    }
                    
                    // Detalhes da negociação
                    negotiationDetailsSection(negotiation)
                    
                    // Informações do comprador/vendedor
                    if store.isSeller, let buyer = negotiation.buyer {
                        userInfoSection(buyer, role: "Comprador")
                    }
                    
                    if store.isBuyer, let seller = negotiation.seller {
                        userInfoSection(seller, role: "Vendedor")
                    }
                    
                    // Botões de ação
                    actionButtons(negotiation)
                }
                .padding()
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Detalhes da Negociação")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(isPresented: $store.showingRejectSheet) {
            rejectSheet
        }
        .sheet(isPresented: $store.showingContactReveal) {
            contactRevealSheet
        }
        .alert("Erro", isPresented: $store.showingErrorAlert) {
            Button("OK") {
                store.send(.dismissErrorAlert)
            }
        } message: {
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Status Badge
    
    private func statusBadge(_ negotiation: Negotiation) -> some View {
        HStack {
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: negotiation.status.iconName)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(negotiation.status.displayName)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(statusColor(negotiation.status))
            )
            
            Spacer()
        }
    }
    
    private func statusColor(_ status: NegotiationStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        case .cancelled: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .disputed: return .red
        }
    }
    
    // MARK: - Ticket Info Section
    
    private func ticketInfoSection(_ ticket: Ticket, negotiation: Negotiation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ticket.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            if let event = ticket.event {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(event.date, style: .date)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Preço do Ingresso")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Text("R$ \(String(format: "%.2f", ticket.price))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                }
                
                Spacer()
                
                if let proposedPrice = negotiation.proposedPrice {
                    VStack(alignment: .trailing) {
                        Text("Preço Proposto")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Text("R$ \(String(format: "%.2f", proposedPrice))")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
        .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Negotiation Details Section
    
    private func negotiationDetailsSection(_ negotiation: Negotiation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informações da Negociação")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            VStack(alignment: .leading, spacing: 8) {
                detailRow(icon: "clock.fill", title: "Criada em", value: negotiation.createdAt.formatted(date: .abbreviated, time: .shortened))
                
                if let approvedAt = negotiation.approvedAt {
                    detailRow(icon: "checkmark.circle.fill", title: "Aprovada em", value: approvedAt.formatted(date: .abbreviated, time: .shortened))
                }
                
                if let validUntil = negotiation.validUntil {
                    detailRow(icon: "hourglass", title: "Válida até", value: validUntil.formatted(date: .abbreviated, time: .shortened))
                }
                
                if let rejectionReason = negotiation.rejectionReason {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Motivo da Recusa:")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text(rejectionReason)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primaryText)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
        .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.primary)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.primaryText)
        }
    }
    
    // MARK: - User Info Section
    
    private func userInfoSection(_ user: User, role: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(role)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(user.name.prefix(1)))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    
                    if user.isVerified {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            Text("Verificado")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
        .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Action Buttons
    
    @ViewBuilder
    private func actionButtons(_ negotiation: Negotiation) -> some View {
        VStack(spacing: 12) {
            // Botões para vendedor
            if store.canApprove {
                Button {
                    store.send(.approveNegotiation)
                } label: {
                    HStack {
                        if store.isUpdating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        }
                        Image(systemName: "checkmark.circle.fill")
                        Text("Aprovar Negociação")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green)
                    )
                }
                .disabled(store.isUpdating)
            }
            
            if store.canReject {
                Button {
                    store.send(.showRejectSheet)
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Recusar Negociação")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red)
                    )
                }
                .disabled(store.isUpdating)
            }
            
            // Botão para comprador revelar contato
            if store.canRevealContact {
                Button {
                    store.send(.revealContact)
                } label: {
                    HStack {
                        if store.isRevealingContact {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        }
                        Image(systemName: "lock.open.fill")
                        Text("Revelar Dados de Contato")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.primary)
                    )
                }
                .disabled(store.isRevealingContact)
            }
            
            // Botão de cancelar
            if store.canCancel {
                Button {
                    store.send(.cancelNegotiation)
                } label: {
                    HStack {
                        Image(systemName: "slash.circle")
                        Text("Cancelar Negociação")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.red)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red, lineWidth: 1.5)
                    )
                }
                .disabled(store.isUpdating)
            }
        }
    }
    
    // MARK: - Reject Sheet
    
    private var rejectSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Informe o motivo da recusa para que o comprador possa entender melhor.")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextEditor(text: $store.rejectionReason)
                    .frame(height: 150)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                Button {
                    store.send(.rejectNegotiation)
                } label: {
                    Text("Confirmar Recusa")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red)
                        )
                }
                .padding(.horizontal)
                .disabled(store.rejectionReason.isEmpty)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Recusar Negociação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        store.send(.hideRejectSheet)
                    }
                }
            }
        }
    }
    
    // MARK: - Contact Reveal Sheet
    
    @ViewBuilder
    private var contactRevealSheet: some View {
        if let seller = store.revealedSeller {
            NavigationView {
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .padding(.top, 40)
                    
                    Text("Dados de Contato Revelados")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Entre em contato com o vendedor para finalizar a negociação.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        // Nome
                        contactInfoRow(icon: "person.fill", title: "Nome", value: seller.name)
                        
                        // E-mail
                        contactInfoRow(icon: "envelope.fill", title: "E-mail", value: seller.email)
                        
                        // TODO: Adicionar telefone quando disponível
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.cardBackground)
                    )
                    .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        store.showingContactReveal = false
                    } label: {
                        Text("Fechar")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppColors.primary)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .navigationTitle("Contato")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    private func contactInfoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.tertiaryText)
                
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.primaryText)
            }
            
            Spacer()
            
            Button {
                UIPasteboard.general.string = value
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(.vertical, 8)
    }
}

