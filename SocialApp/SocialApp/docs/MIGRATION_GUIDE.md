# Guia de Migração de Features para Clean TCA

Este guia descreve o processo passo-a-passo para migrar Features existentes para a nova arquitetura Clean TCA com Design System.

## Visão Geral

### O que estamos migrando?

**De**: Features antigas com lógica misturada entre View e Reducer, usando tipos antigos e componentes UI customizados.

**Para**: Features organizadas com separação clara de responsabilidades, usando tipos do Domain e componentes do Design System.

### Quando migrar?

A migração deve ser feita **incrementalmente por contexto** na Task 10.0. Este guia serve como referência para todas as migrações futuras.

### Priorização

1. **Alta Prioridade**: Features core (Profile, Events, Tickets)
2. **Média Prioridade**: Features de apoio (Negotiations, Verification)
3. **Baixa Prioridade**: Features secundárias (Settings, About)

## Processo de Migração

### Fase 1: Análise (15-30 min)

#### 1.1 Inventário da Feature

Crie um checklist do que precisa ser migrado:

```markdown
## [FeatureName] - Análise

### Arquivos Atuais
- [ ] [FeatureName]Feature.swift
- [ ] [FeatureName]View.swift
- [ ] Componentes customizados: ___________
- [ ] Cells customizadas: ___________

### State Atual
- [ ] Usa tipos do Domain? (Sim/Não)
- [ ] Usa DTOs diretamente? (Sim/Não)
- [ ] Tem derived state? (Sim/Não)

### UI Atual
- [ ] Componentes customizados: ___________
- [ ] Pode usar componentes DS: ___________
- [ ] Lógica na View: ___________

### Dependencies
- [ ] Clients usados: ___________
- [ ] NetworkService direto: ___________
```

#### 1.2 Identificar Lógica na View

Procure por estes patterns que indicam lógica na View:

❌ **Lógica que deve estar no Reducer:**
```swift
// Na View
Button("Deletar") {
  Task {
    do {
      try await deleteItem(id)
      await loadItems()  // ❌ Lógica na View!
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}
```

✅ **Como deve ser:**
```swift
// Na View
Button("Deletar") {
  store.send(.deleteButtonTapped(id))
}

// No Reducer
case let .deleteButtonTapped(id):
  return .run { send in
    try await client.deleteItem(id)
    await send(.loadItems)
  }
```

#### 1.3 Identificar Componentes Customizados

Liste componentes que podem ser substituídos por Design System:

| Componente Atual | Substituir por |
|-----------------|----------------|
| CustomButton | DSButton (.dsPrimaryButton()) |
| CustomCard | DSCard |
| CustomBadge | DSBadge |
| CustomEmptyView | DSEmptyState |
| CustomLoadingView | DSLoadingIndicator |
| CustomList | DSListCell ou DSCardListCell |

### Fase 2: Refatoração do State (30-45 min)

#### 2.1 Atualizar Tipos para Domain

**Antes:**
```swift
@ObservableState
public struct State: Equatable {
  public var apiResponse: APITicketResponse?  // ❌ DTO
  public var tickets: [APITicket] = []  // ❌ DTO
}
```

**Depois:**
```swift
@ObservableState
public struct State: Equatable {
  public var ticket: Ticket?  // ✅ Domain
  public var tickets: [Ticket] = []  // ✅ Domain
}
```

#### 2.2 Adicionar Derived State

Identifique estado que pode ser computado:

**Antes:**
```swift
@ObservableState
public struct State: Equatable {
  public var tickets: [Ticket] = []
  public var activeTickets: [Ticket] = []  // ❌ Duplicação
  public var hasTickets: Bool = false  // ❌ Pode desincronizar
}
```

**Depois:**
```swift
@ObservableState
public struct State: Equatable {
  public var tickets: [Ticket] = []
  
  // ✅ Derived state
  public var activeTickets: [Ticket] {
    tickets.filter { $0.status == .available }
  }
  
  public var hasTickets: Bool {
    !tickets.isEmpty
  }
}
```

#### 2.3 Organizar Estado por Categoria

```swift
@ObservableState
public struct State: Equatable {
  // MARK: - Domain Data
  public var tickets: [Ticket] = []
  public var selectedTicket: Ticket?
  
  // MARK: - UI State
  public var isLoading = false
  public var errorMessage: String?
  
  // MARK: - Navigation State
  public var showingDetail = false
  public var showingFilters = false
  
  // MARK: - Derived State
  public var hasTickets: Bool {
    !tickets.isEmpty
  }
}
```

### Fase 3: Refatoração das Actions (20-30 min)

#### 3.1 Organizar Actions por Categoria

**Antes:**
```swift
public enum Action {
  case load
  case response(Result<[Ticket], Error>)
  case tap(UUID)
  case delete(UUID)
  case showDetail(Bool)
}
```

**Depois:**
```swift
public enum Action: Equatable {
  // MARK: - Lifecycle
  case onAppear
  case onDisappear
  
  // MARK: - Data Loading
  case loadTickets
  case ticketsResponse(Result<[Ticket], NetworkError>)
  
  // MARK: - User Interactions
  case ticketTapped(UUID)
  case deleteButtonTapped(UUID)
  case refreshRequested
  
  // MARK: - Navigation
  case setShowingDetail(Bool)
  
  // MARK: - Error Handling
  case dismissError
}
```

#### 3.2 Garantir Equatable

Certifique-se de que Action conforma com `Equatable`:

```swift
public enum Action: Equatable {  // ✅ Equatable
  case loadData
  case dataResponse(Result<Data, NetworkError>)  // NetworkError deve ser Equatable
}
```

### Fase 4: Refatoração do Reducer (45-60 min)

#### 4.1 Mover Lógica da View para Reducer

**Antes** (lógica na View):
```swift
// Na View
Button("Salvar") {
  Task {
    do {
      isLoading = true
      let result = try await saveData(item)
      item = result
      isLoading = false
      showSuccess = true
    } catch {
      errorMessage = error.localizedDescription
      isLoading = false
    }
  }
}
```

**Depois** (lógica no Reducer):
```swift
// Na View
Button("Salvar") {
  store.send(.saveButtonTapped)
}

// No Reducer
case .saveButtonTapped:
  state.isLoading = true
  state.errorMessage = nil
  return .run { [item = state.item] send in
    do {
      let result = try await client.save(item)
      await send(.saveResponse(.success(result)))
    } catch {
      let error = error as? NetworkError ?? .unknown(error.localizedDescription)
      await send(.saveResponse(.failure(error)))
    }
  }

case let .saveResponse(.success(item)):
  state.isLoading = false
  state.item = item
  state.showSuccess = true
  return .none

case let .saveResponse(.failure(error)):
  state.isLoading = false
  state.errorMessage = error.localizedDescription
  return .none
```

#### 4.2 Usar Clients ao invés de NetworkService Direto

**Antes:**
```swift
case .loadTickets:
  state.isLoading = true
  return .run { send in
    do {
      let response: APIListResponse<APITicketResponse> = try await NetworkService.shared.request(
        endpoint: "/tickets",
        method: .get
      )
      let tickets = response.data.map { /* mapear */ }
      await send(.ticketsResponse(.success(tickets)))
    } catch {
      await send(.ticketsResponse(.failure(error)))
    }
  }
```

**Depois:**
```swift
@Dependency(\.ticketsClient) var ticketsClient

case .loadTickets:
  state.isLoading = true
  state.errorMessage = nil
  return .run { send in
    do {
      let tickets = try await ticketsClient.fetchTickets()
      await send(.ticketsResponse(.success(tickets)))
    } catch {
      let networkError = error as? NetworkError ?? .unknown(error.localizedDescription)
      await send(.ticketsResponse(.failure(networkError)))
    }
  }
```

### Fase 5: Refatoração da View (60-90 min)

#### 5.1 Substituir Componentes Customizados por DS

**Antes:**
```swift
Button("Comprar") {
  store.send(.buyButtonTapped)
}
.font(.system(size: 16, weight: .bold))
.foregroundColor(.white)
.padding(.horizontal, 20)
.padding(.vertical, 12)
.background(Color.blue.gradient)
.cornerRadius(12)
```

**Depois:**
```swift
Button("Comprar") {
  store.send(.buyButtonTapped)
}
.dsPrimaryButton()
```

#### 5.2 Usar Estados do Design System

**Antes:**
```swift
if store.isLoading {
  ProgressView()
} else if store.tickets.isEmpty {
  VStack {
    Image(systemName: "ticket")
    Text("Sem ingressos")
  }
} else {
  // Lista
}
```

**Depois:**
```swift
if store.isLoading {
  DSFullScreenLoading(message: "Carregando ingressos...")
} else if store.tickets.isEmpty {
  DSEmptyState(
    icon: "ticket.fill",
    title: "Sem ingressos",
    message: "Adicione seus primeiros ingressos para vê-los aqui"
  )
} else {
  // Lista
}
```

#### 5.3 Organizar View em Subviews

**Antes** (tudo em um body):
```swift
var body: some View {
  ScrollView {
    if store.isLoading {
      ProgressView()
    } else {
      VStack {
        ForEach(store.tickets) { ticket in
          // 50 linhas de UI...
        }
      }
    }
  }
}
```

**Depois** (organizado):
```swift
var body: some View {
  contentView
    .onAppear { store.send(.onAppear) }
}

@ViewBuilder
private var contentView: some View {
  if store.isLoading {
    loadingView
  } else if store.hasTickets {
    ticketsListView
  } else {
    emptyView
  }
}

@ViewBuilder
private var loadingView: some View {
  DSLoadingIndicator(size: .large)
}

@ViewBuilder
private var ticketsListView: some View {
  ScrollView {
    LazyVStack(spacing: DSSpacing.m) {
      ForEach(store.tickets) { ticket in
        TicketCell(ticket: ticket) {
          store.send(.ticketTapped(ticket.id))
        }
      }
    }
  }
}

@ViewBuilder
private var emptyView: some View {
  DSEmptyState(
    icon: "ticket.fill",
    title: "Sem ingressos"
  )
}
```

### Fase 6: Atualizar Client (30-45 min)

#### 6.1 Usar DTOs da Camada Data

**Antes:**
```swift
import Foundation

struct TicketsClient {
  var fetchTickets: () async throws -> [Ticket]
}

extension TicketsClient {
  static let live = Self(
    fetchTickets: {
      let response: [Ticket] = try await NetworkService.shared.request(
        endpoint: "/tickets",
        method: .get
      )
      return response
    }
  )
}
```

**Depois:**
```swift
import Dependencies
import Data
import Domain

struct TicketsClient {
  var fetchTickets: @Sendable () async throws -> [Ticket]
  var deleteTicket: @Sendable (String) async throws -> Void
}

extension TicketsClient: DependencyKey {
  static let liveValue = Self(
    fetchTickets: {
      let networkService = NetworkService.shared
      let response: APIListResponse<APITicketResponse> = try await networkService.request(
        endpoint: "/tickets",
        method: .get
      )
      // ✅ Mapear DTOs para Domain
      return response.data.map { $0.toTicket() }
    },
    deleteTicket: { id in
      let networkService = NetworkService.shared
      let _: APIErrorResponse = try await networkService.request(
        endpoint: "/tickets/\(id)",
        method: .delete
      )
    }
  )
  
  static let testValue = Self(
    fetchTickets: { [.mock] },
    deleteTicket: { _ in }
  )
}

extension DependencyValues {
  var ticketsClient: TicketsClient {
    get { self[TicketsClient.self] }
    set { self[TicketsClient.self] = newValue }
  }
}
```

### Fase 7: Testes (30-45 min)

#### 7.1 Checklist de Testes Manuais

- [ ] Compilar sem erros
- [ ] Testar loading state
- [ ] Testar empty state
- [ ] Testar error state
- [ ] Testar data state (lista populada)
- [ ] Testar navegação (sheets, modals)
- [ ] Testar pull-to-refresh
- [ ] Testar interações (tap, swipe, etc.)
- [ ] Testar light mode
- [ ] Testar dark mode

#### 7.2 Testes Comuns

Após migração, teste cenários comuns:

1. **Fluxo Feliz**: Load → Success → Display data
2. **Erro de Rede**: Load → Network error → Display error → Retry
3. **Empty State**: Load → Success com array vazio → Display empty
4. **Navegação**: Tap item → Sheet opens → Dismiss → Back to list

### Fase 8: Limpeza e Documentação (15-20 min)

#### 8.1 Remover Código Antigo

- [ ] Remover componentes customizados não utilizados
- [ ] Remover imports não necessários
- [ ] Remover código comentado
- [ ] Remover arquivos não utilizados

#### 8.2 Adicionar Documentação

```swift
/// Feature responsável por gerenciar a lista de ingressos do usuário.
///
/// **Responsabilidades:**
/// - Carregar ingressos do usuário
/// - Permitir filtragem e busca
/// - Navegação para detalhes do ingresso
///
/// **Dependencies:**
/// - `ticketsClient`: Acesso aos dados de ingressos
/// - `favoritesClient`: Gerenciamento de favoritos
@Reducer
public struct TicketsListFeature {
  // ...
}
```

## Checklist Completo de Migração

### Pre-Migration
- [ ] Analisar feature atual
- [ ] Identificar lógica na View
- [ ] Identificar componentes customizados
- [ ] Mapear para componentes DS
- [ ] Estimar tempo de migração

### State
- [ ] Migrar para tipos do Domain
- [ ] Adicionar derived state
- [ ] Organizar por categoria
- [ ] Adicionar @ObservableState

### Actions
- [ ] Organizar por categoria
- [ ] Adicionar Equatable
- [ ] Renomear para convenção consistente
- [ ] Adicionar actions de lifecycle

### Reducer
- [ ] Mover lógica da View para Reducer
- [ ] Usar @Dependency para clients
- [ ] Adicionar proper error handling
- [ ] Usar Result types

### Views
- [ ] Substituir componentes por DS
- [ ] Organizar em subviews
- [ ] Adicionar loading/empty/error states
- [ ] Remover lógica de negócio

### Client
- [ ] Mover para SocialApp/Sources/Dependencies
- [ ] Usar DTOs da camada Data
- [ ] Mapear para Domain
- [ ] Adicionar testValue

### Testing
- [ ] Compilar sem erros
- [ ] Testar todos os fluxos
- [ ] Testar em light/dark mode
- [ ] Verificar navegação

### Documentation
- [ ] Adicionar comentários
- [ ] Atualizar README (se existir)
- [ ] Documentar casos especiais

## Estimativas de Tempo

### Feature Pequena (ex: Settings)
- Análise: 15 min
- Migração: 1-2 horas
- Testes: 30 min
- **Total: 2-3 horas**

### Feature Média (ex: Profile, Tickets)
- Análise: 30 min
- Migração: 3-4 horas
- Testes: 1 hora
- **Total: 4-5 horas**

### Feature Grande (ex: Events, Negotiations)
- Análise: 45 min
- Migração: 5-8 horas
- Testes: 1-2 horas
- **Total: 7-10 horas**

## Troubleshooting

### Erro: "Type 'Action' does not conform to protocol 'Equatable'"

**Solução**: Certifique-se de que todos os associated values são Equatable:

```swift
public enum Action: Equatable {
  case loadData
  case dataResponse(Result<[Ticket], NetworkError>)  // NetworkError deve ser Equatable
}
```

### Erro: "Cannot find 'toDomain' in scope"

**Solução**: Importe a camada Data:

```swift
import Data  // ✅ Contém os mappers toDomain()
```

### Problema: View não atualiza quando State muda

**Solução**: Certifique-se de usar @ObservableState:

```swift
@ObservableState  // ✅ Necessário!
public struct State: Equatable {
  public var tickets: [Ticket] = []
}
```

### Problema: Client não disponível no Reducer

**Solução**: Registre o client em DependencyValues:

```swift
extension DependencyValues {
  var myClient: MyClient {
    get { self[MyClient.self] }
    set { self[MyClient.self] = newValue }
  }
}
```

## Referências

- [PRESENTATION_LAYER.md](./PRESENTATION_LAYER.md) - Padrões detalhados
- [FEATURE_TEMPLATE.md](./FEATURE_TEMPLATE.md) - Template de Feature
- [Design System README](../DesignSystem/README.md) - Componentes DS

## Suporte

Para dúvidas ou problemas durante a migração:
1. Consulte os documentos de referência acima
2. Veja exemplos em Features já migradas
3. Siga o template de Feature

---

✅ **Use este guia para migrar Features de forma consistente e eficiente**

📋 **Próxima migração**: Task 10.0 - Migração Incremental por Contexto

