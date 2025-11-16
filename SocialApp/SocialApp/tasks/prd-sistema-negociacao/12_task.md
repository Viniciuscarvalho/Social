# Tarefa 12.0: Criar UI de NegotiationsList (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Implementar a view SwiftUI da lista de negociações com cards que mostram informações resumidas de cada negociação, incluindo foto, nome, status, contador de perguntas e badge visual para itens não lidos.

## Subtarefas

- [ ] 12.1 Criar `NegotiationsListView` com estrutura básica
- [ ] 12.2 Implementar lista com `List` ou `ScrollView` + `LazyVStack`
- [ ] 12.3 Criar componente `NegotiationCard` para exibir cada negociação
- [ ] 12.4 Implementar exibição de foto e nome da outra pessoa
- [ ] 12.5 Implementar badge de status da negociação
- [ ] 12.6 Implementar contador de perguntas respondidas vs total
- [ ] 12.7 Implementar badge visual para itens não lidos
- [ ] 12.8 Implementar pull-to-refresh
- [ ] 12.9 Implementar empty state quando não houver negociações
- [ ] 12.10 Implementar loading state
- [ ] 12.11 Implementar error state com retry
- [ ] 12.12 Adicionar navegação para detalhes ao tocar no card
- [ ] 12.13 Aplicar design system existente (cores, tipografia, espaçamentos)

## Detalhes de Implementação

### Localização
- Arquivo: `Projects/Features/Negotiations/Sources/NegotiationsListView.swift`
- Criar novo arquivo

### Estrutura da View

```swift
public struct NegotiationsListView: View {
    @Bindable var store: StoreOf<NegotiationsListFeature>
    
    public var body: some View {
        // Lista de negociações
    }
}
```

### Componente NegotiationCard

Deve exibir:
- Avatar/foto da outra pessoa (comprador ou vendedor)
- Nome da outra pessoa
- Badge de status (pending, approved, etc.)
- Contador de perguntas (ex: "3/5 respondidas")
- Badge visual se houver perguntas não respondidas
- Timestamp da última atualização

### Estados da View

- **Loading**: Exibir `ProgressView` ou skeleton
- **Empty**: Exibir mensagem e ilustração quando lista vazia
- **Error**: Exibir mensagem de erro com botão de retry
- **Content**: Exibir lista de cards

### Pull-to-Refresh

```swift
.refreshable {
    await store.send(.refreshRequested).finish()
}
```

### Navegação

Usar `NavigationLink` ou delegate pattern conforme padrão do projeto.

## Critérios de Sucesso

- [ ] Lista exibe todas as negociações corretamente
- [ ] Cards mostram todas as informações necessárias
- [ ] Badge de status é visualmente claro
- [ ] Contador de perguntas está correto
- [ ] Badge de não lido aparece quando apropriado
- [ ] Pull-to-refresh funciona
- [ ] Empty state é informativo
- [ ] Loading e error states estão implementados
- [ ] Navegação para detalhes funciona
- [ ] Design segue padrões do app
- [ ] Build do projeto compila sem erros

## Dependências

- **11.0**: NegotiationsListFeature deve estar implementada

## Observações

- Reutilizar componentes do design system quando possível
- Seguir padrão visual de `TicketsListView` como referência
- Usar `AppColors` e tipografia do tema existente

