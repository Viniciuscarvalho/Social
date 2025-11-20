import Testing
import ComposableArchitecture
import Foundation
@testable import SocialApp

/// Testes de integração para fluxos completos
struct IntegrationTests {
    
    @Test("Fluxo completo: Perfil → Vendedor → Ingressos")
    func testProfileToSellerToTicketsFlow() async throws {
        // Setup: Criar mocks
        let sellerId = "seller-123"
        let mockSeller = User(
            name: "Vendedor Teste",
            title: "Vendedor Verificado",
            profileImageURL: "https://example.com/photo.jpg",
            email: "vendedor@teste.com"
        )
        mockSeller.id = sellerId
        
        let mockTicket = Ticket(
            eventId: UUID().uuidString,
            sellerId: sellerId,
            name: "Ingresso VIP",
            description: "Descrição",
            price: 100.0,
            ticketType: "VIP",
            validUntil: Date(),
            quantity: 1,
            currencyCode: "BRL"
        )
        
        let mockEvent = Event(
            id: UUID().uuidString,
            name: "Evento Teste",
            description: "Descrição do evento",
            category: "Música",
            location: Location(
                name: "Local Teste",
                address: "Endereço Teste",
                city: "Cidade",
                state: "Estado",
                zipCode: "12345"
            )
        )
        
        // 1. ProfileFeature: Navegar para perfil do vendedor
        let profileStore = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }
        
        var notificationReceived = false
        let observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToSellerProfile"),
            object: nil,
            queue: nil
        ) { notification in
            notificationReceived = true
            #expect(notification.userInfo?["sellerId"] as? String == sellerId)
        }
        
        await profileStore.send(.navigateToSellerProfile(sellerId))
        #expect(notificationReceived == true)
        
        NotificationCenter.default.removeObserver(observer)
        
        // 2. SellerProfileFeature: Carregar perfil e ingressos
        let sellerStore = TestStore(initialState: SellerProfileFeature.State(sellerId: sellerId)) {
            SellerProfileFeature()
        } withDependencies: {
            $0.userClient.getUserProfile = { _ in mockSeller }
            $0.ticketsClient.fetchTicketsBySeller = { _ in [mockTicket] }
            $0.eventsClient.fetchEventById = { _ in mockEvent }
        }
        
        await sellerStore.send(.loadSeller(sellerId))
        await sellerStore.receive(.sellerResponse(.success(mockSeller))) {
            $0.seller = mockSeller
            $0.isLoading = false
        }
        
        await sellerStore.send(.loadSellerTickets)
        await sellerStore.receive(.sellerTicketsResponse(.success([TicketWithEvent(ticket: mockTicket, event: mockEvent)]))) {
            $0.sellerTickets = [TicketWithEvent(ticket: mockTicket, event: mockEvent)]
            $0.isLoadingTickets = false
        }
        
        // Verificar que o título da tab é "Ingressos"
        #expect(sellerStore.state.selectedTab == .tickets)
    }
    
    @Test("Fluxo completo: Evento → Negociar → Lista de Vendedores")
    func testEventToNegotiateToSellersListFlow() async throws {
        let eventId = UUID()
        let mockEvent = Event(
            id: eventId.uuidString,
            name: "Evento Teste",
            description: "Descrição",
            category: "Música",
            location: Location(name: "Local", address: "End", city: "City", state: "ST", zipCode: "12345")
        )
        
        let mockSeller = User(
            name: "Vendedor",
            title: "Vendedor",
            profileImageURL: nil,
            email: nil
        )
        mockSeller.id = "seller-123"
        
        let mockTicket = Ticket(
            eventId: eventId.uuidString,
            sellerId: "seller-123",
            name: "Ingresso",
            description: "Desc",
            price: 100.0,
            ticketType: "Normal",
            validUntil: Date(),
            quantity: 1,
            currencyCode: "BRL"
        )
        
        let mockSellersWithTickets = [
            SellerWithTickets(seller: mockSeller, tickets: [mockTicket])
        ]
        
        // 1. EventDetailFeature: Carregar evento e clicar em "Negociar"
        let eventStore = TestStore(initialState: EventDetailFeature.State(eventId: eventId)) {
            EventDetailFeature()
        } withDependencies: {
            $0.eventsClient.fetchEventDetail = { _ in mockEvent }
            $0.favoritesClient.isFavorite = { _ in false }
        }
        
        await eventStore.send(.loadEvent(eventId))
        await eventStore.receive(.eventResponse(.success(mockEvent))) {
            $0.event = mockEvent
        }
        
        await eventStore.send(.negotiateTicket)
        // A navegação é tratada pelo parent
        
        // 2. SellersListFeature: Carregar lista de vendedores
        let sellersStore = TestStore(initialState: SellersListFeature.State(eventId: eventId, event: mockEvent)) {
            SellersListFeature()
        } withDependencies: {
            $0.ticketsClient.fetchSellersByEvent = { _ in mockSellersWithTickets }
        }
        
        await sellersStore.send(.onAppear)
        await sellersStore.receive(.loadSellers)
        await sellersStore.receive(.sellersResponse(.success(mockSellersWithTickets))) {
            $0.sellers = mockSellersWithTickets
            $0.isLoading = false
        }
        
        // Verificar que vendedores foram carregados
        #expect(sellersStore.state.sellers.count == 1)
        #expect(sellersStore.state.sellers.first?.seller.id == "seller-123")
    }
}

