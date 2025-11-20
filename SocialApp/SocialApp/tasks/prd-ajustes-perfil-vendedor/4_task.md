# Tarefa 4.0: Implementar tela de lista de vendedores por evento (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa envolve criar uma nova tela que lista vendedores que possuem ingressos disponíveis para um evento específico. Esta tela será acessada quando o usuário clicar em "Negociar ingresso" no detalhe do evento. A tela deve exibir informações relevantes de cada vendedor e permitir navegação para perfil do vendedor ou início de negociação.

<requirements>
- Criar nova feature SellersListFeature para gerenciar estado e ações
- Criar SellersListView para exibir lista de vendedores
- Integrar com endpoint de API para buscar vendedores por evento
- Exibir informações relevantes de cada vendedor (nome, foto, preço, etc.)
- Permitir navegação para perfil do vendedor
- Permitir iniciar negociação a partir da lista
- Conectar navegação do EventDetailFeature para esta tela
</requirements>

## Subtarefas

- [ ] 4.1 Criar SellersListFeature com estado e ações
- [ ] 4.2 Criar SellersListView com layout de lista de vendedores
- [ ] 4.3 Integrar SellersClient para buscar vendedores por evento
- [ ] 4.4 Implementar card/componente para exibir vendedor na lista
- [ ] 4.5 Implementar navegação para SellerProfileView ao clicar no vendedor
- [ ] 4.6 Implementar ação para iniciar negociação a partir da lista
- [ ] 4.7 Conectar EventDetailFeature para navegar para SellersListView
- [ ] 4.8 Implementar estados de loading e erro
- [ ] 4.9 Testar carregamento e exibição de vendedores
- [ ] 4.10 Testar navegações e fluxo completo

## Detalhes de Implementação

### Nova Feature

Conforme especificado na techspec.md, criar nova feature seguindo padrão TCA:

1. **SellersListFeature**:
   - Estado: `eventId`, `sellers: [Seller]`, `isLoading`, `error`
   - Ações: `loadSellers`, `sellerTapped`, `startNegotiation`
   - Reducer: Carrega vendedores via `SellersClient.fetchSellersByEvent`

2. **SellersListView**:
   - Exibe lista de vendedores em formato de cards
   - Cada card mostra: nome, foto, preço do ingresso (min/max), quantidade disponível
   - Permite toque para navegar ou iniciar negociação

3. **Integração**:
   - `EventDetailFeature` navega para `SellersListView` quando `negotiateTicketTapped`
   - Passa `eventId` como parâmetro

Referência: Seção "SellersClient (novo ou ajuste)" e "Endpoints de API" na techspec.md

## Critérios de Sucesso

- Tela de lista de vendedores é criada e exibida corretamente
- Lista exibe apenas vendedores que possuem ingressos do evento especificado
- Cada vendedor exibe informações relevantes (nome, foto, preço, etc.)
- Estado de loading é exibido durante carregamento
- Erros são tratados e exibidos adequadamente
- Ao clicar em um vendedor, navega para perfil do vendedor ou inicia negociação
- Navegação a partir do detalhe do evento funciona corretamente
- Testes unitários cobrem feature e navegações
- Testes de integração validam fluxo completo

## Dependências

- Tarefa 3.0 (ajuste da tela de detalhe do evento)
- Tarefa 5.0 (endpoint de backend para vendedores por evento - pode ser desenvolvido em paralelo)

## Arquivos relevantes

- `Projects/Features/SellersList/Sources/SellersListFeature.swift` (novo)
- `Projects/Features/SellersList/Sources/SellersListView.swift` (novo)
- `SocialApp/Sources/Dependencies/SellersClient.swift` (novo ou ajuste)
- `Projects/Features/Events/Sources/EventDetailFeature.swift` (ajuste)

## status: pending

<task_context>
<domain>features/sellers_list</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>api_endpoints,event_detail</dependencies>
</task_context>

