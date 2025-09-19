import Foundation

public struct TicketDetail: Codable, Identifiable, Equatable {
    public let id: UUID
    public var ticketId: UUID
    public var event: Event
    public var seller: SellerProfile
    public var price: Double
    public var quantity: Int
    public var ticketType: TicketType
    public var validUntil: Date
    public var isTransferable: Bool
    public var qrCode: String?
    public var purchaseDate: Date?
    public var status: TicketStatus
    
    public init(ticketId: UUID, event: Event, seller: SellerProfile, price: Double, 
         quantity: Int, ticketType: TicketType, validUntil: Date) {
        self.id = UUID()
        self.ticketId = ticketId
        self.event = event
        self.seller = seller
        self.price = price
        self.quantity = quantity
        self.ticketType = ticketType
        self.validUntil = validUntil
        self.isTransferable = true
        self.qrCode = nil
        self.purchaseDate = nil
        self.status = .available
    }
}