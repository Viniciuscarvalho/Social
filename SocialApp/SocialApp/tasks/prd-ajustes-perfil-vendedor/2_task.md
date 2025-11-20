# Tarefa 2.0: Ajustar tela de perfil do vendedor para exibir "Vendedor" e lista de ingressos (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa envolve ajustar a tela de perfil do vendedor para exibir o título "Vendedor" (ao invés de "Organizer") e mostrar lista de ingressos do vendedor ao invés de eventos. A tela deve manter as estatísticas do vendedor (seguidores, seguindo, etc.) e permitir navegação para detalhes dos ingressos.

<requirements>
- Alterar título da tela de "Organizer" para "Vendedor"
- Substituir lista de eventos por lista de ingressos do vendedor
- Carregar ingressos do vendedor via API
- Exibir ingressos em formato de cards/listagem
- Permitir navegação para detalhe do ingresso ao clicar
- Manter estatísticas do vendedor (seguidores, seguindo, etc.)
</requirements>

## Subtarefas

- [ ] 2.1 Alterar título "Organizer" para "Vendedor" na SellerProfileView
- [ ] 2.2 Adicionar estado para lista de ingressos na SellerProfileFeature
- [ ] 2.3 Implementar ação para carregar ingressos do vendedor
- [ ] 2.4 Ajustar SellerProfileClient para buscar ingressos por vendedor (ou criar novo endpoint)
- [ ] 2.5 Substituir lista de eventos por lista de ingressos na UI
- [ ] 2.6 Implementar navegação para detalhe do ingresso
- [ ] 2.7 Testar carregamento e exibição de ingressos
- [ ] 2.8 Testar navegação para detalhe do ingresso

## Detalhes de Implementação

### Alteração de Título

1. Localizar onde o título "Organizer" é exibido na `SellerProfileView`
2. Substituir por "Vendedor"
3. Verificar se há outros lugares onde "Organizer" aparece e ajustar

### Lista de Ingressos

Conforme especificado na techspec.md:

1. Adicionar `sellerTickets: [Ticket]` e `isLoadingTickets: Bool` no estado
2. Criar ação `loadSellerTickets(sellerId: String)`
3. No reducer, chamar client para buscar ingressos: `fetchSellerTickets(sellerId)`
4. Atualizar UI para exibir ingressos ao invés de eventos
5. Cada ingresso deve exibir informações relevantes (evento, preço, disponibilidade)

Referência: Seção "SellerProfileFeature (ajustes)" e "Endpoints de API" na techspec.md

## Critérios de Sucesso

- Título da tela exibe "Vendedor" (não "Organizer")
- Lista de ingressos do vendedor é carregada e exibida corretamente
- Ingressos são exibidos em formato de cards/listagem com informações relevantes
- Estado de loading é exibido durante carregamento
- Erros de carregamento são tratados adequadamente
- Ao clicar em um ingresso, navega para detalhe do ingresso ou inicia negociação
- Estatísticas do vendedor continuam sendo exibidas
- Testes unitários cobrem carregamento e exibição de ingressos

## Dependências

- Tarefa 1.0 (navegação para perfil de vendedor deve estar funcionando)
- Endpoint de backend para listar ingressos por vendedor (pode ser implementado na tarefa 5.0)

## Arquivos relevantes

- `Projects/Features/SellerProfile/Sources/SellerProfileView.swift`
- `Projects/Features/SellerProfile/Sources/SellerProfileFeature.swift`
- `SocialApp/Sources/Dependencies/SellerProfileClient.swift` (ou similar)
- Modelos de dados: `Ticket`, `Seller`

## status: pending

<task_context>
<domain>features/seller_profile</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>api_endpoints</dependencies>
</task_context>

