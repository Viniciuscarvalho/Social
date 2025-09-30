import ComposableArchitecture
import SwiftUI

public struct SocialAppView: View {
    @Bindable var store: StoreOf<SocialAppFeature>
    
    public init(store: StoreOf<SocialAppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            eventsTab
            ticketsTab
            favoritesTab
            profileTab
        }
    }
    
    @ViewBuilder
    private var eventsTab: some View {
        NavigationStack {
            EventsView(
                store: store.scope(
                    state: \.eventsFeature,
                    action: \.eventsFeature
                )
            )
            .navigationDestination(item: $store.selectedEventId.sending(\.dismissEventNavigation)) { eventId in
                EventDetailView(eventId: eventId)
            }
            .navigationDestination(item: $store.selectedTicketId.sending(\.dismissTicketNavigation)) { ticketId in
                TicketDetailView(
                    store: store.scope(
                        state: \.ticketDetailFeature,
                        action: \.ticketDetailFeature
                    ),
                    ticketId: ticketId
                )
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
        .tabItem {
            Image(systemName: AppTab.events.icon)
            Text(AppTab.events.displayName)
        }
        .tag(AppTab.events)
    }
    
    @ViewBuilder
    private var ticketsTab: some View {
        NavigationStack {
            TicketsListView(
                store: store.scope(
                    state: \.ticketsListFeature,
                    action: \.ticketsListFeature
                )
            )
            .navigationDestination(item: $store.selectedTicketId.sending(\.dismissTicketNavigation)) { ticketId in
                TicketDetailView(
                    store: store.scope(
                        state: \.ticketDetailFeature,
                        action: \.ticketDetailFeature
                    ),
                    ticketId: ticketId
                )
            }
        }
        .tabItem {
            Image(systemName: AppTab.tickets.icon)
            Text(AppTab.tickets.displayName)
        }
        .tag(AppTab.tickets)
    }
    
    @ViewBuilder
    private var favoritesTab: some View {
        NavigationStack {
            FavoritesView(
                store: store.scope(
                    state: \.favoritesFeature,
                    action: \.favoritesFeature
                )
            )
            .navigationDestination(item: $store.selectedEventId.sending(\.dismissEventNavigation)) { eventId in
                EventDetailView(eventId: eventId)
            }
        }
        .tabItem {
            Image(systemName: AppTab.favorites.icon)
            Text(AppTab.favorites.displayName)
        }
        .tag(AppTab.favorites)
    }
    
    @ViewBuilder
    private var profileTab: some View {
        NavigationStack {
            ProfileView()
        }
        .tabItem {
            Image(systemName: AppTab.profile.icon)
            Text(AppTab.profile.displayName)
        }
        .tag(AppTab.profile)
    }
}
