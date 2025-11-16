# Tarefa 18.0: Criar UI de Galeria de Documentos (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Implementar componente para exibir thumbnails das fotos do ingresso com possibilidade de visualização em tela cheia, zoom e indicadores de status de verificação (pendente/aprovado/rejeitado).

## Subtarefas

- [ ] 18.1 Criar componente `DocumentGalleryView`
- [ ] 18.2 Implementar grid de thumbnails
- [ ] 18.3 Implementar carregamento de imagens (async)
- [ ] 18.4 Implementar visualização em tela cheia
- [ ] 18.5 Implementar zoom e pan na visualização
- [ ] 18.6 Implementar indicadores de status (badges)
- [ ] 18.7 Adicionar overlay com informações do documento
- [ ] 18.8 Implementar navegação entre documentos (swipe)
- [ ] 18.9 Adicionar botão de deletar documento (se permitido)
- [ ] 18.10 Implementar loading state para imagens
- [ ] 18.11 Adicionar tratamento de erros de carregamento
- [ ] 18.12 Integrar com NegotiationDetailsView

## Detalhes de Implementação

### Localização
- Arquivo: `SocialApp/Sources/Commons/DocumentGalleryView.swift`
- Criar novo arquivo

### Estrutura do Componente

```swift
struct DocumentGalleryView: View {
    let documents: [NegotiationDocument]
    @State private var selectedDocument: NegotiationDocument?
    @State private var showingFullScreen: Bool = false
    
    var body: some View {
        // Grid de thumbnails
        // Full screen viewer
    }
}
```

### Grid de Thumbnails

- Layout em grid (2 colunas)
- Thumbnails com aspect ratio mantido
- Badge de status sobreposto
- Tocar para abrir em tela cheia

### Visualização em Tela Cheia

- `fullScreenCover` ou `sheet` com imagem
- Zoom e pan usando `MagnificationGesture` e `DragGesture`
- Botão de fechar
- Navegação entre documentos com swipe

### Indicadores de Status

- **Pendente**: Badge laranja/cinza com ícone de clock
- **Aprovado**: Badge verde com checkmark
- **Rejeitado**: Badge vermelho com X

### Carregamento de Imagens

- Usar `AsyncImage` ou biblioteca de cache se necessário
- Mostrar placeholder enquanto carrega
- Tratar erros de carregamento

## Critérios de Sucesso

- [ ] Grid de thumbnails é exibido corretamente
- [ ] Imagens carregam de forma assíncrona
- [ ] Visualização em tela cheia funciona
- [ ] Zoom e pan funcionam adequadamente
- [ ] Indicadores de status são claros
- [ ] Navegação entre documentos funciona
- [ ] Loading e error states estão implementados
- [ ] Design segue padrões do app
- [ ] Performance é adequada (sem lag)
- [ ] Build do projeto compila sem erros

## Dependências

- **9.0**: Models devem estar criados
- **13.0**: NegotiationDetailFeature deve estar implementada
- **17.0**: Upload de documentos deve estar implementado

## Observações

- Considerar usar biblioteca de cache de imagens se necessário
- Otimizar para performance com muitas imagens
- Seguir padrões de UX do iOS para galerias

