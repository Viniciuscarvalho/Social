# Estratégia de Testes

## Visão Geral

Este documento define a estratégia completa de testes para o projeto, incluindo tipos de testes, prioridades, cobertura e ferramentas.

## Pirâmide de Testes

```
        /\
       /  \      E2E Tests (Poucos)
      /____\
     /      \    Integration Tests (Alguns)
    /________\
   /          \  Unit Tests (Muitos)
  /____________\
```

### Distribuição

- **70% Unit Tests**: Testes rápidos e isolados
- **20% Integration Tests**: Testes de fluxos entre componentes
- **10% E2E Tests**: Testes de fluxos completos (futuro)

## Tipos de Testes

### 1. Testes Unitários

**Escopo**: Componentes isolados (mappers, helpers, utilities)

**Exemplos**:
- Mappers (Data → Domain)
- Helpers e utilities
- Funções puras
- Computed properties

**Características**:
- Rápidos (< 1s cada)
- Isolados (sem dependências externas)
- Determinísticos (mesmo resultado sempre)
- Fáceis de manter

### 2. Testes de Reducers (TCA)

**Escopo**: Lógica de negócio nas Features

**Exemplos**:
- Transformações de estado
- Side effects
- Error handling
- Sincronização

**Características**:
- Usam TestStore do TCA
- Mock de dependencies
- Testam comportamento, não implementação

### 3. Testes de Integração

**Escopo**: Fluxos entre Features

**Exemplos**:
- Navegação entre Features
- Sincronização de dados
- Fluxos completos

**Características**:
- Testam múltiplos componentes juntos
- Mais lentos que unitários
- Mais próximos do comportamento real

### 4. Testes E2E (Futuro)

**Escopo**: Fluxos completos do usuário

**Exemplos**:
- Login → Home → Event → Ticket → Negotiation
- Criar ticket → Ver em lista → Editar → Deletar

**Características**:
- Mais lentos
- Mais frágeis
- Testam comportamento real do app

## Priorização de Testes

### Alta Prioridade (Crítico)

1. **Mappers** (100% cobertura)
   - Garantem integridade de dados
   - Fáceis de testar
   - Alto impacto

2. **Reducers de Features Core** (80%+ cobertura)
   - ProfileFeature
   - TicketsListFeature
   - EventsFeature

3. **Lógica de Negócio Complexa**
   - Sincronização de dados
   - Transformações complexas
   - Validações

### Média Prioridade

4. **Reducers de Features Secundárias** (70%+ cobertura)
   - NegotiationsListFeature
   - VerificationFeature
   - SellerProfileFeature

5. **Helpers e Utilities** (70%+ cobertura)
   - Funções de formatação
   - Transformações de dados
   - Validadores

### Baixa Prioridade

6. **Views** (Opcional)
   - Snapshot tests se necessário
   - Testes de acessibilidade

7. **Componentes UI** (Opcional)
   - Testes de renderização
   - Testes de interação

## Cobertura de Código

### Metas por Camada

| Camada | Meta de Cobertura | Prioridade |
|--------|-------------------|------------|
| Data (Mappers) | 100% | Crítica |
| Presentation (Reducers) | 80%+ | Alta |
| Domain (Helpers) | 70%+ | Média |
| Design System | 60%+ | Baixa |
| Views | Opcional | Baixa |

### Como Medir

```bash
# Xcode
Product → Scheme → Edit Scheme → Test → Options → Code Coverage ✅

# Terminal
xcodebuild test -scheme SocialApp -enableCodeCoverage YES
```

## Ferramentas

### Swift Testing

Framework nativo do Swift para testes.

**Vantagens**:
- Sintaxe moderna
- Type-safe
- Integração nativa com Swift
- Suporte a async/await

**Uso**:
```swift
import Testing

@Test("Descrição")
func testExample() {
  #expect(value == expected)
}
```

### TCA TestStore

Para testar Features TCA.

**Uso**:
```swift
let store = TestStore(initialState: State()) {
  Feature()
} withDependencies: {
  $0.client.method = { /* mock */ }
}
```

### Mocks

Criar mocks para dependencies.

**Localização**: `Domain/Sources/MockData.swift`

**Uso**:
```swift
extension User {
  static var mock: User { /* ... */ }
}
```

## Estrutura de Testes

### Organização

```
Data/Tests/
  └── DataMapperTests.swift

Domain/Tests/ (futuro)
  └── DomainHelperTests.swift

SocialApp/Tests/
  ├── ProfileFeatureTests.swift
  ├── TicketsListFeatureTests.swift
  ├── EventsFeatureTests.swift
  └── IntegrationTests.swift
```

### Nomenclatura

- **Arquivos**: `[Component]Tests.swift`
- **Structs**: `[Component]Tests`
- **Métodos**: `test[Scenario]()`
- **Anotações**: `@Test("Descrição clara")`

## Exemplos de Testes

### Teste de Mapper

```swift
@Test("APIUserResponse.toUser() deve mapear corretamente")
func testAPIUserResponseToUser() {
  let apiResponse = APIUserResponse(...)
  let user = apiResponse.toUser()
  
  #expect(user.id == "user-123")
  #expect(user.name == "João")
}
```

### Teste de Reducer

```swift
@Test("loadProfile deve carregar e atualizar state")
func testLoadProfile() async {
  let store = TestStore(...) withDependencies: {
    $0.profileClient.fetchProfile = { .mock }
  }
  
  await store.send(.loadProfile) {
    $0.isLoading = true
  }
  
  await store.receive(.profileResponse(.success(.mock))) {
    $0.isLoading = false
    $0.user = .mock
  }
}
```

## Executando Testes

### Xcode

- **Cmd + U**: Executar todos os testes
- **Cmd + Option + U**: Executar com coverage
- **Diamante ao lado do teste**: Executar teste específico

### Terminal

```bash
# Todos os testes
xcodebuild test -scheme SocialApp

# Com coverage
xcodebuild test -scheme SocialApp -enableCodeCoverage YES

# Teste específico
xcodebuild test -scheme SocialApp -only-testing:SocialAppTests/ProfileFeatureTests
```

## CI/CD (Futuro)

### Integração Contínua

```yaml
# .github/workflows/tests.yml (exemplo)
- name: Run Tests
  run: xcodebuild test -scheme SocialApp

- name: Generate Coverage
  run: xcodebuild test -enableCodeCoverage YES
```

## Manutenção de Testes

### Quando Atualizar

- Quando adicionar nova funcionalidade
- Quando corrigir bug (adicionar teste de regressão)
- Quando refatorar código (atualizar testes)

### Quando Remover

- Testes obsoletos (funcionalidade removida)
- Testes duplicados
- Testes que não agregam valor

## Boas Práticas

### ✅ DO

1. **Testar comportamento, não implementação**
2. **Manter testes isolados**
3. **Usar nomes descritivos**
4. **Testar edge cases**
5. **Manter testes rápidos**

### ❌ DON'T

1. **Não testar implementação interna**
2. **Não criar testes frágeis**
3. **Não ignorar erros**
4. **Não duplicar testes**
5. **Não testar frameworks (SwiftUI, TCA)**

## Referências

- [TESTING_GUIDE.md](./TESTING_GUIDE.md) - Guia detalhado
- [QA_GUIDE.md](./QA_GUIDE.md) - Guia de QA
- [Swift Testing](https://developer.apple.com/documentation/testing)
- [TCA Testing](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/testing/)

---

✅ **Estratégia de testes estabelecida**

📚 **Use esta estratégia para guiar criação de testes**

🎯 **Foco em mappers e reducers para garantir qualidade**

