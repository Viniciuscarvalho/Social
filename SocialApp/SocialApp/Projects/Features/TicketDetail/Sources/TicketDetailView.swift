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
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Ticket/Event Image Header
                        ZStack(alignment: .topLeading) {
                            AsyncImage(url: URL(string: ticketDetail.event.imageURL ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        Image(systemName: "ticket.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.5))
                                    )
                            }
                            .frame(width: geometry.size.width, height: min(geometry.size.height * 0.4, 320))
                            .clipped()
                            
                            // Gradient overlay
                            LinearGradient(
                                colors: [Color.black.opacity(0.3), Color.clear, Color.black.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(width: geometry.size.width, height: min(geometry.size.height * 0.4, 320))
                        }
                        
                        // Conteúdo principal
                        VStack(alignment: .leading, spacing: 20) {
                            // Evento e Info do Ingresso
                            VStack(alignment: .leading, spacing: 12) {
                                Text(ticketDetail.event.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.8)
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                    Text(ticketDetail.event.location.name)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                HStack(spacing: 12) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                        Text(ticketDetail.event.dateFormatted)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: "clock")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                        Text(ticketDetail.event.timeRange)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            // Informações do Ingresso
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Ticket Information")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                // Ticket Info Grid
                                LazyVGrid(
                                    columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ],
                                    spacing: 12
                                ) {
                                    InfoCard(
                                        icon: "ticket.fill",
                                        title: "Tipo",
                                        value: ticketDetail.ticketType.displayName
                                    )
                                    
                                    InfoCard(
                                        icon: "number",
                                        title: "Quantidade",
                                        value: "\(ticketDetail.quantity)"
                                    )
                                    
                                    InfoCard(
                                        icon: "checkmark.circle.fill",
                                        title: "Status",
                                        value: ticketDetail.status.displayName,
                                        valueColor: Color(ticketDetail.status.color)
                                    )
                                    
                                    InfoCard(
                                        icon: "calendar",
                                        title: "Válido até",
                                        value: formatDate(ticketDetail.validUntil)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            
                            // Price Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Preço Total")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Text("R$ \(String(format: "%.2f", ticketDetail.price))")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            
                            // Seller Info
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Vendedor")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                NavigationLink {
                                    SellerProfileView(
                                        store: Store(
                                            initialState: SellerProfileFeature.State(sellerId: ticketDetail.seller.id)
                                        ) {
                                            SellerProfileFeature()
                                        }
                                    )
                                } label: {
                                    HStack(spacing: 12) {
                                        AsyncImage(url: URL(string: ticketDetail.seller.profileImageURL ?? "")) { image in
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
                                                        .font(.system(size: 18))
                                                        .foregroundColor(.white)
                                                )
                                        }
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 4) {
                                                Text(ticketDetail.seller.name)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(.primary)
                                                
                                                if ticketDetail.seller.isVerified {
                                                    Image(systemName: "checkmark.seal.fill")
                                                        .foregroundColor(.blue)
                                                        .font(.system(size: 14))
                                                }
                                            }
                                            
                                            if let title = ticketDetail.seller.title {
                                                Text(title)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            
                            // Action Buttons
                            VStack(spacing: 12) {
                                if ticketDetail.status == .available {
                                    Button(action: {
                                        print("ℹ️ Botão Negociar clicado - funcionalidade em desenvolvimento")
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                                .font(.system(size: 16))
                                            Text("Negociar Ingresso")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.blue, Color.purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                }
                                
                                // Validate Ticket Button
                                if ticketDetail.status == .sold || ticketDetail.status == .reserved {
                                    Button(action: {
                                        store.send(.validateTicket)
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.system(size: 16))
                                            Text("Validate Ticket")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.green, Color.green.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                        }
                    }
                }
                
                // Botão de voltar FIXO no topo - Fora do ScrollView
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.4))
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.leading, 16)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
    
    // MARK: - Supporting Views
    
    struct InfoCard: View {
        let icon: String
        let title: String
        let value: String
        var valueColor: Color = .primary
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                    
                    Text(title)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(valueColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
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
