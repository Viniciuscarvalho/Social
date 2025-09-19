import ComposableArchitecture
import Events
import SwiftUI
import TicketsList

public struct SocialAppView: View {
    @Bindable var store: StoreOf<SocialAppFeature>
    
    public init(store: StoreOf<SocialAppFeature>) {
        self.store = store
    }
    
    public var body: some View {
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
            
            FavoritesPlaceholderView()
                .tabItem {
                    Image(systemName: AppTab.favorites.icon)
                    Text(AppTab.favorites.displayName)
                }
                .tag(AppTab.favorites)
            
            ProfilePlaceholderView()
                .tabItem {
                    Image(systemName: AppTab.profile.icon)
                    Text(AppTab.profile.displayName)
                }
                .tag(AppTab.profile)
        }
        .accentColor(.blue)
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