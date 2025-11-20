import Testing
import ComposableArchitecture
@testable import SocialApp

struct ProfileFeatureTests {
    
    @Test("navigateToSellerProfile deve postar notificação com sellerId")
    func testNavigateToSellerProfile() async {
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }
        
        let sellerId = "test-seller-123"
        
        // Observar notificações
        var receivedNotification: Notification?
        let observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToSellerProfile"),
            object: nil,
            queue: nil
        ) { notification in
            receivedNotification = notification
        }
        
        await store.send(.navigateToSellerProfile(sellerId))
        
        // Verificar que a notificação foi postada
        #expect(receivedNotification != nil)
        if let notification = receivedNotification {
            let receivedSellerId = notification.userInfo?["sellerId"] as? String
            #expect(receivedSellerId == sellerId)
        }
        
        NotificationCenter.default.removeObserver(observer)
    }
    
    @Test("themeSelectionTapped deve atualizar showingThemeSelection para true")
    func testThemeSelectionTapped() async {
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }
        
        await store.send(.themeSelectionTapped)
        #expect(store.state.showingThemeSelection == true)
    }
    
    @Test("setShowingThemeSelection deve atualizar estado corretamente")
    func testSetShowingThemeSelection() async {
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }
        
        await store.send(.setShowingThemeSelection(true))
        #expect(store.state.showingThemeSelection == true)
        
        await store.send(.setShowingThemeSelection(false))
        #expect(store.state.showingThemeSelection == false)
    }
    
    @Test("ticketDeleted deve recarregar contagem de tickets")
    func testTicketDeleted() async {
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        } withDependencies: {
            $0.ticketsClient.fetchMyTicketsCount = { 5 }
        }
        
        await store.send(.ticketDeleted)
        
        // Verificar que loadTicketsCount foi chamado
        await store.receive(.ticketsCountResponse(.success(5)))
        #expect(store.state.ticketsCount == 5)
    }
    
    @Test("ticketCreated deve recarregar contagem de tickets")
    func testTicketCreated() async {
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        } withDependencies: {
            $0.ticketsClient.fetchMyTicketsCount = { 3 }
        }
        
        await store.send(.ticketCreated)
        
        await store.receive(.ticketsCountResponse(.success(3)))
        #expect(store.state.ticketsCount == 3)
    }
}

