import ComposableArchitecture
import SwiftUI

public struct SellersListView: View {
    @Bindable var store: StoreOf<SellersListFeature>
    @Environment(\.dismiss) var dismiss
    
    public init(store: StoreOf<SellersListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            if store.isLoading {
                loadingView
            } else if store.sellers.isEmpty {
                emptyStateView
            } else {
                sellersListView
            }
        }
        .navigationTitle("Vendedores")
        .navigationBarTitleDisplayMode(.large)
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
        .alert("Erro", isPresented: .constant(store.errorMessage != nil)) {
            Button("OK") {
                store.send(.sellersResponse(.failure(NetworkError.unknown(""))))
            }
        } message: {
            Text(store.errorMessage ?? "")
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Carregando vendedores...")
                .font(.headline)
                .foregroundColor(AppColors.secondaryText)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.secondaryText.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("Nenhum vendedor encontrado")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Não há vendedores com ingressos disponíveis para este evento no momento")
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Sellers List
    
    private var sellersListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let event = store.event {
                    eventHeaderView(event: event)
                }
                
                ForEach(store.sellers) { sellerWithTickets in
                    SellerCard(
                        sellerWithTickets: sellerWithTickets,
                        onSellerTapped: {
                            store.send(.sellerTapped(sellerWithTickets.seller.id))
                        },
                        onNegotiateTapped: {
                            // Usar o primeiro ticket para iniciar negociação
                            if let firstTicket = sellerWithTickets.tickets.first {
                                store.send(.startNegotiation(sellerWithTickets.seller.id, firstTicket.id))
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Event Header
    
    private func eventHeaderView(event: Event) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingressos disponíveis para:")
                .font(.subheadline)
                .foregroundColor(AppColors.secondaryText)
            
            Text(event.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
        )
    }
}

// MARK: - Seller Card

private struct SellerCard: View {
    let sellerWithTickets: SellerWithTickets
    let onSellerTapped: () -> Void
    let onNegotiateTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Card principal
            Button(action: onSellerTapped) {
                HStack(spacing: 16) {
                    // Foto do vendedor
                    AsyncImage(url: URL(string: sellerWithTickets.seller.profileImageURL ?? "")) { image in
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
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            )
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    
                    // Informações do vendedor
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text(sellerWithTickets.seller.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.primaryText)
                            
                            if sellerWithTickets.seller.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            }
                            
                            if sellerWithTickets.seller.isCertified {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        // Preço
                        if sellerWithTickets.minPrice == sellerWithTickets.maxPrice {
                            Text("R$ \(Int(sellerWithTickets.minPrice))")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        } else {
                            Text("R$ \(Int(sellerWithTickets.minPrice)) - R$ \(Int(sellerWithTickets.maxPrice))")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        // Quantidade de ingressos
                        Text("\(sellerWithTickets.ticketsCount) ingresso\(sellerWithTickets.ticketsCount == 1 ? "" : "s") disponível\(sellerWithTickets.ticketsCount == 1 ? "" : "eis")")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.tertiaryText)
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
                .padding(.horizontal)
            
            // Botão de negociar
            Button(action: onNegotiateTapped) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 14))
                    Text("Negociar")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(8)
            }
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.cardShadow.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    NavigationStack {
        SellersListView(
            store: Store(
                initialState: SellersListFeature.State(eventId: UUID())
            ) {
                SellersListFeature()
            }
        )
    }
}


