# Guia de Navegação para Desenvolvedores

Este guia prático ajuda desenvolvedores a implementar navegação entre Features seguindo os padrões estabelecidos.

## Quick Start

### 1. Navegação Simples (Tab)

```swift
// Em qualquer Feature
store.send(.delegate(.navigateToTab(.tickets)))

// No SocialAppFeature
case let .homeFeature(.delegate(.navigateToTab(tab))):
  state.selectedTab = tab
  return .none
```

### 2. Navegação para Detalhe (Modal)

```swift
// 1. Adicionar state em SocialAppFeature.State
public var myDetailFeature: MyDetailFeature.State?

// 2. Adicionar action
case navigateToMyDetail(UUID)

// 3. Implementar reducer
case let .navigateToMyDetail(id):
  state.myDetailFeature = MyDetailFeature.State(id: id)
  return .none

// 4. Adicionar sheet na View
.sheet(item: $store.myDetailFeature) { feature in
  MyDetailView(store: Store(initialState: feature) { MyDetailFeature() })
}
```

### 3. Navegação Cross-Feature (Delegate Pattern)

```swift
// 1. Na Feature origem (ex: TicketDetailFeature)
public enum Action {
  case delegate(Delegate)
  
  public enum Delegate: Equatable {
    case navigateToOtherFeature(String)
  }
}

// 2. No reducer, quando necessário
case .someAction:
  return .run { send in
    await send(.delegate(.navigateToOtherFeature(id)))
  }

// 3. No SocialAppFeature
case let .ticketDetailFeature(.delegate(.navigateToOtherFeature(id))):
  // Implementar navegação
  return .none
```

## Templates

### Template: Navegação para Detalhe

```swift
// MARK: - State (SocialAppFeature.State)
public var myDetailFeature: MyDetailFeature.State?

// MARK: - Action (SocialAppFeature.Action)
case navigateToMyDetail(UUID)
case dismissMyDetail

// MARK: - Reducer (SocialAppFeature)
case let .navigateToMyDetail(id):
  state.myDetailFeature = MyDetailFeature.State(id: id)
  return .none

case .dismissMyDetail:
  state.myDetailFeature = nil
  return .none

// MARK: - View (SocialAppView)
.sheet(item: $store.myDetailFeature) { feature in
  MyDetailView(store: Store(initialState: feature) { MyDetailFeature() })
    .dsTransition(.slideFromBottom)
}
```

### Template: Navegação Cross-Feature

```swift
// MARK: - Na Feature Origem
public enum Action {
  case delegate(Delegate)
  
  public enum Delegate: Equatable {
    case navigateToTarget(String)
  }
}

// No reducer
case .triggerAction:
  return .run { send in
    // Lógica...
    await send(.delegate(.navigateToTarget(id)))
  }

// MARK: - No SocialAppFeature
case let .sourceFeature(.delegate(.navigateToTarget(id))):
  state.targetFeature = TargetFeature.State(id: id)
  return .none
```

## Checklist de Implementação

### Navegação para Detalhe

- [ ] Adicionar state opcional em `SocialAppFeature.State`
- [ ] Adicionar action `navigateToMyDetail(UUID)`
- [ ] Adicionar action `dismissMyDetail`
- [ ] Implementar reducer para navegação
- [ ] Implementar reducer para dismiss
- [ ] Adicionar sheet/fullscreenCover na View
- [ ] Adicionar transição do Design System
- [ ] Testar navegação
- [ ] Testar dismiss
- [ ] Verificar limpeza de state

### Navegação Cross-Feature

- [ ] Criar enum `Delegate` na Feature origem
- [ ] Adicionar `case delegate(Delegate)` nas Actions
- [ ] Implementar delegate no reducer quando necessário
- [ ] Adicionar handler no `SocialAppFeature`
- [ ] Implementar navegação no handler
- [ ] Testar fluxo completo
- [ ] Verificar sincronização de dados (se necessário)

## Exemplos Práticos

### Exemplo 1: Navegar de Home para Event Detail

```swift
// 1. Em HomeFeature
case eventTapped(UUID)

// 2. No reducer
case let .eventTapped(eventId):
  return .run { send in
    await send(.delegate(.navigateToEvent(eventId)))
  }

// 3. Delegate
public enum Delegate: Equatable {
  case navigateToEvent(UUID)
}

// 4. No SocialAppFeature
case let .homeFeature(.delegate(.navigateToEvent(eventId))):
  state.selectedEventId = eventId
  state.eventDetailFeature = EventDetailFeature.State(eventId: eventId)
  return .none

// 5. Na View
.sheet(item: $store.eventDetailFeature) { feature in
  EventDetailView(store: Store(initialState: feature) { EventDetailFeature() })
    .dsTransition(.slideFromBottom)
}
```

### Exemplo 2: Navegar de Ticket para Negotiation

```swift
// 1. Em TicketDetailFeature
case startNegotiationTapped

// 2. No reducer
case .startNegotiationTapped:
  return .run { send in
    let negotiation = try await negotiationClient.create(ticketId: state.ticketId)
    await send(.delegate(.negotiationStarted(negotiation.id)))
  }

// 3. Delegate
public enum Delegate: Equatable {
  case negotiationStarted(String)
}

// 4. No SocialAppFeature
case let .ticketDetailFeature(.delegate(.negotiationStarted(negotiationId))):
  state.selectedNegotiationId = negotiationId
  state.selectedTab = .negotiations
  state.selectedTicketId = nil  // Fecha modal de ticket
  return .none
```

### Exemplo 3: Navegação com Sincronização

```swift
// Quando criar ticket, sincronizar em todas as Features
case let .addTicket(.publishTicketResponse(.success(ticket))):
  state.showingAddTicket = false
  return .run { send in
    // Sincronizar em todas as listas
    await send(.ticketsListFeature(.syncTicketCreated(ticket)))
    
    // Se for do usuário, atualizar perfil
    if ticket.sellerId == state.currentUser?.id {
      await send(.profileFeature(.refreshMyTickets))
    }
  }
```

## Transições Recomendadas

| Tipo | Transição | Exemplo |
|------|-----------|---------|
| Sheet/Modal | `.slideFromBottom` | EventDetail, TicketDetail |
| Fullscreen | `.scaleWithFade` | AddTicket, Authentication |
| Tab Change | `.fade` | Home → Tickets |
| Navigation Stack | `.move(edge: .trailing)` | Settings → Privacy |
| Cross-Feature | `.slideFromBottom` | Ticket → Negotiation |

## Boas Práticas

### ✅ DO

1. **Sempre limpar state ao dismiss**
   ```swift
   case .dismiss:
     state.detailFeature = nil  // ✅
   ```

2. **Usar delegate pattern para cross-feature**
   ```swift
   case .delegate(.navigateToOther)  // ✅
   ```

3. **Sincronizar dados ao navegar**
   ```swift
   return .run { send in
     await send(.otherFeature(.syncData(data)))  // ✅
   }
   ```

4. **Usar transições do Design System**
   ```swift
   .dsTransition(.slideFromBottom)  // ✅
   ```

5. **Documentar fluxos complexos**
   ```swift
   // Navega para negociação e fecha ticket detail  // ✅
   ```

### ❌ DON'T

1. **Não navegar diretamente entre Features**
   ```swift
   // ❌ RUIM
   store.send(.otherFeature(.action))
   
   // ✅ BOM
   store.send(.delegate(.navigateToOther))
   ```

2. **Não esquecer de limpar state**
   ```swift
   // ❌ RUIM - Memory leak
   case .dismiss:
     // Não limpa
   
   // ✅ BOM
   case .dismiss:
     state.detailFeature = nil
   ```

3. **Não usar NavigationLink diretamente**
   ```swift
   // ❌ RUIM - Não funciona bem com TCA
   NavigationLink("Detail", destination: DetailView())
   
   // ✅ BOM - Usa actions
   Button("Detail") {
     store.send(.navigateToDetail(id))
   }
   ```

## Troubleshooting

### Problema: Sheet não fecha

**Solução**: Verificar se state está sendo limpo
```swift
case .dismiss:
  state.detailFeature = nil  // ✅ Necessário
```

### Problema: Navegação não funciona

**Solução**: Verificar se action está sendo tratada no reducer
```swift
case let .navigateToDetail(id):
  state.detailFeature = MyDetailFeature.State(id: id)  // ✅
  return .none
```

### Problema: Dados não sincronizam

**Solução**: Usar sync actions
```swift
return .run { send in
  await send(.otherFeature(.syncData(data)))  // ✅
}
```

## Referências

- [NAVIGATION_PATTERNS.md](./NAVIGATION_PATTERNS.md) - Padrões técnicos
- [NAVIGATION_FLOWS.md](./NAVIGATION_FLOWS.md) - Fluxos principais
- [PRESENTATION_LAYER.md](./PRESENTATION_LAYER.md) - Padrões de Presentation
- [Design System - Transitions](../DesignSystem/README.md#dsviewtransitions)

---

✅ **Guia prático para implementar navegação**

📚 **Use este guia ao implementar novas Features ou navegação**

🎯 **Quick reference para padrões comuns**

