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
            print("🚀 Iniciando carregamento otimizado da Home")
            
            // Criar dependências localmente para evitar capture cycles
            let eventsClient = DependencyValues._current.eventsClient
            let ticketsClient = DependencyValues._current.ticketsClient
            let userClient = DependencyValues._current.userClient
            
            // STEP 1: Carregar usuário primeiro (prioritário)
            print("📝 Step 1: Carregando dados do usuário...")
            var user: User? = nil
            do {
                user = try await userClient.fetchCurrentUser()
                print("✅ Usuário carregado: \(user?.name ?? "Unknown")")
            } catch {
                print("⚠️ Não foi possível carregar usuário: \(error)")
                user = nil
            }
            
            // STEP 2: Carregar events e tickets em paralelo usando async let
            print("📝 Step 2: Carregando eventos e tickets em paralelo...")
            
            async let eventsTask = eventsClient.fetchEvents()
            async let ticketsTask = ticketsClient.fetchAvailableTickets()
            
            do {
                let (events, tickets) = try await (eventsTask, ticketsTask)
                print("✅ Eventos carregados: \(events.count)")
                print("✅ Tickets carregados: \(tickets.count)")
                
                // Separar eventos curados dos trending
                let curatedEvents = events.filter { $0.isRecommended }
                let trendingEvents = events.filter { !$0.isRecommended }
                
                print("🎉 Carregamento da Home concluído com sucesso")
                return HomeContent(
                    curatedEvents: curatedEvents,
                    trendingEvents: trendingEvents,
                    availableTickets: tickets,
                    user: user
                )
            } catch {
                print("❌ Erro ao carregar eventos/tickets: \(error)")
                // Retorna conteúdo vazio mas com usuário carregado
                return HomeContent(
                    curatedEvents: [],
                    trendingEvents: [],
                    availableTickets: [],
                    user: user
                )
            }
        }
    )
    
    static let testValue = HomeClient(
        loadHomeContent: { HomeContent() }
    )
}
