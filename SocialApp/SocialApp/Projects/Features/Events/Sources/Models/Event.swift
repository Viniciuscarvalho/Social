import Foundation
import CoreLocation

public struct Event: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var imageURL: String?
    public var startPrice: Double
    public var location: Location
    public var category: EventCategory
    public var isRecommended: Bool
    public var rating: Double?
    public var reviewCount: Int?
    public let createdAt: Date
    public var eventDate: Date?
    
    public init(name: String, description: String? = nil, imageURL: String? = nil, 
         startPrice: Double, location: Location, category: EventCategory, 
         isRecommended: Bool = false, eventDate: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.startPrice = startPrice
        self.location = location
        self.category = category
        self.isRecommended = isRecommended
        self.rating = nil
        self.reviewCount = nil
        self.createdAt = Date()
        self.eventDate = eventDate
    }
}