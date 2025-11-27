import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct SellerProfileView: View {
    @Bindable var store: StoreOf<SellerProfileFeature>
    @Environment(\.dismiss) var dismiss
    
    public init(store: StoreOf<SellerProfileFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            DSGradients.backgroundMain
                .ignoresSafeArea()
            
            if store.isLoading && !store.hasSeller {
                // Loading inicial
                loadingView
            } else if let seller = store.seller {
                // Conteúdo principal com pull-to-refresh
                ScrollView {
                    VStack(spacing: 0) {
                        // Header com foto e nome
                        profileHeaderSection(seller)
                        
                        // Estatísticas
                        statsSection(seller)
                        
                        // Botões de ação
                        actionButtonsSection
                        
                        // Abas
                        tabsSection
                        
                        // Conteúdo da aba selecionada
                        if store.selectedTab == .about {
                            aboutSection(seller)
                        } else {
                            ticketsSection
                        }
                    }
                }
                .refreshable {
                    store.send(.refresh)
                }
            } else {
                errorView
            }
        }
        .navigationTitle("Vendedor")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
    }
    
    // MARK: - Profile Header
    
    private func profileHeaderSection(_ seller: User) -> some View {
        VStack(spacing: 16) {
            // Foto de perfil
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: seller.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(DSGradients.primary)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(DSColors.primary.opacity(0.3), lineWidth: 4)
                )
                
                // Badge de certificação  
                if seller.isCertified {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 3)
                        )
                        .offset(x: 4, y: 4)
                }
            }
            .padding(.top, 24)
            
            // Nome
            HStack(spacing: DSSpacing.xs) {
                Text(seller.name)
                    .font(DSTypography.title1(weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
                
                if seller.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(DSColors.primary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 24)
    }
    
    // MARK: - Stats Section
    
    private func statsSection(_ seller: User) -> some View {
        HStack(spacing: 40) {
            statItem(value: "\(seller.ticketsCount)", label: "Ingressos")
            statItem(value: "\(seller.followersCount)k", label: "Seguidores")
            statItem(value: "\(seller.followingCount)", label: "Seguindo")
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: DSSpacing.xxs) {
            Text(value)
                .font(DSTypography.title3(weight: .bold))
                .foregroundColor(DSColors.textPrimary)
            Text(label)
                .font(DSTypography.footnote())
                .foregroundColor(DSColors.textSecondary)
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtonsSection: some View {
        let currentUserId = UserDefaults.standard.string(forKey: "currentUserId")
        // ✅ CRÍTICO: Verificar se sellerId está disponível e corresponde ao usuário atual
        let sellerId = store.sellerId ?? store.seller?.id ?? ""
        let isOwnProfile = (!sellerId.isEmpty) && (currentUserId == sellerId)
        
        return HStack(spacing: 12) {
            // Botão Seguir - só aparece se não for o próprio perfil
            if !isOwnProfile {
                Button {
                    store.send(.toggleFollow)
                } label: {
                    Text(store.isFollowing ? "Seguindo" : "Seguir")
                        .font(DSTypography.body(weight: .semibold))
                        .foregroundColor(store.isFollowing ? DSColors.primary : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(store.isFollowing ? DSColors.primary.opacity(0.1) : DSColors.primary)
                        .dsCornerRadius(DSRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadius.medium)
                                .stroke(DSColors.primary, lineWidth: store.isFollowing ? 1 : 0)
                        )
                }
                .dsTapFeedback()
            }
            
            // Botão Negociar - não aparece no próprio perfil
            if !isOwnProfile {
                Button {
                    store.send(.negotiateTapped)
                } label: {
                    Text("Negociar")
                        .font(DSTypography.body(weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(DSGradients.primary)
                        .dsCornerRadius(DSRadius.medium)
                }
                .dsTapFeedback()
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, isOwnProfile ? 0 : 24)
    }
    
    // MARK: - Tabs Section
    
    private var tabsSection: some View {
        HStack(spacing: 0) {
            ForEach(SellerProfileFeature.State.Tab.allCases, id: \.self) { tab in
                Button {
                    store.send(.tabSelected(tab))
                } label: {
                    VStack(spacing: DSSpacing.xs) {
                        Text(tab.rawValue)
                            .font(DSTypography.body(weight: .semibold))
                            .foregroundColor(store.selectedTab == tab ? DSColors.textPrimary : DSColors.textSecondary)
                        
                        Rectangle()
                            .fill(store.selectedTab == tab ? DSColors.primary : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .background(DSColors.background)
        .overlay(
            Rectangle()
                .fill(DSColors.border)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - About Section
    
    private func aboutSection(_ seller: User) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            if let bio = seller.bio, !bio.isEmpty {
                Text(bio)
                    .font(DSTypography.body())
                    .foregroundColor(DSColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Este vendedor ainda não adicionou uma biografia.")
                    .font(DSTypography.body())
                    .foregroundColor(DSColors.textSecondary)
                    .italic()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
    }
    
    // MARK: - Tickets Section
    
    private var ticketsSection: some View {
        VStack(spacing: 16) {
            if store.isLoadingTickets {
                DSFullScreenLoading(message: "Carregando ingressos...")
            } else if !store.hasTickets {
                emptyTicketsView
            } else {
                LazyVStack(spacing: DSSpacing.m) {
                    ForEach(Array(store.sellerTickets.enumerated()), id: \.element.id) { index, ticketWithEvent in
                        NavigationLink {
                            TicketDetailView(
                                store: Store(initialState: TicketDetailFeature.State()) {
                                    TicketDetailFeature()
                                },
                                ticketId: UUID(uuidString: ticketWithEvent.ticket.id) ?? UUID(),
                                ticket: ticketWithEvent.ticket
                            )
                        } label: {
                            SellerTicketCard(ticketWithEvent: ticketWithEvent)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .dsEnterAnimation(isVisible: true, delay: Double(index) * 0.05)
                    }
                }
                .padding(.horizontal, DSSpacing.m)
                .padding(.vertical, DSSpacing.m)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyTicketsView: some View {
        DSEmptyState(
            icon: "ticket.fill",
            title: "Nenhum Ingresso Disponível",
            message: "Este vendedor não possui ingressos disponíveis no momento"
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.xxl)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        DSFullScreenLoading(message: "Carregando perfil...")
    }
    
    // MARK: - Error View
    
    private var errorView: some View {
        DSErrorState(
            title: "Erro ao carregar perfil",
            message: store.errorMessage ?? "Ocorreu um erro ao carregar o perfil do vendedor.",
            retryAction: {
                store.send(.onAppear)
            }
        )
    }
}

// MARK: - Seller Ticket Card

struct SellerTicketCard: View {
    let ticketWithEvent: TicketWithEvent
    
    var body: some View {
        ZStack {
            // Cartão com perfuração simulada
            HStack(spacing: 0) {
                // Lado esquerdo com informações e imagem
                HStack(spacing: 12) {
                    // Imagem do evento
                    AsyncImage(url: URL(string: ticketWithEvent.event.imageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 80, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        Group {
                            if ticketWithEvent.ticket.price == 0 {
                                Text("Grátis")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            } else {
                                Text("R$\(Int(ticketWithEvent.ticket.price))")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.blue, Color.purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(8)
                            }
                        }
                        .padding(6),
                        alignment: .topLeading
                    )
                    
                    // Informações do ingresso
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ticketWithEvent.event.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            if let eventDate = ticketWithEvent.event.eventDate {
                                Text(eventDate, style: .date)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Data a definir")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            Text(ticketWithEvent.event.location.address ?? ticketWithEvent.event.location.name)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Linha perfurada
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 1)
                    .overlay(
                        VStack(spacing: 6) {
                            ForEach(0..<10) { _ in
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .frame(width: 3, height: 3)
                            }
                        }
                    )
                
                // Lado direito com QR
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(.systemGray6))
                    Image(systemName: "qrcode")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(width: 88)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}
