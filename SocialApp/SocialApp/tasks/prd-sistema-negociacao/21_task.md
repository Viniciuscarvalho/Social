# Tarefa 21.0: Implementar Badge System (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Criar sistema global no app que monitora notificações não lidas e exibe badge na tab bar do chat. Implementar usando TCA's global state ou notification center, atualizando quando o app abre ou periodicamente em foreground.

## Subtarefas

- [ ] 21.1 Criar `BadgeFeature` com TCA para gerenciar estado global
- [ ] 21.2 Implementar State com contador de perguntas não respondidas
- [ ] 21.3 Implementar Action para atualizar badge
- [ ] 21.4 Integrar com `SocialAppFeature` (parent feature)
- [ ] 21.5 Implementar método para buscar contador do backend
- [ ] 21.6 Adicionar polling periódico em foreground
- [ ] 21.7 Atualizar badge quando app abre
- [ ] 21.8 Atualizar badge após responder perguntas
- [ ] 21.9 Implementar exibição de badge na tab bar
- [ ] 21.10 Adicionar animação quando badge muda
- [ ] 21.11 Testar atualização em diferentes cenários

## Detalhes de Implementação

### Localização
- Arquivo: `SocialApp/Sources/SocialAppFeature.swift`
- Expandir feature existente ou criar `BadgeFeature` separada

### Estrutura do Badge State

```swift
@ObservableState
public struct BadgeState: Equatable {
    public var unreadQuestionsCount: Int = 0
    public var lastUpdate: Date?
}
```

### Atualização do Badge

- Ao abrir app: Buscar contador do backend
- Após responder pergunta: Decrementar contador local
- Periodicamente: Polling a cada 30-60 segundos em foreground
- Ao receber notificação: Atualizar contador

### Exibição na Tab Bar

- Adicionar badge visual na tab de negociações
- Mostrar número quando > 0
- Ocultar quando = 0
- Animação sutil ao atualizar

### Endpoint da API

- `GET /api/negotiations/unread-count` - Retorna contador de perguntas não respondidas

## Critérios de Sucesso

- [ ] Badge é exibido na tab bar corretamente
- [ ] Contador é atualizado quando app abre
- [ ] Polling periódico funciona
- [ ] Badge atualiza após responder perguntas
- [ ] Animação é sutil e não intrusiva
- [ ] Performance é adequada (não impacta app)
- [ ] Build do projeto compila sem erros

## Dependências

- **10.0**: NegotiationClient deve estar implementado
- **11.0**: NegotiationsListFeature deve estar implementada
- **13.0**: NegotiationDetailFeature deve estar implementada

## Observações

- Considerar usar `NotificationCenter` se TCA não for adequado
- Polling deve ser eficiente (não fazer muitas requisições)
- Badge deve ser visível mas não intrusivo

