import Foundation
import Events

public struct Ticket: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var event: Event
    public var seller: SellerProfile
    public var price: Double
    public var originalPrice: Double?
    public var ticketType: TicketType
    public var status: TicketStatus
    public var validUntil: Date
    public let createdAt: Date
    public var isFavorited: Bool
    
    public init(name: String, description: String? = nil, event: Event, 
         seller: SellerProfile, price: Double, ticketType: TicketType, validUntil: Date) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.event = event
        self.seller = seller
        self.price = price
        self.originalPrice = nil
        self.ticketType = ticketType
        self.status = .available
        self.validUntil = validUntil
        self.createdAt = Date()
        self.isFavorited = false
    }
    
    public var discountPercentage: Double? {
        guard let originalPrice = originalPrice, originalPrice > price else { return nil }
        return ((originalPrice - price) / originalPrice) * 100
    }
}