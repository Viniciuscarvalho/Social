# Tarefa 15.0: Criar UI para Fazer Perguntas (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Implementar sheet ou modal que permite ao comprador selecionar perguntas pré-definidas organizadas por categoria. Incluir validação (máximo 5 perguntas) e preview antes de enviar.

## Subtarefas

- [ ] 15.1 Criar `QuestionSelectionView` como sheet
- [ ] 15.2 Implementar lista de perguntas pré-definidas por categoria
- [ ] 15.3 Implementar seleção múltipla de perguntas (checkboxes)
- [ ] 15.4 Implementar validação de máximo 5 perguntas
- [ ] 15.5 Implementar preview das perguntas selecionadas
- [ ] 15.6 Implementar botão de enviar com estado disabled quando inválido
- [ ] 15.7 Adicionar indicador de quantas perguntas podem ser selecionadas
- [ ] 15.8 Implementar categorias com seções colapsáveis
- [ ] 15.9 Adicionar animações para seleção
- [ ] 15.10 Integrar com NegotiationDetailFeature
- [ ] 15.11 Implementar loading state ao enviar
- [ ] 15.12 Adicionar tratamento de erros

## Detalhes de Implementação

### Localização
- Arquivo: `Projects/Features/Negotiations/Sources/QuestionSelectionView.swift`
- Criar novo arquivo

### Estrutura da View

```swift
struct QuestionSelectionView: View {
    @Bindable var store: StoreOf<NegotiationDetailsFeature>
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedQuestions: Set<String> = []
    
    var body: some View {
        NavigationView {
            // Lista de perguntas por categoria
            // Preview das selecionadas
            // Botão de enviar
        }
    }
}
```

### Perguntas Pré-definidas

Definir lista fixa de perguntas organizadas por categoria:
- **Autenticidade**: "O ingresso é original?", "Tem algum dano?"
- **Condições**: "Qual a validade?", "Pode ser transferido?"
- **Entrega**: "Como será a entrega?", "Quando posso receber?"
- **Pagamento**: "Qual a forma de pagamento?", "Há desconto?"

### Validação

- Máximo 5 perguntas selecionadas
- Desabilitar outras quando limite atingido
- Mostrar mensagem quando tentar selecionar mais
- Botão enviar desabilitado se nenhuma selecionada

### Preview

- Mostrar lista das perguntas selecionadas
- Permitir remover selecionadas
- Mostrar contador (ex: "3 de 5 selecionadas")

## Critérios de Sucesso

- [ ] Sheet exibe perguntas organizadas por categoria
- [ ] Seleção múltipla funciona corretamente
- [ ] Validação de máximo 5 perguntas funciona
- [ ] Preview mostra perguntas selecionadas
- [ ] Botão enviar funciona e desabilita quando apropriado
- [ ] Loading state é exibido ao enviar
- [ ] Erros são tratados adequadamente
- [ ] Design segue padrões do app
- [ ] Build do projeto compila sem erros

## Dependências

- **9.0**: Models devem estar criados
- **13.0**: NegotiationDetailFeature deve estar implementada

## Observações

- Perguntas pré-definidas devem ser fixas (não vêm do backend)
- Usar `sheet` modifier do SwiftUI
- Considerar UX: tornar fácil selecionar perguntas relevantes

