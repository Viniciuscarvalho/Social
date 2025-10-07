import ComposableArchitecture
import Foundation

@Reducer
public struct EventsFeature {
    @ObservableState
    public struct State: Equatable {
        public var events: [Event] = []
        public var searchText: String = ""
        public var selectedCategory: EventCategory?
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public var todayEvent: Event? {
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            
            return events.first { event in
                let dateToCheck = event.eventDate ?? event.createdAt
                return dateToCheck >= today && dateToCheck < tomorrow
            }
        }
        
        public var upcomingEvents: [Event] {
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            
            return events.filter { event in
                let dateToCheck = event.eventDate ?? event.createdAt
                return dateToCheck >= tomorrow
            }.sorted {
                let date1 = $0.eventDate ?? $0.createdAt
                let date2 = $1.eventDate ?? $1.createdAt
                return date1 < date2
            }
        }
        
        // Computed property para debugging - mostra todos os eventos de hoje
        public var allTodayEvents: [Event] {
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            
            return events.filter { event in
                let dateToCheck = event.eventDate ?? event.createdAt
                return dateToCheck >= today && dateToCheck < tomorrow
            }
        }
        
        public var user: User? {
            // This would be loaded from UserClient in a real implementation
            return nil
        }
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadEvents
        case eventsResponse(Result<[Event], APIError>)
        case searchTextChanged(String)
        case searchTapped
        case categorySelected(EventCategory?)
        case eventSelected(UUID)
        case refreshRequested
    }
    
    @Dependency(\.eventsClient) var eventsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadEvents)
                
            case .loadEvents:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        print("🔄 Carregando events...")
                        let events = try await eventsClient.fetchEvents()
                        print("✅ Events carregados: \(events.count) events")
                        await send(.eventsResponse(.success(events)))
                    } catch {
                        print("❌ Erro ao carregar events: \(error.localizedDescription)")
                        await send(.eventsResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                    }
                }
                
            case let .eventsResponse(.success(events)):
                print("📊 Processando resposta: \(events.count) events recebidos")
                state.isLoading = false
                state.events = events
                
                // Logs detalhados para debugging
                let today = Calendar.current.startOfDay(for: Date())
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy HH:mm"
                
                print("🗓️ Data atual: \(formatter.string(from: Date()))")
                print("🌅 Início do dia: \(formatter.string(from: today))")
                print("🌅 Início do próximo dia: \(formatter.string(from: tomorrow))")
                
                for event in events {
                    let dateToCheck = event.eventDate ?? event.createdAt
                    let isToday = dateToCheck >= today && dateToCheck < tomorrow
                    print("📅 Event '\(event.name)' - Data: \(formatter.string(from: dateToCheck)), É hoje? \(isToday)")
                }
                
                print("🎯 Events finais: \(state.events.count), todayEvent: \(state.todayEvent?.name ?? "nil"), upcomingEvents: \(state.upcomingEvents.count), allTodayEvents: \(state.allTodayEvents.count)")
                return .none
                
            case let .eventsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.message
                return .none
                
            case let .searchTextChanged(text):
                state.searchText = text
                if !text.isEmpty {
                    return .run { send in
                        do {
                            let events = try await eventsClient.searchEvents(text)
                            await send(.eventsResponse(.success(events)))
                        } catch {
                            await send(.eventsResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                        }
                    }
                } else {
                    return .send(.loadEvents)
                }
                
            case let .categorySelected(category):
                state.selectedCategory = category
                if let category = category {
                    return .run { send in
                        do {
                            let events = try await eventsClient.fetchEventsByCategory(category)
                            await send(.eventsResponse(.success(events)))
                        } catch {
                            await send(.eventsResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                        }
                    }
                } else {
                    return .send(.loadEvents)
                }
                
            case .searchTapped:
                return .none
                
            case .eventSelected:
                return .none
                
            case .refreshRequested:
                return .send(.loadEvents)
            }
        }
    }
}
