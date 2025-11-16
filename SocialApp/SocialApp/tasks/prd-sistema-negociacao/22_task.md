# Tarefa 22.0: Implementar Lógica de Marcar como Lido (S)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar lógica que automaticamente marca uma negociação como visualizada quando o usuário abre seus detalhes, limpando badges e atualizando timestamps no backend.

## Subtarefas

- [ ] 22.1 Adicionar action `markAsRead` no `NegotiationDetailFeature`
- [ ] 22.2 Implementar chamada ao backend para marcar como lido
- [ ] 22.3 Disparar marcação automática ao abrir detalhes
- [ ] 22.4 Atualizar estado local após marcar como lido
- [ ] 22.5 Atualizar badge global após marcar como lido
- [ ] 22.6 Implementar tratamento de erros (silencioso)
- [ ] 22.7 Testar em diferentes cenários

## Detalhes de Implementação

### Localização
- Arquivo: `Projects/Features/Negotiations/Sources/NegotiationDetailsFeature.swift`
- Expandir feature existente

### Lógica

```swift
case .onAppear:
    // Marcar como lido se houver perguntas não respondidas
    if negotiation.hasUnreadQuestions {
        return .run { send in
            await send(.markAsRead)
        }
    }
    return .none

case .markAsRead:
    return .run { [negotiationId = state.negotiationId] send in
        do {
            try await negotiationClient.markAsRead(negotiationId)
            await send(.delegate(.negotiationRead))
        } catch {
            // Silenciar erro - não crítico
        }
    }
```

### Endpoint da API

- `PATCH /api/negotiations/:id/mark-read` - Marca negociação como lida

### Atualização de Badge

- Após marcar como lido, atualizar `BadgeFeature` para decrementar contador
- Usar delegate ou notification para comunicação entre features

## Critérios de Sucesso

- [ ] Negociação é marcada como lida ao abrir detalhes
- [ ] Chamada ao backend funciona
- [ ] Estado local é atualizado
- [ ] Badge global é atualizado
- [ ] Erros são tratados silenciosamente
- [ ] Não há impacto negativo na performance
- [ ] Build do projeto compila sem erros

## Dependências

- **10.0**: NegotiationClient deve estar implementado
- **13.0**: NegotiationDetailFeature deve estar implementada
- **21.0**: Badge System deve estar implementado

## Observações

- Marcação deve ser automática e transparente
- Erros não devem interromper experiência do usuário
- Considerar debounce se usuário abrir/fechar rapidamente

