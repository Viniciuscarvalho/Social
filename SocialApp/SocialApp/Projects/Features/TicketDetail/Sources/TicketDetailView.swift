import ComposableArchitecture
import SwiftUI

public struct TicketDetailView: View {
    @Bindable var store: StoreOf<TicketDetailFeature>
    let ticketId: UUID
    let ticket: Ticket? // ✅ Ticket opcional para evitar chamada API
    
    public init(store: StoreOf<TicketDetailFeature>, ticketId: UUID, ticket: Ticket? = nil) {
        self.store = store
        self.ticketId = ticketId
        self.ticket = ticket
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if store.isLoading {
                    loadingView
                } else if let ticketDetail = store.ticketDetail {
                    ticketContentView(ticketDetail)
                } else if let simpleTicket = ticket {
                    // ✅ Carrega automaticamente os detalhes completos quando só temos o ticket básico
                    VStack(spacing: 20) {
                        Text("Carregando detalhes completos...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        ProgressView()
                            .scaleEffect(1.2)
                    }
                    .onAppear {
                        if store.ticketDetail == nil {
                            store.send(.loadTicketDetail(ticketId))
                        }
                    }
                } else {
                    errorView
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
        .navigationTitle("Detalhes do Ingresso")
        .navigationBarTitleDisplayMode(.large)
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
        VStack(spacing: 24) {
            // Event Image
            AsyncImage(url: URL(string: ticketDetail.event.imageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 200)
            .cornerRadius(12)
            
            // Event Info
            VStack(alignment: .leading, spacing: 16) {
                Text(ticketDetail.event.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.secondary)
                    Text(ticketDetail.event.location.name)
                        .foregroundColor(.secondary)
                }
                
                // Ticket Info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Tipo:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(ticketDetail.ticketType.displayName)
                    }
                    
                    HStack {
                        Text("Quantidade:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(ticketDetail.quantity)")
                    }
                    
                    HStack {
                        Text("Status:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(ticketDetail.status.displayName)
                            .foregroundColor(Color(ticketDetail.status.color))
                    }
                    
                    HStack {
                        Text("Válido até:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(ticketDetail.validUntil, style: .date)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Price
                HStack {
                    Text("Preço Total:")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("$\(Int(ticketDetail.price))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                // Seller Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vendedor")
                        .font(.headline)
                    
                    NavigationLink {
                        SellerProfileView(
                            store: Store(
                                initialState: SellerProfileFeature.State(sellerId: ticketDetail.seller.id)
                            ) {
                                SellerProfileFeature()
                            }
                        )
                    } label: {
                        HStack {
                            AsyncImage(url: URL(string: ticketDetail.seller.profileImageURL ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.blue)
                                    )
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(ticketDetail.seller.name)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    if ticketDetail.seller.isVerified {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                    }
                                }
                                
                                if let title = ticketDetail.seller.title {
                                    Text(title)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                
                // Trade Button
                if ticketDetail.status == .available {
                    Button(action: {
                        // Converter ticketId de String para UUID
                        if let uuid = UUID(uuidString: ticketDetail.ticketId) {
                            store.send(.purchaseTicket(uuid))
                        }
                    }) {
                        HStack {
                            if store.isPurchasing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(store.isPurchasing ? "Processando..." : "Negociar Ingresso")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(store.isPurchasing)
                }
            }
        }
        
    }
    
    // MARK: - Supporting Views
    
    struct DetailRow: View {
        let title: String
        let value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .fontWeight(.semibold)
                Spacer()
                Text(value)
                    .foregroundColor(.secondary)
            }
        }
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
