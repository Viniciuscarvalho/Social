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
            @Dependency(\.eventsClient) var eventsClient
            @Dependency(\.ticketsClient) var ticketsClient
            @Dependency(\.userClient) var userClient
            
            async let events = eventsClient.fetchEvents()
            async let tickets = ticketsClient.fetchTickets()
            async let user = userClient.fetchCurrentUser()
            
            do {
                let (allEvents, allTickets, currentUser) = try await (events, tickets, user)
                
                // Separar eventos curados dos trending
                let curatedEvents = allEvents.filter { $0.isRecommended }
                let trendingEvents = allEvents.filter { !$0.isRecommended }
                
                return HomeContent(
                    curatedEvents: curatedEvents,
                    trendingEvents: trendingEvents,
                    availableTickets: allTickets.filter { $0.status == .available },
                    user: currentUser
                )
            } catch {
                // Em caso de erro, retorna um HomeContent vazio
                // Os clients já têm fallbacks para SharedMockData
                print("❌ Erro ao carregar home content: \(error)")
                return HomeContent()
            }
        }
    )
    
    static let testValue = HomeClient(
        loadHomeContent: { HomeContent() }
    )
}
