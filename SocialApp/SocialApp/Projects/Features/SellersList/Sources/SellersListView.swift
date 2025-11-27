import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct SellersListView: View {
    @Bindable var store: StoreOf<SellersListFeature>
    @Environment(\.dismiss) var dismiss
    
    public init(store: StoreOf<SellersListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            DSGradients.backgroundMain
                .ignoresSafeArea()
            
            if store.isLoading {
                loadingView
            } else if !store.hasSellers {
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
                        .font(DSTypography.body(weight: .semibold))
                        .foregroundColor(DSColors.textPrimary)
                }
                .dsTapFeedback()
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
        .alert("Erro", isPresented: .constant(store.errorMessage != nil)) {
            Button("OK") {
                store.send(.dismissError)
            }
        } message: {
            Text(store.errorMessage ?? "")
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        DSFullScreenLoading(message: "Carregando vendedores...")
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        DSEmptyState(
            icon: "person.3.fill",
            title: "Nenhum vendedor encontrado",
            message: "Não há vendedores com ingressos disponíveis para este evento no momento"
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Sellers List
    
    private var sellersListView: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.m) {
                if let event = store.event {
                    eventHeaderView(event: event)
                        .dsEnterAnimation(isVisible: true, delay: 0)
                }
                
                ForEach(Array(store.sellers.enumerated()), id: \.element.seller.id) { index, sellerWithTickets in
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
                    .dsEnterAnimation(isVisible: true, delay: Double(index) * 0.05)
                }
            }
            .padding(DSSpacing.m)
        }
    }
    
    // MARK: - Event Header
    
    private func eventHeaderView(event: Event) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Ingressos disponíveis para:")
                    .font(DSTypography.footnote())
                    .foregroundColor(DSColors.textSecondary)
                
                Text(event.name)
                    .font(DSTypography.title2(weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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
                            .fill(DSGradients.primary)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            )
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    
                    // Informações do vendedor
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        HStack(spacing: DSSpacing.xs) {
                            Text(sellerWithTickets.seller.name)
                                .font(DSTypography.body(weight: .semibold))
                                .foregroundColor(DSColors.textPrimary)
                            
                            if sellerWithTickets.seller.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(DSColors.primary)
                            }
                            
                            if sellerWithTickets.seller.isCertified {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(DSColors.success)
                            }
                        }
                        
                        // Preço
                        if sellerWithTickets.minPrice == sellerWithTickets.maxPrice {
                            Text("R$ \(Int(sellerWithTickets.minPrice))")
                                .font(DSTypography.body(weight: .bold))
                                .foregroundColor(DSColors.primary)
                        } else {
                            Text("R$ \(Int(sellerWithTickets.minPrice)) - R$ \(Int(sellerWithTickets.maxPrice))")
                                .font(DSTypography.body(weight: .bold))
                                .foregroundColor(DSColors.primary)
                        }
                        
                        // Quantidade de ingressos
                        Text("\(sellerWithTickets.ticketsCount) ingresso\(sellerWithTickets.ticketsCount == 1 ? "" : "s") disponível\(sellerWithTickets.ticketsCount == 1 ? "" : "eis")")
                            .font(DSTypography.footnote())
                            .foregroundColor(DSColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(DSTypography.footnote(weight: .semibold))
                        .foregroundColor(DSColors.textTertiary)
                }
                .padding(DSSpacing.m)
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
                        .font(DSTypography.body(weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.sm)
                .background(DSGradients.primary)
                .dsCornerRadius(DSRadius.small)
            }
            .padding(DSSpacing.m)
            .dsTapFeedback()
        }
        .background(
            RoundedRectangle(cornerRadius: DSRadius.large)
                .fill(DSColors.cardBackground)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
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


