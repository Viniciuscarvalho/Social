import SwiftUI
import ComposableArchitecture
import DesignSystem

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
        .onDisappear {
            store.send(.onDisappear)
        }
    }
    
    private var loadingView: some View {
        DSFullScreenLoading(message: "Carregando detalhes do evento...")
                
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
                                .padding(.horizontal, DSSpacing.m)
                                .padding(.vertical, DSSpacing.xs)
                                .background(
                                    Capsule()
                                        .fill(DSColors.primary)
                                )
                                
                                // Nome do evento
                                Text(event.name)
                                    .font(DSTypography.title1(weight: .bold))
                                    .foregroundColor(DSColors.textPrimary)
                                    .lineLimit(3)
                            }
                            .padding(.horizontal, DSSpacing.m)
                            .padding(.top, DSSpacing.xl)
                            .padding(.bottom, DSSpacing.m)
                            
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
                                .font(DSTypography.body(weight: .semibold))
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
                        .padding(.leading, DSSpacing.m)
                        .padding(.top, DSSpacing.xs)
                        .dsTapFeedback()
                        
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
        VStack(spacing: DSSpacing.m) {
            // Card de Preço
            DSCard {
                HStack(spacing: DSSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(DSColors.primary.opacity(0.1))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "ticket.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DSColors.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text(formatPrice(event.startPrice))
                            .font(DSTypography.title3(weight: .bold))
                            .foregroundColor(DSColors.textPrimary)
                        
                        Text(String(localized: "events.detail.price.subtitle"))
                            .font(DSTypography.caption1())
                            .foregroundColor(DSColors.textSecondary)
                    }
                    
                    Spacer()
                }
            }
            
            // Card de Data e Hora
            DSCard {
                HStack(spacing: DSSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(DSColors.primary.opacity(0.1))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 20))
                            .foregroundColor(DSColors.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text(event.dateFormatted)
                            .font(DSTypography.body(weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                        
                        Text(event.timeRange)
                            .font(DSTypography.caption1())
                            .foregroundColor(DSColors.textSecondary)
                    }
                    
                    Spacer()
                }
            }
            
            // Card de Localização
            DSCard {
                HStack(spacing: DSSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(DSColors.primary.opacity(0.1))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "location.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DSColors.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text("\(event.location.city), \(event.location.state)")
                            .font(DSTypography.body(weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                        
                        Text(event.location.name)
                            .font(DSTypography.caption1())
                            .foregroundColor(DSColors.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, DSSpacing.m)
    }
    
    // MARK: - About Section
    
    @ViewBuilder
    private func aboutSection(event: Event) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(String(localized: "events.detail.about.title"))
                .font(DSTypography.title2(weight: .bold))
                .foregroundColor(DSColors.textPrimary)
            
            if let description = event.description {
                Text(description)
                    .font(DSTypography.body())
                    .foregroundColor(DSColors.textSecondary)
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
                .font(DSTypography.title2(weight: .bold))
                .foregroundColor(DSColors.textPrimary)
            
            // Mapa placeholder com pin
            ZStack {
                Rectangle()
                    .fill(DSGradients.primary.opacity(0.1))
                    .frame(height: 180)
                    .dsCornerRadius(DSRadius.medium)
                
                VStack(spacing: DSSpacing.xs) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DSColors.primary.opacity(0.3))
                    
                    ZStack {
                        Circle()
                            .fill(DSColors.primary)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.horizontal, DSSpacing.m)
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
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Outros eventos recomendados")
                .font(DSTypography.title3(weight: .bold))
                .foregroundColor(DSColors.textPrimary)
                .padding(.horizontal, DSSpacing.m)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.m) {
                    ForEach(Array(store.recommendedEvents.enumerated()), id: \.element.id) { index, event in
                        RecommendedEventSmallCard(event: event) {
                            store.send(.recommendedEventSelected(event.id))
                        }
                        .dsEnterAnimation(isVisible: true, delay: Double(index) * 0.05)
                    }
                }
                .padding(.horizontal, DSSpacing.m)
            }
        }
    }
    
    @ViewBuilder
    private func actionButtons(event: Event) -> some View {
        // Botão principal - Negociar Ingresso (navega para lista de vendedores)
        Button {
            store.send(.viewAvailableTickets)
        } label: {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 16))
                Text("Negociar Ingresso")
                    .font(DSTypography.body(weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.m)
            .background(DSGradients.primary)
            .dsCornerRadius(DSRadius.medium)
        }
        .dsTapFeedback()
    }
    
    private var errorView: some View {
        DSErrorState(
            title: "Erro ao carregar evento",
            message: store.errorMessage ?? "Não foi possível carregar os detalhes do evento.",
            retryAction: {
                store.send(.loadEvent(store.eventId))
            }
        )
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
                        .font(DSTypography.caption1(weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xxs)
                        .background(
                            Capsule()
                                .fill(getPriceColor())
                        )
                        .padding(DSSpacing.sm)
                }
                .frame(width: 160, height: 120)
                
                // Event info
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(event.name)
                        .font(DSTypography.caption1(weight: .semibold))
                        .foregroundColor(DSColors.textPrimary)
                        .lineLimit(2)
                    
                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                            .foregroundColor(DSColors.textSecondary)
                        
                        Text(event.dateFormatted)
                            .font(DSTypography.caption2())
                            .foregroundColor(DSColors.textSecondary)
                    }
                    
                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(DSColors.textSecondary)
                        
                        Text(event.location.city)
                            .font(DSTypography.caption2())
                            .foregroundColor(DSColors.textSecondary)
                            .lineLimit(1)
                    }
                }
                .padding(DSSpacing.sm)
            }
            .frame(width: 160)
            .background(DSColors.cardBackground)
            .dsCornerRadius(DSRadius.medium)
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
            return DSColors.success
        }
        return DSColors.primary
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
