import ComposableArchitecture
import Foundation

@DependencyClient
struct EventsClient {
    var fetchEvents: @Sendable () async throws -> [Event]
    var fetchEvent: @Sendable (_ id: String) async throws -> Event
    var searchEvents: @Sendable (_ query: String) async throws -> [Event]
    var fetchEventsByCategory: @Sendable (_ category: EventCategory) async throws -> [Event]
}

extension EventsClient: DependencyKey {
    static let liveValue = Self(
        fetchEvents: {
            do {
                let apiEvents: [Event] = try await NetworkService.shared.request(
                    endpoint: "/events",
                    method: .GET
                )
                return apiEvents
            } catch {
                // Fallback para JSON local
                print("API call failed, falling back to local JSON: \(error)")
                return try await loadEventsFromJSON()
            }
        },
        fetchEvent: { id in
            do {
                let apiEvent: Event = try await NetworkService.shared.request(
                    endpoint: "/events/\(id)",
                    method: .GET
                )
                return apiEvent
            } catch {
                // Fallback para JSON local
                print("API call failed, falling back to local JSON: \(error)")
                let events = try await loadEventsFromJSON()
                guard let event = events.first(where: { $0.id.uuidString == id }) else {
                    throw NetworkError.notFound
                }
                return event
            }
        },
        searchEvents: { query in
            do {
                let queryItems = [URLQueryItem(name: "q", value: query)]
                let apiEvents: [Event] = try await NetworkService.shared.request(
                    endpoint: "/events",
                    method: .GET,
                    queryItems: queryItems
                )
                return apiEvents
            } catch {
                // Fallback para busca local
                print("API call failed, falling back to local search: \(error)")
                let events = try await loadEventsFromJSON()
                return events.filter { event in
                    event.name.localizedCaseInsensitiveContains(query) ||
                    event.description?.localizedCaseInsensitiveContains(query) == true ||
                    event.location.name.localizedCaseInsensitiveContains(query)
                }
            }
        },
        fetchEventsByCategory: { category in
            do {
                let queryItems = [URLQueryItem(name: "category", value: category.rawValue)]
                let apiEvents: [Event] = try await NetworkService.shared.request(
                    endpoint: "/events",
                    method: .GET,
                    queryItems: queryItems
                )
                return apiEvents
            } catch {
                // Fallback para filtro local
                print("API call failed, falling back to local filtering: \(error)")
                let events = try await loadEventsFromJSON()
                return events.filter { $0.category == category }
            }
        }
    )
    
    static let testValue = Self(
        fetchEvents: unimplemented("EventsClient.fetchEvents"),
        fetchEvent: unimplemented("EventsClient.fetchEvent"),
        searchEvents: unimplemented("EventsClient.searchEvents"),
        fetchEventsByCategory: unimplemented("EventsClient.fetchEventsByCategory")
    )
}

extension DependencyValues {
    var eventsClient: EventsClient {
        get { self[EventsClient.self] }
        set { self[EventsClient.self] = newValue }
    }
}
