# PRD — Perfil do Vendedor

## Contexto
Usuários podem acessar o perfil de um vendedor a partir do detalhe do evento/ticket. A tela deve refletir o termo “Vendedor” (não “Organizer”), manter estatísticas do vendedor e listar ingressos disponíveis, com navegação ao detalhe do ticket.

## Objetivos
- Substituir rótulos “Organizer/Organizer Profile” por “Vendedor”.
- Mostrar contadores: Ingressos, Seguidores, Seguindo.
- Ocultar botão “Seguir” quando o perfil for do próprio usuário.
- Exibir lista de ingressos disponíveis do vendedor usando layout de tickets.
- Ao tocar em um ticket, abrir o detalhe do ticket.
- Ajustar layout para igualar aos mockups fornecidos.

## Requisitos Funcionais
1. Renomear “Organizer” → “Vendedor” em títulos, seções e cartões relevantes.
2. Exibir estatísticas do vendedor: `ticketsCount`, `followersCount`, `followingCount`.
3. Se `currentUserId == sellerId`, não renderizar botão “Seguir”.
4. Aba “Ingressos” lista tickets do vendedor em cards no estilo dos mockups.
5. Toque no card do ticket navega para o detalhe do ticket (deep-link por `ticket.id`).
6. Layout, espaçamentos e tipografia conforme mockups anexos.

## Requisitos Não Funcionais
- Manter performance de scroll suave.
- Acessibilidade mínima: tamanhos de toque e contraste adequados.
- Seguir padrões de theming existentes.

## Fora de Escopo
- CRUD de tickets do vendedor.
- Fluxos de compra/venda.

## Métricas de Sucesso
- Zero regressões de navegação para detalhe de ticket.
- Botão “Seguir” não aparece no próprio perfil.
- Layout visual aprovado pelos mockups.



