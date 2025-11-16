# Tarefa 14.0: Criar UI de Perguntas e Respostas (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Implementar componentes SwiftUI para exibir perguntas e respostas como cards estruturados, com estados visuais diferentes para pendente/respondido, timestamps e possibilidade de expansão/colapso.

## Subtarefas

- [ ] 14.1 Criar componente `QuestionCard` para exibir pergunta
- [ ] 14.2 Implementar exibição de texto da pergunta
- [ ] 14.3 Implementar badge de categoria da pergunta
- [ ] 14.4 Implementar exibição de resposta quando disponível
- [ ] 14.5 Implementar indicador visual de status (pendente/respondido)
- [ ] 14.6 Implementar exibição de timestamps (criada em, respondida em)
- [ ] 14.7 Implementar expansão/colapso para respostas longas
- [ ] 14.8 Criar seção de perguntas na `NegotiationDetailsView`
- [ ] 14.9 Implementar empty state quando não houver perguntas
- [ ] 14.10 Adicionar animações sutis para transições
- [ ] 14.11 Aplicar design system (cores, espaçamentos, tipografia)
- [ ] 14.12 Testar com diferentes tamanhos de texto

## Detalhes de Implementação

### Localização
- Arquivo: `SocialApp/Sources/Commons/QuestionCard.swift` (componente)
- Arquivo: `Projects/Features/Negotiations/Sources/NegotiationDetailsView.swift` (integração)

### Estrutura do QuestionCard

```swift
struct QuestionCard: View {
    let question: NegotiationQuestion
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header com categoria e status
            // Texto da pergunta
            // Resposta (se disponível) com expansão
            // Timestamps
        }
    }
}
```

### Estados Visuais

- **Pendente**: Badge laranja/cinza, sem resposta visível
- **Respondido**: Badge verde, resposta visível, timestamp de resposta
- **Expandido**: Mostra resposta completa (se longa)
- **Colapsado**: Mostra preview da resposta (primeiras linhas)

### Design

- Usar cards com `RoundedRectangle` e sombra
- Cores diferentes para status (pendente vs respondido)
- Ícones apropriados para cada estado
- Espaçamento consistente com design system

## Critérios de Sucesso

- [ ] Cards exibem perguntas e respostas corretamente
- [ ] Estados visuais são claros e distintos
- [ ] Timestamps são formatados adequadamente
- [ ] Expansão/colapso funciona para respostas longas
- [ ] Empty state é informativo
- [ ] Design segue padrões do app
- [ ] Animações são sutis e melhoram UX
- [ ] Build do projeto compila sem erros

## Dependências

- **9.0**: Models devem estar criados
- **13.0**: NegotiationDetailFeature deve estar implementada

## Observações

- Reutilizar componentes do design system
- Seguir padrão visual de outros cards do app
- Considerar acessibilidade (tamanhos de fonte, contraste)

