# Techspec — Fluxo de Negociação e Validação de Ingressos (iOS, TCA)

## Resumo Executivo

Implementaremos, no app iOS (SwiftUI + TCA), os fluxos de negociação entre compradores e vendedores e a validação de ingressos, com verificação progressiva de conta. Usaremos dependências injetáveis (Clients) para acesso a APIs REST, autenticação biométrica para proteger dados sensíveis e integração com Push Notifications e deep links para navegação contextual. O trabalho será entregue em fases alinhadas ao `Task5.md`.

## Arquitetura do Sistema

### Visão Geral dos Componentes

- **Features TCA (domínio):**
  - `NegotiationRequestFeature`, `NegotiationDetailsFeature`, `NegotiationReviewFeature`
  - `ValidationUploadFeature`, `ValidationStatusFeature`
  - `EmailVerificationFeature`, `PhoneVerificationFeature`, `DocumentVerificationFeature`
  - `ContactRevealFeature`, `SellerProfileFeature`
- **Clientes/Serviços (dependências):**
  - `TicketNegotiationClient`, `UserVerificationClient`
  - `PushNotificationService`, `DeepLinkService`, `BiometricAuthService`, `BackgroundProtectionService`
- **Commons (UI/UX):**
  - `NegotiationCounter`, `TrustScoreBadge`, `VerificationProgressView`, `ValidationStatusBanner`, `StarRatingView`, `SkeletonView`, `LazyImageView`, `ErrorView`

Fluxo de dados: Views → Store (Reducer TCA) → Efeitos (Clients/Services) → Respostas → Store → Views. Estados e ações serão rastreáveis e reversíveis segundo TCA.

## Design de Implementação

### Interfaces Principais

Exemplos de contratos em Swift (protocolos) para injeção via TCA:

```swift
public protocol TicketNegotiationClient {
  func requestNegotiation(ticketId: String) async throws -> Negotiation
  func approve(negotiationId: String) async throws -> Negotiation
  func reject(negotiationId: String, reason: String?) async throws -> Negotiation
  func fetchDetails(negotiationId: String) async throws -> Negotiation
}
```
```swift
public protocol UserVerificationClient {
  func verificationStatus() async throws -> VerificationStatus
  func verifyEmail(code: String) async throws -> VerificationStatus
  func verifyPhone(code: String) async throws -> VerificationStatus
  func uploadDocument(front: Data, back: Data?) async throws -> VerificationStatus
}
```
```swift
public protocol BiometricAuthService {
  func authenticate(reason: String) async throws
}
```
```swift
public protocol DeepLinkService {
  func openWhatsApp(phone: String, message: String?)
  func openTelegram(username: String)
  func openEmail(address: String, subject: String?, body: String?)
}
```
```swift
public protocol PushNotificationService {
  func configure()
  func requestAuthorization() async throws
  func handleNotification(userInfo: [AnyHashable: Any])
}
```
```swift
public protocol BackgroundProtectionService {
  func enable()
  func disable()
}
```

### Modelos de Dados

- **Negotiation**: `id`, `ticketId`, `buyerId`, `sellerId`, `status` (requested/approved/rejected), `createdAt`, `updatedAt`.
- **VerificationStatus**: `email` (unverified/verified), `phone`, `document`, `level` (none/partial/verified), `requirements` pendentes.
- **ValidationUpload**: `negotiationId`, `images[]` (após compressão), `progress` (0–1), `result` (pending/approved/rejected).
- **ContactData**: `phone`, `email`, `telegram`, liberados somente após biometria + aprovação.

Tipos Swift (exemplo conciso):

```swift
public struct Negotiation: Codable, Equatable { /* campos conforme acima */ }
public struct VerificationStatus: Codable, Equatable { /* ... */ }
```

### Endpoints de API

- **POST** `/api/v0/negotiations` — solicita negociação (comprador)
- **GET** `/api/v0/negotiations/{id}` — detalhes
- **PATCH** `/api/v0/negotiations/{id}/approve` — aprovar (vendedor)
- **PATCH** `/api/v0/negotiations/{id}/reject` — recusar (vendedor)
- **POST** `/api/v0/negotiations/{id}/validation/uploads` — upload de imagens para validação
- **GET** `/api/v0/user/verification-status` — status de verificação
- **POST** `/api/v0/user/verify/email` — confirmar email
- **POST** `/api/v0/user/verify/phone` — confirmar telefone
- **POST** `/api/v0/user/verify/document` — upload documento
- **POST** `/api/v0/negotiations/{id}/contact/reveal` — revelar dados de contato (gated por biometria)

Referências: Autenticação via JWT (header `Authorization: Bearer <token>`). Respostas JSON nos modelos listados.

## Pontos de Integração

- **Serviços externos**: Firebase (Push), apps externos (WhatsApp, Telegram, Mail) via URL schemes.
- **Autenticação**: JWT fornecido pelo app, renovação fora do escopo; biometria via `LocalAuthentication`.
- **Tratamento de erros**: Mapear erros de rede/validação para `AlertState` nas Stores; reintentos com backoff leve onde fizer sentido (upload).

## Abordagem de Testes

### Testes Unitários

- Reducers TCA: `Negotiation*`, `Validation*`, `UserVerification*` com `TestStore`.
- Mocks: `TicketNegotiationClient`, `UserVerificationClient`, upload e biometria.
- Cenários críticos:
  - Gate de solicitação (mínimo nível de verificação + < 3 negociações ativas)
  - Aprovação/recusa com atualização de estado e feedback visual
  - Revelação de contato após biometria
  - Upload com compressão, progresso e estados (pending/approved/rejected)
  - Degradação de rede: timeouts, 401/403, 422 validação

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. Seller/Negotiation (Request/Details) — base do fluxo e contratos de API
2. Verificação de Usuário (Email/Phone/Document) — requisitos de gating
3. Biometria + Contact Reveal + Deep Links — segurança e navegação contextual
4. Validation Upload/Status — fluxo de validação de ingressos
5. Review — reputação e feedback (estrelinhas, texto)
6. Push Notifications + Lazy Image + Skeleton + Error handling — UX e growth

### Dependências Técnicas

- Firebase SDK (SPM) para Push
- Permissões de Foto/Biometria/Notificações
- Endpoints REST estáveis e chaves de configuração

## Considerações Técnicas

### Decisões Principais

- **TCA** para previsibilidade, testabilidade e orquestração de efeitos.
- **Clients injetáveis** para REST e serviços de SO, isolando infraestrutura.
- **Biometria** para proteger dados de contato.
- **Compressão de imagens** antes de upload para reduzir latência e consumo.

### Riscos Conhecidos

- Variação/instabilidade dos contratos de API (mitigar com feature flags e versionamento)
- Tamanho de imagens e limites de upload (mitigar com compressão e chunking se necessário)
- Falhas de biometria/permíssões (caminhos de fallback claros)
- Entrega de push/latência de deep links (telemetria e fallback manual)

### Requisitos Especiais

- Performance: upload < 5s em redes 4G típicas após compressão; render liso (60fps) nas telas principais.
- Segurança: dados sensíveis apenas em memória; logs sem PII; biometria obrigatória para contato.
- Observabilidade: pontos de log para fluxos críticos; contadores de sucesso/falha.

### Conformidade com Padrões

- Seguir `@.cursor/rules/code-standards.md` (nomenclatura Swift, separação de camadas, TCA idiomática)
- Aderir ao Design System existente (cores, tipografia, componentes `Commons`)

### Arquivos relevantes

- Features: `Projects/Features/Negotiations/Sources/*`, `Projects/Features/Verification/Sources/*`
- Views: `Projects/Features/Negotiations/Sources/*.swift`, `Projects/Features/Verification/Sources/*.swift`
- Services: `SocialApp/Sources/Services/*` (Biometric, DeepLink, Push, Background)
- Commons: `SocialApp/Sources/Commons/*` (Counter, Badges, Skeleton, Error, LazyImage, StarRating)
- Cache: `Projects/Features/SellerProfile/Sources/SellerProfileCache.swift`