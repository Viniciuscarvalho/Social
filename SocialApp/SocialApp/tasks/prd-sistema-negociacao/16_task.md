# Tarefa 16.0: Criar UI para Responder Perguntas (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Implementar interface para o vendedor ver perguntas pendentes e respondê-las. Incluir validação e feedback visual após envio. Respostas não podem ser editadas após envio.

## Subtarefas

- [ ] 16.1 Criar seção de perguntas pendentes na `NegotiationDetailsView`
- [ ] 16.2 Implementar lista de perguntas não respondidas
- [ ] 16.3 Criar componente `AnswerQuestionView` (sheet ou inline)
- [ ] 16.4 Implementar campo de texto para resposta
- [ ] 16.5 Implementar validação (resposta não pode estar vazia)
- [ ] 16.6 Implementar botão de enviar resposta
- [ ] 16.7 Adicionar loading state ao enviar
- [ ] 16.8 Implementar feedback visual após envio (sucesso)
- [ ] 16.9 Atualizar UI após resposta (remover de pendentes)
- [ ] 16.10 Adicionar indicador de perguntas não respondidas
- [ ] 16.11 Implementar tratamento de erros
- [ ] 16.12 Adicionar contador de perguntas pendentes

## Detalhes de Implementação

### Localização
- Arquivo: `Projects/Features/Negotiations/Sources/NegotiationDetailsView.swift`
- Expandir view existente

### Estrutura da Resposta

```swift
struct AnswerQuestionView: View {
    let question: NegotiationQuestion
    @State private var answerText: String = ""
    @State private var isSubmitting: Bool = false
    
    var body: some View {
        VStack {
            // Exibir pergunta
            // Campo de texto para resposta
            // Botão de enviar
        }
    }
}
```

### Fluxo

1. Vendedor vê lista de perguntas pendentes
2. Toca em uma pergunta para responder
3. Abre sheet ou expande card com campo de resposta
4. Digita resposta
5. Envia resposta
6. UI atualiza mostrando resposta enviada
7. Pergunta sai da lista de pendentes

### Validação

- Resposta não pode estar vazia
- Mínimo de caracteres (opcional, ex: 10 caracteres)
- Botão enviar desabilitado se inválido

### Feedback Visual

- Loading spinner ao enviar
- Mensagem de sucesso após envio
- Animação de transição (pergunta pendente → respondida)

## Critérios de Sucesso

- [ ] Lista de perguntas pendentes é exibida corretamente
- [ ] Interface para responder é clara e intuitiva
- [ ] Validação funciona corretamente
- [ ] Loading state é exibido ao enviar
- [ ] Feedback visual após envio é claro
- [ ] UI atualiza após resposta
- [ ] Contador de pendentes é atualizado
- [ ] Erros são tratados adequadamente
- [ ] Design segue padrões do app
- [ ] Build do projeto compila sem erros

## Dependências

- **9.0**: Models devem estar criados
- **13.0**: NegotiationDetailFeature deve estar implementada
- **14.0**: UI de perguntas deve estar implementada

## Observações

- Respostas não podem ser editadas após envio (requisito)
- Focar em UX: tornar fácil responder rapidamente
- Considerar notificações para vendedor sobre novas perguntas

