# Data - Camada de Acesso a Dados

## Estrutura Atual (Task 4.0 Completa)

Esta camada é responsável por DTOs de API, mappers e acesso a dados. A camada Data conhece Domain, mas Domain não conhece Data.

### Arquivos da Camada Data

#### 📁 `APICommon.swift`
**DTOs Genéricos e Compartilhados:**
- `APIResponse<T>` - Wrapper genérico para respostas únicas
- `APIListResponse<T>` - Wrapper para listas com paginação
- `APISingleResponse<T>` - Wrapper simples para item único
- `APIError` - Modelo de erro da API
- `APIErrorResponse` - Resposta de erro detalhada
- `PaginationInfo` - Informações de paginação

#### 📁 `APIUser.swift`
**DTOs de Usuário e Auth:**
- `LoginRequest`, `RegisterRequest` - Requests de autenticação
- `UserUpdateRequest` - Request de atualização de usuário
- `AuthResponse` - Resposta de autenticação
- `UserResponse`, `UsersListResponse` - Respostas de usuário
- `FollowResponse` - Resposta de follow/unfollow
- `APIUserResponse` - DTO de usuário da API
- `APIUserVerificationResponse` - DTO de verificação de usuário

**Mappers:**
- `APIUserResponse.toUser() -> User`
- `APIUserVerificationResponse.toUserVerification() -> UserVerification`

#### 📁 `APIEvent.swift`
**DTOs de Evento:**
- `APIEventResponse` - DTO de evento da API
- `APILocationResponse` - DTO de localização
- `APICoordinateResponse` - DTO de coordenadas

**Mappers:**
- `APIEventResponse.toEvent() -> Event`
- `APILocationResponse.toLocation() -> Location`
- `APICoordinateResponse.toCoordinate() -> Coordinate`

#### 📁 `APITicket.swift`
**DTOs de Ticket:**
- `APITicketResponse` - DTO de ticket da API
- `TicketsListResponse` - Lista de tickets com paginação
- `CreateTicketRequest` - Request de criação de ticket
- `UpdateTicketRequest` - Request de atualização de ticket
- `CreateTicketResponse` - Resposta de criação de ticket
- `PurchaseTicketRequest` - Request de compra
- `FavoriteTicketRequest` - Request de favoritar

**Mappers:**
- `APITicketResponse.toTicket() -> Ticket`
- `CreateTicketResponse.toTicket() -> Ticket`

#### 📁 `APITicketDetail.swift` ✨ NOVO
**DTOs de Detalhes de Ticket e Sellers:**
- `APITicketDetailResponse` - DTO de detalhes completos de ticket
- `APISellersByEventResponse` - Resposta de vendedores por evento
- `APISellerSummary` - Resumo de vendedor com informações agregadas
- `APITicketsBySellerResponse` - Resposta de tickets por vendedor

**Mappers:**
- `APITicketDetailResponse.toTicketDetail() -> TicketDetail`

#### 📁 `APINegotiation.swift` ✨ NOVO
**DTOs de Negociação:**
- `APINegotiationResponse` - DTO de negociação da API
- `APINegotiationQuestionResponse` - DTO de pergunta de negociação
- `APINegotiationAnswerResponse` - DTO de resposta de negociação
- `APINegotiationDocumentResponse` - DTO de documento de negociação

**Requests:**
- `CreateNegotiationRequest` - Request de criação de negociação
- `UpdateNegotiationRequest` - Request de atualização de negociação
- `CreateQuestionRequest` - Request de criação de pergunta
- `AnswerQuestionRequest` - Request de resposta de pergunta
- `UploadDocumentRequest` - Request de upload de documento

**Mappers:**
- `APINegotiationResponse.toNegotiation() -> Negotiation`
- `APINegotiationQuestionResponse.toNegotiationQuestion() -> NegotiationQuestion`
- `APINegotiationAnswerResponse.toNegotiationAnswer() -> NegotiationAnswer`
- `APINegotiationDocumentResponse.toNegotiationDocument() -> NegotiationDocument`

#### 📁 `APIReview.swift` ✨ NOVO
**Requests:**
- `CreateReviewRequest` - Request de criação de review/avaliação

## Dependências

```
Data → Domain (depende de modelos de domínio)
Domain ✗ Data (não conhece Data)
```

## Princípios

### 1. DTOs Separados de Domain
- DTOs refletem exatamente a estrutura da API
- Suportam tanto camelCase quanto snake_case para compatibilidade
- Computed properties para unificar campos duplicados

### 2. Mappers Claros
- Cada DTO tem uma extensão com método `toDomain()`
- Exemplo: `APIUserResponse.toUser() -> User`
- Mappers lidam com conversões de data, enums e parsing

### 3. Resiliência na Decodificação
- Decodificação customizada quando necessário
- Fallbacks para campos opcionais
- Suporte a múltiplos formatos de data

### 4. Compatibilidade API
- Suporta tanto camelCase quanto snake_case
- Computed properties escolhem o valor correto
- Exemplo: `finalProfileImageURL` escolhe entre `profileImageURL` e `profile_image_url`

## Padrões de Código

### DTO com Decodificação Customizada

```swift
public struct APIUserResponse: Codable {
  let id: String
  let name: String
  let profileImageURL: String?
  let profile_image_url: String? // Compatibilidade snake_case
  
  var finalProfileImageURL: String? {
    return profileImageURL ?? profile_image_url
  }
}
```

### Mapper toDomain()

```swift
extension APIUserResponse {
  public func toUser() -> User {
    var user = User(
      name: self.name,
      profileImageURL: self.finalProfileImageURL
    )
    user.id = self.id
    return user
  }
}
```

### Parsing de Datas

```swift
let parseDate: (String?) -> Date? = { dateString in
  guard let dateString = dateString else { return nil }
  let dateFormatter = DateFormatter()
  dateFormatter.locale = Locale(identifier: "en_US_POSIX")
  let formats = [
    "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
    "yyyy-MM-dd'T'HH:mm:ssZ",
    "yyyy-MM-dd"
  ]
  for format in formats {
    dateFormatter.dateFormat = format
    if let date = dateFormatter.date(from: dateString) {
      return date
    }
  }
  return nil
}
```

## Migração Incremental

### ✅ Concluído na Task 4.0
- Estrutura Data/ criada
- DTOs principais: User, Event, Ticket
- Mappers toDomain() implementados
- Padrões estabelecidos

### ✅ Migração Completa

Todos os DTOs principais foram migrados para a camada Data:

- ✅ **APINegotiation.swift** - Criado
  - APINegotiationResponse
  - APINegotiationQuestionResponse
  - APINegotiationAnswerResponse
  - APINegotiationDocumentResponse
  - CreateNegotiationRequest, UpdateNegotiationRequest
  - CreateQuestionRequest, AnswerQuestionRequest
  - UploadDocumentRequest

- ✅ **APITicketDetail.swift** - Criado
  - APITicketDetailResponse
  - APISellersByEventResponse, APISellerSummary
  - APITicketsBySellerResponse

- ✅ **APIReview.swift** - Criado
  - CreateReviewRequest

- ✅ **APITicket.swift** - Atualizado
  - UpdateTicketRequest, CreateTicketResponse (adicionados)

### 📝 Nota sobre Domain/APIModels.swift

O arquivo `Domain/Sources/APIModels.swift` ainda contém:
- Modelos de domínio (User, Event, Ticket, Negotiation, etc.) - **DEVEM permanecer em Domain**
- Alguns DTOs duplicados que agora estão em Data - **podem ser removidos após atualizar clients**

**Recomendação:** Manter `APIModels.swift` temporariamente para compatibilidade durante a migração incremental dos clients.

## Uso nos Clients TCA

Os clients TCA em `SocialApp/Sources/Dependencies/` devem:

1. Importar `Data` para acessar DTOs
2. Importar `Domain` para retornar modelos de domínio
3. Usar mappers `toDomain()` antes de retornar

```swift
import Dependencies
import Domain
import Data

public struct UserClient {
  public var fetchUser: (String) async throws -> User
}

extension UserClient: DependencyKey {
  public static let liveValue = UserClient(
    fetchUser: { userId in
      let apiResponse: APIUserResponse = try await networkService.get("/users/\(userId)")
      return apiResponse.toUser() // ← Mapper
    }
  )
}
```

## Convenções de Nomenclatura

- **DTOs de API**: `API{Entity}Response` (ex: `APIUserResponse`)
- **Requests**: `{Action}{Entity}Request` (ex: `CreateTicketRequest`)
- **Responses especializadas**: `{Entity}{Type}Response` (ex: `UsersListResponse`)
- **Mappers**: `func to{Domain}() -> {Domain}` (ex: `func toUser() -> User`)

## Próximos Passos

1. **Task 4.0 continuação**: Migrar DTOs de Negotiation restantes
2. **Task 5.0**: Reorganizar Presentation usando tipos de Domain (não DTOs)
3. **Clients TCA**: Atualizar gradualmente para usar Data layer
4. **Testes**: Adicionar testes de mappers

## Exemplo Completo: Fluxo de Dados

```
API Response (JSON)
    ↓
APIUserResponse (Data layer)
    ↓
.toUser() (Mapper)
    ↓
User (Domain layer)
    ↓
State (Presentation/TCA)
    ↓
View (SwiftUI)
```

## Notas Importantes

- **Domain nunca importa Data** - Manter separação unidirecional
- **DTOs são internos** - Apenas Domain models são expostos ao app
- **Migração incremental** - Não precisa migrar tudo de uma vez
- **Testes de mapper** - Adicionar conforme necessário

