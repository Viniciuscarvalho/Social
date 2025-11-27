# Guia de Testes

## Visão Geral

Este guia descreve a estratégia de testes para o projeto, incluindo testes unitários, de integração e boas práticas.

## Estrutura de Testes

### Organização

```
Data/Tests/
  └── DataMapperTests.swift        → Testes de mappers

SocialApp/Tests/
  ├── ProfileFeatureTests.swift    → Testes de ProfileFeature
  ├── EventDetailFeatureTests.swift → Testes de EventDetailFeature
  └── IntegrationTests.swift       → Testes de integração
```

## Tipos de Testes

### 1. Testes de Mappers (Data Layer)

Testam a conversão de DTOs para modelos do Domain.

**O que testar:**
- Mapeamento de campos básicos
- Fallback para snake_case
- Valores padrão para campos opcionais
- Edge cases (valores nulos, inválidos)
- Mapeamento de objetos aninhados

**Exemplo:**
```swift
@Test("APIUserResponse.toUser() deve mapear corretamente campos básicos")
func testAPIUserResponseToUserBasicFields() {
  let apiResponse = APIUserResponse(...)
  let user = apiResponse.toUser()
  
  #expect(user.id == "user-123")
  #expect(user.name == "João Silva")
}
```

### 2. Testes de Reducers (Presentation Layer)

Testam a lógica de negócio nas Features TCA.

**O que testar:**
- Transformações de estado (actions → state updates)
- Side effects (chamadas de API, navegação)
- Error handling
- Sincronização de dados
- Edge cases

**Exemplo:**
```swift
@Test("loadTicketsCount deve atualizar state corretamente")
func testLoadTicketsCount() async {
  let store = TestStore(initialState: ProfileFeature.State()) {
    ProfileFeature()
  } withDependencies: {
    $0.ticketsClient.fetchMyTicketsCount = { 5 }
  }
  
  await store.send(.loadTicketsCount) {
    $0.isLoading = true
  }
  
  await store.receive(.ticketsCountResponse(.success(5))) {
    $0.isLoading = false
    $0.ticketsCount = 5
  }
}
```

### 3. Testes de Integração

Testam fluxos completos entre Features.

**O que testar:**
- Fluxos de navegação
- Sincronização entre Features
- Fluxos de dados end-to-end

## Framework de Testes

### Swift Testing (Novo)

O projeto usa o novo framework **Swift Testing** introduzido no iOS 18+.

**Vantagens:**
- Sintaxe moderna e limpa
- Type-safe assertions
- Melhor integração com Swift
- Suporte a async/await nativo

**Sintaxe:**
```swift
import Testing

@Test("Descrição do teste")
func testExample() async throws {
  // Arrange
  let value = 10
  
  // Act
  let result = value * 2
  
  // Assert
  #expect(result == 20)
}
```

### TCA TestStore

Para testar Features TCA, usamos `TestStore`:

```swift
import ComposableArchitecture
import Testing

@Test("Action deve atualizar state")
func testAction() async {
  let store = TestStore(initialState: Feature.State()) {
    Feature()
  } withDependencies: {
    $0.client.method = { /* mock */ }
  }
  
  await store.send(.action) {
    $0.property = newValue
  }
  
  await store.receive(.response(.success(data))) {
    $0.property = updatedValue
  }
}
```

## Padrões de Teste

### AAA Pattern (Arrange-Act-Assert)

```swift
@Test("Descrição")
func testExample() {
  // Arrange - Preparar dados
  let input = "test"
  
  // Act - Executar ação
  let result = process(input)
  
  // Assert - Verificar resultado
  #expect(result == expected)
}
```

### Given-When-Then

```swift
@Test("Dado um usuário, quando carregar perfil, então deve atualizar state")
func testLoadProfile() async {
  // Given
  let store = TestStore(...)
  
  // When
  await store.send(.loadProfile)
  
  // Then
  await store.receive(.profileResponse(.success(user))) {
    $0.user = user
  }
}
```

## Mocking Dependencies

### TCA Dependencies

```swift
let store = TestStore(...) withDependencies: {
  $0.profileClient.fetchProfile = {
    return User.mock
  }
  
  $0.ticketsClient.fetchTickets = {
    return [Ticket.mock]
  }
}
```

### Criar Mocks

```swift
// Em Domain/Sources/MockData.swift
extension User {
  static var mock: User {
    var user = User(name: "Test User", email: "test@example.com")
    user.id = "test-id"
    return user
  }
}
```

## Cobertura de Testes

### Prioridades

1. **Alta Prioridade**:
   - Mappers (crítico para integridade de dados)
   - Reducers de Features core
   - Lógica de negócio complexa

2. **Média Prioridade**:
   - Reducers de Features secundárias
   - Helpers e utilities
   - Transformações de dados

3. **Baixa Prioridade**:
   - Views (testes de snapshot se necessário)
   - Componentes UI simples

### Meta de Cobertura

- **Mappers**: 100% (crítico)
- **Reducers**: 80%+ (focar em lógica complexa)
- **Helpers**: 70%+
- **Views**: Opcional (snapshot tests)

## Checklist de Testes

### Para cada Mapper

- [ ] Testar mapeamento de campos básicos
- [ ] Testar fallback para snake_case
- [ ] Testar valores padrão
- [ ] Testar objetos aninhados
- [ ] Testar edge cases (nulos, inválidos)
- [ ] Testar diferentes formatos de data

### Para cada Reducer

- [ ] Testar lifecycle (onAppear, onDisappear)
- [ ] Testar data loading (success, failure)
- [ ] Testar user interactions
- [ ] Testar navigation actions
- [ ] Testar error handling
- [ ] Testar sincronização (se aplicável)
- [ ] Testar edge cases

## Exemplos Completos

### Exemplo 1: Teste de Mapper

```swift
import Testing
@testable import Data
@testable import Domain

struct DataMapperTests {
  @Test("APIUserResponse.toUser() deve mapear corretamente")
  func testAPIUserResponseToUser() {
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
}
```

### Exemplo 2: Teste de Reducer

```swift
import Testing
import ComposableArchitecture
@testable import SocialApp

struct ProfileFeatureTests {
  @Test("loadTicketsCount deve carregar e atualizar contagem")
  func testLoadTicketsCount() async {
    // Arrange
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.ticketsClient.fetchMyTicketsCount = { 10 }
    }
    
    // Act & Assert
    await store.send(.loadTicketsCount) {
      $0.isLoading = true
    }
    
    await store.receive(.ticketsCountResponse(.success(10))) {
      $0.isLoading = false
      $0.ticketsCount = 10
    }
  }
  
  @Test("loadTicketsCount deve tratar erro corretamente")
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

## Boas Práticas

### ✅ DO

1. **Testar comportamento, não implementação**
   ```swift
   // ✅ BOM - Testa comportamento
   #expect(user.name == "João")
   
   // ❌ RUIM - Testa implementação
   #expect(user.name.count > 0)
   ```

2. **Usar nomes descritivos**
   ```swift
   // ✅ BOM
   @Test("APIUserResponse.toUser() deve mapear corretamente campos básicos")
   
   // ❌ RUIM
   @Test("test1")
   ```

3. **Testar edge cases**
   ```swift
   // ✅ BOM
   @Test("deve lidar com valores nulos")
   @Test("deve usar valores padrão")
   @Test("deve tratar erros corretamente")
   ```

4. **Manter testes isolados**
   ```swift
   // ✅ BOM - Cada teste é independente
   @Test("test1") { /* ... */ }
   @Test("test2") { /* ... */ }
   ```

5. **Usar mocks apropriados**
   ```swift
   // ✅ BOM - Mock específico
   $0.client.method = { return .mock }
   ```

### ❌ DON'T

1. **Não testar implementação interna**
   ```swift
   // ❌ RUIM
   #expect(internalVariable == value)
   ```

2. **Não criar testes frágeis**
   ```swift
   // ❌ RUIM - Depende de ordem
   test1()
   test2() // Depende de test1
   ```

3. **Não ignorar erros**
   ```swift
   // ❌ RUIM
   try? function() // Ignora erro
   
   // ✅ BOM
   do {
     try function()
   } catch {
     #expect(error is ExpectedError)
   }
   ```

## Executando Testes

### Xcode

1. Cmd + U - Executar todos os testes
2. Cmd + Option + U - Executar testes com coverage
3. Clicar no diamante ao lado do teste - Executar teste específico

### Terminal

```bash
# Executar todos os testes
xcodebuild test -scheme SocialApp -destination 'platform=iOS Simulator,name=iPhone 15'

# Executar testes com coverage
xcodebuild test -scheme SocialApp -enableCodeCoverage YES
```

## Cobertura de Código

### Verificar Cobertura

1. Xcode → Product → Scheme → Edit Scheme
2. Test → Options → Code Coverage: ✅
3. Executar testes (Cmd + Option + U)
4. Report Navigator → Coverage

### Meta de Cobertura

- **Mappers**: 100%
- **Reducers**: 80%+
- **Helpers**: 70%+
- **Geral**: 70%+

## Troubleshooting

### Problema: Teste não compila

**Solução**: Verificar imports
```swift
import Testing
@testable import Data  // ✅ Necessário
@testable import Domain
```

### Problema: TestStore não recebe action

**Solução**: Verificar se action está sendo enviada corretamente
```swift
await store.send(.action)  // ✅ Deve usar await
```

### Problema: Mock não funciona

**Solução**: Verificar se dependency está registrada
```swift
withDependencies: {
  $0.client.method = { /* mock */ }  // ✅ Deve estar registrado
}
```

## Referências

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [TCA Testing](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/testing/)
- [PRESENTATION_LAYER.md](./PRESENTATION_LAYER.md) - Padrões de Presentation

---

✅ **Guia completo de testes estabelecido**

📚 **Use este guia para criar e manter testes**

🎯 **Foco em mappers e reducers para garantir qualidade**

