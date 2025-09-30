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
            
            TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
                homeTab
                ticketsTab
                
                Color.clear
                    .tag(AppTab.addTicket)
                
                favoritesTab
                profileTab
            }
            .preferredColorScheme(.dark)
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
            }
            .navigationDestination(item: $store.selectedEventId.sending(\.dismissEventNavigation)) { eventId in
                ZStack {
                    AppColors.backgroundGradient
                        .ignoresSafeArea()
                    
                    EventDetailView(eventId: eventId)
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
        .tag(AppTab.home)
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
                }
            }
        }
        .tag(AppTab.tickets)
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
            }
            .navigationDestination(item: $store.selectedEventId.sending(\.dismissEventNavigation)) { eventId in
                ZStack {
                    AppColors.backgroundGradient
                        .ignoresSafeArea()
                    
                    EventDetailView(eventId: eventId)
                }
            }
        }
        .tag(AppTab.favorites)
    }
    
    @ViewBuilder
    private var profileTab: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                ProfileView()
            }
        }
        .tag(AppTab.profile)
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
                title: AppTab.home.title,
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            
            // Tickets
            TabBarButton(
                icon: AppTab.tickets.icon,
                title: AppTab.tickets.title,
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
                title: AppTab.favorites.title,
                isSelected: selectedTab == .favorites
            ) {
                selectedTab = .favorites
            }
            
            // Profile
            TabBarButton(
                icon: AppTab.profile.icon,
                title: AppTab.profile.title,
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .frame(height: 70)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.cardShadow.opacity(0.15), radius: 20, x: 0, y: -8)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.tertiaryText)
                    .frame(height: 24)
                
                if !title.isEmpty {
                    Text(title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isSelected ? AppColors.primary : AppColors.tertiaryText)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
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
        .offset(y: -15) // Eleva o botão acima da TabBar
        .buttonStyle(PlainButtonStyle())
    }
}
