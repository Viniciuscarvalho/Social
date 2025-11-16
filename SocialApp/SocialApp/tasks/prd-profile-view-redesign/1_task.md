# [1.0] Validar busca e filtros na tela de Explorar (S)

## Objetivo
- Garantir que `SearchBarView` está presente, funcional e alinhado com a UX (placeholder, ação de filtro, atualização de lista).

## Subtarefas
- [ ] 1.1 Confirmar binding `searchText` e ação `.searchTextChanged`
- [ ] 1.2 Verificar ação do botão de filtro e apresentação do sheet
- [ ] 1.3 Testar `.refreshable` e `.onAppear` para carregar/atualizar eventos
- [ ] 1.4 Cobrir casos: string vazia, categorias selecionadas e popular section

## Critérios de Sucesso
- `SearchBarView` visível e responsiva; sheet de filtro abre/fecha; lista responde a buscar/filtrar.

## Dependências
- Nenhuma

## Observações
- Conferir consistência de layout com header fixo em `EventsView`.


