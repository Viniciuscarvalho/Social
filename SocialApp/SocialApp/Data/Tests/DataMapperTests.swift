import Testing
import Foundation
@testable import Data
@testable import Domain

/// Testes para mappers da camada Data
struct DataMapperTests {
  
  // MARK: - APIUserResponse Tests
  
  @Test("APIUserResponse.toUser() deve mapear corretamente campos básicos")
  func testAPIUserResponseToUserBasicFields() {
    let apiResponse = APIUserResponse(
      id: "user-123",
      name: "João Silva",
      title: "Desenvolvedor",
      profileImageURL: "https://example.com/avatar.jpg",
      profile_image_url: nil,
      email: "joao@example.com",
      followersCount: 100,
      followers_count: nil,
      followingCount: 50,
      following_count: nil,
      ticketsCount: 10,
      tickets_count: nil,
      isVerified: true,
      is_verified: nil,
      tickets: nil,
      createdAt: "2024-01-15T10:30:00Z",
      created_at: nil,
      verification: nil
    )
    
    let user = apiResponse.toUser()
    
    #expect(user.id == "user-123")
    #expect(user.name == "João Silva")
    #expect(user.title == "Desenvolvedor")
    #expect(user.profileImageURL == "https://example.com/avatar.jpg")
    #expect(user.email == "joao@example.com")
    #expect(user.followersCount == 100)
    #expect(user.followingCount == 50)
    #expect(user.ticketsCount == 10)
    #expect(user.isVerified == true)
  }
  
  @Test("APIUserResponse.toUser() deve usar snake_case como fallback")
  func testAPIUserResponseSnakeCaseFallback() {
    let apiResponse = APIUserResponse(
      id: "user-456",
      name: "Maria Santos",
      title: nil,
      profileImageURL: nil,
      profile_image_url: "https://example.com/maria.jpg",
      email: "maria@example.com",
      followersCount: nil,
      followers_count: 200,
      followingCount: nil,
      following_count: 100,
      ticketsCount: nil,
      tickets_count: 5,
      isVerified: nil,
      is_verified: false,
      tickets: nil,
      createdAt: nil,
      created_at: "2024-02-20T15:45:00Z",
      verification: nil
    )
    
    let user = apiResponse.toUser()
    
    #expect(user.profileImageURL == "https://example.com/maria.jpg")
    #expect(user.followersCount == 200)
    #expect(user.followingCount == 100)
    #expect(user.ticketsCount == 5)
    #expect(user.isVerified == false)
  }
  
  @Test("APIUserResponse.toUser() deve mapear tickets aninhados")
  func testAPIUserResponseWithTickets() {
    let apiTicket = APITicketResponse(
      id: "ticket-1",
      eventId: "event-1",
      event_id: nil,
      sellerId: "user-123",
      seller_id: nil,
      name: "Ingresso VIP",
      description: "Descrição",
      price: 99.99,
      originalPrice: nil,
      original_price: nil,
      ticketType: "vip",
      ticket_type: nil,
      status: "available",
      validUntil: nil,
      valid_until: nil,
      createdAt: nil,
      created_at: nil,
      isFavorited: false,
      is_favorited: nil,
      quantity: 1,
      currencyCode: "BRL",
      currency_code: nil,
      imageUrls: nil,
      image_urls: nil
    )
    
    let apiResponse = APIUserResponse(
      id: "user-123",
      name: "João",
      title: nil,
      profileImageURL: nil,
      profile_image_url: nil,
      email: nil,
      followersCount: nil,
      followers_count: nil,
      followingCount: nil,
      following_count: nil,
      ticketsCount: nil,
      tickets_count: nil,
      isVerified: nil,
      is_verified: nil,
      tickets: [apiTicket],
      createdAt: nil,
      created_at: nil,
      verification: nil
    )
    
    let user = apiResponse.toUser()
    
    #expect(user.tickets.count == 1)
    #expect(user.tickets.first?.id == "ticket-1")
    #expect(user.tickets.first?.name == "Ingresso VIP")
    #expect(user.tickets.first?.price == 99.99)
  }
  
  // MARK: - APITicketResponse Tests
  
  @Test("APITicketResponse.toTicket() deve mapear corretamente")
  func testAPITicketResponseToTicket() {
    let apiResponse = APITicketResponse(
      id: "ticket-123",
      eventId: "event-456",
      event_id: nil,
      sellerId: "seller-789",
      seller_id: nil,
      name: "Ingresso VIP",
      description: "Ingresso VIP para o evento",
      price: 150.00,
      originalPrice: 200.00,
      original_price: nil,
      ticketType: "vip",
      ticket_type: nil,
      status: "available",
      validUntil: "2024-12-31T23:59:59Z",
      valid_until: nil,
      createdAt: "2024-01-01T10:00:00Z",
      created_at: nil,
      isFavorited: true,
      is_favorited: nil,
      quantity: 2,
      currencyCode: "BRL",
      currency_code: nil,
      imageUrls: ["https://example.com/image1.jpg"],
      image_urls: nil
    )
    
    let ticket = apiResponse.toTicket()
    
    #expect(ticket.id == "ticket-123")
    #expect(ticket.eventId == "event-456")
    #expect(ticket.sellerId == "seller-789")
    #expect(ticket.name == "Ingresso VIP")
    #expect(ticket.description == "Ingresso VIP para o evento")
    #expect(ticket.price == 150.00)
    #expect(ticket.originalPrice == 200.00)
    #expect(ticket.ticketType == .vip)
    #expect(ticket.status == .available)
    #expect(ticket.isFavorited == true)
    #expect(ticket.quantity == 2)
    #expect(ticket.currencyCode == "BRL")
    #expect(ticket.imageUrls?.count == 1)
  }
  
  @Test("APITicketResponse.toTicket() deve usar valores padrão para campos opcionais")
  func testAPITicketResponseDefaultValues() {
    let apiResponse = APITicketResponse(
      id: "ticket-456",
      eventId: nil,
      event_id: nil,
      sellerId: nil,
      seller_id: nil,
      name: "Ingresso",
      description: nil,
      price: 50.00,
      originalPrice: nil,
      original_price: nil,
      ticketType: nil,
      ticket_type: nil,
      status: "available",
      validUntil: nil,
      valid_until: nil,
      createdAt: nil,
      created_at: nil,
      isFavorited: nil,
      is_favorited: nil,
      quantity: nil,
      currencyCode: nil,
      currency_code: nil,
      imageUrls: nil,
      image_urls: nil
    )
    
    let ticket = apiResponse.toTicket()
    
    #expect(ticket.id == "ticket-456")
    #expect(ticket.name == "Ingresso")
    #expect(ticket.price == 50.00)
    #expect(ticket.ticketType == .general) // Valor padrão
    #expect(ticket.status == .available)
    #expect(ticket.isFavorited == false) // Valor padrão
  }
  
  // MARK: - APIEventResponse Tests
  
  @Test("APIEventResponse.toEvent() deve mapear corretamente")
  func testAPIEventResponseToEvent() {
    let apiLocation = APILocationResponse(
      name: "São Paulo",
      address: "Av. Paulista, 1000",
      city: "São Paulo",
      state: "SP",
      country: "Brasil",
      zipCode: "01310-100",
      zip_code: nil,
      coordinate: APICoordinateResponse(latitude: -23.5505, longitude: -46.6333)
    )
    
    let apiResponse = APIEventResponse(
      id: "event-123",
      name: "Festival de Música",
      description: "Grande festival de música",
      imageURL: "https://example.com/event.jpg",
      image_url: nil,
      startPrice: 80.00,
      start_price: nil,
      location: apiLocation,
      category: "music",
      isRecommended: true,
      is_recommended: nil,
      rating: 4.5,
      reviewCount: 100,
      review_count: nil,
      createdAt: "2024-01-01T00:00:00Z",
      created_at: nil,
      eventDate: "2024-06-15T20:00:00Z",
      event_date: nil
    )
    
    let event = apiResponse.toEvent()
    
    #expect(event.id == "event-123")
    #expect(event.name == "Festival de Música")
    #expect(event.description == "Grande festival de música")
    #expect(event.imageURL == "https://example.com/event.jpg")
    #expect(event.startPrice == 80.00)
    #expect(event.category == .music)
    #expect(event.isRecommended == true)
    #expect(event.rating == 4.5)
    #expect(event.reviewCount == 100)
    #expect(event.location.name == "São Paulo")
  }
  
  // MARK: - Edge Cases
  
  @Test("APIUserResponse.toUser() deve lidar com datas inválidas")
  func testAPIUserResponseInvalidDate() {
    let apiResponse = APIUserResponse(
      id: "user-123",
      name: "Test User",
      title: nil,
      profileImageURL: nil,
      profile_image_url: nil,
      email: nil,
      followersCount: nil,
      followers_count: nil,
      followingCount: nil,
      following_count: nil,
      ticketsCount: nil,
      tickets_count: nil,
      isVerified: nil,
      is_verified: nil,
      tickets: nil,
      createdAt: "invalid-date",
      created_at: nil,
      verification: nil
    )
    
    let user = apiResponse.toUser()
    
    // Deve criar user mesmo com data inválida (não crashar)
    #expect(user.id == "user-123")
    #expect(user.name == "Test User")
  }
  
  @Test("APITicketResponse.toTicket() deve lidar com status inválido")
  func testAPITicketResponseInvalidStatus() {
    let apiResponse = APITicketResponse(
      id: "ticket-123",
      eventId: nil,
      event_id: nil,
      sellerId: nil,
      seller_id: nil,
      name: "Ticket",
      description: nil,
      price: 50.00,
      originalPrice: nil,
      original_price: nil,
      ticketType: nil,
      ticket_type: nil,
      status: "invalid_status",
      validUntil: nil,
      valid_until: nil,
      createdAt: nil,
      created_at: nil,
      isFavorited: nil,
      is_favorited: nil,
      quantity: nil,
      currencyCode: nil,
      currency_code: nil,
      imageUrls: nil,
      image_urls: nil
    )
    
    let ticket = apiResponse.toTicket()
    
    // Deve usar valor padrão para status inválido
    #expect(ticket.status == .available) // Valor padrão
  }
}

