import ComposableArchitecture
import Events
import SharedModels
import SwiftUI
import TicketsList

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
                    TicketDetailView(ticketId: ticketId)
                }
                .navigationDestination(item: $store.selectedSellerId.sending(\.dismissSellerNavigation)) { sellerId in
                    SellerProfileView(sellerId: sellerId)
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
        EventsView(store: store.scope(state: \.eventsFeature, action: \.eventsFeature))
            .tabItem {
                Image(systemName: AppTab.events.icon)
                Text(AppTab.events.displayName)
            }
            .tag(AppTab.events)
    }
    
    @ViewBuilder
    private var ticketsTab: some View {
        TicketsListView(store: store.scope(state: \.ticketsListFeature, action: \.ticketsListFeature))
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

// MARK: - Placeholder Views (temporary)
struct FavoritesPlaceholderView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                Text("Favoritos")
                    .font(.title)
                Text("Em desenvolvimento")
                    .foregroundColor(.gray)
            }
            .navigationTitle("Favoritos")
        }
    }
}

struct ProfilePlaceholderView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                Text("Perfil")
                    .font(.title)
                Text("Em desenvolvimento")
                    .foregroundColor(.gray)
            }
            .navigationTitle("Perfil")
        }
    }
}

struct EventDetailView: View {
    let eventId: UUID
    
    var body: some View {
        VStack {
            Text("Event Detail")
            Text("Event ID: \(eventId)")
        }
        .navigationTitle("Detalhes do Evento")
    }
}

struct TicketDetailView: View {
    let ticketId: UUID
    
    var body: some View {
        VStack {
            Text("Ticket Detail")
            Text("Ticket ID: \(ticketId)")
        }
        .navigationTitle("Detalhes do Ingresso")
    }
}

struct SellerProfileView: View {
    let sellerId: UUID
    
    var body: some View {
        VStack {
            Text("Seller Profile")
            Text("Seller ID: \(sellerId)")
        }
        .navigationTitle("Perfil do Vendedor")
    }
}
