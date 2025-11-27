# Domain - Camada de Modelos de Negócio

## Estrutura Atual (Task 3.0 Completa)

Esta camada contém os modelos de domínio puros do aplicativo, organizados por contexto de negócio.

### Arquivos de Modelos de Domínio

#### 📁 `User.swift`
- `User` - Modelo principal de usuário
- `Profile` - Perfil detalhado do usuário

#### 📁 `Event.swift`
- `Event` - Evento principal
- `EventCategory` - Categorias de eventos
- `Location` - Localização do evento
- `Coordinate` - Coordenadas geográficas

#### 📁 `Ticket.swift`
- `Ticket` - Ingresso principal
- `TicketType` - Tipos de ingresso (VIP, Geral, etc.)
- `TicketStatus` - Status do ingresso (Disponível, Vendido, etc.)
- `TicketDetail` - Detalhes expandidos do ingresso

#### 📁 `Filter.swift`
- `SearchFilter` - Filtros de busca de eventos
- `FilterState` - Estado do filtro da UI
- `PriceRange` - Faixa de preço
- `DateRange` - Intervalo de datas
- `TicketsListFilter` - Filtros para lista de ingressos
- `TicketSortOption` - Opções de ordenação de ingressos

#### 📁 `Home.swift`
- `AppTab` - Abas da navegação principal
- `HomeContent` - Conteúdo da tela inicial
- `EventSection` - Seções de eventos (Curated, Trending)

#### 📁 `Negotiation.swift`
- `Negotiation` - Negociação entre comprador e vendedor
- `NegotiationStatus` - Status da negociação
- `NegotiationQuestion` - Perguntas na negociação
- `NegotiationAnswer` - Respostas às perguntas
- `QuestionCategory` - Categorias de perguntas
- `DocumentType` - Tipos de documentos
- `NegotiationDocument` - Documentos anexados à negociação

#### 📁 `Verification.swift`
- `VerificationLevel` - Níveis de verificação do usuário
- `UserVerification` - Verificação completa do usuário
- `ValidationStatus` - Status de validação
- `TicketValidation` - Validação de ingresso
- `ValidationProof` - Comprovantes de validação

#### 📁 `Review.swift`
- `Review` - Avaliação de usuário/transação

### Arquivos de Suporte

#### 📁 `APIModels.swift`
**TEMPORÁRIO** - Contém DTOs e modelos de API response que serão migrados para a camada Data na Task 4.0:
- Request models (LoginRequest, RegisterRequest, CreateTicketRequest, etc.)
- Response models (APIEventResponse, APITicketResponse, APIUserResponse, etc.)
- Generic wrappers (APIResponse, APIListResponse, etc.)
- Mappers (extensões com `toDomain()`)

#### 📁 `MockData.swift`
Dados mock para desenvolvimento e testes.

## Princípios

1. **Domínio Puro**: Sem dependências de SwiftUI, NetworkService ou frameworks externos
2. **Imutabilidade**: Preferência por `let` onde possível
3. **Value Types**: Uso de `struct` e `enum` (não `class`)
4. **Codable**: Todos os modelos implementam `Codable` para serialização
5. **Identifiable**: Modelos principais implementam `Identifiable`
6. **Sendable**: Modelos compartilhados entre threads marcados como `Sendable`

## Próximos Passos

**Task 4.0** - Criar Camada Data:
- Mover `APIModels.swift` para a camada Data
- Criar DTOs específicos (separados dos modelos de domínio)
- Implementar mappers claros `API → Domain`
- Configurar clients TCA para usar DTOs da camada Data

## Convenções de Nomenclatura

- Modelos de domínio: `User`, `Event`, `Ticket`
- DTOs de API: `APIUserResponse`, `APIEventResponse` (em APIModels.swift)
- Requests: `CreateTicketRequest`, `LoginRequest` (em APIModels.swift)
- Enums: sufixo descritivo (`EventCategory`, `TicketType`)
- Status/State: sufixo `Status` ou `State` (`NegotiationStatus`, `FilterState`)

