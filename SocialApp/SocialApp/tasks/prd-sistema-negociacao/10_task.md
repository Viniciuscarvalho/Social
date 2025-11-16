# Tarefa 10.0: Criar Services de API (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Expandir o `NegotiationClient` existente para incluir todos os métodos necessários para comunicação com a API de negociações, perguntas, respostas e documentos. Implementar usando async/await e tratamento adequado de erros.

## Subtarefas

- [ ] 10.1 Adicionar métodos de perguntas ao `NegotiationClient`
- [ ] 10.2 Adicionar métodos de respostas ao `NegotiationClient`
- [ ] 10.3 Adicionar métodos de documentos ao `NegotiationClient`
- [ ] 10.4 Implementar `fetchQuestions(negotiationId:)` usando NetworkService
- [ ] 10.5 Implementar `createQuestion(negotiationId:request:)` usando NetworkService
- [ ] 10.6 Implementar `answerQuestion(negotiationId:questionId:answer:)` usando NetworkService
- [ ] 10.7 Implementar `uploadDocument(negotiationId:data:type:)` com multipart/form-data
- [ ] 10.8 Implementar `fetchDocuments(negotiationId:)` usando NetworkService
- [ ] 10.9 Implementar `deleteDocument(negotiationId:documentId:)` usando NetworkService
- [ ] 10.10 Implementar `markAsRead(negotiationId:)` usando NetworkService
- [ ] 10.11 Adicionar tratamento de erros específicos para cada método
- [ ] 10.12 Adicionar logs de debug para facilitar troubleshooting

## Detalhes de Implementação

### Localização
- Arquivo: `SocialApp/Sources/Dependencies/NegotiationClient.swift`
- Expandir o `NegotiationClient` existente

### Métodos a Implementar

```swift
// Perguntas
public var fetchQuestions: (String) async throws -> [NegotiationQuestion]
public var createQuestion: (String, CreateQuestionRequest) async throws -> NegotiationQuestion

// Respostas
public var answerQuestion: (String, String, String) async throws -> NegotiationAnswer

// Documentos
public var uploadDocument: (String, Data, String) async throws -> NegotiationDocument
public var fetchDocuments: (String) async throws -> [NegotiationDocument]
public var deleteDocument: (String, String) async throws -> Void

// Utilidades
public var markAsRead: (String) async throws -> Void
```

### Endpoints da API

- `GET /api/negotiations/:id/questions` - Lista perguntas
- `POST /api/negotiations/:id/questions` - Cria pergunta
- `POST /api/negotiations/:id/questions/:questionId/answer` - Responde pergunta
- `GET /api/negotiations/:id/documents` - Lista documentos
- `POST /api/negotiations/:id/documents` - Upload documento (multipart/form-data)
- `DELETE /api/negotiations/:id/documents/:documentId` - Remove documento
- `PATCH /api/negotiations/:id/mark-read` - Marca como lido

### Upload de Documentos

- Usar `multipart/form-data` para upload
- Incluir `negotiation_id`, `document_type` e `file` no form
- Implementar progress tracking se possível (opcional nesta fase)

### Tratamento de Erros

- Mapear códigos HTTP para `NetworkError` apropriados
- Fornecer mensagens de erro amigáveis
- Logar erros para debug

## Critérios de Sucesso

- [ ] Todos os métodos estão implementados no `NegotiationClient`
- [ ] Métodos usam async/await (não completion handlers)
- [ ] Tratamento de erros está adequado
- [ ] Upload de documentos funciona com multipart/form-data
- [ ] Logs de debug estão presentes
- [ ] Código segue padrões existentes em outros Clients
- [ ] Build do projeto compila sem erros
- [ ] Testes unitários podem mockar o client facilmente

## Dependências

- **9.0**: Models e DTOs devem estar criados

## Observações

- Reutilizar padrões de `TicketsClient` e `UserClient` existentes
- Usar `NetworkService.shared` para todas as requisições
- Manter consistência com tratamento de erros existente

