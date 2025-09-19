import Foundation

public struct SearchFilter: Codable, Equatable {
    public var category: EventCategory?
    public var priceRange: PriceRange?
    public var location: String?
    public var dateRange: DateRange?
    public var isRecommendedOnly: Bool
    
    public init() {
        self.category = nil
        self.priceRange = nil
        self.location = nil
        self.dateRange = nil
        self.isRecommendedOnly = false
    }
}