import Foundation

public enum MockData {
    public static let sampleUser = User(
        name: "João Silva",
        profileImageURL: "https://example.com/avatar.jpg",
        email: "joao@example.com"
    )
    
    public static let sampleEvents: [Event] = [
        Event(
            name: "Rock in Rio",
            description: "Festival de música rock",
            imageURL: "https://example.com/rock.jpg",
            startPrice: 240.0,
            location: Location(
                name: "Cidade do Rock",
                city: "Rio de Janeiro",
                state: "RJ",
                country: "Brasil",
                coordinate: Coordinate(latitude: -22.9068, longitude: -43.1729)
            ),
            category: .music,
            isRecommended: true
        ),
        Event(
            name: "Festival de Gastronomia",
            description: "Os melhores pratos da cidade",
            imageURL: "https://example.com/food.jpg",
            startPrice: 80.0,
            location: Location(
                name: "Centro de Convenções",
                city: "São Paulo",
                state: "SP",
                country: "Brasil",
                coordinate: Coordinate(latitude: -23.5505, longitude: -46.6333)
            ),
            category: .food,
            isRecommended: false
        )
    ]
}