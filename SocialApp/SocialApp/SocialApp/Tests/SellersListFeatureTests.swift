import Testing
import ComposableArchitecture
import Foundation
@testable import SocialApp

struct SellersListFeatureTests {
    
    @Test("loadSellers deve carregar vendedores com sucesso")
    func testLoadSellersSuccess() async throws {
        let eventId = UUID()
        
        let mockSeller = User(
            name: "Vendedor Teste",
            title: "Vendedor",
            profileImageURL: "https://example.com/photo.jpg",
            email: "vendedor@teste.com"
        )
        mockSeller.id = "seller-123"
        
        let mockTicket = Ticket(
            eventId: eventId.uuidString,
            sellerId: "seller-123",
            name: "Ingresso VIP",
            description: "Descrição",
            price: 100.0,
            ticketType: "VIP",
            validUntil: Date(),
            quantity: 1,
            currencyCode: "BRL"
        )
        
        let mockSellersWithTickets = [
            SellerWithTickets(seller: mockSeller, tickets: [mockTicket])
        ]
        
        let store = TestStore(initialState: SellersListFeature.State(eventId: eventId)) {
            SellersListFeature()
        } withDependencies: {
            $0.ticketsClient.fetchSellersByEvent = { _ in mockSellersWithTickets }
        }
        
        await store.send(.loadSellers) {
            $0.isLoading = true
            $0.errorMessage = nil
        }
        
        await store.receive(.sellersResponse(.success(mockSellersWithTickets))) {
            $0.isLoading = false
            $0.sellers = mockSellersWithTickets
        }
    }
    
    @Test("loadSellers deve tratar erro corretamente")
    func testLoadSellersError() async {
        let eventId = UUID()
        let error = NetworkError.notFound
        
        let store = TestStore(initialState: SellersListFeature.State(eventId: eventId)) {
            SellersListFeature()
        } withDependencies: {
            $0.ticketsClient.fetchSellersByEvent = { _ in throw error }
        }
        
        await store.send(.loadSellers) {
            $0.isLoading = true
            $0.errorMessage = nil
        }
        
        await store.receive(.sellersResponse(.failure(error))) {
            $0.isLoading = false
            $0.errorMessage = error.userFriendlyMessage
        }
    }
    
    @Test("onAppear deve carregar vendedores automaticamente")
    func testOnAppear() async {
        let eventId = UUID()
        let mockSellers: [SellerWithTickets] = []
        
        let store = TestStore(initialState: SellersListFeature.State(eventId: eventId)) {
            SellersListFeature()
        } withDependencies: {
            $0.ticketsClient.fetchSellersByEvent = { _ in mockSellers }
        }
        
        await store.send(.onAppear)
        await store.receive(.loadSellers)
    }
    
    @Test("sellerTapped não deve alterar estado")
    func testSellerTapped() async {
        let eventId = UUID()
        let store = TestStore(initialState: SellersListFeature.State(eventId: eventId)) {
            SellersListFeature()
        }
        
        await store.send(.sellerTapped("seller-123"))
        // A navegação é tratada pelo parent, então não há mudança de estado
        #expect(store.state.sellers.isEmpty)
    }
}

