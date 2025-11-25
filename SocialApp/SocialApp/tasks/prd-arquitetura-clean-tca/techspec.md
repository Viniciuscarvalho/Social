# Template de Especificação Técnica

## Resumo Executivo

Esta Tech Spec descreve a refatoração do app iOS para uma arquitetura modular com as camadas:
- **Domain**: modelos e regras de negócio puros.
- **Data**: DTOs, mappers e acesso a dados (API/mocks).
- **Presentation**: Features TCA (State/Action/Reducer), Views SwiftUI e Stores.
- **DesignSystem**: tokens de tema, componentes UI e animações compartilhadas.

O objetivo é reduzir acoplamento, tirar lógica de negócio das Views e tornar navegação e manutenção mais previsíveis.

## Arquitetura do Sistema

### Visão Geral dos Componentes

- **Domain**
  - Responsável por entidades de negócio (`User`, `Event`, `Ticket`, `Negotiation`, etc.) e lógica simples de domínio.
  - Não referencia `SwiftUI`, `NetworkService` nem DTOs de API.

- **Data**
  - Contém DTOs de API, responses e mappers (`APIUserResponse`, `APITicketResponse`, etc.).
  - Implementa conversões `toDomain()` para os modelos de `Domain`.
  - Depende de `Domain`, mas `Domain` não depende de `Data`.

- **Presentation**
  - Abriga as Features TCA existentes (`ProfileFeature`, `SellerProfileFeature`, `TicketDetailFeature`, etc.).
  - Organização interna: `Feature` (reducer), `Views` (SwiftUI), e entrypoints/Stores.
  - Consumirá somente tipos de domínio e services/clients expostos pela camada Data/SocialApp.

- **DesignSystem**
  - Tokens (cores, tipografia, espaçamentos, radius, sombras).
  - Componentes visuais base (botões, cards, list cells, badges, estados vazios, loaders).
  - Animações/microinterações (helpers, modifiers) baseadas em Aivent Mobile App UI Kit (ui8) e makeanimated.dev.

- **SocialApp (App Target)**
  - Composition root: orquestra navegação global (via `SocialAppFeature`/`SocialAppView`).
  - Injeta dependências (clients TCA) e faz o “wire-up” entre Domain, Data, Presentation e DesignSystem.

Fluxo de dados em alto nível:
`View (Presentation)` → `Feature TCA` → `Client/Service (Data)` → `NetworkService` → API → volta como DTO → `mapper` → `Domain` → `State`.

## Design de Implementação

### Interfaces Principais

- **Domain**
  - Structs e enums simples, sem protocolos de repositório por enquanto (TCA usa diretamente clients injetados).

- **Data**
  - Mappers no formato:
  ```swift
  extension APIUserResponse {
      func toUser() -> User { ... }
  }
  ```
  - Clients TCA (`UserClient`, `TicketsClient`, `NegotiationClient`) podem ficar em `SocialApp/Sources/Dependencies`, mas usando DTOs de `Data`.

### Modelos de Dados

- **Domain**
  - Arquivos separados por contexto:
    - `User.swift`, `Event.swift`, `Ticket.swift`, `Negotiation.swift`, `Verification.swift`, etc.

- **Data**
  - Arquivos como:
    - `APIUserResponse.swift`, `APITicketResponse.swift`, `APINegotiationResponse.swift`, `APIUserVerificationResponse.swift`, etc.
  - Cada DTO com seu `toDomain()` correspondente.

### Endpoints de API

- Mantêm os contratos já existentes (ex.: `/users/{id}`, `/tickets`, `/negotiations`, etc.).
- Tech Spec irá apenas referenciar as estruturas (DTOs) e mappers necessários para cada endpoint, reaproveitando `NetworkService`.

## Pontos de Integração

- **NetworkService**
  - Continua centralizando chamadas HTTP.
  - A camada `Data` configura endpoints, bodies e mapeia respostas para Domain.

- **TCA (The Composable Architecture)**
  - As Features continuam usando `@Dependency` para injetar clients.
  - Somente os tipos de domínio são expostos para a Presentation, nunca DTOs crus.

## Abordagem de Testes

### Testes Unitários

- Testar mappers (`APITicketResponse.toTicket()`, `APIUserResponse.toUser()`, etc.).
- Testar reducers das principais Features após extração de lógica de View para TCA.

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. Definir PRD e Tech Spec (este documento) para alinhar escopo e arquitetura.
2. Quebrar `Domain/Sources/Models.swift` em arquivos focados por contexto, deixando apenas domínio puro.
3. Criar camada `Data` com DTOs e mappers, ajustando clients existentes.
4. Reorganizar `Projects/Features` para separar Feature/Views/Stores, movendo lógica de Views para reducers.
5. Criar módulo/pasta `DesignSystem` com:
   - Fundamentos (tokens, tema, tipografia).
   - Componentes base (layout, botões, cards, etc.) inspirados no Aivent UI Kit.
   - Animações e microinterações inspiradas em makeanimated.dev.
6. Padronizar navegação global no composition root (`SocialAppFeature`/`SocialAppView`).
7. Migrar contextos (Users/Profile → Events/Tickets → Negotiations) usando as novas camadas.
8. Rodar testes, ajustar e limpar código legado.

### Dependências Técnicas

- Definição clara da estrutura de pastas/targets no projeto Xcode/Tuist.
- Manter compatibilidade com o `NetworkService` e clients TCA existentes durante a migração.

## Considerações Técnicas

### Decisões Principais

- Manter TCA como framework de state management.
- Usar `Domain` como fonte única da verdade para modelos de negócio.
- `Data` é a única camada que conhece formatos de API (DTOs).
- `DesignSystem` expõe APis estáveis de UI para o app, evitando que cada Feature crie seus próprios componentes visuais básicos.

### Riscos Conhecidos

- Migração grande: risco de regressões se feita em “big bang”.
- Dependências cruzadas entre Features atuais podem dificultar reorganização inicial.
- Possível necessidade de ajustes em testes existentes e mock data.

### Requisitos Especiais

- UI e animações devem seguir a linguagem visual do Aivent Mobile App UI Kit e referências de makeanimated.dev sempre que possível, respeitando limitações de tempo e escopo.

### Conformidade com Padrões

- Seguir o guia de estilo em `.cursor/rules/code-standards.md` (nomeação, organização em extensões, spacing, etc.).

### Arquivos relevantes

- `Domain/Sources/Models.swift` (ponto de partida para a divisão em múltiplos arquivos).
- `SocialApp/Sources/Dependencies/*.swift` (clients TCA).
- `Projects/Features/**` (Features TCA e Views SwiftUI).
- `SocialApp/Sources/ThemeApp/*` (tema atual, a ser movido para DesignSystem).


