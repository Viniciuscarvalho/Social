# Template de Documento de Requisitos de Produto (PRD)

## Visão Geral

A iniciativa **arquitetura-clean-tca** tem como objetivo reorganizar o app iOS em uma arquitetura modular clara, separando responsabilidades em quatro grandes áreas:
- **Domain**: modelos e regras de negócio puros (sem dependência de UI ou rede).
- **Data**: DTOs, mapeadores e acesso a dados (APIs, mocks, etc.).
- **Presentation**: Features TCA (State/Action/Reducer), Views SwiftUI e Stores.
- **Design System**: componentes visuais compartilhados, tema e animações.

Isso deve reduzir acoplamento entre camadas, remover lógica excessiva das Views, simplificar a navegação e facilitar a evolução do app.

## Objetivos

- Clarificar a separação entre **Domain**, **Data**, **Presentation** e **Design System**.
- Diminuir a quantidade de lógica de negócio nas Views SwiftUI, centralizando-a nas Features TCA.
- Organizar os modelos hoje concentrados em `Domain/Sources/Models.swift` em arquivos/coesas de domínio.
- Introduzir um **Design System** reutilizável (UI, tema, animações) alinhado ao Aivent Mobile App UI Kit e referências de makeanimated.dev.
- Padronizar a navegação global, tornando mais fácil seguir o fluxo entre Features.

## Histórias de Usuário

- Como **desenvolvedor iOS**, quero uma arquitetura modular clara (Domain/Data/Presentation/DS) para entender rapidamente onde implementar e manter cada tipo de lógica.
- Como **desenvolvedor iOS**, quero Features TCA com Views enxutas para conseguir testar e evoluir regras de negócio sem mexer diretamente na UI.
- Como **usuário final**, quero uma interface visualmente consistente, fluida e animada, com componentes e interações coerentes em todo o app.

## Funcionalidades Principais

1. **Camada Domain limpa**
   - Modelos de negócio (`User`, `Event`, `Ticket`, `Negotiation`, etc.) separados por contexto.
   - Sem DTOs de API, nem lógica de rede dentro de Domain.

2. **Camada Data**
   - DTOs e responses de API separados dos modelos de domínio.
   - Mapeadores claros (`toDomain()`) entre DTOs e Domain.

3. **Camada Presentation**
   - Features TCA organizadas em State/Action/Reducer, com Views apenas consumindo estado e disparando ações.
   - Navegação entre Features documentada e rastreável.

4. **Design System**
   - Tokens de tema (cores, tipografia, espaçamento, etc.).
   - Componentes base (botões, cards, listas, estados vazios, loadings).
   - Animações e microinterações inspiradas em Aivent Mobile App UI Kit e makeanimated.dev.

## Experiência do Usuário

- UI mais consistente e previsível em todas as telas.
- Animações sutis melhorando a percepção de fluidez (entradas de tela, feedback de tap, transições).
- Menos “quebras” visuais entre diferentes partes do app (mesmos componentes base sendo reutilizados).

## Restrições Técnicas de Alto Nível

- Manter o uso de **SwiftUI** e **The Composable Architecture (TCA)**.
- Evitar breaking changes drásticos no curto prazo: migração deve ser **incremental por contexto** (Users/Profile, Events/Tickets, Negotiations).
- Manter compatibilidade com o `NetworkService` atual, apenas extraindo DTOs/mappers da camada Domain.

## Não-Objetivos (Fora de Escopo)

- Reescrever completamente o backend ou contratos de API.
- Trocar TCA por outro framework de state management.
- Refazer todas as telas do zero em um único ciclo (a refatoração deve ser incremental).

## Questões em Aberto

- Nível de granularidade dos targets (módulos Swift Package separados vs. pastas internas): decidido inicialmente em Tech Spec, podendo evoluir depois.
- Prioridade de migração por contexto (começar por Profile/Users, Events/Tickets ou Negotiations).



