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
            try await Task.sleep(for: .seconds(1))
            do {
                let events = try await loadEventsFromJSON()
                return events
            } catch {
                return SharedMockData.sampleEvents
            }
        },
        searchEvents: { query in
            do {
                let allEvents = try await loadEventsFromJSON()
                return allEvents.filter { event in
                    event.name.localizedCaseInsensitiveContains(query)
                }
            } catch {
                return SharedMockData.sampleEvents.filter { event in
                    event.name.localizedCaseInsensitiveContains(query)
                }
            }
        },
        fetchEventsByCategory: { category in
            do {
                let allEvents = try await loadEventsFromJSON()
                return allEvents.filter { $0.category == category }
            } catch {
                return SharedMockData.sampleEvents.filter { $0.category == category }
            }
        },
        fetchEventDetail: { eventId in
            do {
                let allEvents = try await loadEventsFromJSON()
                guard let event = allEvents.first(where: { $0.id == eventId }) else {
                    throw APIError(message: "Event not found", code: 404)
                }
                return event
            } catch {
                guard let event = SharedMockData.sampleEvents.first(where: { $0.id == eventId }) else {
                    throw APIError(message: "Event not found", code: 404)
                }
                return event
            }
        }
    )
    
    public static let testValue = EventsClient(
        fetchEvents: { SharedMockData.sampleEvents },
        searchEvents: { _ in SharedMockData.sampleEvents },
        fetchEventsByCategory: { _ in SharedMockData.sampleEvents },
        fetchEventDetail: { _ in SharedMockData.sampleEvents[0] }
    )
}

extension DependencyValues {
    public var eventsClient: EventsClient {
        get { self[EventsClient.self] }
        set { self[EventsClient.self] = newValue }
    }
}
