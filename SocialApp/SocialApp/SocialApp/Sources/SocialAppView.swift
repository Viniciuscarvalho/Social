import ComposableArchitecture
import SwiftUI

public struct SocialAppView: View {
    @Bindable var store: StoreOf<SocialAppFeature>
    
    public init(store: StoreOf<SocialAppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            TabView(selection: $store.selectedTab) {
                EventsView(store: store.scope(state: \.eventsFeature, action: \.eventsFeature))
                    .tabItem {
                        Image(systemName: AppTab.events.icon)
                        Text(AppTab.events.displayName)
                    }
                    .tag(AppTab.events)
                
                TicketsListView(store: store.scope(state: \.ticketsListFeature, action: \.ticketsListFeature))
                    .tabItem {
                        Image(systemName: AppTab.tickets.icon)
                        Text(AppTab.tickets.displayName)
                    }
                    .tag(AppTab.tickets)
                
                // Outras tabs...
            }
            .navigationDestination(item: $store.selectedEventId) { eventId in
                EventDetailView(eventId: eventId)
            }
            .navigationDestination(item: $store.selectedTicketId) { ticketId in
                TicketDetailView(ticketId: ticketId)
            }
            .navigationDestination(item: $store.selectedSellerId) { sellerId in
                SellerProfileView(sellerId: sellerId)
            }
        }
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