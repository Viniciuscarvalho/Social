# Tech Spec — Ajuste de Layout da Tela de Detalhes do Evento

## Arquitetura e Arquivos
- Tela alvo: `Projects/Features/Events/Sources/Details/EventDetailView.swift`
- Navegação: a ação do botão “Negociar ingresso” deve acionar fluxo para a lista de vendedores:
  - Se existir `EventsFeature`/`EventDetailFeature`, adicionar ação de navegação (ex.: `.showSellers(eventId)`).
  - Tela de vendedores (participantes com ingressos): reusar view existente se houver; caso contrário, placeholder navegável “Participants/Vendedores”.

## Regras de Layout
- Cabeçalho com imagem hero do evento; título e badge de categoria.
- Blocos informativos (cards/icons alinhados) para:
  - Preço (usar formatação local/PT-BR)
  - Data e horário (exibir range legível)
  - Localização (cidade/estado, venue)
- “Sobre o evento”: título e parágrafo com line height confortável, múltiplas linhas.
- “Localização”: mapa/placeholder com pin.
- Remover do layout:
  - Linha de “participantes”/avatars logo abaixo do título
  - Card “Event Organizer”
- Não alterar o botão “Negociar ingresso” (ação apenas direciona para lista de vendedores).

## Localização
- Adicionar chaves no `Localizable.xcstrings` para rótulos: “Sobre o evento”, “Localização”, “Preço”, “Data”, “Local”, “Comprar/Negociar” (sem alterar o botão de negociar — só garantir chave existente).

## Estados
- Loading do evento (skeleton simples).
- Erro (mensagem genérica e retry).

## Testes
- Snapshot da `EventDetailView` (layout principal).
- Teste de navegação do botão “Negociar ingresso” para lista de vendedores.




