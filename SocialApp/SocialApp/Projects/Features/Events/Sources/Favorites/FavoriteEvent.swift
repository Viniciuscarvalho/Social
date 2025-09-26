import SwiftData
import Foundation

@Model
public class FavoriteEvent {
    public var eventId: String
    public var eventName: String
    public var eventImageURL: String?
    public var eventPrice: Double
    public var eventLocation: String
    public var eventDate: Date?
    public var favoriteDate: Date
    
    public init(eventId: String, eventName: String, eventImageURL: String? = nil, 
                eventPrice: Double, eventLocation: String, eventDate: Date? = nil) {
        self.eventId = eventId
        self.eventName = eventName
        self.eventImageURL = eventImageURL
        self.eventPrice = eventPrice
        self.eventLocation = eventLocation
        self.eventDate = eventDate
        self.favoriteDate = Date()
    }
    
    public init(from event: Event) {
        self.eventId = event.id.uuidString
        self.eventName = event.name
        self.eventImageURL = event.imageURL
        self.eventPrice = event.startPrice
        self.eventLocation = event.location.city
        self.eventDate = event.eventDate
        self.favoriteDate = Date()
    }
}

// Extension para converter de volta para Event (se necessário)
extension FavoriteEvent {
    var asEvent: Event {
        Event(
            name: eventName,
            description: nil,
            imageURL: eventImageURL,
            startPrice: eventPrice,
            location: Location(
                name: eventLocation,
                city: eventLocation,
                state: "",
                country: "Brasil",
                coordinate: Coordinate(latitude: 0, longitude: 0)
            ),
            category: .culture, // Default category
            eventDate: eventDate
        )
    }
}