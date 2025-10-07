import ComposableArchitecture
import Foundation

@DependencyClient
public struct EventsClient {
    public var fetchEvents: () async throws -> [Event]
    public var searchEvents: (String) async throws -> [Event]
    public var fetchEventsByCategory: (EventCategory) async throws -> [Event]
    public var fetchEventDetail: (UUID) async throws -> Event
}

extension EventsClient: DependencyKey {
    public static let liveValue = EventsClient(
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
        },
        fetchEventDetail: { id in
            do {
                let apiEvent: Event = try await NetworkService.shared.request(
                    endpoint: "/events/\(id.uuidString)",
                    method: .GET
                )
                return apiEvent
            } catch {
                // Fallback para JSON local
                print("API call failed, falling back to local JSON: \(error)")
                let events = try await loadEventsFromJSON()
                guard let event = events.first(where: { $0.id == id.uuidString }) else {
                    throw NetworkError.notFound
                }
                return event
            }
        }
    )
    
    public static let testValue = EventsClient(
        fetchEvents: { SharedMockData.sampleEvents },
        searchEvents: { _ in SharedMockData.sampleEvents },
        fetchEventsByCategory: { _ in SharedMockData.sampleEvents },
        fetchEventDetail: { _ in SharedMockData.sampleEvents[0] },
    )
}

extension DependencyValues {
    var eventsClient: EventsClient {
        get { self[EventsClient.self] }
        set { self[EventsClient.self] = newValue }
    }
}
