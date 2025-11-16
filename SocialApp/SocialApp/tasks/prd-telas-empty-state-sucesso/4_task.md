## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>features/events</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>small</complexity>
<dependencies>2.0</dependencies>
</task_context>

# Tarefa 4.0: Implementar empty state de favoritos em FavoritesView

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Substituir o `ContentUnavailableView` em `FavoritesView` por um empty state customizado conforme o design das imagens, incluindo ícone de coração, mensagem explicativa e botão de ação.

<requirements>
- Atualizar `Projects/Features/Events/Sources/Favorites/FavoritesView.swift` (linhas 18-29)
- Substituir ContentUnavailableView por EmptyStateView ou componente customizado
- Ícone: `heart.fill` em círculo (rosa/preto conforme design)
- Título: "Nenhum Favorito Ainda" (localizado)
- Mensagem: "Toque no ícone de coração para salvar eventos que você ama e acessá-los a qualquer momento aqui" (localizado)
- Botão "Adicionar" que navega para a tela de eventos
- Usar EmptyStateView existente ou componente customizado
</requirements>

## Subtarefas

- [ ] 4.1 Adicionar chaves de localização no String Catalog
- [ ] 4.2 Substituir ContentUnavailableView por empty state customizado
- [ ] 4.3 Implementar ícone de coração em círculo rosa
- [ ] 4.4 Implementar botão "Adicionar" com navegação
- [ ] 4.5 Testar visualmente no simulador
- [ ] 4.6 Testar navegação do botão para eventos

## Detalhes de Implementação

A view atual usa `ContentUnavailableView` (linhas 18-29). Precisa ser substituída por:
- EmptyStateView customizado ou componente específico
- Ícone de coração (`heart.fill`) em círculo com fundo rosa claro
- Layout conforme design das imagens
- Botão que navega para tela de eventos (usar sistema de navegação existente)

**Estrutura sugerida**:
```swift
private var emptyStateView: some View {
    VStack(spacing: 24) {
        ZStack {
            Circle()
                .fill(Color.pink.opacity(0.1)) // Rosa claro
                .frame(width: 100, height: 100)
            
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundColor(.pink)
        }
        
        VStack(spacing: 8) {
            Text(String(localized: "empty_state.favorites.title"))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(String(localized: "empty_state.favorites.message"))
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        
        Button(action: {
            // Navegar para eventos
        }) {
            Text(String(localized: "empty_state.favorites.add_button"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primary)
                .cornerRadius(12)
        }
    }
    .padding(40)
}
```

**Navegação**: O botão deve usar o sistema de navegação existente. Verificar como FavoritesView se integra com o TabView principal.

## Critérios de Sucesso

- Empty state exibido corretamente quando não há favoritos
- Layout visualmente alinhado com o design da imagem
- Ícone de coração estilizado corretamente
- Botão "Adicionar" navega para eventos
- Textos localizados funcionando

## Arquivos relevantes
- `Projects/Features/Events/Sources/Favorites/FavoritesView.swift` (linhas 18-29 - empty state)
- `SocialApp/Resources/Localizable.xcstrings` (chaves de localização)
- `SocialApp/Sources/SocialAppView.swift` (referência de navegação entre tabs)


