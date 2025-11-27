import ComposableArchitecture
import SwiftUI
import DesignSystem

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
        .onDisappear {
            store.send(.onDisappear)
        }
    }
    
    private var loadingView: some View {
        DSFullScreenLoading(message: "Carregando detalhes...")
    }
    
    private func ticketContentView(_ ticketDetail: TicketDetail) -> some View {
        ZStack(alignment: .top) {
            DSGradients.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header com botões de navegação
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(DSTypography.body(weight: .semibold))
                                .foregroundColor(DSColors.textPrimary)
                                .frame(width: 40, height: 40)
                                .background(DSColors.backgroundSecondary)
                                .dsCornerRadius(DSRadius.small)
                        }
                        .dsTapFeedback()
                        
                        Spacer()
                    }
                    .padding(.horizontal, DSSpacing.m)
                    .padding(.top, DSSpacing.m)
                    .padding(.bottom, DSSpacing.xl)
                    
                    // Título do evento
                    VStack(alignment: .leading, spacing: DSSpacing.m) {
                        Text(ticketDetail.event.name)
                            .font(DSTypography.title1(weight: .bold))
                            .foregroundColor(DSColors.textPrimary)
                            .lineLimit(2)
                        
                        // Informações do evento
                        VStack(alignment: .leading, spacing: DSSpacing.sm) {
                            HStack(spacing: DSSpacing.xs) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(DSColors.primary)
                                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                                    Text(ticketDetail.event.location.name)
                                        .font(DSTypography.footnote(weight: .medium))
                                        .foregroundColor(DSColors.textPrimary)
                                    Text("\(ticketDetail.event.location.city), \(ticketDetail.event.location.state)")
                                        .font(DSTypography.caption1())
                                        .foregroundColor(DSColors.textSecondary)
                                }
                            }
                            
                            HStack(spacing: DSSpacing.xs) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14))
                                    .foregroundColor(DSColors.primary)
                                Text(ticketDetail.event.dateFormatted)
                                    .font(DSTypography.footnote(weight: .medium))
                                    .foregroundColor(DSColors.textPrimary)
                            }
                            
                            HStack(spacing: DSSpacing.xs) {
                                Image(systemName: "clock")
                                    .font(.system(size: 14))
                                    .foregroundColor(DSColors.primary)
                                Text(ticketDetail.event.timeRange)
                                    .font(DSTypography.footnote(weight: .medium))
                                    .foregroundColor(DSColors.textPrimary)
                            }
                        }
                    }
                    .padding(.horizontal, DSSpacing.m)
                    .padding(.bottom, DSSpacing.xl)
                    
                    // Informações do Ticket
                    VStack(alignment: .leading, spacing: DSSpacing.m) {
                        Text("Informações do Ticket")
                            .font(DSTypography.title3(weight: .bold))
                            .foregroundColor(DSColors.textPrimary)
                            .padding(.horizontal, DSSpacing.m)
                        
                        DSCard {
                            VStack(spacing: 0) {
                                // Tipo de Ingresso
                                ticketInfoRow(
                                    title: "Tipo de Ingresso",
                                    value: ticketDetail.ticketType.displayName,
                                    icon: ticketTypeIcon(ticketDetail.ticketType),
                                    iconColor: ticketTypeColor(ticketDetail.ticketType)
                                )
                                
                                Divider()
                                    .padding(.horizontal, DSSpacing.m)
                                
                                // Quantidade
                                ticketInfoRow(
                                    title: "Quantidade",
                                    value: "\(ticketDetail.quantity) disponíveis"
                                )
                                
                                Divider()
                                    .padding(.horizontal, DSSpacing.m)
                                
                                // Validade
                                ticketInfoRow(
                                    title: "Validade",
                                    value: formatDate(ticketDetail.validUntil)
                                )
                                
                                Divider()
                                    .padding(.horizontal, DSSpacing.m)
                                
                                // Preço
                                HStack {
                                    Text("Preço")
                                        .font(DSTypography.body(weight: .bold))
                                        .foregroundColor(DSColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text("R$ \(String(format: "%.0f", ticketDetail.price))")
                                        .font(DSTypography.title2(weight: .bold))
                                        .foregroundColor(DSColors.primary)
                                }
                                .padding(.horizontal, DSSpacing.m)
                                .padding(.vertical, DSSpacing.m)
                            }
                        }
                    }
                    .padding(.horizontal, DSSpacing.m)
                    .padding(.bottom, DSSpacing.xl)
                    
                    // Card do Vendedor
                    DSCard {
                        Button {
                            store.send(.navigateToSellerProfile(ticketDetail.seller.id))
                        } label: {
                            VStack(alignment: .leading, spacing: DSSpacing.m) {
                                HStack(spacing: DSSpacing.sm) {
                                    // Imagem do vendedor
                                    AsyncImage(url: URL(string: ticketDetail.seller.profileImageURL ?? "")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(DSColors.backgroundSecondary)
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(DSColors.textSecondary)
                                            )
                                    }
                                    .frame(width: 60, height: 60)
                                    .dsCornerRadius(DSRadius.medium)
                                    
                                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                        HStack(spacing: DSSpacing.xs) {
                                            Text(ticketDetail.seller.name)
                                                .font(DSTypography.body(weight: .bold))
                                                .foregroundColor(DSColors.textPrimary)
                                            
                                            if ticketDetail.seller.isVerified {
                                                ZStack {
                                                    Circle()
                                                        .fill(DSColors.success)
                                                        .frame(width: 18, height: 18)
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                        
                                        HStack(spacing: DSSpacing.xxs) {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.orange)
                                            Text("4.8 (124 avaliações)")
                                                .font(DSTypography.caption1())
                                                .foregroundColor(DSColors.textSecondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        // TODO: Implementar chat
                                    } label: {
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(DSColors.textSecondary)
                                    }
                                    .dsTapFeedback()
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, DSSpacing.m)
                    .padding(.bottom, DSSpacing.xl)
                    
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
                                    .font(DSTypography.body(weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.m)
                        .background(
                            store.canNegotiate && !store.isStartingNegotiation ?
                            DSColors.primary : DSColors.textTertiary
                        )
                        .dsCornerRadius(DSRadius.medium)
                    }
                    .disabled(!store.canNegotiate || store.isStartingNegotiation)
                    .padding(.horizontal, DSSpacing.m)
                    .padding(.bottom, DSSpacing.xxl)
                    .dsTapFeedback()
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
                .font(DSTypography.footnote())
                .foregroundColor(DSColors.textSecondary)
            
            Spacer()
            
            if let icon = icon, let iconColor = iconColor {
                HStack(spacing: DSSpacing.xxs) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(iconColor)
                    Text(value)
                        .font(DSTypography.footnote(weight: .medium))
                        .foregroundColor(DSColors.textPrimary)
                }
            } else {
                Text(value)
                    .font(DSTypography.footnote(weight: .medium))
                    .foregroundColor(DSColors.textPrimary)
            }
        }
        .padding(.horizontal, DSSpacing.m)
        .padding(.vertical, DSSpacing.m)
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
        DSErrorState(
            title: "Erro ao carregar detalhes",
            message: store.errorMessage ?? "Ocorreu um erro ao carregar os detalhes do ingresso.",
            retryAction: {
                if let ticketId = store.currentTicketId {
                    store.send(.loadTicketDetail(ticketId))
                }
            }
        )
    }
    
}
