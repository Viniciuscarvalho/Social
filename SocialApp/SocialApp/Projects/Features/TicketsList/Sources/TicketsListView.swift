import SharedModels
import SwiftUI

public struct TicketsListView: View {
    @Binding var state: TicketsListFeature.State
    
    let sendAction: (TicketsListFeature.Action) -> Void
    
    public init(
        state: Binding<TicketsListFeature.State>,
        sendAction: @escaping (TicketsListFeature.Action) -> Void
    ) {
        self._state = state
        self.sendAction = sendAction
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                if state.isLoading {
                    loadingView
                } else if state.tickets.isEmpty {
                    emptyStateView
                } else {
                    ticketsContentView
                }
            }
            .navigationTitle("Ingressos")
            .onAppear {
                sendAction(.onAppear)
            }
            .refreshable {
                sendAction(.refreshRequested)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Carregando ingressos...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Lista de Ingressos")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Nenhum ingresso encontrado")
                .foregroundColor(.secondary)
            
            Button("Buscar Eventos") {
                // Could trigger navigation to events tab
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var ticketsContentView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(state.displayTickets) { ticket in
                    TicketCard(
                        ticket: ticket,
                        onTap: { sendAction(.ticketSelected(ticket.id)) },
                        onFavorite: { sendAction(.favoriteToggled(ticket.id)) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
