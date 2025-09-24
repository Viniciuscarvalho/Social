import ComposableArchitecture
import SwiftUI
import SharedModels

public struct TicketDetailView: View {
    @Bindable var store: StoreOf<TicketDetailFeature>
    let ticketId: UUID
    
    public init(store: StoreOf<TicketDetailFeature>, ticketId: UUID) {
        self.store = store
        self.ticketId = ticketId
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if store.isLoading {
                    loadingView
                } else if let ticketDetail = store.ticketDetail {
                    ticketContentView(ticketDetail)
                } else {
                    errorView
                }
            }
            .padding()
        }
        .navigationTitle("Detalhes do Ingresso")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            store.send(.onAppear(ticketId))
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
                    
                    HStack {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(ticketDetail.seller.name)
                                .fontWeight(.semibold)
                            if let title = ticketDetail.seller.title {
                                Text(title)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                
                // Purchase Button
                if ticketDetail.status == .available {
                    Button(action: {
                        store.send(.purchaseTicket(ticketDetail.ticketId))
                    }) {
                        HStack {
                            if store.isPurchasing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(store.isPurchasing ? "Processando..." : "Comprar Ingresso")
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
            
            Button("Tentar Novamente") {
                store.send(.onAppear(ticketId))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
