# Especificação Técnica: Ajustes de Perfil e Fluxo de Vendedor

## Resumo Executivo

Os ajustes serão implementados seguindo a arquitetura TCA (The Composable Architecture) já estabelecida no projeto. As mudanças envolvem principalmente ajustes em features existentes (Profile, SellerProfile, EventDetail) e possíveis ajustes em clients de API para suportar novos filtros. A seleção de tema será reintroduzida na tela de perfil utilizando o `ThemeManager` existente. O fluxo de negociação será corrigido para direcionar para lista de vendedores por evento ao invés de lista completa de ingressos.

## Arquitetura do Sistema

### Visão Geral dos Componentes

As mudanças afetam as seguintes features existentes:

1. **ProfileFeature**: Gerencia estado e ações da tela de perfil do usuário
2. **SellerProfileFeature**: Gerencia estado e ações da tela de perfil do vendedor
3. **EventDetailFeature**: Gerencia estado e ações da tela de detalhe do evento
4. **NegotiationsFeature**: Pode precisar de ajustes para suportar navegação a partir de lista de vendedores

**Relacionamentos**:
- `ProfileFeature` navega para `SellerProfileFeature` quando usuário clica no card do vendedor
- `EventDetailFeature` navega para lista de vendedores quando usuário clica em "Negociar ingresso"
- Lista de vendedores pode navegar para `SellerProfileFeature` ou iniciar negociação
- `SellerProfileFeature` exibe ingressos do vendedor ao invés de eventos

**Fluxo de dados**:
- User actions → Feature Actions → Reducer → Client (API) → NetworkService → Backend API
- Backend API → NetworkService → Client → Feature State → UI Update

## Design de Implementação

### Interfaces Principais

#### ProfileFeature (ajustes)

A feature de perfil precisará incluir:
- Ação para navegar para perfil de vendedor
- Integração com ThemeManager para seleção de tema

```swift
// Ações adicionais necessárias
enum ProfileAction {
  // ... ações existentes
  case navigateToSellerProfile(sellerId: String)
  case themeSelectionChanged(ColorScheme?)
}
```

#### SellerProfileFeature (ajustes)

A feature de perfil do vendedor precisará:
- Alterar título de "Organizer" para "Vendedor"
- Carregar ingressos do vendedor ao invés de eventos
- Ajustar UI para exibir ingressos

```swift
// Estado ajustado
struct SellerProfileState {
  // ... campos existentes
  var sellerTickets: [Ticket] = []
  var isLoadingTickets: Bool = false
  // Remover ou ajustar eventos se existir
}
```

#### EventDetailFeature (ajustes)

A feature de detalhe do evento precisará:
- Remover botão "Salvar para depois"
- Ajustar ação de "Negociar ingresso" para navegar para lista de vendedores

```swift
// Ações ajustadas
enum EventDetailAction {
  // ... ações existentes
  case negotiateTicketTapped // Deve navegar para lista de vendedores do evento
  // Remover ação relacionada a "Salvar para depois"
}
```

#### SellersClient (novo ou ajuste)

Pode ser necessário criar ou ajustar um client para buscar vendedores por evento:

```swift
@DependencyClient
public struct SellersClient {
  public var fetchSellersByEvent: (String) async throws -> [Seller]
  public var fetchSellerTickets: (String) async throws -> [Ticket]
}
```

### Modelos de Dados

Os modelos existentes devem ser suficientes, mas pode ser necessário ajustar:

```swift
// Seller pode precisar de campos adicionais se não existirem
public struct Seller: Codable, Identifiable, Equatable {
  public var id: String
  public var name: String
  public var photo: String?
  public var ticketsCount: Int
  public var followersCount: Int
  public var followingCount: Int
  // ... outros campos
}

// Ticket deve ter relação com evento
public struct Ticket: Codable, Identifiable, Equatable {
  public var id: String
  public var eventId: String
  public var sellerId: String
  public var price: Double
  // ... outros campos
}
```

### Endpoints de API

#### Backend - Listar Vendedores por Evento

**Endpoint**: `GET /api/v1/events/{eventId}/sellers`

**Descrição**: Retorna lista de vendedores que possuem ingressos disponíveis para o evento especificado.

**Request**:
- Path parameter: `eventId` (String)

**Response**:
```json
{
  "sellers": [
    {
      "id": "seller-123",
      "name": "João Silva",
      "photo": "https://...",
      "ticketsCount": 5,
      "minPrice": 50.00,
      "maxPrice": 150.00
    }
  ]
}
```

#### Backend - Listar Ingressos por Vendedor

**Endpoint**: `GET /api/v1/sellers/{sellerId}/tickets`

**Descrição**: Retorna lista de ingressos disponíveis de um vendedor específico.

**Request**:
- Path parameter: `sellerId` (String)

**Response**:
```json
{
  "tickets": [
    {
      "id": "ticket-123",
      "eventId": "event-456",
      "eventName": "Show de Rock",
      "price": 100.00,
      "available": true
    }
  ]
}
```

## Pontos de Integração

### ThemeManager

O `ThemeManager` já existe no projeto e deve ser utilizado:

```swift
// Uso na ProfileView
@State private var themeManager = ThemeManager.shared

// Componente de seleção de tema
ThemeToggleView(themeManager: themeManager)
```

### API Clients

- **SellersClient**: Pode precisar ser criado ou ajustado para suportar novos endpoints
- **TicketsClient**: Pode precisar de ajustes para buscar ingressos por vendedor
- **EventsClient**: Pode precisar de ajustes para buscar vendedores por evento

## Abordagem de Testes

### Testes Unitários

**ProfileFeature**:
- Testar ação `navigateToSellerProfile` atualiza estado de navegação corretamente
- Testar ação `themeSelectionChanged` atualiza ThemeManager

**SellerProfileFeature**:
- Testar carregamento de ingressos do vendedor
- Testar exibição de título "Vendedor"
- Testar navegação para detalhe do ingresso

**EventDetailFeature**:
- Testar remoção do botão "Salvar para depois"
- Testar ação `negotiateTicketTapped` navega para lista de vendedores

**SellersClient**:
- Mock de `fetchSellersByEvent` retorna vendedores corretos
- Mock de `fetchSellerTickets` retorna ingressos corretos

### Testes de Integração

- Testar fluxo completo: Perfil → Vendedor → Ingressos
- Testar fluxo completo: Evento → Negociar → Lista de Vendedores → Negociação

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. **Ajustar ProfileFeature para incluir seleção de tema e navegação para vendedor**
   - Por que primeiro: Base para outras funcionalidades
   - Dependências: ThemeManager (já existe)

2. **Ajustar SellerProfileFeature para exibir "Vendedor" e ingressos**
   - Por que segundo: Depende de navegação do perfil
   - Dependências: Endpoint de ingressos por vendedor (pode precisar de ajuste no backend)

3. **Ajustar EventDetailFeature para remover botão e corrigir navegação**
   - Por que terceiro: Fluxo independente mas relacionado
   - Dependências: Endpoint de vendedores por evento (pode precisar de ajuste no backend)

4. **Implementar ou ajustar SellersClient e endpoints de backend**
   - Por que quarto: Suporta funcionalidades anteriores
   - Dependências: Definição de contratos de API

5. **Implementar tela de lista de vendedores por evento**
   - Por que quinto: Completa o fluxo de negociação
   - Dependências: SellersClient e EventDetailFeature

6. **Testes e integração**
   - Por que último: Valida todas as mudanças
   - Dependências: Todas as features anteriores

### Dependências Técnicas

- **Backend**: Pode ser necessário implementar ou ajustar endpoints:
  - `GET /api/v1/events/{eventId}/sellers`
  - `GET /api/v1/sellers/{sellerId}/tickets`
- **ThemeManager**: Já existe, apenas precisa ser integrado na UI
- **TCA**: Já estabelecido no projeto

## Considerações Técnicas

### Decisões Principais

1. **Reutilizar ThemeManager existente**: O `ThemeManager` já existe e funciona, apenas precisa ser exposto na UI da tela de perfil.

2. **Criar nova feature para lista de vendedores ou reutilizar**: Avaliar se é melhor criar uma nova feature `SellersListFeature` ou ajustar feature existente. Recomendação: criar nova feature para manter separação de responsabilidades.

3. **Backend vs Frontend para filtros**: Decidir se filtro de vendedores por evento será feito no backend (recomendado para performance) ou no frontend (mais simples mas menos eficiente).

### Riscos Conhecidos

1. **Endpoints de backend podem não existir**: Pode ser necessário implementar endpoints novos ou ajustar existentes.
   - **Mitigação**: Validar endpoints existentes primeiro, criar mocks para desenvolvimento se necessário.

2. **Performance com muitos vendedores/ingressos**: Listas podem ficar lentas se não houver paginação.
   - **Mitigação**: Implementar paginação ou lazy loading se necessário.

3. **Sincronização de dados**: Ingressos podem mudar enquanto usuário visualiza.
   - **Mitigação**: Implementar refresh ou atualização automática se necessário.

### Requisitos Especiais

- **Performance**: Listagens devem carregar em menos de 2 segundos
- **Acessibilidade**: Todos os componentes devem suportar VoiceOver
- **Localização**: Textos devem usar String Catalog para suportar múltiplos idiomas

### Conformidade com Padrões

Conforme `.cursor/rules/code-standards.md`:

- Usar extensões para organizar código (`// MARK: -`)
- Seguir convenções de nomenclatura Swift (camelCase, UpperCamelCase)
- Usar `guard` para early returns (Golden Path)
- Evitar uso desnecessário de `self`
- Usar type inference quando possível
- Organizar imports de forma mínima
- Usar trailing closures quando apropriado
- Manter funções curtas e focadas

### Arquivos relevantes

**iOS**:
- `Projects/Features/Profile/ProfileView.swift`
- `Projects/Features/Profile/ProfileFeature.swift`
- `Projects/Features/SellerProfile/Sources/SellerProfileView.swift`
- `Projects/Features/SellerProfile/Sources/SellerProfileFeature.swift`
- `Projects/Features/Events/Sources/EventDetailView.swift` (ou similar)
- `Projects/Features/Events/Sources/EventDetailFeature.swift` (ou similar)
- `SocialApp/Sources/ThemeApp/ThemeManager.swift`
- `SocialApp/Sources/ThemeApp/ThemeToggleView.swift` (se existir)

**Backend** (se necessário):
- Endpoints de API para vendedores e ingressos
- Contratos de API/documentação


