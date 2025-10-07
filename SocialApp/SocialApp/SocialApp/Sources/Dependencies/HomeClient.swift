import ComposableArchitecture
import Foundation

public struct HomeClient {
    public var loadHomeContent: () async throws -> HomeContent
}

extension DependencyValues {
    public var homeClient: HomeClient {
        get { self[HomeClientKey.self] }
        set { self[HomeClientKey.self] = newValue }
    }
}

private enum HomeClientKey: DependencyKey {
    static let liveValue = HomeClient(
        loadHomeContent: {
            // Usar Task para evitar vazamentos de memória
            return try await withThrowingTaskGroup(of: Void.self) { group in
                var events: [Event] = []
                var tickets: [Ticket] = []
                var user: User? = nil
                
                // Criar dependências localmente para evitar capture cycles
                let eventsClient = DependencyValues._current.eventsClient
                let ticketsClient = DependencyValues._current.ticketsClient
                let userClient = DependencyValues._current.userClient
                
                // Buscar eventos
                group.addTask {
                    events = try await eventsClient.fetchEvents()
                }
                
                // Buscar tickets disponíveis
                group.addTask {
                    tickets = try await ticketsClient.fetchAvailableTickets()
                }
                
                // Buscar usuário atual (opcional)
                group.addTask {
                    do {
                        user = try await userClient.fetchCurrentUser()
                    } catch {
                        // Log do erro mas não falha a operação toda
                        print("Warning: Não foi possível carregar usuário atual: \(error)")
                        user = nil
                    }
                }
                
                // Aguardar todas as tasks completarem
                try await group.waitForAll()
                
                // Separar eventos curados dos trending
                let curatedEvents = events.filter { $0.isRecommended }
                let trendingEvents = events.filter { !$0.isRecommended }
                
                return HomeContent(
                    curatedEvents: curatedEvents,
                    trendingEvents: trendingEvents,
                    availableTickets: tickets,
                    user: user
                )
            }
        }
    )
    
    static let testValue = HomeClient(
        loadHomeContent: { HomeContent() }
    )
}
