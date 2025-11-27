# Padrões de Navegação Global

## Visão Geral

A navegação no app é gerenciada centralmente pelo **SocialAppFeature**, que atua como composition root e orquestra todos os fluxos de navegação entre Features.

## Arquitetura de Navegação

### Composition Root

O **SocialAppFeature** é responsável por:
- Gerenciar estado global de navegação
- Orquestrar transições entre Features
- Manter sincronização entre Features
- Gerenciar tabs e navigation stack

### Estrutura de Navegação

```
SocialAppFeature (Root)
├── AuthFeature (Autenticação)
├── VerificationFeature (Verificação - opcional)
├── MainTabView
│   ├── HomeTab
│   │   └── HomeFeature
│   ├── TicketsTab
│   │   └── TicketsListFeature
│   ├── AddTicketTab (Action)
│   ├── NegotiationsTab
│   │   └── NegotiationsListFeature
│   └── ProfileTab
│       └── ProfileFeature
└── Detail Views (Modals/Sheets)
    ├── EventDetailFeature
    ├── TicketDetailFeature
    ├── SellerProfileFeature
    └── SellersListFeature
```

## Tipos de Navegação

### 1. Tab Navigation

Navegação principal entre seções do app usando `AppTab`.

```swift
public enum AppTab: Hashable, CaseIterable {
  case home
  case tickets
  case addTicket  // Action, não uma tab real
  case negotiations
  case profile
}
```

**Uso:**
```swift
// No SocialAppFeature.State
public var selectedTab: AppTab = .home

// Action
case tabSelected(AppTab)

// No Reducer
case let .tabSelected(tab):
  state.selectedTab = tab
  return .none
```

### 2. Modal/Sheet Navigation

Para telas de detalhes que aparecem sobre o conteúdo principal.

**Padrão:**
```swift
// State
public var selectedEventId: UUID?
public var selectedTicketId: UUID?
public var selectedSellerId: UUID?
public var showingAddTicket = false

// Actions
case navigateToEventDetail(UUID)
case navigateToTicketDetail(UUID)
case navigateToSellerProfile(UUID)
case dismissEventNavigation(UUID?)
case dismissTicketNavigation(UUID?)
case dismissSellerNavigation(UUID?)
```

**Uso:**
```swift
// Navegar
store.send(.navigateToEventDetail(eventId))

// Dismiss
store.send(.dismissEventNavigation(eventId))
```

### 3. Navigation Stack (iOS 16+)

Para navegação hierárquica dentro de uma Feature.

```swift
// State
public var navigationPath = NavigationPath()

// Uso com NavigationStack
NavigationStack(path: $store.navigationPath) {
  // Content
}
```

### 4. Deep Linking (Estrutura Futura)

Preparação para deep linking (não implementado ainda, mas estrutura pronta):

```swift
// State
public var deepLink: DeepLink?

public enum DeepLink {
  case event(UUID)
  case ticket(UUID)
  case seller(UUID)
  case negotiation(String)
  case profile(String)
}

// Action
case handleDeepLink(DeepLink)
```

## Padrões de Navegação

### Padrão 1: Navegação Simples (Tab)

**Quando usar**: Navegação entre seções principais do app.

```swift
// Action
case tabSelected(AppTab)

// Reducer
case let .tabSelected(tab):
  state.selectedTab = tab
  return .none

// View
Tab(selection: $store.selectedTab) {
  // Tabs
}
```

### Padrão 2: Navegação para Detalhe (Modal)

**Quando usar**: Abrir detalhes de um item (evento, ticket, seller).

```swift
// 1. Definir state opcional
public var eventDetailFeature: EventDetailFeature.State?

// 2. Action de navegação
case navigateToEventDetail(UUID)

// 3. Reducer
case let .navigateToEventDetail(eventId):
  state.selectedEventId = eventId
  state.eventDetailFeature = EventDetailFeature.State(eventId: eventId)
  return .none

// 4. Dismiss
case let .dismissEventNavigation(eventId):
  state.selectedEventId = nil
  state.eventDetailFeature = nil
  return .none

// 5. View
.sheet(item: $store.eventDetailFeature) { feature in
  EventDetailView(store: Store(initialState: feature) { EventDetailFeature() })
}
```

### Padrão 3: Navegação com Dados Compartilhados

**Quando usar**: Navegação que precisa passar dados entre Features.

```swift
// 1. State com dados
public var selectedEventId: UUID?
public var eventDetailFeature: EventDetailFeature.State?

// 2. Action com dados
case navigateToEventDetail(UUID)

// 3. Reducer - inicializar Feature com dados
case let .navigateToEventDetail(eventId):
  state.selectedEventId = eventId
  // Carregar dados e inicializar Feature
  return .run { send in
    let event = try await eventsClient.fetchEvent(id: eventId)
    await send(.eventDetailLoaded(event))
  }

case let .eventDetailLoaded(event):
  state.eventDetailFeature = EventDetailFeature.State(event: event)
  return .none
```

### Padrão 4: Navegação Cross-Feature

**Quando usar**: Navegação de uma Feature para outra (ex: de Ticket para Negotiation).

```swift
// 1. Usar delegate pattern
// No TicketDetailFeature
public enum Action {
  case delegate(Delegate)
  
  public enum Delegate {
    case negotiationStarted(String)  // negotiationId
    case navigateToExistingNegotiation(String)
  }
}

// 2. No SocialAppFeature
case let .ticketDetailFeature(.delegate(.negotiationStarted(negotiationId))):
  state.selectedNegotiationId = negotiationId
  state.selectedTab = .negotiations
  return .none
```

### Padrão 5: Navegação com Sincronização

**Quando usar**: Navegação que precisa sincronizar dados entre Features.

```swift
// Exemplo: Criar ticket e sincronizar em todas as listas
case let .addTicket(.publishTicketResponse(.success(ticket))):
  state.showingAddTicket = false
  return .run { send in
    // Sincronizar em todas as Features relevantes
    await send(.ticketsListFeature(.syncTicketCreated(ticket)))
    await send(.profileFeature(.refreshMyTickets))
  }
```

## Fluxos Principais

### Fluxo 1: Home → Event Detail → Tickets

```
1. Usuário toca em evento na Home
   → Action: homeFeature(.eventSelected(eventId))
   
2. SocialAppFeature recebe
   → Action: navigateToEventDetail(eventId)
   → State: selectedEventId = eventId
   
3. EventDetailView é apresentado (sheet)
   
4. Usuário toca "Ver Ingressos"
   → Action: eventDetailFeature(.viewTicketsTapped)
   
5. SocialAppFeature recebe
   → Action: navigateToEventTickets(eventId)
   → State: selectedTab = .tickets
   → State: selectedEventId = nil (fecha modal)
   → Action: ticketsListFeature(.filterByEvent(eventId))
```

### Fluxo 2: Tickets → Ticket Detail → Negotiation

```
1. Usuário toca em ticket
   → Action: ticketsListFeature(.ticketSelected(ticketId))
   
2. SocialAppFeature recebe
   → Action: navigateToTicketDetail(ticketId)
   → State: selectedTicketId = ticketId
   
3. TicketDetailView é apresentado (sheet)
   
4. Usuário toca "Iniciar Negociação"
   → Action: ticketDetailFeature(.startNegotiationTapped)
   
5. TicketDetailFeature cria negociação
   → Action: delegate(.negotiationStarted(negotiationId))
   
6. SocialAppFeature recebe
   → Action: navigateToNegotiation(negotiationId)
   → State: selectedTab = .negotiations
   → State: selectedNegotiationId = negotiationId
```

### Fluxo 3: Profile → My Tickets → Ticket Detail

```
1. Usuário toca "Meus Ingressos" no Profile
   → Action: profileFeature(.myTicketsTapped)
   → State: showingMyTickets = true
   
2. MyTicketsView é apresentado (sheet)
   
3. Usuário toca em ticket
   → Action: myTicketsFeature(.ticketSelected(ticketId))
   
4. SocialAppFeature recebe
   → Action: navigateToTicketDetail(ticketId)
   → State: selectedTicketId = ticketId
   → State: showingMyTickets = false (fecha sheet anterior)
```

## Transições de Navegação

### Usando Design System Transitions

```swift
// Sheet com transição customizada
.sheet(item: $store.eventDetailFeature) { feature in
  EventDetailView(store: Store(initialState: feature) { EventDetailFeature() })
    .dsTransition(.slideFromBottom)
}

// Fullscreen cover
.fullScreenCover(isPresented: $store.showingAddTicket) {
  AddTicketView(store: store.addTicket)
    .dsTransition(.scaleWithFade)
}
```

### Transições Recomendadas

| Tipo de Navegação | Transição Recomendada |
|-------------------|----------------------|
| Tab change | `.fade` |
| Modal/Sheet | `.slideFromBottom` |
| Fullscreen | `.scaleWithFade` |
| Detail view | `.slideFromTrailing` |
| Navigation stack | `.move(edge: .trailing)` |

## Boas Práticas

### ✅ DO

1. **Usar Actions específicas para navegação**
   ```swift
   case navigateToEventDetail(UUID)  // ✅ BOM
   ```

2. **Manter state de navegação no SocialAppFeature**
   ```swift
   public var selectedEventId: UUID?  // ✅ BOM
   ```

3. **Usar delegate pattern para cross-feature navigation**
   ```swift
   case delegate(.negotiationStarted(String))  // ✅ BOM
   ```

4. **Sincronizar dados ao navegar**
   ```swift
   return .run { send in
     await send(.ticketsListFeature(.syncTicketCreated(ticket)))
   }
   ```

5. **Limpar state ao dismiss**
   ```swift
   case let .dismissEventNavigation(eventId):
     state.selectedEventId = nil
     state.eventDetailFeature = nil
   ```

### ❌ DON'T

1. **Não navegar diretamente de uma Feature para outra**
   ```swift
   // ❌ RUIM - Feature conhece outra Feature
   store.send(.otherFeature(.action))
   
   // ✅ BOM - Usa delegate
   store.send(.delegate(.navigateToOtherFeature))
   ```

2. **Não manter state de navegação em Features filhas**
   ```swift
   // ❌ RUIM
   public var showingDetail = false  // Em Feature filha
   
   // ✅ BOM
   public var selectedItemId: UUID?  // Em SocialAppFeature
   ```

3. **Não esquecer de limpar state**
   ```swift
   // ❌ RUIM - Memory leak
   case .dismiss:
     // Não limpa state
   
   // ✅ BOM
   case .dismiss:
     state.selectedItemId = nil
     state.detailFeature = nil
   ```

## Helpers de Navegação

### Navigation Helper (Futuro)

```swift
// Em SocialApp/Sources/Navigation/NavigationHelper.swift
public struct NavigationHelper {
  static func navigateToEvent(
    eventId: UUID,
    store: StoreOf<SocialAppFeature>
  ) {
    store.send(.navigateToEventDetail(eventId))
  }
  
  static func navigateToTicket(
    ticketId: UUID,
    store: StoreOf<SocialAppFeature>
  ) {
    store.send(.navigateToTicketDetail(ticketId))
  }
}
```

## Deep Linking (Estrutura Futura)

### Preparação para Deep Linking

```swift
// State
public var deepLink: DeepLink?

public enum DeepLink: Equatable {
  case event(UUID)
  case ticket(UUID)
  case seller(UUID)
  case negotiation(String)
  case profile(String)
  
  // Parser de URL
  static func from(url: URL) -> DeepLink? {
    // Implementar parsing
  }
}

// Action
case handleDeepLink(DeepLink)

// Reducer
case let .handleDeepLink(deepLink):
  switch deepLink {
  case let .event(id):
    return .run { send in
      await send(.navigateToEventDetail(id))
    }
  // ... outros casos
  }
```

## Testes de Navegação

### Testando Navegação

```swift
@MainActor
func testNavigateToEventDetail() async {
  let store = TestStore(initialState: SocialAppFeature.State()) {
    SocialAppFeature()
  }
  
  await store.send(.navigateToEventDetail(eventId)) {
    $0.selectedEventId = eventId
    $0.eventDetailFeature = EventDetailFeature.State(eventId: eventId)
  }
}
```

## Referências

- [PRESENTATION_LAYER.md](./PRESENTATION_LAYER.md) - Padrões de Presentation
- [Design System - Transitions](../DesignSystem/README.md#dsviewtransitions) - Transições disponíveis
- [TCA Navigation](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/navigation/) - Documentação oficial

---

✅ **Padrões de navegação estabelecidos para o projeto**

📚 **Use este guia como referência para implementar navegação entre Features**

🎯 **Próxima implementação**: Helpers de navegação e documentação de fluxos específicos

