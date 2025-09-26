import ComposableArchitecture
import SwiftUI

public struct EventsView: View {
    @Bindable var store: StoreOf<EventsFeature>
    
    public init(store: StoreOf<EventsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header (Search + Profile)
                headerSection
                
                // MARK: - Today Section
                if let todayEvent = store.todayEvent {
                    SectionHeader(title: "Today")
                    EventCardLarge(event: todayEvent) {
                        store.send(.eventSelected(todayEvent.id))
                    } onJoin: {
                        store.send(.eventSelected(todayEvent.id))
                    }
                }
                
                // MARK: - Upcoming Section
                if !store.upcomingEvents.isEmpty {
                    SectionHeader(title: "Upcoming")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(store.upcomingEvents) { event in
                                EventCardSmall(event: event) {
                                    store.send(.eventSelected(event.id))
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Events")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            store.send(.refreshRequested)
        }
        .sheet(isPresented: $store.isSearchPresented.sending(\.setSearchPresented)) {
            SearchView(
                store: store.scope(
                    state: \.searchFeature,
                    action: \.searchFeature
                )
            )
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                store.send(.searchTapped)
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            AsyncImage(url: URL(string: store.user?.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 36, height: 36)
            .clipShape(Circle())
        }
    }
}
