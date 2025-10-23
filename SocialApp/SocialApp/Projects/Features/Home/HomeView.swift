import ComposableArchitecture
import ComposableArchitecture
import SwiftUI

public struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    let searchStore: StoreOf<SearchFeature>?
    
    public init(store: StoreOf<HomeFeature>, searchStore: StoreOf<SearchFeature>? = nil) {
        self.store = store
        self.searchStore = searchStore
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                headerSection
                eventSectionsView
                availableTicketsSection
            }
            .padding(.horizontal, 16)
        }
        .navigationBarHidden(true)
        .refreshable {
            store.send(.refreshHome)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(isPresented: $store.showSearchSheet.sending(\.showSearchSheetChanged)) {
            if let searchStore = searchStore {
                SearchView(store: searchStore)
                    .onDisappear {
                        store.send(.dismissSearch)
                    }
            } else {
                SearchView(store: Store(initialState: SearchFeature.State()) {
                    SearchFeature()
                })
                .onDisappear {
                    store.send(.dismissSearch)
                }
            }
        }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let user = store.homeContent.user {
                    Text("Olá, \(user.name)!")
                        .font(.title2)
                        .fontWeight(.semibold)
                } else {
                    Text("Olá!")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Text("Descubra eventos incríveis")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                store.send(.searchButtonTapped)
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private var eventSectionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Seção selector
            HStack {
                ForEach(EventSection.allCases, id: \.self) { section in
                    Button {
                        store.send(.eventSectionSelected(section))
                    } label: {
                        Text(section.displayName)
                            .font(.headline)
                            .fontWeight(store.selectedEventSection == section ? .bold : .medium)
                            .foregroundColor(store.selectedEventSection == section ? .primary : .secondary)
                            .padding(.bottom, 4)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(.blue)
                                    .opacity(store.selectedEventSection == section ? 1 : 0),
                                alignment: .bottom
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
            
            // Events list
            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                let events = store.selectedEventSection == .curated ? 
                    store.homeContent.curatedEvents : 
                    store.homeContent.trendingEvents
                
                if events.isEmpty {
                    Text("Nenhum evento encontrado")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(events) { event in
                                EventCard(event: event) {
                                    store.send(.eventSelected(event.id))
                                }
                                .frame(width: 300)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, -16)
                }
            }
        }
    }
    
    @ViewBuilder
    private var availableTicketsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Ingressos Disponíveis")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            if store.homeContent.availableTickets.isEmpty {
                Text("Nenhum ingresso disponível")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(store.homeContent.availableTickets) { ticket in
                        TicketCard(ticket: ticket) {
                            store.send(.ticketSelected(ticket.id))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Search Bar

private struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Buscar eventos ou ingressos...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    HomeView(
        store: Store(
            initialState: HomeFeature.State(),
            reducer: { HomeFeature() }
        )
    )
}
