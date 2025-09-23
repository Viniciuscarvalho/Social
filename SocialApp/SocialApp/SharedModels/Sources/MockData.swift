import Foundation

public enum SharedMockData {
    // MARK: - Users
    public static let sampleUsers: [User] = [
        User(name: "João Silva", profileImageURL: "https://example.com/joao.jpg"),
        User(name: "Maria Santos", profileImageURL: "https://example.com/maria.jpg"),
        User(name: "Pedro Costa", profileImageURL: "https://example.com/pedro.jpg")
    ]
    
    // MARK: - Events
    public static let sampleEvents: [Event] = [
        Event(
            name: "Cliff Front Pandawa Beach",
            description: "Grand Canyon National Park, located in Arizona, is one of the most breathtaking natural wonders on the planet.",
            imageURL: "https://example.com/pandawa-beach.jpg",
            startPrice: 240.0,
            location: Location(
                name: "Grand Canyon National Park",
                city: "Arizona",
                state: "United States",
                country: "USA",
                coordinate: Coordinate(latitude: 36.1069, longitude: -112.1129)
            ),
            category: .nature,
            isRecommended: true
        ),
        Event(
            name: "Festival de Música Eletrônica",
            description: "O maior festival de música eletrônica do Brasil",
            imageURL: "https://example.com/electronic-festival.jpg",
            startPrice: 180.0,
            location: Location(
                name: "Allianz Parque",
                city: "São Paulo",
                state: "SP",
                country: "Brasil",
                coordinate: Coordinate(latitude: -23.5278, longitude: -46.6682)
            ),
            category: .music,
            isRecommended: false
        )
    ]
            sellerId: sampleSellerProfiles[0].id,
            name: "Ingresso VIP - Cliff Front",
            price: 240.0,
    
    // MARK: - Seller Profiles
    public static let sampleSellerProfiles: [SellerProfile] = [
        SellerProfile(name: "João Silva", title: "Event Organizer", profileImageURL: "https://example.com/joao.jpg"),
        SellerProfile(name: "Maria Santos", title: "Concert Promoter", profileImageURL: "https://example.com/maria.jpg"),
        SellerProfile(name: "Pedro Costa", title: "UX Designer", profileImageURL: "https://example.com/pedro.jpg")
    ]
    
    // MARK: - Tickets
    public static let sampleTickets: [Ticket] = [
        Ticket(
            eventId: sampleEvents[0].id,
            ticketType: .vip,
            validUntil: Date().addingTimeInterval(86400 * 30)
        ),
        Ticket(
            eventId: sampleEvents[1].id,
            sellerId: sampleSellerProfiles[1].id,
            name: "Ingresso Geral - Festival Eletrônico",
            price: 180.0,
            ticketType: .general,
            validUntil: Date().addingTimeInterval(86400 * 45)
        )
    ]
    
    // MARK: - Ticket Details
    public static func sampleTicketDetail(for ticketId: UUID) -> TicketDetail {
        TicketDetail(
            ticketId: ticketId,
            event: sampleEvents[0],
            seller: sampleSellerProfiles[0],
            price: 240.0,
            quantity: 1,
            ticketType: .general,
            validUntil: Date().addingTimeInterval(86400 * 30)
        )
    }
    
    // MARK: - Helper Methods
    public static func randomEvent() -> Event {
        sampleEvents.randomElement() ?? sampleEvents[0]
    }
    
    public static func randomSeller() -> SellerProfile {
        sampleSellerProfiles.randomElement() ?? sampleSellerProfiles[0]
    }
    
    public static func randomTicket() -> Ticket {
        sampleTickets.randomElement() ?? sampleTickets[0]
    }
}

