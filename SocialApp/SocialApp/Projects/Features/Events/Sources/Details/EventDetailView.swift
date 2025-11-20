import SwiftUI
import ComposableArchitecture

public struct EventDetailView: View {
    @Bindable var store: StoreOf<EventDetailFeature>
    let eventId: UUID
    let event: Event? // ✅ Evento opcional para evitar chamada API
    @Environment(\.dismiss) var dismiss
    
    public init(store: StoreOf<EventDetailFeature>, eventId: UUID, event: Event? = nil) {
        self.store = store
        self.eventId = eventId
        self.event = event
    }
    
    public var body: some View {
        Group {
            if store.isLoading {
                loadingView
            } else if let event = store.event {
                eventContentView(event)
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
            print("🎪 EventDetailView apareceu para evento: \(eventId)")
            store.send(.onAppear(eventId, event)) // ✅ Passa o evento se tiver
        }
    }
    
    private var loadingView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero image skeleton
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 300)
                    .shimmer()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Badge skeleton
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(width: 100, height: 30)
                        .shimmer()
                    
                    // Title skeleton
                    VStack(alignment: .leading, spacing: 8) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 28)
                            .shimmer()
                        
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(width: 200, height: 28)
                            .shimmer()
                    }
                    
                    // Info cards skeletons
                    ForEach(0..<3) { _ in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 48, height: 48)
                                .shimmer()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 120, height: 16)
                                    .shimmer()
                                
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 80, height: 12)
                                    .shimmer()
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
    }
    
    @ViewBuilder
    private func eventContentView(_ event: Event) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Event Image
                        ZStack(alignment: .topLeading) {
                            AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
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
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.5))
                                    )
                            }
                            .frame(width: geometry.size.width, height: min(geometry.size.height * 0.5, 450))
                            .clipped()
                            
                            // Gradient overlay
                            LinearGradient(
                                colors: [Color.black.opacity(0.3), Color.clear, Color.black.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(width: geometry.size.width, height: min(geometry.size.height * 0.5, 450))
                        }
                        
                        // Conteúdo principal
                        VStack(alignment: .leading, spacing: 0) {
                            // Badge da categoria e nome do evento
                            VStack(alignment: .leading, spacing: 12) {
                                // Badge da categoria
                                HStack(spacing: 6) {
                                    Text(event.category.icon)
                                        .font(.system(size: 14))
                                    Text(event.category.displayName)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.blue)
                                )
                                
                                // Nome do evento
                                Text(event.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                                    .lineLimit(3)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 20)
                            
                            // Cards de informação
                            infoCards(event: event)
                            
                            Divider()
                                .padding(.vertical, 24)
                            
                            // Sobre o evento
                            aboutSection(event: event)
                            
                            Divider()
                                .padding(.vertical, 24)
                            
                            // Localização
                            locationSection(event: event)
                            
                            // Botões de ação
                            actionButtons(event: event)
                                .padding(.horizontal, 20)
                                .padding(.top, 32)
                                .padding(.bottom, 100)
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
    
    // MARK: - Info Cards (Preço, Data, Localização)
    
    @ViewBuilder
    private func infoCards(event: Event) -> some View {
        VStack(spacing: 16) {
            // Card de Preço
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "ticket.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatPrice(event.startPrice))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(String(localized: "events.detail.price.subtitle"))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            
            // Card de Data e Hora
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.dateFormatted)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(event.timeRange)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            
            // Card de Localização
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "location.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(event.location.city), \(event.location.state)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(event.location.name)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - About Section
    
    @ViewBuilder
    private func aboutSection(event: Event) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "events.detail.about.title"))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            if let description = event.description {
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
            } else {
                Text(String(localized: "events.detail.about.placeholder"))
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Location Section
    
    @ViewBuilder
    private func locationSection(event: Event) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "events.detail.location.title"))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            // Mapa placeholder com pin
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)
                    .cornerRadius(12)
                
                VStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue.opacity(0.3))
                    
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func formatPrice(_ price: Double) -> String {
        if price == 0 {
            return String(localized: "common.price.free")
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: price)) ?? "R$ \(price)"
    }
    
    @ViewBuilder
    private var recommendedEventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Outros eventos recomendados")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.recommendedEvents) { event in
                        RecommendedEventSmallCard(event: event) {
                            store.send(.recommendedEventSelected(event.id))
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    @ViewBuilder
    private func actionButtons(event: Event) -> some View {
        // Botão principal - Negociar Ingresso (navega para lista de vendedores)
        Button {
            store.send(.viewAvailableTickets)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 16))
                Text("Negociar Ingresso")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Erro ao carregar evento")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Tentar Novamente") {
                store.send(.onAppear(eventId, event))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}


// MARK: - Recommended Event Small Card

struct RecommendedEventSmallCard: View {
    let event: Event
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Event image with price badge
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
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
                    }
                    .frame(width: 160, height: 120)
                    .clipped()
                    
                    // Price badge
                    Text(getPriceText())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(getPriceColor())
                        )
                        .padding(10)
                }
                .frame(width: 160, height: 120)
                
                // Event info
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text(event.dateFormatted)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text(event.location.city)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(10)
            }
            .frame(width: 160)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func getPriceText() -> String {
        if event.startPrice == 0 {
            return "Free"
        }
        return "$\(Int(event.startPrice))"
    }
    
    private func getPriceColor() -> Color {
        if event.startPrice == 0 {
            return Color.green
        }
        return Color.blue
    }
}

// MARK: - Shimmer Effect

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        Color.white.opacity(0.3),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = UIScreen.main.bounds.width * 2
                }
            }
    }
}
