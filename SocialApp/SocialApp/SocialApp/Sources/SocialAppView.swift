import ComposableArchitecture
import SwiftUI

public struct SocialAppView: View {
    @Bindable var store: StoreOf<SocialAppFeature>
    
    public init(store: StoreOf<SocialAppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            tabView
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
    }
    
    @ViewBuilder
    private var tabView: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            eventsTab
            ticketsTab
            favoritesTab
            profileTab
        }
    }
    
    @ViewBuilder
    private var eventsTab: some View {
        EventsView(
            store: store.scope(
                state: \.eventsFeature,
                action: \.eventsFeature
            )
        )
        .tabItem {
            Image(systemName: AppTab.events.icon)
            Text(AppTab.events.displayName)
        }
        .tag(AppTab.events)
    }
    
    @ViewBuilder
    private var ticketsTab: some View {
        TicketsListView(
            store: store.scope(
                state: \.ticketsListFeature,
                action: \.ticketsListFeature
            )
        )
        .tabItem {
            Image(systemName: AppTab.tickets.icon)
            Text(AppTab.tickets.displayName)
        }
        .tag(AppTab.tickets)
    }
    
    @ViewBuilder
    private var favoritesTab: some View {
        FavoritesPlaceholderView()
            .tabItem {
                Image(systemName: AppTab.favorites.icon)
                Text(AppTab.favorites.displayName)
            }
            .tag(AppTab.favorites)
    }
    
    @ViewBuilder
    private var profileTab: some View {
        ProfilePlaceholderView()
            .tabItem {
                Image(systemName: AppTab.profile.icon)
                Text(AppTab.profile.displayName)
            }
            .tag(AppTab.profile)
    }
}
