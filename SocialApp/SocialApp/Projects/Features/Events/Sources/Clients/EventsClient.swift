import ComposableArchitecture
import Foundation

@DependencyClient
public struct EventsClient {
    public var fetchEvents: () async throws -> [Event]
    public var searchEvents: (String) async throws -> [Event]
    public var fetchEventsByCategory: (EventCategory) async throws -> [Event]
}

extension EventsClient: DependencyKey {
    public static let liveValue = EventsClient(
        fetchEvents: {
            try await Task.sleep(for: .seconds(1))
            return try await loadEventsFromJSON()
        },
        searchEvents: { query in
            let allEvents = try await loadEventsFromJSON()
            return allEvents.filter { event in
                event.name.localizedCaseInsensitiveContains(query) ||
                event.description?.localizedCaseInsensitiveContains(query) == true
            }
        },
        fetchEventsByCategory: { category in
            let allEvents = try await loadEventsFromJSON()
            return allEvents.filter { $0.category == category }
        }
    )
    
    public static let testValue = EventsClient(
        fetchEvents: { MockData.sampleEvents },
        searchEvents: { _ in MockData.sampleEvents },
        fetchEventsByCategory: { _ in MockData.sampleEvents }
    )
}

extension DependencyValues {
    public var eventsClient: EventsClient {
        get { self[EventsClient.self] }
        set { self[EventsClient.self] = newValue }
    }
}