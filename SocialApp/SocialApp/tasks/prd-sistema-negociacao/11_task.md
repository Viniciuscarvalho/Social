# Tarefa 11.0: Criar Feature NegotiationsList (TCA) (L)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Implementar o reducer TCA para a tela de listagem de negociações, incluindo lógica de carregamento, refresh, filtros e navegação para detalhes. A feature deve gerenciar estado de loading, erros e lista de negociações.

## Subtarefas

- [ ] 11.1 Criar `NegotiationsListFeature` com `@Reducer` macro
- [ ] 11.2 Definir `State` com propriedades necessárias (negociations, isLoading, errorMessage, etc.)
- [ ] 11.3 Definir `Action` enum com todas as ações (loadNegotiations, refresh, selectNegotiation, etc.)
- [ ] 11.4 Implementar reducer body com lógica de cada ação
- [ ] 11.5 Implementar `loadNegotiations` action com chamada ao NegotiationClient
- [ ] 11.6 Implementar `refreshNegotiations` action com pull-to-refresh
- [ ] 11.7 Implementar `selectNegotiation` action para navegação
- [ ] 11.8 Implementar tratamento de erros com AlertState
- [ ] 11.9 Adicionar lógica de filtros (opcional, se necessário)
- [ ] 11.10 Implementar computed properties úteis (ex: `unreadCount`, `hasUnread`)
- [ ] 11.11 Adicionar delegate actions para comunicação com parent feature
- [ ] 11.12 Testar reducer com diferentes cenários

## Detalhes de Implementação

### Localização
- Arquivo: `Projects/Features/Negotiations/Sources/NegotiationsListFeature.swift`
- Criar novo arquivo

### Estrutura do State

```swift
@ObservableState
public struct State: Equatable {
    public var negotiations: [Negotiation] = []
    public var isLoading: Bool = false
    public var isRefreshing: Bool = false
    public var errorMessage: String?
    public var showingErrorAlert: Bool = false
    public var selectedNegotiationId: String?
}
```

### Actions Principais

```swift
public enum Action: Equatable {
    case onAppear
    case loadNegotiations
    case negotiationsResponse(Result<[Negotiation], NetworkError>)
    case refreshRequested
    case negotiationSelected(String)
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
        case negotiationSelected(String)
    }
}
```

### Lógica do Reducer

- `onAppear`: Carrega negociações se lista estiver vazia
- `loadNegotiations`: Chama `negotiationClient.fetchMyNegotiations()`
- `negotiationsResponse`: Atualiza state com resultado ou erro
- `refreshRequested`: Recarrega lista com indicador de refresh
- `negotiationSelected`: Atualiza selectedNegotiationId e dispara delegate

### Dependências

```swift
@Dependency(\.negotiationClient) var negotiationClient
```

## Critérios de Sucesso

- [ ] Feature segue padrão TCA estabelecido no projeto
- [ ] State gerencia corretamente loading, errors e dados
- [ ] Actions cobrem todos os casos de uso necessários
- [ ] Reducer trata erros adequadamente
- [ ] Pull-to-refresh funciona corretamente
- [ ] Navegação para detalhes funciona via delegate
- [ ] Código segue padrões de outras features (TicketsListFeature)
- [ ] Build do projeto compila sem erros

## Dependências

- **9.0**: Models devem estar criados
- **10.0**: NegotiationClient deve estar implementado

## Observações

- Seguir padrão de `TicketsListFeature` como referência
- Usar `@ObservableState` para compatibilidade com SwiftUI
- Implementar delegate pattern para navegação (como em outras features)

