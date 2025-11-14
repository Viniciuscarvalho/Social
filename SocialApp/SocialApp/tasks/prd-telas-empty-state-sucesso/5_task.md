## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>features/tickets</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>2.0</dependencies>
</task_context>

# Tarefa 5.0: Implementar tabs e empty state de Meus Ingressos em MyTicketsView

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar tabs "Upcoming" e "Past Ticket" em `MyTicketsView` e atualizar o empty state para exibir conforme o design das imagens, incluindo tabs, ícone de ingresso, mensagem e botão "Browse Events".

<requirements>
- Atualizar `Projects/Features/TicketsList/Sources/MyTicketsView.swift`
- Adicionar tabs "Upcoming" e "Past Ticket" acima do conteúdo
- Tab ativa deve ter fundo roxo (AppColors.primary) e texto branco
- Tab inativa deve ter fundo claro e texto cinza
- Empty state deve mostrar título dinâmico baseado na tab selecionada
- Ícone: `ticket.fill` (amarelo/preto conforme design)
- Mensagem explicativa (localizada)
- Botão "Browse Events" que navega para eventos
- Atualizar MyTicketsFeature para gerenciar estado da tab
</requirements>

## Subtarefas

- [ ] 5.1 Adicionar enum TicketTab (upcoming, past) no MyTicketsFeature
- [ ] 5.2 Adicionar state selectedTab no MyTicketsFeature.State
- [ ] 5.3 Implementar tabs UI em MyTicketsView
- [ ] 5.4 Atualizar empty state com tabs e layout conforme design
- [ ] 5.5 Implementar filtro de ingressos baseado na tab selecionada
- [ ] 5.6 Adicionar chaves de localização no String Catalog
- [ ] 5.7 Implementar botão "Browse Events" com navegação
- [ ] 5.8 Testar visualmente no simulador
- [ ] 5.9 Testar navegação e filtros

## Detalhes de Implementação

**Adicionar ao MyTicketsFeature**:
```swift
public enum TicketTab: Equatable {
    case upcoming
    case past
}

@ObservableState
public struct State: Equatable {
    public var selectedTab: TicketTab = .upcoming
    // ... resto do state
}
```

**Tabs UI**:
```swift
private var tabsView: some View {
    HStack(spacing: 12) {
        TabButton(title: "Upcoming", isSelected: store.selectedTab == .upcoming) {
            store.send(.tabChanged(.upcoming))
        }
        TabButton(title: "Past Ticket", isSelected: store.selectedTab == .past) {
            store.send(.tabChanged(.past))
        }
    }
    .padding(.horizontal, 20)
}

private func TabButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? AppColors.primary : Color(.systemGray6))
            .cornerRadius(20)
    }
}
```

**Empty State atualizado**:
- Mostrar tabs acima do empty state
- Título dinâmico: "Nenhum Ingresso Futuro" ou "Nenhum Ingresso Passado"
- Ícone de ingresso estilizado conforme design
- Botão "Browse Events" com navegação

**Filtro de ingressos**:
```swift
private var filteredTickets: [Ticket] {
    switch store.selectedTab {
    case .upcoming:
        return store.myTickets.filter { $0.validUntil > Date() }
    case .past:
        return store.myTickets.filter { $0.validUntil <= Date() }
    }
}
```

## Critérios de Sucesso

- Tabs implementadas e funcionando corretamente
- Tab ativa destacada visualmente (roxo)
- Empty state exibido corretamente quando não há ingressos
- Título do empty state muda baseado na tab selecionada
- Filtro de ingressos funciona corretamente (upcoming vs past)
- Botão "Browse Events" navega para eventos
- Layout visualmente alinhado com o design das imagens

## Arquivos relevantes
- `Projects/Features/TicketsList/Sources/MyTicketsView.swift` (linhas 62-81 - emptyStateView)
- `Projects/Features/TicketsList/Sources/MyTicketsFeature.swift` (adicionar state e actions)
- `SocialApp/Resources/Localizable.xcstrings` (chaves de localização)

