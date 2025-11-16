# Resumo de Tarefas de Implementação de Sistema de Negociação

## Tarefas

- [ ] 9.0 Criar Models e DTOs do Sistema de Negociação (M)
- [ ] 10.0 Criar Services de API (M)
- [ ] 11.0 Criar Feature NegotiationsList (TCA) (L)
- [ ] 12.0 Criar UI de NegotiationsList (M)
- [ ] 13.0 Criar Feature NegotiationDetail (TCA) (L)
- [ ] 14.0 Criar UI de Perguntas e Respostas (M)
- [ ] 15.0 Criar UI para Fazer Perguntas (M)
- [ ] 16.0 Criar UI para Responder Perguntas (M)
- [ ] 17.0 Implementar Upload de Documentos (L)
- [ ] 18.0 Criar UI de Galeria de Documentos (M)
- [ ] 19.0 Implementar Revelação de Contato com Biometria (M)
- [ ] 20.0 Implementar Integração com WhatsApp (S)
- [ ] 21.0 Implementar Badge System (M)
- [ ] 22.0 Implementar Lógica de Marcar como Lido (S)
- [ ] 23.0 Integrar Negociações com Tela de Tickets (M)
- [ ] 24.0 Implementar Máquina de Estados Visual (M)

## Notas sobre tamanho
- S - Small (1-2 dias)
- M - Medium (3-5 dias)
- L - Large (6-10 dias)

## Dependências

### Fase 1: Fundação (Tasks 9-10)
- **9.0** → **10.0**: Services dependem dos Models

### Fase 2: Listagem (Tasks 11-12)
- **9.0, 10.0** → **11.0, 12.0**: Features dependem de Models e Services

### Fase 3: Detalhes (Tasks 13-16)
- **11.0, 12.0** → **13.0**: Detail depende de List
- **13.0** → **14.0, 15.0, 16.0**: UI de perguntas depende de Detail

### Fase 4: Documentos (Tasks 17-18)
- **13.0** → **17.0, 18.0**: Upload depende de Detail

### Fase 5: Contato (Tasks 19-20)
- **13.0** → **19.0**: Revelação depende de Detail
- **19.0** → **20.0**: WhatsApp depende de Revelação

### Fase 6: Notificações (Tasks 21-22)
- **11.0, 13.0** → **21.0, 22.0**: Badge depende de List e Detail

### Fase 7: Integração (Tasks 23-24)
- **Todas anteriores** → **23.0, 24.0**: Integração final e polish

## Tarefas que podem ser executadas em paralelo

- **11.0 e 12.0**: Feature e UI de List podem ser desenvolvidas em paralelo
- **14.0, 15.0 e 16.0**: UIs de perguntas podem ser desenvolvidas em paralelo após 13.0
- **17.0 e 18.0**: Upload e Galeria podem ser desenvolvidas em paralelo
- **21.0 e 22.0**: Badge e Marcar como Lido podem ser desenvolvidas em paralelo

