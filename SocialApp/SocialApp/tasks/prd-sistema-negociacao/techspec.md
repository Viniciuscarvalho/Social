# Especificação Técnica: Sistema de Negociação de Ingressos

## Resumo Executivo

O Sistema de Negociação será implementado usando TCA (The Composable Architecture) seguindo os padrões já estabelecidos no projeto. A solução será composta por múltiplas features modulares que gerenciam diferentes aspectos do fluxo: listagem, detalhes, perguntas/respostas, upload de documentos e revelação de contato. A comunicação com o backend será feita através de um `NegotiationClient` que encapsula todas as chamadas de API, seguindo o padrão de Dependency Injection do TCA. O sistema utilizará autenticação biométrica para proteger a revelação de contatos e PhotosPicker para seleção de imagens com compressão automática.

## Arquitetura do Sistema

### Visão Geral dos Componentes

O sistema é composto pelas seguintes features principais:

1. **NegotiationsListFeature**: Gerencia estado e ações da lista de negociações
2. **NegotiationDetailFeature**: Gerencia estado e ações dos detalhes de uma negociação específica
3. **NegotiationQuestionsFeature**: Gerencia seleção e exibição de perguntas/respostas
4. **DocumentUploadFeature**: Gerencia upload e visualização de documentos
5. **ContactRevealFeature**: Gerencia revelação segura de contatos com biometria

**Relacionamentos**:
- `NegotiationsListFeature` navega para `NegotiationDetailFeature`
- `NegotiationDetailFeature` pode apresentar `NegotiationQuestionsFeature` e `DocumentUploadFeature` como sheets/modals
- `ContactRevealFeature` é apresentado como sheet após autenticação biométrica
- Todas as features dependem de `NegotiationClient` para comunicação com API

**Fluxo de dados**:
- User actions → Feature Actions → Reducer → NegotiationClient → NetworkService → Backend API
- Backend API → NetworkService → NegotiationClient → Feature State → UI Update

## Design de Implementação

### Interfaces Principais

#### NegotiationClient

```swift
@DependencyClient
public struct NegotiationClient {
    // Negociações
    public var fetchMyNegotiations: () async throws -> [Negotiation]
    public var fetchNegotiation: (String) async throws -> Negotiation
    public var createNegotiation: (CreateNegotiationRequest) async throws -> Negotiation
    public var updateNegotiation: (String, UpdateNegotiationRequest) async throws -> Negotiation
    public var revealContact: (String) async throws -> User
    
    // Perguntas e Respostas
    public var fetchQuestions: (String) async throws -> [NegotiationQuestion]
    public var createQuestion: (String, CreateQuestionRequest) async throws -> NegotiationQuestion
    public var answerQuestion: (String, String, String) async throws -> NegotiationAnswer
    public var markAsRead: (String) async throws -> Void
    
    // Documentos
    public var uploadDocument: (String, Data, String) async throws -> NegotiationDocument
    public var fetchDocuments: (String) async throws -> [NegotiationDocument]
    public var deleteDocument: (String, String) async throws -> Void
}
```

#### BiometricAuthService

```swift
public class BiometricAuthService {
    public static let shared = BiometricAuthService()
    
    public func authenticate(
        reason: String,
        fallbackTitle: String
    ) async throws -> Bool
    
    public var isAvailable: Bool { get }
    public var biometricType: BiometricType { get }
}
```

### Modelos de Dados

#### NegotiationQuestion

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
    
    enum CodingKeys: String, CodingKey {
        case id, questionText, category, isAnswered, answer, createdAt, answeredAt
        case negotiationId = "negotiation_id"
        case questionText = "question_text"
    }
}

public enum QuestionCategory: String, Codable, CaseIterable {
    case authenticity = "authenticity"
    case conditions = "conditions"
    case delivery = "delivery"
    case payment = "payment"
    case other = "other"
}
```

#### NegotiationAnswer

```swift
public struct NegotiationAnswer: Codable, Identifiable, Equatable {
    public var id: String
    public var questionId: String
    public var negotiationId: String
    public var answerText: String
    public var answeredBy: String
    public var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, answerText, answeredBy, createdAt
        case questionId = "question_id"
        case negotiationId = "negotiation_id"
        case answerText = "answer_text"
        case answeredBy = "answered_by"
    }
}
```

#### NegotiationDocument

```swift
public struct NegotiationDocument: Codable, Identifiable, Equatable {
    public var id: String
    public var negotiationId: String
    public var documentType: DocumentType
    public var fileUrl: String
    public var thumbnailUrl: String?
    public var status: ValidationStatus
    public var uploadedAt: Date
    public var validatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, fileUrl, thumbnailUrl, status, uploadedAt, validatedAt
        case negotiationId = "negotiation_id"
        case documentType = "document_type"
        case fileUrl = "file_url"
        case thumbnailUrl = "thumbnail_url"
        case uploadedAt = "uploaded_at"
        case validatedAt = "validated_at"
    }
}

public enum DocumentType: String, Codable {
    case ticketPhoto = "ticket_photo"
    case idDocument = "id_document"
}
```

### Endpoints de API

#### Negociações
- `GET /api/negotiations` - Lista negociações do usuário
- `GET /api/negotiations/:id` - Busca negociação específica
- `POST /api/negotiations` - Cria nova negociação
- `PATCH /api/negotiations/:id` - Atualiza negociação (status)
- `POST /api/negotiations/:id/reveal-contact` - Revela contato do vendedor

#### Perguntas e Respostas
- `GET /api/negotiations/:id/questions` - Lista perguntas da negociação
- `POST /api/negotiations/:id/questions` - Cria pergunta
- `POST /api/negotiations/:id/questions/:questionId/answer` - Responde pergunta
- `PATCH /api/negotiations/:id/mark-read` - Marca negociação como lida

#### Documentos
- `GET /api/negotiations/:id/documents` - Lista documentos da negociação
- `POST /api/negotiations/:id/documents` - Upload de documento (multipart/form-data)
- `DELETE /api/negotiations/:id/documents/:documentId` - Remove documento

## Pontos de Integração

### Backend API
- **Base URL**: Configurada em `NetworkConfig.baseURL`
- **Autenticação**: JWT token via header `Authorization: Bearer {token}`
- **Formato**: JSON para requisições/respostas, multipart/form-data para uploads
- **Tratamento de erros**: `NetworkError` enum com casos específicos (unauthorized, notFound, serverError, etc.)

### LocalAuthentication Framework
- **Uso**: Autenticação biométrica antes de revelar contato
- **Fallback**: Senha do dispositivo se biometria não disponível
- **Disponibilidade**: Verificada via `LAContext.canEvaluatePolicy`

### PhotosPicker
- **Uso**: Seleção de imagens da galeria ou câmera
- **Limitações**: Máximo 2 documentos por negociação
- **Compressão**: Imagens comprimidas antes do upload usando `UIImageJPEGRepresentation` com qualidade 0.7

### Deep Linking (WhatsApp)
- **Formato**: `whatsapp://send?phone={phone}&text={message}`
- **Fallback**: Se WhatsApp não instalado, copia mensagem para clipboard
- **Mensagem pré-formatada**: Inclui detalhes da negociação (ticket, evento, preço)

## Abordagem de Testes

### Testes Unitários

**Componentes principais a testar**:
- Reducers de cada feature (NegotiationsListFeature, NegotiationDetailFeature, etc.)
- Transformações de estado (actions → state updates)
- Lógica de validação (limite de perguntas, limite de documentos)
- Compressão de imagens

**Requisitos de mock**:
- `NegotiationClient` deve ser mockado em todos os testes
- `BiometricAuthService` deve ser mockado para testes de revelação de contato
- `NetworkService` não precisa ser mockado diretamente (já mockado via NegotiationClient)

**Cenários de teste críticos**:
1. Criação de negociação com ticket já em negociação (deve falhar)
2. Seleção de mais de 5 perguntas (deve ser bloqueada)
3. Upload de mais de 2 documentos (deve ser bloqueado)
4. Revelação de contato sem autenticação biométrica (deve falhar)
5. Marcação automática como lida ao abrir detalhes
6. Atualização de badge ao responder perguntas

### Testes de Integração

- Fluxo completo: Criar negociação → Selecionar perguntas → Responder → Enviar documentos → Aprovar → Revelar contato
- Sincronização de estado entre lista e detalhes
- Atualização de badge após mudanças de estado

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. **Models e DTOs (Task 9)**
   - Por que primeiro: Base para todas as outras features
   - Dependências: Nenhuma

2. **NegotiationService/Client (Task 10)**
   - Por que segundo: Necessário para todas as features
   - Dependências: Models e DTOs

3. **NegotiationsListFeature (Tasks 11-12)**
   - Por que terceiro: Feature principal de entrada
   - Dependências: Models, NegotiationClient

4. **NegotiationDetailFeature (Task 13)**
   - Por que quarto: Base para outras funcionalidades
   - Dependências: NegotiationsListFeature, NegotiationClient

5. **UI de Perguntas e Respostas (Tasks 14-16)**
   - Por que quinto: Funcionalidade core do sistema
   - Dependências: NegotiationDetailFeature, NegotiationClient

6. **Upload de Documentos (Tasks 17-18)**
   - Por que sexto: Funcionalidade importante mas pode ser desenvolvida em paralelo
   - Dependências: NegotiationDetailFeature, PhotosPicker

7. **Revelação de Contato (Task 19)**
   - Por que sétimo: Requer negociação aprovada
   - Dependências: NegotiationDetailFeature, BiometricAuthService

8. **Integração WhatsApp (Task 20)**
   - Por que oitavo: Depende de revelação de contato
   - Dependências: ContactRevealFeature, DeepLinkService

9. **Sistema de Badge (Task 21)**
   - Por que nono: Requer todas as features anteriores funcionando
   - Dependências: Todas as features anteriores

10. **Integração com Tickets (Task 23)**
    - Por que décimo: Integração final
    - Dependências: Todas as features anteriores

11. **Máquina de Estados Visual (Task 24)**
    - Por que último: Polish final
    - Dependências: Todas as features anteriores

### Dependências Técnicas

- **iOS 15.0+**: Para PhotosPicker e async/await
- **Backend API**: Endpoints de negociação devem estar disponíveis
- **LocalAuthentication**: Framework nativo do iOS (sem dependências externas)

## Considerações Técnicas

### Decisões Principais

1. **TCA para gerenciamento de estado**
   - Justificativa: Padrão já estabelecido no projeto, facilita testes e manutenção
   - Trade-offs: Curva de aprendizado inicial, mas benefícios a longo prazo

2. **NegotiationClient como Dependency**
   - Justificativa: Facilita testes e permite diferentes implementações (live/test)
   - Trade-offs: Nenhum significativo

3. **Compressão de imagens antes do upload**
   - Justificativa: Reduz uso de banda e tempo de upload
   - Trade-offs: Qualidade ligeiramente reduzida, mas aceitável para documentos

4. **Autenticação biométrica obrigatória**
   - Justificativa: Segurança e proteção de dados sensíveis
   - Trade-offs: Pode ser inconveniente para alguns usuários, mas necessário

5. **Perguntas pré-definidas (não customizadas)**
   - Justificativa: Mantém foco e evita transformar em chat
   - Trade-offs: Menos flexibilidade, mas mais estrutura

### Riscos Conhecidos

1. **Backend não disponível durante desenvolvimento**
   - Mitigação: Usar mocks e dados de teste
   - Área de pesquisa: Nenhuma

2. **Performance com muitas negociações**
   - Mitigação: Implementar paginação se necessário
   - Área de pesquisa: Avaliar necessidade de paginação após testes

3. **Compressão de imagens muito agressiva**
   - Mitigação: Testar diferentes níveis de qualidade e ajustar
   - Área de pesquisa: Qualidade ideal para documentos legíveis

4. **Autenticação biométrica falhando**
   - Mitigação: Implementar fallback para senha do dispositivo
   - Área de pesquisa: Tratamento de erros específicos do LocalAuthentication

### Requisitos Especiais

- **Performance**: 
  - Upload de imagens deve mostrar progresso em tempo real
  - Lista de negociações deve carregar em < 1s
  - Compressão de imagens não deve bloquear UI (usar background queue)

- **Segurança**:
  - Dados de contato nunca devem ser logados
  - Tokens JWT devem ser armazenados de forma segura (Keychain)
  - Autenticação biométrica obrigatória para revelação de contato

- **Monitoramento**:
  - Logs de criação/atualização de negociações
  - Métricas de tempo de resposta a perguntas
  - Taxa de sucesso de uploads de documentos

### Conformidade com Padrões

- **TCA Patterns**: Seguir padrões estabelecidos em outras features (TicketsListFeature, TicketDetailFeature)
- **SwiftUI Patterns**: Usar componentes reutilizáveis do design system existente
- **Error Handling**: Usar `NetworkError` e `AlertState` para exibição de erros
- **Dependency Injection**: Usar `@Dependency` do TCA para todos os clients
- **Async/Await**: Usar async/await para todas as operações assíncronas (não usar completion handlers)

### Arquivos relevantes

**Models**:
- `Domain/Sources/Models.swift` - Adicionar NegotiationQuestion, NegotiationAnswer, NegotiationDocument

**Services**:
- `SocialApp/Sources/Dependencies/NegotiationClient.swift` - Expandir com métodos de perguntas, respostas e documentos
- `SocialApp/Sources/Services/BiometricAuthService.swift` - Criar serviço de autenticação biométrica
- `SocialApp/Sources/Services/DeepLinkService.swift` - Expandir com método de WhatsApp

**Features**:
- `Projects/Features/Negotiations/Sources/NegotiationsListFeature.swift` - Criar feature de listagem
- `Projects/Features/Negotiations/Sources/NegotiationsListView.swift` - Criar view de listagem
- `Projects/Features/Negotiations/Sources/NegotiationDetailsFeature.swift` - Expandir feature existente
- `Projects/Features/Negotiations/Sources/NegotiationDetailsView.swift` - Expandir view existente
- `Projects/Features/Negotiations/Sources/NegotiationQuestionsFeature.swift` - Criar feature de perguntas
- `Projects/Features/Negotiations/Sources/DocumentUploadFeature.swift` - Criar feature de upload
- `Projects/Features/Negotiations/Sources/ContactRevealFeature.swift` - Criar feature de revelação

**Commons**:
- `SocialApp/Sources/Commons/QuestionCard.swift` - Criar componente de card de pergunta
- `SocialApp/Sources/Commons/DocumentGalleryView.swift` - Criar componente de galeria
- `SocialApp/Sources/Commons/NegotiationStatusBadge.swift` - Criar componente de badge de status
- `SocialApp/Sources/Commons/StateMachineView.swift` - Criar componente de máquina de estados

