import Testing
import ComposableArchitecture
import Foundation
@testable import SocialApp

struct SellerProfileFeatureTests {
    
    @Test("loadSeller deve carregar perfil do vendedor com sucesso")
    func testLoadSellerSuccess() async throws {
        let mockSeller = User(
            name: "Vendedor Teste",
            title: "Vendedor Verificado",
            profileImageURL: "https://example.com/photo.jpg",
            email: "vendedor@teste.com"
        )
        mockSeller.id = "seller-123"
        
        let store = TestStore(initialState: SellerProfileFeature.State(sellerId: "seller-123")) {
            SellerProfileFeature()
        } withDependencies: {
            $0.userClient.getUserProfile = { _ in mockSeller }
        }
        
        await store.send(.loadSeller("seller-123"))
        await store.receive(.sellerResponse(.success(mockSeller))) {
            $0.seller = mockSeller
            $0.isLoading = false
        }
    }
    
    @Test("loadSellerTickets deve carregar ingressos do vendedor")
    func testLoadSellerTickets() async throws {
        let mockTickets = [
            Ticket(
                eventId: UUID().uuidString,
                sellerId: "seller-123",
                name: "Ingresso 1",
                description: "Descrição",
                price: 100.0,
                ticketType: "VIP",
                validUntil: Date(),
                quantity: 1,
                currencyCode: "BRL"
            )
        ]
        
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
        
        let store = TestStore(initialState: SellerProfileFeature.State(sellerId: "seller-123")) {
            SellerProfileFeature()
        } withDependencies: {
            $0.ticketsClient.fetchTicketsBySeller = { _ in mockTickets }
            $0.eventsClient.fetchEventById = { _ in mockEvent }
        }
        
        await store.send(.loadSellerTickets)
        await store.receive(.sellerTicketsResponse(.success([TicketWithEvent(ticket: mockTickets[0], event: mockEvent)]))) {
            $0.isLoadingTickets = false
            $0.sellerTickets = [TicketWithEvent(ticket: mockTickets[0], event: mockEvent)]
        }
    }
    
    @Test("tabSelected deve atualizar tab selecionada")
    func testTabSelected() async {
        let store = TestStore(initialState: SellerProfileFeature.State()) {
            SellerProfileFeature()
        }
        
        await store.send(.tabSelected(.about)) {
            $0.selectedTab = .about
        }
        
        await store.send(.tabSelected(.tickets)) {
            $0.selectedTab = .tickets
        }
    }
    
    @Test("syncTicketDeleted deve remover ticket da lista")
    func testSyncTicketDeleted() async {
        let ticket1 = Ticket(
            eventId: UUID().uuidString,
            sellerId: "seller-123",
            name: "Ticket 1",
            description: "Desc",
            price: 100.0,
            ticketType: "VIP",
            validUntil: Date(),
            quantity: 1,
            currencyCode: "BRL"
        )
        ticket1.id = "ticket-1"
        
        let ticket2 = Ticket(
            eventId: UUID().uuidString,
            sellerId: "seller-123",
            name: "Ticket 2",
            description: "Desc",
            price: 200.0,
            ticketType: "Normal",
            validUntil: Date(),
            quantity: 1,
            currencyCode: "BRL"
        )
        ticket2.id = "ticket-2"
        
        let mockEvent = Event(
            id: UUID().uuidString,
            name: "Evento",
            description: "Desc",
            category: "Música",
            location: Location(name: "Local", address: "End", city: "City", state: "ST", zipCode: "12345")
        )
        
        let initialState = SellerProfileFeature.State(sellerId: "seller-123")
        initialState.sellerTickets = [
            TicketWithEvent(ticket: ticket1, event: mockEvent),
            TicketWithEvent(ticket: ticket2, event: mockEvent)
        ]
        
        let store = TestStore(initialState: initialState) {
            SellerProfileFeature()
        }
        
        await store.send(.syncTicketDeleted("ticket-1")) {
            $0.sellerTickets = [TicketWithEvent(ticket: ticket2, event: mockEvent)]
        }
    }
}

