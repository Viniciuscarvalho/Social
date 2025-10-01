import ComposableArchitecture
import SwiftUI

public struct SocialAppView: View {
    @Bindable var store: StoreOf<SocialAppFeature>
    
    public init(store: StoreOf<SocialAppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            // Content based on selected tab
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
            
            CustomTabBar(
                selectedTab: $store.selectedTab.sending(\.tabSelected),
                onAddTicket: {
                    store.send(.addTicketTapped)
                }
            )
        }
        .sheet(isPresented: $store.showingAddTicket.sending(\.setShowingAddTicket)) {
            AddTicketView(store: store.scope(state: \.addTicket, action: \.addTicket))
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
                    )
                )
                .padding(.bottom, 100)
            }
            .navigationDestination(item: $store.selectedEventId.sending(\.dismissEventNavigation)) { eventId in
                ZStack {
                    AppColors.backgroundGradient
                        .ignoresSafeArea()
                    
                    EventDetailView(eventId: eventId)
                        .toolbar(.hidden, for: .tabBar)
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
                    store.send(.sellerProfileFeature(.loadProfileById(sellerId)))
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
                .padding(.bottom, 100)
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
                    
                    EventDetailView(eventId: eventId)
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
                
                ProfileView()
                    .padding(.bottom, 100)
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
                .padding(.horizontal, 20)
            
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
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.cardShadow.opacity(0.15), radius: 20, x: 0, y: -8)
        )
        .padding(.bottom, 0)
    }
    
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .frame(height: 24)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .foregroundColor(isSelected ? AppColors.primary : AppColors.tertiaryText)
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
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.accentGreen, AppColors.accentGreen.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: AppColors.accentGreen.opacity(0.25), radius: 8, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .offset(y: -20)
        .buttonStyle(PlainButtonStyle())
    }
}
