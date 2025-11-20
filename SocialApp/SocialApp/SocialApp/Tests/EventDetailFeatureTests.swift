import Testing
import ComposableArchitecture
import Foundation
@testable import SocialApp

struct EventDetailFeatureTests {
    
    @Test("negotiateTicket deve ser tratado pelo reducer")
    func testNegotiateTicket() async {
        let eventId = UUID()
        let store = TestStore(initialState: EventDetailFeature.State(eventId: eventId)) {
            EventDetailFeature()
        }
        
        await store.send(.negotiateTicket)
        // A action é tratada pelo parent, então não há mudança de estado aqui
        // Mas verificamos que não há erro
        #expect(store.state.errorMessage == nil)
    }
    
    @Test("loadEvent deve carregar evento com sucesso")
    func testLoadEventSuccess() async throws {
        let eventId = UUID()
        let mockEvent = Event(
            id: eventId.uuidString,
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
        
        let store = TestStore(initialState: EventDetailFeature.State(eventId: eventId)) {
            EventDetailFeature()
        } withDependencies: {
            $0.eventsClient.fetchEventDetail = { _ in mockEvent }
            $0.favoritesClient.isFavorite = { _ in false }
        }
        
        await store.send(.loadEvent(eventId)) {
            $0.isLoading = true
            $0.errorMessage = nil
        }
        
        await store.receive(.eventResponse(.success(mockEvent))) {
            $0.isLoading = false
            $0.event = mockEvent
        }
    }
    
    @Test("onAppear com evento existente não deve fazer chamada API")
    func testOnAppearWithExistingEvent() async {
        let eventId = UUID()
        let existingEvent = Event(
            id: eventId.uuidString,
            name: "Evento Existente",
            description: "Desc",
            category: "Música",
            location: Location(name: "Local", address: "End", city: "City", state: "ST", zipCode: "12345")
        )
        
        var apiCalled = false
        let store = TestStore(initialState: EventDetailFeature.State(eventId: eventId, event: existingEvent)) {
            EventDetailFeature()
        } withDependencies: {
            $0.eventsClient.fetchEventDetail = { _ in
                apiCalled = true
                return existingEvent
            }
            $0.favoritesClient.isFavorite = { _ in false }
        }
        
        await store.send(.onAppear(eventId, existingEvent))
        
        // Verificar que a API não foi chamada
        #expect(apiCalled == false)
        #expect(store.state.event?.name == "Evento Existente")
    }
    
    @Test("toggleFavorite deve adicionar aos favoritos quando não está favoritado")
    func testToggleFavoriteAdd() async {
        let eventId = UUID()
        let mockEvent = Event(
            id: eventId.uuidString,
            name: "Evento",
            description: "Desc",
            category: "Música",
            location: Location(name: "Local", address: "End", city: "City", state: "ST", zipCode: "12345")
        )
        
        var favoriteAdded = false
        let store = TestStore(initialState: EventDetailFeature.State(eventId: eventId, event: mockEvent)) {
            EventDetailFeature()
        } withDependencies: {
            $0.favoritesClient.addToFavorites = { _ in
                favoriteAdded = true
            }
        }
        
        await store.send(.toggleFavorite)
        await store.receive(.favoriteStatusLoaded(true)) {
            $0.isFavorited = true
        }
        
        #expect(favoriteAdded == true)
    }
}

