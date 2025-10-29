import ComposableArchitecture
import Foundation

@DependencyClient
public struct EventsClient {
    public var fetchEvents: () async throws -> [Event]
    public var searchEvents: (String) async throws -> [Event]
    public var fetchEventsByCategory: (EventCategory) async throws -> [Event]
    public var fetchEventDetail: (UUID) async throws -> Event
    public var fetchEventById: (UUID) async throws -> Event
}

extension EventsClient: DependencyKey {
    public static let liveValue = EventsClient(
        fetchEvents: {
            do {
                print("🌐 Fetching events from API...")
                let apiEvents: [APIEventResponse] = try await NetworkService.shared.requestArray(
                    endpoint: "/events",
                    method: .GET
                )
                print("✅ Successfully fetched \(apiEvents.count) events from API")
                let events = apiEvents.map { $0.toEvent() }
                return events
            } catch {
                print("❌ API call failed for fetchEvents: \(error)")
                print("🔄 Falling back to local JSON")
                return try await loadEventsFromJSON()
            }
        },
        searchEvents: { query in
            do {
                print("🔍 Searching events for query: \(query)")
                let queryItems = [URLQueryItem(name: "q", value: query)]
                let apiEvents: [APIEventResponse] = try await NetworkService.shared.requestArray(
                    endpoint: "/events",
                    method: .GET,
                    queryItems: queryItems
                )
                print("✅ Search returned \(apiEvents.count) events from API")
                let events = apiEvents.map { $0.toEvent() }
                return events
            } catch {
                print("❌ API search failed: \(error)")
                print("🔄 Falling back to local search")
                let events = try await loadEventsFromJSON()
                let normalizedQuery = query.lowercased()
                return events.filter { event in
                    event.name.lowercased().contains(normalizedQuery) ||
                    event.description?.lowercased().contains(normalizedQuery) == true ||
                    event.location.name.lowercased().contains(normalizedQuery) ||
                    event.location.city.lowercased().contains(normalizedQuery) ||
                    event.category.displayName.lowercased().contains(normalizedQuery)
                }
            }
        },
        fetchEventsByCategory: { category in
            do {
                print("📂 Fetching events for category: \(category.rawValue)")
                let queryItems = [URLQueryItem(name: "category", value: category.rawValue)]
                let apiEvents: [APIEventResponse] = try await NetworkService.shared.requestArray(
                    endpoint: "/events",
                    method: .GET,
                    queryItems: queryItems
                )
                print("✅ Category search returned \(apiEvents.count) events from API")
                let events = apiEvents.map { $0.toEvent() }
                return events
            } catch {
                print("❌ API category search failed: \(error)")
                print("🔄 Falling back to local filtering")
                let events = try await loadEventsFromJSON()
                return events.filter { $0.category == category }
            }
        },
        fetchEventDetail: { id in
            do {
                print("📋 Fetching event detail for ID: \(id)")
                let apiEvent: APIEventResponse = try await NetworkService.shared.requestSingle(
                    endpoint: "/events/\(id.uuidString)",
                    method: .GET
                )
                print("✅ Successfully fetched event detail from API")
                return apiEvent.toEvent()
            } catch {
                print("❌ API event detail failed: \(error)")
                print("🔄 Falling back to local JSON")
                let events = try await loadEventsFromJSON()
                guard let event = events.first(where: { $0.id == id.uuidString }) else {
                    throw NetworkError.notFound
                }
                return event
            }
        },
        fetchEventById: { id in
            do {
                let apiEvent: APIEventResponse = try await NetworkService.shared.requestSingle(
                    endpoint: "/events/\(id.uuidString)",
                    method: .GET
                )
                return apiEvent.toEvent()
            } catch {
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
        fetchEventById: { _ in SharedMockData.sampleEvents[0] }
    )
}

extension DependencyValues {
    var eventsClient: EventsClient {
        get { self[EventsClient.self] }
        set { self[EventsClient.self] = newValue }
    }
}
