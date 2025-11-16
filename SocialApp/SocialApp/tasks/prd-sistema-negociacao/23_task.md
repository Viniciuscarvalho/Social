# Tarefa 23.0: Integrar Negociações com Tela de Tickets (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar botão "Iniciar Negociação" na tela de detalhes do ticket que cria uma nova negociação e navega para a tela de perguntas iniciais. Garantir que o fluxo completo funciona end-to-end.

## Subtarefas

- [ ] 23.1 Adicionar botão "Iniciar Negociação" na `TicketDetailView`
- [ ] 23.2 Implementar verificação de ticket disponível
- [ ] 23.3 Implementar verificação de negociação ativa existente
- [ ] 23.4 Adicionar action `startNegotiation` no `TicketDetailFeature`
- [ ] 23.5 Implementar criação de negociação no backend
- [ ] 23.6 Implementar navegação para tela de seleção de perguntas
- [ ] 23.7 Adicionar tratamento de erros (ticket não disponível, negociação existente)
- [ ] 23.8 Atualizar estado do ticket após criar negociação
- [ ] 23.9 Testar fluxo completo end-to-end
- [ ] 23.10 Adicionar loading state durante criação

## Detalhes de Implementação

### Localização
- Arquivo: `Projects/Features/TicketDetail/Sources/TicketDetailView.swift`
- Arquivo: `Projects/Features/TicketDetail/Sources/TicketDetailFeature.swift`

### Condições para Exibir Botão

- Ticket deve ter status `available`
- Não deve existir negociação ativa para o ticket
- Usuário deve estar autenticado

### Fluxo

1. Usuário toca em "Iniciar Negociação"
2. Sistema verifica se ticket está disponível
3. Sistema verifica se já existe negociação ativa
4. Se tudo OK, cria negociação no backend
5. Navega para `QuestionSelectionView`
6. Usuário seleciona perguntas
7. Perguntas são enviadas

### Tratamento de Erros

- **Ticket não disponível**: Mostrar mensagem e desabilitar botão
- **Negociação existente**: Navegar para detalhes da negociação existente
- **Erro de criação**: Mostrar alerta com opção de retry

### Integração com Navigation

- Usar `NavigationLink` ou delegate pattern
- Passar `negotiationId` para `NegotiationDetailsView`

## Critérios de Sucesso

- [ ] Botão aparece apenas quando apropriado
- [ ] Verificação de ticket disponível funciona
- [ ] Verificação de negociação existente funciona
- [ ] Criação de negociação funciona
- [ ] Navegação para perguntas funciona
- [ ] Tratamento de erros está completo
- [ ] Estado é atualizado corretamente
- [ ] Fluxo end-to-end funciona
- [ ] Build do projeto compila sem erros

## Dependências

- **9.0**: Models devem estar criados
- **10.0**: NegotiationClient deve estar implementado
- **13.0**: NegotiationDetailFeature deve estar implementada
- **15.0**: UI de perguntas deve estar implementada

## Observações

- Botão deve ser visível e claro
- Considerar UX: tornar fácil iniciar negociação
- Integrar com navegação existente do app

