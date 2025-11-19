import ComposableArchitecture
import SwiftUI

public struct TicketDetailView: View {
    @Bindable var store: StoreOf<TicketDetailFeature>
    let ticketId: UUID
    let ticket: Ticket? // ✅ Ticket opcional para evitar chamada API
    @Environment(\.dismiss) var dismiss
    
    public init(store: StoreOf<TicketDetailFeature>, ticketId: UUID, ticket: Ticket? = nil) {
        self.store = store
        self.ticketId = ticketId
        self.ticket = ticket
    }
    
    public var body: some View {
        Group {
            if store.isLoading {
                loadingView
            } else if let ticketDetail = store.ticketDetail {
                ticketContentView(ticketDetail)
            } else {
                errorView
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width > 100 {
                        dismiss()
                    }
                }
        )
        .onAppear {
            print("🎫 TicketDetailView apareceu para ticket: \(ticketId)")
            store.send(.onAppear(ticketId, ticket)) // ✅ Passa o ticket se tiver
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Carregando detalhes...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private func ticketContentView(_ ticketDetail: TicketDetail) -> some View {
        ZStack(alignment: .top) {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header com botões de navegação
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 40, height: 40)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        Spacer()
                        
                        Button {
                            // TODO: Implementar favoritar
                        } label: {
                            Image(systemName: "heart")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 40, height: 40)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    
                    // Título do evento
                    VStack(alignment: .leading, spacing: 16) {
                        Text(ticketDetail.event.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        // Informações do evento
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.primary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ticketDetail.event.location.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text("\(ticketDetail.event.location.city), \(ticketDetail.event.location.state)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.primary)
                                Text(ticketDetail.event.dateFormatted)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.primary)
                                Text(ticketDetail.event.timeRange)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    
                    // Informações do Ticket
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Informações do Ticket")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            // Tipo de Ingresso
                            ticketInfoRow(
                                title: "Tipo de Ingresso",
                                value: ticketDetail.ticketType.displayName,
                                icon: ticketTypeIcon(ticketDetail.ticketType),
                                iconColor: ticketTypeColor(ticketDetail.ticketType)
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            // Quantidade
                            ticketInfoRow(
                                title: "Quantidade",
                                value: "\(ticketDetail.quantity) disponíveis"
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            // Validade
                            ticketInfoRow(
                                title: "Validade",
                                value: formatDate(ticketDetail.validUntil)
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            // Preço
                            HStack {
                                Text("Preço")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("R$ \(String(format: "%.0f", ticketDetail.price))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    
                    // Card do Vendedor
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            // Imagem do vendedor
                            AsyncImage(url: URL(string: ticketDetail.seller.profileImageURL ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.gray)
                                    )
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 6) {
                                    Text(ticketDetail.seller.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    if ticketDetail.seller.isVerified {
                                        ZStack {
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 18, height: 18)
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.orange)
                                    Text("4.8 (124 avaliações)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                // TODO: Implementar chat
                            } label: {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    
                    // Botão Negociar
                    Button(action: {
                        store.send(.negotiateTapped)
                    }) {
                        HStack {
                            if store.isStartingNegotiation {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Text("Iniciar Negociação")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            (store.ticketDetail?.status == .available && !store.isStartingNegotiation) ?
                            AppColors.primary : Color.gray
                        )
                        .cornerRadius(12)
                    }
                    .disabled(store.ticketDetail?.status != .available || store.isStartingNegotiation)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    .alert("Erro", isPresented: Binding(
                        get: { store.showingNegotiationError },
                        set: { _ in store.send(.dismissNegotiationError) }
                    )) {
                        Button("OK", role: .cancel) {
                            store.send(.dismissNegotiationError)
                        }
                    } message: {
                        if let errorMessage = store.errorMessage {
                            Text(errorMessage)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func ticketInfoRow(title: String, value: String, icon: String? = nil, iconColor: Color? = nil) -> some View {
        HStack {
            if let icon = icon, let iconColor = iconColor {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
            }
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let icon = icon, let iconColor = iconColor {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(iconColor)
                    Text(value)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
            } else {
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private func ticketTypeIcon(_ type: TicketType) -> String {
        switch type {
        case .vip:
            return "crown.fill"
        case .senior:
            return "star.fill"
        case .general:
            return "person.3.fill"
        case .earlyBird:
            return "sunrise.fill"
        case .group:
            return "person.2.fill"
        case .student:
            return "graduationcap.fill"
        }
    }
    
    private func ticketTypeColor(_ type: TicketType) -> Color {
        switch type {
        case .vip:
            return Color.purple
        case .senior:
            return Color.blue
        case .general:
            return Color.green
        case .earlyBird:
            return Color.yellow
        case .group:
            return Color.brown
        case .student:
            return Color.accentColor
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "pt_BR")
        let dateString = formatter.string(from: date)
        // Capitalizar primeira letra do mês
        return dateString.prefix(1).uppercased() + dateString.dropFirst()
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Erro ao carregar detalhes")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
}
