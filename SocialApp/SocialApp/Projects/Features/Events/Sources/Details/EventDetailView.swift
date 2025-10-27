import SwiftUI
import ComposableArchitecture

public struct EventDetailView: View {
    @Bindable var store: StoreOf<EventDetailFeature>
    let eventId: UUID
    let event: Event? // ✅ Evento opcional para evitar chamada API
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: EventDetailTab = .about
    
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
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Carregando evento...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
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
                        VStack(alignment: .leading, spacing: 20) {
                            // Nome e data do evento - Responsivo
                            VStack(alignment: .leading, spacing: 8) {
                                Text(event.name)
                                    .font(.system(size: min(geometry.size.width * 0.08, 32), weight: .bold))
                                    .foregroundColor(.primary)
                                    .lineLimit(4)
                                    .minimumScaleFactor(0.8)
                                
                                HStack(spacing: 12) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                        Text("\(event.dateFormatted)")
                                            .font(.system(size: 15))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: "clock")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                        Text(event.timeRange)
                                            .font(.system(size: 15))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Tabs customizadas
                            tabSelector
                            
                            // Conteúdo das tabs
                            tabContent(event: event, geometry: geometry)
                            
                            // Eventos recomendados
                            if !store.recommendedEvents.isEmpty {
                                recommendedEventsSection
                            }
                            
                            // Botões de ação
                            actionButtons(event: event)
                                .padding(.horizontal, 20)
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
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(EventDetailTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(tab.title)
                            .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    @ViewBuilder
    private func tabContent(event: Event, geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            switch selectedTab {
            case .about:
                aboutContent(event: event)
            case .participants:
                participantsContent()
            case .location:
                locationContent(event: event)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .frame(minHeight: geometry.size.height * 0.3)
        .animation(.easeInOut, value: selectedTab)
    }
    
    @ViewBuilder
    private func aboutContent(event: Event) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let description = event.description {
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
            } else {
                Text("This week, Abel comes back to California to perform his newest studio album, as well as some newest hits. Check him out!")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
            }
            
            // Category
            HStack(spacing: 8) {
                Text(event.category.icon)
                    .font(.system(size: 16))
                Text(event.category.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue.opacity(0.1))
            )
        }
    }
    
    @ViewBuilder
    private func participantsContent() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Participantes")
                .font(.system(size: 16, weight: .semibold))
            
            Text("Esta funcionalidade estará disponível em breve.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private func locationContent(event: Event) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.location.name)
                        .font(.system(size: 16, weight: .semibold))
                    
                    if let address = event.location.address {
                        Text(address)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(event.location.city), \(event.location.state)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
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
        VStack(spacing: 12) {
            // Botão principal - Negociar Ingresso
            Button {
                store.send(.negotiateTicket)
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
            
            // Botão secundário - Save for later
            Button {
                store.send(.toggleFavorite)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: store.isFavorited ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                    Text(store.isFavorited ? "Salvo" : "Salvar para depois")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1.5)
                )
            }
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

// MARK: - Event Detail Tab

enum EventDetailTab: CaseIterable {
    case about
    case participants
    case location
    
    var title: String {
        switch self {
        case .about:
            return "ABOUT"
        case .participants:
            return "PARTICIPANTS"
        case .location:
            return "LOCATION"
        }
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
