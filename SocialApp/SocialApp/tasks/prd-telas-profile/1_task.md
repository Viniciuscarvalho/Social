## status: pending

<task_context>
<domain>features/profile/view</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>swiftui|tca|theme</dependencies>
</task_context>

# Tarefa 1.0: Redesenhar ProfileView principal conforme Figma

## Visão Geral

Atualizar o layout da tela ProfileView removendo seções desnecessárias (Notificações, Configurações, Meus Eventos) e redesenhando o header com fundo azul escuro, mantendo apenas os links para Tickets, My Favorite, More e Logout. Adicionar ilustração de festival na parte inferior da tela.

<requirements>
- Header com fundo azul escuro (dark card) contendo avatar, nome, email e botão de editar como ícone
- Remover seções: Notificações, Configurações (Aparência/Privacidade), Meus Eventos
- Manter seção de estatísticas (Seguidores, Seguindo, Ingressos)
- Menu simplificado com 4 opções: Tickets, My Favorite, More, Logout
- Ilustração de festival na parte inferior
- Utilizar AppColors existentes
- Manter compatibilidade com tema claro/escuro
</requirements>

## Subtarefas

- [ ] 1.1 Redesenhar `profileHeaderView` com fundo azul escuro e botão de ícone
- [ ] 1.2 Remover `notificationsSection` e `settingsSection`
- [ ] 1.3 Criar nova seção `mainMenuSection` com 4 opções
- [ ] 1.4 Adicionar ilustração de festival no rodapé
- [ ] 1.5 Ajustar `ProfileFeature.State` removendo `pushNotifications`
- [ ] 1.6 Adicionar actions `moreMenuTapped` e `favoritesTapped`
- [ ] 1.7 Testar responsividade em light/dark mode

## Detalhes de Implementação

### 1.1 Novo Header
- Usar `RoundedRectangle` com `AppColors.cardBackground` e gradiente azul
- Avatar de 100x100 (aumentado de 80x80)
- Nome em `.title` (mais destacado)
- Email em `.subheadline`
- Botão de editar como `Image(systemName: "pencil.circle.fill")` no canto superior direito

### 1.3 Menu Principal
Criar 4 rows usando função `settingsRow`:
```swift
VStack(spacing: 0) {
    settingsRow(icon: "ticket.fill", iconColor: AppColors.accentGreen, 
                title: "Tickets", subtitle: "Gerenciar ingressos") {
        store.send(.myTicketsTapped)
    }
    Divider()
    settingsRow(icon: "heart.fill", iconColor: AppColors.favoriteRed, 
                title: "My Favorite", subtitle: "Eventos favoritos") {
        store.send(.favoritesTapped)
    }
    Divider()
    settingsRow(icon: "ellipsis.circle.fill", iconColor: AppColors.secondary, 
                title: "More", subtitle: "Configurações e suporte") {
        store.send(.moreMenuTapped)
    }
    Divider()
    settingsRow(icon: "rectangle.portrait.and.arrow.right", iconColor: AppColors.error, 
                title: "Logout", subtitle: "Sair da conta") {
        store.send(.signOutTapped)
    }
}
```

### 1.4 Ilustração
- Usar asset `empty_events` ou criar novo
- Posicionar após o menu principal
- Largura fixa de 300pt
- Padding vertical de 40pt

## Critérios de Sucesso

- ✅ Header exibe fundo azul com avatar centralizado
- ✅ Apenas 4 opções de menu visíveis
- ✅ Ilustração aparece na parte inferior
- ✅ Tema claro/escuro funciona corretamente
- ✅ Transições suaves entre seções
- ✅ Sem erros de compilação ou linter

## Arquivos relevantes
- `Projects/Features/Profile/ProfileView.swift`
- `Projects/Features/Profile/ProfileFeature.swift`
- `SocialApp/Sources/ThemeApp/AppColors.swift`
- `SocialApp/Resources/Assets.xcassets/empty_events.imageset/`


