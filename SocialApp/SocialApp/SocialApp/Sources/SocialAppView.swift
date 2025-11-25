import ComposableArchitecture
import SwiftUI

public struct SocialAppView: View {
    @Bindable var store: StoreOf<SocialAppFeature>
    @Environment(ThemeManager.self) private var themeManager
    @State private var showingSplash = false
    
    public init(store: StoreOf<SocialAppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            // Conteúdo principal
            Group {
                if store.isAuthenticated && store.currentUser != nil {
                    MainTabView(store: store)
                        .onAppear {
                            print("🏠 SocialAppView: MainTabView apareceu (usuário autenticado)")
                        }
                } else {
                    AuthenticationView(store: store)
                        .onAppear {
                            print("🔐 SocialAppView: AuthenticationView apareceu (usuário não autenticado)")
                            print("   • store.isAuthenticated: \(store.isAuthenticated)")
                            print("   • store.currentUser: \(store.currentUser?.name ?? "nil")")
                        }
                }
            }
            .opacity(showingSplash ? 0 : 1)
            
            // Splash sobreposto - só aparece na primeira vez
            if showingSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            print("🚀 SocialAppView: onAppear chamado")
            store.send(.onAppear)
            // Configurar listeners de NotificationCenter para sincronização global
            setupTicketSyncListeners(store: store)
            
            // Mostrar splash apenas na primeira vez que o app abre
            if store.isFirstLaunch {
                print("🎬 Primeira vez abrindo o app - mostrando splash")
                showingSplash = true
                
                // Mostrar splash por 2 segundos e depois marcar que não é mais o primeiro launch
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 segundos
                    withAnimation(.easeOut(duration: 0.3)) {
                        showingSplash = false
                    }
                    // Marcar que não é mais o primeiro launch
                    store.send(.auth(.markFirstLaunchComplete))
                }
            } else {
                print("✅ App já foi aberto antes - pulando splash")
                showingSplash = false
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }
    
    // MARK: - NotificationCenter Listeners para Sincronização Global
    
    private func setupTicketSyncListeners(store: StoreOf<SocialAppFeature>) {
        // Listener para ticket deletado
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("TicketDeleted"),
            object: nil,
            queue: .main
        ) { notification in
            if let ticketId = notification.userInfo?["ticketId"] as? String,
               let sellerId = notification.userInfo?["sellerId"] as? String {
                print("📢 SocialAppView recebeu notificação: TicketDeleted(\(ticketId)) do vendedor \(sellerId)")
                
                // Sincronizar em todas as features (incluindo MyTicketsFeature)
                store.send(.ticketsListFeature(.syncTicketDeleted(ticketId)))
                store.send(.profileFeature(.ticketDeleted))
                store.send(.sellerProfileFeature(.syncTicketDeleted(ticketId)))
                
                // ✅ CRÍTICO: Notificar MyTicketsFeature também (via ProfileFeature que gerencia o MyTicketsView)
                // O ProfileFeature já gerencia a sheet do MyTickets, então não precisamos notificar diretamente
                // Mas podemos criar uma action no ProfileFeature para notificar o MyTickets
                
                // Invalidar cache do perfil do vendedor específico
                Task {
                    await SellerProfileCache.shared.invalidateCache(for: sellerId)
                    print("🗑️ Cache do vendedor \(sellerId) invalidado após deleção de ticket")
                }
            } else if let ticketId = notification.userInfo?["ticketId"] as? String {
                // Fallback: sem sellerId, sincronizar e limpar todos os caches
                print("📢 SocialAppView recebeu notificação: TicketDeleted(\(ticketId)) sem sellerId")
                store.send(.ticketsListFeature(.syncTicketDeleted(ticketId)))
                store.send(.profileFeature(.ticketDeleted))
                
                Task {
                    await SellerProfileCache.shared.clearAll()
                    print("🗑️ Cache de vendedores invalidado após deleção de ticket")
                }
            }
        }
        
        // Listener para ticket atualizado
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("TicketUpdated"),
            object: nil,
            queue: .main
        ) { notification in
            if let ticket = notification.userInfo?["ticket"] as? Ticket {
                print("📢 SocialAppView recebeu notificação: TicketUpdated(\(ticket.id)) do vendedor \(ticket.sellerId)")
                
                // Sincronizar em todas as features
                store.send(.ticketsListFeature(.syncTicketUpdated(ticket)))
                store.send(.sellerProfileFeature(.syncTicketUpdated(ticket)))
                
                // Invalidar cache do perfil do vendedor desse ticket
                Task {
                    await SellerProfileCache.shared.invalidateCache(for: ticket.sellerId)
                    print("🗑️ Cache do vendedor \(ticket.sellerId) invalidado após atualização de ticket")
                }
            }
        }
        
        // Listener para ticket criado
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("TicketCreated"),
            object: nil,
            queue: .main
        ) { notification in
            if let ticket = notification.userInfo?["ticket"] as? Ticket {
                print("📢 SocialAppView recebeu notificação: TicketCreated(\(ticket.id))")
                // A criação já é tratada no .addTicket(.publishTicketResponse(.success))
                // Mas garantimos sincronização aqui também
                store.send(.ticketsListFeature(.syncTicketCreated(ticket)))
                // ✅ Atualizar contador no perfil após criar ticket
                store.send(.profileFeature(.ticketCreated))
            }
        }
        
        // Listener para navegação para eventos
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToEventsTab"),
            object: nil,
            queue: .main
        ) { _ in
            store.send(.tabSelected(.home))
        }
        
        // Listener para navegação para detalhe do evento a partir de favoritos
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToEventDetail"),
            object: nil,
            queue: .main
        ) { notification in
            if let eventId = notification.userInfo?["eventId"] as? UUID {
                print("📢 SocialAppView: Navegando para evento favorito: \(eventId.uuidString)")
                store.send(.homeFeature(.eventSelected(eventId.uuidString)))
            }
        }
        
        // Listener para navegação para perfil de vendedor
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToSellerProfile"),
            object: nil,
            queue: .main
        ) { notification in
            if let sellerIdString = notification.userInfo?["sellerId"] as? String,
               let sellerId = UUID(uuidString: sellerIdString) {
                print("📢 SocialAppView: Navegando para perfil de vendedor: \(sellerIdString)")
                store.send(.navigateToSellerProfile(sellerId))
            }
        }
        
        // Listener para atualizar badge quando pergunta é respondida
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("QuestionAnswered"),
            object: nil,
            queue: .main
        ) { _ in
            print("🔔 Pergunta respondida - atualizando badge")
            store.send(.updateBadgeCount)
        }
        
        // Listener para atualizar badge quando negociação é marcada como lida
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NegotiationRead"),
            object: nil,
            queue: .main
        ) { _ in
            print("🔔 Negociação marcada como lida - atualizando badge")
            store.send(.updateBadgeCount)
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Bindable var store: StoreOf<SocialAppFeature>
    
    // Verifica se estamos em uma tela de detalhes
    private var isShowingDetail: Bool {
        store.selectedEventId != nil || 
        store.selectedTicketId != nil || 
        store.selectedSellerId != nil ||
        store.showingSellersList
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            Group {
                switch store.selectedTab {
                case .home:
                    homeTab
                case .tickets:
                    ticketsTab
                case .addTicket:
                    Color.clear
                case .negotiations:
                    negotiationsTab
                case .profile:
                    profileTab
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea(.keyboard)
            
            // TabBar só aparece quando não estiver em tela de detalhes
            if !isShowingDetail {
                CustomTabBar(
                    selectedTab: $store.selectedTab.sending(\.tabSelected),
                    unreadQuestionsCount: store.unreadQuestionsCount,
                    onAddTicket: {
                        store.send(.addTicketTapped)
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isShowingDetail)
        .sheet(isPresented: $store.showingAddTicket.sending(\.setShowingAddTicket)) {
            AddTicketView(store: store.scope(state: \.addTicket, action: \.addTicket))
        }
        .sheet(isPresented: $store.showingRecommendedEvents.sending(\.setShowingRecommendedEvents)) {
            NavigationStack {
                RecommendedEventsView(
                    events: store.homeFeature.recommendedEvents,
                    onEventSelected: { eventId in
                        store.send(.homeFeature(.eventSelected(eventId)))
                        store.send(.setShowingRecommendedEvents(false))
                    }
                )
            }
        }
        .sheet(isPresented: $store.showingPopularEvents.sending(\.setShowingPopularEvents)) {
            NavigationStack {
                PopularEventsView(
                    events: store.homeFeature.homeContent.curatedEvents,
                    onEventSelected: { eventId in
                        store.send(.homeFeature(.eventSelected(eventId)))
                        store.send(.setShowingPopularEvents(false))
                    }
                )
            }
        }
        .sheet(isPresented: $store.showingSellersList.sending(\.setShowingSellersList)) {
            if let sellersListStore = store.scope(state: \.sellersListFeature, action: \.sellersListFeature) {
                NavigationStack {
                    SellersListView(store: sellersListStore)
                }
            }
        }
    }
    
    @ViewBuilder
    private var homeTab: some View {
        NavigationStack {
            homeTabContent
        }
    }
    
    @ViewBuilder
    private var homeTabContent: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            HomeView(
                store: store.scope(
                    state: \.homeFeature,
                    action: \.homeFeature
                ),
                searchStore: store.scope(
                    state: \.searchFeature,
                    action: \.searchFeature
                )
            )
            .padding(.bottom, 120)
        }
        .navigationDestination(item: $store.selectedEventId.sending(\.dismissEventNavigation)) { eventId in
            eventDetailDestination(eventId: eventId)
        }
        .navigationDestination(item: $store.selectedTicketId.sending(\.dismissTicketNavigation)) { ticketId in
            ticketDetailDestination(ticketId: ticketId)
        }
        .navigationDestination(item: $store.selectedSellerId.sending(\.dismissSellerNavigation)) { sellerId in
            sellerProfileDestination(sellerId: sellerId)
        }
    }
    
    @ViewBuilder
    private func eventDetailDestination(eventId: UUID) -> some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            if let eventDetailStore = store.scope(state: \.eventDetailFeature, action: \.eventDetailFeature) {
                EventDetailView(store: eventDetailStore, eventId: eventId)
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }
    
    @ViewBuilder
    private func ticketDetailDestination(ticketId: UUID) -> some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            TicketDetailView(
                store: store.scope(
                    state: \.ticketDetailFeature,
                    action: \.ticketDetailFeature
                ),
                ticketId: ticketId
            )
            .toolbar(.hidden, for: .tabBar)
        }
    }
    
    @ViewBuilder
    private func sellerProfileDestination(sellerId: UUID) -> some View {
        SellerProfileView(
            store: store.scope(
                state: \.sellerProfileFeature,
                action: \.sellerProfileFeature
            )
        )
        .onAppear {
            store.send(.sellerProfileFeature(.loadSeller(sellerId.uuidString)))
        }
    }
    
    @ViewBuilder
    private var ticketsTab: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                TicketsListView(
                    store: store.scope(
                        state: \.ticketsListFeature,
                        action: \.ticketsListFeature
                    )
                )
                .padding(.bottom, 120)
            }
            .navigationDestination(item: $store.selectedTicketId.sending(\.dismissTicketNavigation)) { ticketId in
                ZStack {
                    AppColors.backgroundGradient
                        .ignoresSafeArea()
                    
                    TicketDetailView(
                        store: store.scope(
                            state: \.ticketDetailFeature,
                            action: \.ticketDetailFeature
                        ),
                        ticketId: ticketId
                    )
                    .toolbar(.hidden, for: .tabBar)
                }
            }
            .navigationDestination(item: $store.selectedSellerId.sending(\.dismissSellerNavigation)) { sellerId in
                sellerProfileDestination(sellerId: sellerId)
            }
        }
    }
    
    @ViewBuilder
    private var negotiationsTab: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                NegotiationsListView(
                    store: store.scope(
                        state: \.negotiationsListFeature,
                        action: \.negotiationsListFeature
                    )
                )
                .padding(.bottom, 120)
            }
            .navigationDestination(item: $store.selectedNegotiationId.sending(\.dismissNegotiationNavigation)) { negotiationId in
                ZStack {
                    AppColors.backgroundGradient
                        .ignoresSafeArea()
                    
                    NegotiationChatView(
                        store: Store(
                            initialState: NegotiationDetailsFeature.State(negotiationId: negotiationId),
                            reducer: { NegotiationDetailsFeature() }
                        )
                    )
                    .onReceive(
                        NotificationCenter.default.publisher(for: NSNotification.Name("NegotiationRead"))
                    ) { notification in
                        if let negotiationId = notification.userInfo?["negotiationId"] as? String {
                            store.send(.negotiationsListFeature(.delegate(.negotiationRead(negotiationId))))
                        }
                    }
                    .toolbar(.hidden, for: .tabBar)
                }
            }
        }
    }
    
    @ViewBuilder
    private var profileTab: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                ProfileView(
                    store: store.scope(
                        state: \.profileFeature,
                        action: \.profileFeature
                    )
                )
                .padding(.bottom, 120)
            }
            .navigationDestination(item: $store.selectedSellerId.sending(\.dismissSellerNavigation)) { sellerId in
                sellerProfileDestination(sellerId: sellerId)
            }
        }
    }
}

// MARK: - Custom TabBar

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    let unreadQuestionsCount: Int
    let onAddTicket: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Home
            TabBarButton(
                icon: AppTab.home.icon,
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            
            // Tickets
            TabBarButton(
                icon: AppTab.tickets.icon,
                isSelected: selectedTab == .tickets
            ) {
                selectedTab = .tickets
            }
            
            // Botão + Central (maior e elevado)
            AddButton(action: onAddTicket)
                .offset(y: -8)
            
            // Negotiations
            TabBarButton(
                icon: AppTab.negotiations.icon,
                isSelected: selectedTab == .negotiations,
                badgeCount: unreadQuestionsCount > 0 ? unreadQuestionsCount : nil
            ) {
                selectedTab = .negotiations
            }
            
            // Profile
            TabBarButton(
                icon: AppTab.profile.icon,
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .frame(height: 70)
        .background(
            ZStack {
                // Fundo principal
                Capsule()
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
                
                // Overlay com gradiente sutil
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let badgeCount: Int?
    let action: () -> Void
    
    init(icon: String, isSelected: Bool, badgeCount: Int? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.isSelected = isSelected
        self.badgeCount = badgeCount
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .frame(height: 28)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .foregroundColor(isSelected ? Color.blue : Color.gray)
                
                // Badge
                if let count = badgeCount, count > 0 {
                    Text(count > 99 ? "99+" : "\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, count > 9 ? 5 : 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.red)
                        )
                        .offset(x: 8, y: -4)
                        .animation(.spring(response: 0.3), value: count)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Círculo externo maior com gradiente
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.blue.opacity(0.4), radius: 15, x: 0, y: 5)
                
                // Ícone +
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
