import ComposableArchitecture
import SwiftUI

public struct SocialAppView: View {
    @Bindable var store: StoreOf<SocialAppFeature>
    @Environment(ThemeManager.self) private var themeManager
    
    public init(store: StoreOf<SocialAppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Group {
            if store.isAuthenticated && store.currentUser != nil {
                MainTabView(store: store)
            } else {
                AuthenticationView(store: store)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .preferredColorScheme(themeManager.colorScheme)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Bindable var store: StoreOf<SocialAppFeature>
    
    // Verifica se estamos em uma tela de detalhes
    private var isShowingDetail: Bool {
        store.selectedEventId != nil || 
        store.selectedTicketId != nil || 
        store.selectedSellerId != nil
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
                case .favorites:
                    favoritesTab
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
    }
    
    @ViewBuilder
    private var homeTab: some View {
        NavigationStack {
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
                .padding(.bottom, 120) // Aumentar para acomodar TabBar maior
            }
            .navigationDestination(item: $store.selectedEventId.sending(\.dismissEventNavigation)) { eventId in
                ZStack {
                    AppColors.backgroundGradient
                        .ignoresSafeArea()
                    
                    if let eventDetailStore = store.scope(state: \.eventDetailFeature, action: \.eventDetailFeature) {
                        EventDetailView(store: eventDetailStore, eventId: eventId)
                        .toolbar(.hidden, for: .tabBar)
                    }
                }
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
                SellerProfileView(
                    store: store.scope(
                        state: \.sellerProfileFeature,
                        action: \.sellerProfileFeature
                    )
                )
                .onAppear {
                    store.send(.sellerProfileFeature(.loadProfileById(sellerId.uuidString)))
                }
            }
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
                .padding(.bottom, 120) // Aumentar para acomodar TabBar maior
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
        }
    }
    
    @ViewBuilder
    private var favoritesTab: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                FavoritesView(
                    store: store.scope(
                        state: \.favoritesFeature,
                        action: \.favoritesFeature
                    )
                )
                .padding(.bottom, 100)
            }
            .navigationDestination(item: $store.selectedEventId.sending(\.dismissEventNavigation)) { eventId in
                ZStack {
                    AppColors.backgroundGradient
                        .ignoresSafeArea()
                    
                    if let eventDetailStore = store.scope(state: \.eventDetailFeature, action: \.eventDetailFeature) {
                        EventDetailView(store: eventDetailStore, eventId: eventId)
                        .toolbar(.hidden, for: .tabBar)
                    }
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
                .padding(.bottom, 120) // Aumentar para acomodar TabBar maior
            }
        }
    }
}

// MARK: - Custom TabBar

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
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
            
            // Favorites
            TabBarButton(
                icon: AppTab.favorites.icon,
                isSelected: selectedTab == .favorites
            ) {
                selectedTab = .favorites
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .frame(height: 28)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .foregroundColor(isSelected ? Color.blue : Color.gray)
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
