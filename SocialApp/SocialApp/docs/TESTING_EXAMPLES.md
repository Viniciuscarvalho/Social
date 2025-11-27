# Exemplos de Testes

Este documento contém exemplos práticos e completos de testes para diferentes cenários.

## Testes de Mappers

### Exemplo 1: Mapper Simples

```swift
import Testing
@testable import Data
@testable import Domain

struct APIUserResponseMapperTests {
  @Test("deve mapear campos básicos corretamente")
  func testBasicFieldsMapping() {
    // Arrange
    let apiResponse = APIUserResponse(
      id: "user-123",
      name: "João Silva",
      email: "joao@example.com",
      // ... outros campos
    )
    
    // Act
    let user = apiResponse.toUser()
    
    // Assert
    #expect(user.id == "user-123")
    #expect(user.name == "João Silva")
    #expect(user.email == "joao@example.com")
  }
  
  @Test("deve usar snake_case como fallback")
  func testSnakeCaseFallback() {
    let apiResponse = APIUserResponse(
      id: "user-456",
      name: "Maria",
      profileImageURL: nil,
      profile_image_url: "https://example.com/avatar.jpg",
      // ...
    )
    
    let user = apiResponse.toUser()
    
    #expect(user.profileImageURL == "https://example.com/avatar.jpg")
  }
  
  @Test("deve mapear objetos aninhados")
  func testNestedObjects() {
    let apiTicket = APITicketResponse(...)
    let apiResponse = APIUserResponse(
      id: "user-123",
      name: "João",
      tickets: [apiTicket],
      // ...
    )
    
    let user = apiResponse.toUser()
    
    #expect(user.tickets.count == 1)
    #expect(user.tickets.first?.id == apiTicket.id)
  }
}
```

### Exemplo 2: Mapper com Edge Cases

```swift
@Test("deve lidar com valores nulos")
func testNullValues() {
  let apiResponse = APIUserResponse(
    id: "user-123",
    name: "João",
    email: nil,
    title: nil,
    // ... todos opcionais como nil
  )
  
  let user = apiResponse.toUser()
  
  #expect(user.id == "user-123")
  #expect(user.name == "João")
  #expect(user.email == nil)
  #expect(user.title == nil)
}

@Test("deve usar valores padrão para campos inválidos")
func testInvalidValues() {
  let apiResponse = APITicketResponse(
    id: "ticket-123",
    name: "Ticket",
    status: "invalid_status", // Status inválido
    // ...
  )
  
  let ticket = apiResponse.toTicket()
  
  // Deve usar valor padrão
  #expect(ticket.status == .available) // Valor padrão
}
```

## Testes de Reducers

### Exemplo 1: Reducer Simples

```swift
import Testing
import ComposableArchitecture
@testable import SocialApp

struct ProfileFeatureReducerTests {
  @Test("onAppear deve carregar dados")
  func testOnAppear() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.profileClient.fetchProfile = { .mock }
      $0.ticketsClient.fetchMyTicketsCount = { 10 }
    }
    
    await store.send(.onAppear)
    
    await store.receive(.loadUserProfile)
    await store.receive(.loadTicketsCount) {
      $0.isLoading = true
    }
    
    await store.receive(.ticketsCountResponse(.success(10))) {
      $0.isLoading = false
      $0.ticketsCount = 10
    }
  }
  
  @Test("loadTicketsCount deve tratar erro")
  func testLoadTicketsCountError() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.ticketsClient.fetchMyTicketsCount = {
        throw NetworkError.unknown("Erro de rede")
      }
    }
    
    await store.send(.loadTicketsCount) {
      $0.isLoading = true
    }
    
    await store.receive(.ticketsCountResponse(.failure(NetworkError.unknown("Erro de rede")))) {
      $0.isLoading = false
      $0.error = "Erro de rede"
    }
  }
}
```

### Exemplo 2: Reducer com Sincronização

```swift
@Test("ticketCreated deve recarregar contagem")
func testTicketCreated() async {
  let store = TestStore(initialState: ProfileFeature.State()) {
    ProfileFeature()
  } withDependencies: {
    $0.ticketsClient.fetchMyTicketsCount = { 5 }
  }
  
  await store.send(.ticketCreated)
  
  await store.receive(.loadTicketsCount) {
    $0.isLoading = true
  }
  
  await store.receive(.ticketsCountResponse(.success(5))) {
    $0.isLoading = false
    $0.ticketsCount = 5
  }
}
```

### Exemplo 3: Reducer com Navigation

```swift
@Test("editProfileTapped deve mostrar sheet")
func testEditProfileTapped() async {
  let store = TestStore(initialState: ProfileFeature.State()) {
    ProfileFeature()
  }
  
  await store.send(.editProfileTapped) {
    $0.showingEditProfile = true
  }
}

@Test("setShowingEditProfile deve atualizar state")
func testSetShowingEditProfile() async {
  let store = TestStore(initialState: ProfileFeature.State()) {
    ProfileFeature()
  }
  
  await store.send(.setShowingEditProfile(true)) {
    $0.showingEditProfile = true
  }
  
  await store.send(.setShowingEditProfile(false)) {
    $0.showingEditProfile = false
  }
}
```

## Testes de Integração

### Exemplo: Fluxo Completo

```swift
import Testing
import ComposableArchitecture
@testable import SocialApp

struct IntegrationTests {
  @Test("Fluxo: Criar ticket → Aparece em todas as listas")
  func testCreateTicketFlow() async {
    // Este teste verifica sincronização entre Features
    // Implementação futura quando migração estiver completa
  }
}
```

## Criando Mocks

### Mock de User

```swift
// Em Domain/Sources/MockData.swift
extension User {
  public static var mock: User {
    var user = User(
      name: "Test User",
      email: "test@example.com",
      title: "Developer"
    )
    user.id = "test-user-id"
    user.followersCount = 100
    user.followingCount = 50
    user.ticketsCount = 5
    user.isVerified = true
    return user
  }
}
```

### Mock de Ticket

```swift
extension Ticket {
  public static var mock: Ticket {
    var ticket = Ticket(
      eventId: "event-123",
      sellerId: "seller-456",
      name: "Test Ticket",
      price: 99.99,
      ticketType: .vip,
      validUntil: Date().addingTimeInterval(86400),
      quantity: 1,
      currencyCode: "BRL"
    )
    ticket.id = "test-ticket-id"
    ticket.status = .available
    return ticket
  }
}
```

### Mock de Client

```swift
// Em testes
let store = TestStore(...) withDependencies: {
  $0.profileClient.fetchProfile = {
    return .mock
  }
  
  $0.ticketsClient.fetchTickets = {
    return [.mock, .mock]
  }
}
```

## Padrões Comuns

### Teste de Loading State

```swift
@Test("deve mostrar loading durante carregamento")
func testLoadingState() async {
  let store = TestStore(initialState: State()) {
    Feature()
  } withDependencies: {
    $0.client.fetch = {
      try await Task.sleep(nanoseconds: 100_000_000) // Simula delay
      return .mock
    }
  }
  
  await store.send(.loadData) {
    $0.isLoading = true
  }
  
  await store.receive(.dataResponse(.success(.mock))) {
    $0.isLoading = false
    $0.data = .mock
  }
}
```

### Teste de Error Handling

```swift
@Test("deve tratar erro de rede")
func testNetworkError() async {
  let store = TestStore(initialState: State()) {
    Feature()
  } withDependencies: {
    $0.client.fetch = {
      throw NetworkError.unknown("Erro")
    }
  }
  
  await store.send(.loadData) {
    $0.isLoading = true
  }
  
  await store.receive(.dataResponse(.failure(NetworkError.unknown("Erro")))) {
    $0.isLoading = false
    $0.error = "Erro"
  }
}
```

### Teste de Empty State

```swift
@Test("deve mostrar empty state quando lista vazia")
func testEmptyState() async {
  let store = TestStore(initialState: State()) {
    Feature()
  } withDependencies: {
    $0.client.fetch = { [] }
  }
  
  await store.send(.loadData)
  
  await store.receive(.dataResponse(.success([]))) {
    $0.data = []
    // Derived state: hasData == false
  }
}
```

## Referências

- [TESTING_GUIDE.md](./TESTING_GUIDE.md) - Guia completo
- [TESTING_STRATEGY.md](./TESTING_STRATEGY.md) - Estratégia
- [QA_GUIDE.md](./QA_GUIDE.md) - QA manual

---

✅ **Exemplos práticos de testes**

📚 **Use estes exemplos como referência**

🎯 **Adapte para seus casos específicos**

