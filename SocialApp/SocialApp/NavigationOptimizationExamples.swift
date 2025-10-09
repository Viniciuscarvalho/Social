import SwiftUI
import ComposableArchitecture

/// Exemplos de como usar a navegação otimizada para evitar chamadas desnecessárias de API
struct NavigationOptimizationExamples: View {
    let sampleEvents: [Event] = [] // Seus eventos carregados
    let sampleTickets: [Ticket] = [] // Seus tickets carregados
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Exemplos de Navegação Otimizada")
                .font(.title)
                .padding()
            
            Text("Use estes padrões nas suas listas de eventos e tickets")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Exemplo para lista de eventos
            eventExamples
            
            // Exemplo para lista de tickets  
            ticketExamples
            
            Spacer()
        }
    }
    
    // MARK: - Exemplos de Eventos
    
    private var eventExamples: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("✅ Lista de Eventos (CORRETO)")
                .font(.headline)
                .foregroundColor(.green)
            
            Text("Cada evento na lista deve navegar passando o objeto evento:")
                .font(.caption)
                .padding(.horizontal)
            
            // Exemplo de como fazer CORRETO
            ForEach(sampleEvents.prefix(2), id: \.id) { event in
                NavigationLink(destination: optimizedEventDetailView(event: event)) {
                    EventRowView(event: event)
                }
            }
            .padding(.horizontal)
            
            Text("❌ EVITE fazer assim (faz chamada API desnecessária):")
                .font(.headline)
                .foregroundColor(.red)
                .padding(.top)
            
            // Exemplo de como NÃO fazer
            ForEach(sampleEvents.prefix(1), id: \.id) { event in
                NavigationLink(destination: inefficientEventDetailView(eventId: UUID(uuidString: event.id) ?? UUID())) {
                    EventRowView(event: event)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Exemplos de Tickets
    
    private var ticketExamples: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("✅ Lista de Tickets (CORRETO)")
                .font(.headline)
                .foregroundColor(.green)
                .padding(.top)
            
            Text("Cada ticket na lista deve navegar passando o objeto ticket:")
                .font(.caption)
                .padding(.horizontal)
            
            // Exemplo de como fazer CORRETO
            ForEach(sampleTickets.prefix(2), id: \.id) { ticket in
                NavigationLink(destination: optimizedTicketDetailView(ticket: ticket)) {
                    TicketRowView(ticket: ticket)
                }
            }
            .padding(.horizontal)
            
            Text("❌ EVITE fazer assim (faz chamada API desnecessária):")
                .font(.headline)
                .foregroundColor(.red)
                .padding(.top)
            
            // Exemplo de como NÃO fazer
            ForEach(sampleTickets.prefix(1), id: \.id) { ticket in
                NavigationLink(destination: inefficientTicketDetailView(ticketId: UUID(uuidString: ticket.id) ?? UUID())) {
                    TicketRowView(ticket: ticket)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Views de Exemplo
    
    // ✅ CORRETO: Passa o evento, evita chamada API
    @ViewBuilder
    private func optimizedEventDetailView(event: Event) -> some View {
        EventDetailView(
            store: Store(initialState: EventDetailFeature.State(eventId: UUID(uuidString: event.id) ?? UUID(), event: event)) {
                EventDetailFeature()
            },
            eventId: UUID(uuidString: event.id) ?? UUID(),
            event: event // ✅ Passa o evento, sem chamada API
        )
    }
    
    // ❌ INEFICIENTE: Só passa o ID, força chamada API
    @ViewBuilder
    private func inefficientEventDetailView(eventId: UUID) -> some View {
        EventDetailView(
            store: Store(initialState: EventDetailFeature.State(eventId: eventId)) {
                EventDetailFeature()
            },
            eventId: eventId
            // ❌ Não passa o evento, vai fazer chamada API desnecessária
        )
    }
    
    // ✅ CORRETO: Passa o ticket, evita chamada API (ou mostra dados básicos)
    @ViewBuilder
    private func optimizedTicketDetailView(ticket: Ticket) -> some View {
        TicketDetailView(
            store: Store(initialState: TicketDetailFeature.State(ticket: ticket)) {
                TicketDetailFeature()
            },
            ticketId: UUID(uuidString: ticket.id) ?? UUID(),
            ticket: ticket // ✅ Passa o ticket, mostra dados básicos sem chamada API
        )
    }
    
    // ❌ INEFICIENTE: Só passa o ID, força chamada API
    @ViewBuilder
    private func inefficientTicketDetailView(ticketId: UUID) -> some View {
        TicketDetailView(
            store: Store(initialState: TicketDetailFeature.State()) {
                TicketDetailFeature()
            },
            ticketId: ticketId
            // ❌ Não passa o ticket, vai fazer chamada API desnecessária
        )
    }
}

// MARK: - Views auxiliares para exemplo

struct EventRowView: View {
    let event: Event
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.name)
                    .font(.headline)
                Text("R$ \(event.startPrice, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct TicketRowView: View {
    let ticket: Ticket
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(ticket.name)
                    .font(.headline)
                Text("R$ \(ticket.price, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        NavigationOptimizationExamples()
    }
}