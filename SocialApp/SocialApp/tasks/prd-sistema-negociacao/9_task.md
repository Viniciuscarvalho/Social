# Tarefa 9.0: Criar Models e DTOs do Sistema de Negociação (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Definir e implementar todos os modelos de dados Swift necessários para o sistema de negociação, incluindo estruturas para perguntas, respostas e documentos. Todos os modelos devem implementar `Codable` para serialização JSON e suportar conversão entre `snake_case` do backend e `camelCase` do iOS.

## Subtarefas

- [ ] 9.1 Criar struct `NegotiationQuestion` com todas as propriedades necessárias
- [ ] 9.2 Criar enum `QuestionCategory` com categorias pré-definidas
- [ ] 9.3 Criar struct `NegotiationAnswer` com propriedades de resposta
- [ ] 9.4 Criar struct `NegotiationDocument` com propriedades de documento
- [ ] 9.5 Criar enum `DocumentType` (ticket_photo, id_document)
- [ ] 9.6 Implementar `CodingKeys` customizados para conversão snake_case ↔ camelCase
- [ ] 9.7 Adicionar computed properties úteis (ex: `isExpired`, `canEdit`)
- [ ] 9.8 Criar DTOs de requisição (`CreateQuestionRequest`, `AnswerQuestionRequest`, `UploadDocumentRequest`)
- [ ] 9.9 Criar DTOs de resposta da API (`APINegotiationQuestionResponse`, etc.)
- [ ] 9.10 Adicionar extensões de conversão (API Response → Domain Model)

## Detalhes de Implementação

### Localização
- Arquivo: `Domain/Sources/Models.swift`
- Seção: Adicionar após modelos de `Negotiation` existentes (linha ~1832)

### Estruturas Principais

**NegotiationQuestion**:
```swift
public struct NegotiationQuestion: Codable, Identifiable, Equatable {
    public var id: String
    public var negotiationId: String
    public var questionText: String
    public var category: QuestionCategory
    public var isAnswered: Bool
    public var answer: NegotiationAnswer?
    public var createdAt: Date
    public var answeredAt: Date?
}
```

**NegotiationAnswer**:
```swift
public struct NegotiationAnswer: Codable, Identifiable, Equatable {
    public var id: String
    public var questionId: String
    public var negotiationId: String
    public var answerText: String
    public var answeredBy: String
    public var createdAt: Date
}
```

**NegotiationDocument**:
```swift
public struct NegotiationDocument: Codable, Identifiable, Equatable {
    public var id: String
    public var negotiationId: String
    public var documentType: DocumentType
    public var fileUrl: String
    public var thumbnailUrl: String?
    public var status: ValidationStatus // Reutilizar enum existente
    public var uploadedAt: Date
    public var validatedAt: Date?
}
```

### Requisitos de Codable

- Todos os campos devem usar `CodingKeys` para mapear `snake_case` ↔ `camelCase`
- Datas devem usar `DateFormatter` com múltiplos formatos (como nos modelos existentes)
- Campos opcionais devem ser tratados com `decodeIfPresent`
- Valores padrão devem ser fornecidos para campos críticos

## Critérios de Sucesso

- [ ] Todos os modelos implementam `Codable`, `Identifiable` e `Equatable`
- [ ] Conversão snake_case ↔ camelCase funciona corretamente
- [ ] DTOs de requisição/resposta estão completos
- [ ] Extensões de conversão API → Domain estão implementadas
- [ ] Código segue padrões existentes em `Models.swift`
- [ ] Build do projeto compila sem erros
- [ ] Não há warnings do compilador

## Dependências

- Nenhuma (tarefa de fundação)

## Observações

- Reutilizar `ValidationStatus` enum já existente em `Models.swift`
- Seguir padrão de parsing de datas usado em `APITicketResponse`
- Manter consistência com nomenclatura de outros modelos do projeto

