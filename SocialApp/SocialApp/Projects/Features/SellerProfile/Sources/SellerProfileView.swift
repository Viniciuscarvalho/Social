import ComposableArchitecture
import SwiftUI

public struct SellerProfileView: View {
    @Bindable var store: StoreOf<SellerProfileFeature>
    @Environment(\.dismiss) var dismiss
    
    public init(store: StoreOf<SellerProfileFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            if store.isLoading && store.seller == nil {
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
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
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
                        .stroke(Color.blue.opacity(0.3), lineWidth: 4)
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
            HStack(spacing: 8) {
                Text(seller.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                if seller.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
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
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtonsSection: some View {
        let currentUserId = UserDefaults.standard.string(forKey: "currentUserId")
        // ✅ CRÍTICO: Verificar se sellerId está disponível e corresponde ao usuário atual
        let sellerId = store.sellerId ?? store.seller?.id ?? ""
        let isOwnProfile = ((currentUserId?.isEmpty) == nil) && !sellerId.isEmpty && currentUserId == sellerId
        
        return HStack(spacing: 12) {
            // Botão Seguir - só aparece se não for o próprio perfil
            if !isOwnProfile {
                Button {
                    store.send(.toggleFollow)
                } label: {
                    Text(store.isFollowing ? "Seguindo" : "Seguir")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(store.isFollowing ? .blue : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(store.isFollowing ? Color.blue.opacity(0.1) : Color.blue)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: store.isFollowing ? 1 : 0)
                        )
                }
            }
            
            // Botão Negociar - não aparece no próprio perfil
            if !isOwnProfile {
                Button {
                    store.send(.negotiateTapped)
                } label: {
                    Text("Negociar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
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
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(store.selectedTab == tab ? .primary : .secondary)
                        
                        Rectangle()
                            .fill(store.selectedTab == tab ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - About Section
    
    private func aboutSection(_ seller: User) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            if let bio = seller.bio, !bio.isEmpty {
                Text(bio)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Este vendedor ainda não adicionou uma biografia.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
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
                ProgressView()
                    .padding(40)
            } else if store.sellerTickets.isEmpty {
                emptyTicketsView
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(store.sellerTickets) { ticketWithEvent in
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
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyTicketsView: some View {
        VStack(spacing: 20) {
            Image("empty_ticket")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Nenhum Ingresso Disponível")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Este vendedor não possui ingressos disponíveis no momento")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Carregando perfil...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Error View
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Erro ao carregar perfil")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button("Tentar Novamente") {
                store.send(.onAppear)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Seller Ticket Card

struct SellerTicketCard: View {
    let ticketWithEvent: TicketWithEvent
    
    var body: some View {
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
                // Badge "Free" ou preço
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
                        Text("$\(Int(ticketWithEvent.ticket.price))")
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
                // Nome do evento
                Text(ticketWithEvent.event.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                // Data e hora
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
                
                // Local
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
            
            // Botão de favorito
            Button {
                // TODO: Implementar favoritar
            } label: {
                Image("unfavorited", bundle: Bundle.main)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
