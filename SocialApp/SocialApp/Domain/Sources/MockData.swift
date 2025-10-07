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
            isRecommended: true,
            eventDate: Date() // Evento de HOJE
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
            isRecommended: false,
            eventDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) // Evento em 2 dias
        ),
        Event(
            name: "Workshop de SwiftUI",
            description: "Aprenda SwiftUI do zero ao avançado",
            imageURL: "https://example.com/swiftui-workshop.jpg",
            startPrice: 150.0,
            location: Location(
                name: "Centro de Convenções",
                city: "São Paulo",
                state: "SP",
                country: "Brasil",
                coordinate: Coordinate(latitude: -23.5505, longitude: -46.6333)
            ),
            category: .technology,
            isRecommended: true,
            eventDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) // Evento HOJE em 2 horas
        )
    ]
    
    // MARK: - Users (Ex-Seller Profiles)
    public static let sampleSellerProfiles: [User] = [
        User(name: "João Silva", title: "Event Organizer", profileImageURL: "https://example.com/joao.jpg"),
        User(name: "Maria Santos", title: "Concert Promoter", profileImageURL: "https://example.com/maria.jpg"),
        User(name: "Pedro Costa", title: "UX Designer", profileImageURL: "https://example.com/pedro.jpg")
    ]
    
    // MARK: - Tickets
    public static let sampleTickets: [Ticket] = [
        Ticket(
            eventId: sampleEvents[0].id,
            sellerId: sampleSellerProfiles[0].id,
            name: "Ingresso VIP - Cliff Front",
            price: 240.0,
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
    public static func sampleTicketDetail(for ticketId: String) -> TicketDetail {
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
    
    public static func randomSeller() -> User {
        sampleSellerProfiles.randomElement() ?? sampleSellerProfiles[0]
    }
    
    public static func randomTicket() -> Ticket {
        sampleTickets.randomElement() ?? sampleTickets[0]
    }
}
