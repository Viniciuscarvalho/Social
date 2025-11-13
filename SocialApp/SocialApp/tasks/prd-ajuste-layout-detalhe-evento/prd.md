# PRD — Ajuste de Layout da Tela de Detalhes do Evento

## Contexto
Usuários acessam a tela de detalhes do evento para entender rapidamente informações essenciais (preço, data/hora, local) e iniciar a negociação de ingressos. O layout atual precisa alinhar-se ao design anexado.

## Problema
- Layout desalinhado do design de referência.
- Elementos extras que não devem ser implementados (participantes abaixo do nome do evento e área “Event Organizer”).
- Ação de “Negociar ingresso” deve levar à lista de vendedores do evento.

## Objetivos
- Adequar o layout da `EventDetailView` ao anexo (tipografia, espaçamentos, hierarquia).
- Exibir seções: preço, data/hora, localização, “Sobre o evento” e mapa/placeholder.
- Conectar o botão “Negociar ingresso” à tela de vendedores do evento.

## Fora de Escopo
- Não implementar as imagens de participantes abaixo do nome do evento.
- Não implementar a área/box “Event Organizer”.
- Não alterar o botão “Negociar ingresso” (texto, estilo e posição permanecem).

## Requisitos Funcionais
1. Layout atualizado conforme anexo: título, badges, blocos de informação (preço, data/hora, local), seção “Sobre o evento”, mapa/placeholder.
2. Botão “Negociar ingresso” navega para a lista de vendedores do evento selecionado.
3. Estados de carregamento/erro para dados do evento.

## Requisitos Não Funcionais
- Acessibilidade básica: suportar Dynamic Type e rotulagem para VoiceOver.
- Textos via String Catalog pt-BR.

## Critérios de Aceite
- Elementos não solicitados ausentes: sem “participantes” e sem “Event Organizer”.
- Navegação para a lista de vendedores do evento funciona.
- Layout visualmente alinhado ao anexo (margens, fontes, hierarquia).





