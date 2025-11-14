## status: pending

<task_context>
<domain>features/profile/testing</domain>
<type>testing</type>
<scope>quality_assurance</scope>
<complexity>medium</complexity>
<dependencies>swiftui|simulator|devices</dependencies>
</task_context>

# Tarefa 8.0: Testes visuais e responsividade tema claro/escuro

## Visão Geral

Realizar testes visuais abrangentes em todas as novas telas (ProfileView, EditProfileView, MoreView, MyTicketsView com QR) garantindo responsividade em diferentes tamanhos de tela, temas (light/dark), e orientações. Verificar acessibilidade e performance.

<requirements>
- Testar em 3 tamanhos de dispositivo: SE, 14, 14 Pro Max
- Validar tema claro e escuro em todas as telas
- Testar landscape e portrait
- Verificar scroll em telas longas (EditProfileView)
- Validar comportamento com teclado aberto
- Checar acessibilidade (VoiceOver labels)
- Medir performance de QR Code generation
- Validar fluxo completo end-to-end
</requirements>

## Subtarefas

- [ ] 8.1 Criar previews para todos os estados (loading, erro, sucesso)
- [ ] 8.2 Testar ProfileView em light/dark mode
- [ ] 8.3 Testar EditProfileView com teclado e scroll
- [ ] 8.4 Testar MoreView e sub-views
- [ ] 8.5 Testar MyTicketsView com QR Codes
- [ ] 8.6 Validar acessibilidade (VoiceOver, Dynamic Type)
- [ ] 8.7 Testar em dispositivos físicos se possível
- [ ] 8.8 Documentar bugs encontrados e fixes aplicados

## Detalhes de Implementação

### 8.1 Previews Completos
```swift
#Preview("Profile - Empty State") {
    ProfileView(store: Store(initialState: ProfileFeature.State(user: nil)) {
        ProfileFeature()
    })
    .environment(ThemeManager.shared)
}

#Preview("Profile - Loaded") {
    ProfileView(store: Store(initialState: ProfileFeature.State(user: mockUser)) {
        ProfileFeature()
    })
    .environment(ThemeManager.shared)
}

#Preview("Profile - Loading") {
    var state = ProfileFeature.State(user: mockUser)
    state.isLoading = true
    
    return ProfileView(store: Store(initialState: state) {
        ProfileFeature()
    })
    .environment(ThemeManager.shared)
}

#Preview("Profile - Error") {
    var state = ProfileFeature.State(user: mockUser)
    state.error = "Erro ao carregar perfil"
    
    return ProfileView(store: Store(initialState: state) {
        ProfileFeature()
    })
    .environment(ThemeManager.shared)
}
```

### 8.2 Checklist de Testes - ProfileView
```
Light Mode:
□ Header exibe corretamente
□ Avatar carrega e placeholder funciona
□ Estatísticas (seguidores, seguindo, tickets) legíveis
□ Menu de 4 opções visível e clicável
□ Ilustração de festival aparece
□ Botão de logout em vermelho

Dark Mode:
□ Header mantém contraste
□ Cards não ficam invisíveis
□ Textos legíveis
□ Ícones com cores adequadas
□ Ilustração visível

Interatividade:
□ Tap em "Editar Perfil" abre modal
□ Tap em "Tickets" abre MyTickets
□ Tap em "More" navega para MoreView
□ Tap em "Logout" mostra confirmação
□ Pull-to-refresh atualiza dados
```

### 8.3 Checklist de Testes - EditProfileView
```
Layout:
□ Avatar grande no topo centralizado
□ Botão de câmera sobreposto
□ Inputs de nome, phone, email alinhados
□ Chips de interesses em grid responsivo
□ Botão Save fixo na base ou scroll junto

Teclado:
□ View scrolls quando teclado abre
□ Inputs não ficam cobertos pelo teclado
□ Tap fora do campo fecha teclado
□ Country code picker funciona

Interação:
□ Tap em chip seleciona/deseleciona
□ Animação suave na transição
□ Múltipla seleção funciona
□ Botão Save ativo apenas se nome preenchido
□ Save persiste mudanças e fecha modal
□ Loading indicator durante save
```

### 8.4 Checklist de Testes - MoreView
```
Navegação:
□ Header "More" exibe corretamente
□ Botão voltar funciona
□ Tap em FAQs navega
□ Tap em Privacy Policy navega
□ Tap em Contact Us navega
□ Tap em Delete Account mostra alert

Alert de Delete:
□ Mensagem clara
□ Botões Cancel e Delete
□ Cancel fecha alert
□ Delete executa ação (placeholder por ora)

Layout:
□ Ilustração de festival na base
□ Ícones coloridos corretos
□ Delete Account em vermelho
□ Spacing adequado
```

### 8.5 Checklist de Testes - MyTicketsView
```
QR Code:
□ QR Code gerado corretamente
□ Escaneável (testar com app de câmera)
□ Tamanho adequado (80x80)
□ Fundo branco visível
□ Performance OK (não trava ao scroll)

Layout:
□ Tabs Upcoming/Past funcionam
□ Cards mostram QR à direita
□ Data formatada como "Feb, Mon 20, 2025"
□ "Ticket : XX" exibido
□ Empty state quando sem tickets
□ Swipe to delete funciona (se owner)

Performance:
□ Scroll smooth com múltiplos tickets
□ QR Code não regenera a cada scroll
□ Transição entre tabs instant
```

### 8.6 Acessibilidade
```swift
// Adicionar labels em todos os elementos interativos:
Button(action: { ... }) {
    Image(systemName: "pencil.circle.fill")
        .accessibilityLabel("Edit profile")
}

QRCodeView(data: ticket.id, size: 80)
    .accessibilityLabel("QR Code for ticket \(ticket.name)")
    .accessibilityHint("Scan to view ticket details")

Image("empty_events")
    .accessibilityLabel("Festival illustration")
    .accessibilityHidden(true) // Se decorativo apenas
```

### 8.7 Testes em Dispositivos
```
Simulators:
□ iPhone SE (3rd gen) - 4.7" small
□ iPhone 14 - 6.1" medium
□ iPhone 14 Pro Max - 6.7" large

Devices Físicos (se possível):
□ iPhone 8 ou similar (iOS 16+)
□ iPhone 14 ou similar (iOS 17+)
□ iPad (landscape mode)

Orientações:
□ Portrait primary
□ Landscape (verificar se layouts quebram)
```

### 8.8 Performance Checklist
```
Métricas:
□ Tempo de load do ProfileView < 500ms
□ QR Code generation < 100ms
□ Scroll FPS > 55fps
□ Memory usage estável (sem leaks)
□ Nenhum crash ao navegar entre telas

Instruments:
□ Rodar Time Profiler
□ Rodar Leaks
□ Rodar Allocations
□ Verificar se há retain cycles
```

## Critérios de Sucesso

- ✅ Todas as telas renderizam corretamente em light/dark
- ✅ Responsivo em 3 tamanhos de dispositivo
- ✅ Teclado não cobre inputs
- ✅ QR Codes são escaneáveis
- ✅ Navegação fluida sem crashes
- ✅ VoiceOver labels presentes
- ✅ Performance adequada (> 55fps scroll)
- ✅ Sem memory leaks
- ✅ Documentação de bugs/fixes completa

## Arquivos relevantes
- `Projects/Features/Profile/ProfileView.swift`
- `Projects/Features/Profile/ProfileFeature.swift`
- `Projects/Features/Profile/MoreView.swift`
- `Projects/Features/TicketsList/Sources/MyTicketsView.swift`
- `SocialApp/Sources/Commons/QRCodeView.swift`
- `SocialApp/Sources/Commons/InterestChip.swift`

## Documentação de Bugs
Criar arquivo `tasks/prd-telas-profile/bugs_encontrados.md`:
```markdown
# Bugs Encontrados Durante Testes

## Bug #1: QR Code regenera a cada scroll
**Severidade**: Média
**Descrição**: QR Code é gerado novamente cada vez que o card sai e volta para a viewport
**Fix**: Adicionar cache de imagem gerada
**Status**: Resolvido

## Bug #2: Teclado cobre botão Save
**Severidade**: Alta
**Descrição**: Em EditProfileView, teclado cobre botão Save em iPhone SE
**Fix**: Adicionar `.scrollDismissesKeyboard(.interactively)` e padding bottom
**Status**: Resolvido
```


