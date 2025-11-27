# DesignSystem - Fundamentos

## Visão Geral

O **DesignSystem** é um módulo centralizado que define tokens de design, componentes visuais e padrões de UI reutilizáveis para todo o app. Baseado no **Aivent Mobile App UI Kit** e adaptado para iOS com suporte completo a light/dark mode.

## Estrutura do Módulo

```
DesignSystem/
├── Project.swift
├── Sources/
│   ├── Tokens/
│   │   ├── DSColors.swift          ✨ Sistema de cores
│   │   ├── DSTypography.swift      ✨ Tipografia e fontes
│   │   ├── DSSpacing.swift         ✨ Espaçamento
│   │   ├── DSRadius.swift          ✨ Corner radius
│   │   └── DSGradients.swift       ✨ Gradientes pré-definidos
│   ├── Theme/
│   │   └── Theme.swift             ✨ Gerenciamento de tema
│   ├── Components/
│   │   ├── DSButton.swift          🔘 Botões padronizados
│   │   ├── DSCard.swift            🃏 Cards e layouts
│   │   ├── DSBadge.swift           🏷️ Badges e tags
│   │   ├── DSEmptyState.swift      📭 Estados vazios
│   │   ├── DSLoading.swift         ⏳ Loading indicators
│   │   └── DSListCell.swift        📋 Células de lista
│   ├── Animations/
│   │   ├── DSAnimations.swift      🎬 Animações e presets
│   │   ├── DSMicroInteractions.swift 🎯 Microinterações
│   │   ├── DSSwipeGestures.swift   👆 Swipe gestures
│   │   ├── DSPullToRefresh.swift   🔄 Pull-to-refresh
│   │   └── DSViewTransitions.swift 🎭 Transições de view
│   └── Utilities/
│       └── ViewModifiers.swift     🛠️ View modifiers
└── README.md
```

## Tokens de Design

### 🎨 DSColors

Sistema completo de cores com suporte a light/dark mode.

#### Cores de Brand
```swift
DSColors.primary           // Cor principal do app
DSColors.secondary         // Cor secundária
DSColors.accentGreen       // Verde limão (#a0f064)
DSColors.accentBlue        // Azul vibrante (#4a90e2)
```

#### Cores de Background
```swift
DSColors.background                 // Background principal
DSColors.backgroundSecondary        // Cards, sections
DSColors.backgroundTertiary         // Input fields
DSColors.backgroundGrouped          // Listas agrupadas
```

#### Cores de Texto
```swift
DSColors.textPrimary        // Texto principal
DSColors.textSecondary      // Subtítulos
DSColors.textTertiary       // Placeholders
DSColors.textQuaternary     // Disabled text
```

#### Cores Semânticas
```swift
DSColors.success           // Verde - sucesso
DSColors.warning           // Laranja - avisos
DSColors.error             // Vermelho - erros
DSColors.info              // Azul - informações
```

#### Cores Especiais
```swift
DSColors.glassBackground    // Efeito glassmorphism
DSColors.shadow             // Sombras adaptativas
DSColors.overlay            // Overlay escuro
DSColors.border             // Bordas padrão
```

#### Uso com Extensions
```swift
Text("Hello")
  .foregroundColor(.dsTextPrimary)  // Atalho

Rectangle()
  .fill(.dsGlass)  // Glassmorphism
```

### ✏️ DSTypography

Sistema tipográfico baseado no iOS Human Interface Guidelines.

#### Estilos Pré-definidos
```swift
DSTypography.largeTitle     // 34pt, Bold
DSTypography.title1         // 28pt, Bold
DSTypography.title2         // 22pt, Bold
DSTypography.title3         // 20pt, Semibold
DSTypography.headline       // 17pt, Semibold
DSTypography.body           // 17pt, Regular
DSTypography.bodyEmphasized // 17pt, Medium
DSTypography.subheadline    // 15pt, Regular
DSTypography.footnote       // 13pt, Regular
DSTypography.caption1       // 12pt, Regular
DSTypography.caption2       // 11pt, Regular
```

#### Extensions para Text
```swift
Text("Título Principal")
  .dsTitle1()  // Aplica estilo + cor automática

Text("Corpo do texto")
  .dsBody()

Text("Legenda pequena")
  .dsCaption()
```

#### Font Customizado
```swift
DSTypography.font(size: .title2, weight: .bold)
```

### 📏 DSSpacing

Escala de espaçamento baseada em múltiplos de 4pt.

#### Escala de Spacing
```swift
DSSpacing.none    // 0pt
DSSpacing.xxxs    // 2pt
DSSpacing.xxs     // 4pt
DSSpacing.xs      // 8pt
DSSpacing.sm      // 12pt
DSSpacing.md      // 16pt  ← Padrão mais comum
DSSpacing.lg      // 20pt
DSSpacing.xl      // 24pt
DSSpacing.xxl     // 32pt
DSSpacing.xxxl    // 40pt
DSSpacing.huge    // 48pt
```

#### Spacing Semântico
```swift
DSSpacing.screenPaddingHorizontal  // 16pt
DSSpacing.cardPadding              // 16pt
DSSpacing.cardSpacing              // 12pt
DSSpacing.stackSpacing             // 12pt
DSSpacing.sectionSpacing           // 24pt
```

#### Corner Radius (DSRadius)
```swift
DSRadius.none     // 0pt
DSRadius.xs       // 6pt
DSRadius.sm       // 8pt
DSRadius.md       // 12pt  ← Padrão cards
DSRadius.lg       // 16pt
DSRadius.xl       // 20pt
DSRadius.circle   // 999pt (círculo)

// Semantic
DSRadius.card            // 12pt
DSRadius.button Small    // 8pt
DSRadius.buttonMedium    // 12pt
DSRadius.input           // 8pt
DSRadius.modal           // 20pt
```

#### Sombras (DSShadow)
```swift
DSShadow.sm      // Pequena (cards, botões)
DSShadow.md      // Média (cards flutuantes)
DSShadow.lg      // Grande (modals)
DSShadow.xl      // Extra grande
```

#### View Extensions
```swift
VStack {
  Text("Hello")
}
.dsScreenPadding()     // Padding de tela
.dsCardPadding()       // Padding de card
.dsCornerRadius()      // Corner radius padrão (12pt)
.dsShadow(.md)         // Sombra média
```

### 🌈 DSGradients

Gradientes pré-definidos para consistência visual.

```swift
// Background
DSGradients.backgroundMain      // Gradient principal
DSGradients.backgroundCard      // Gradient de card

// Brand
DSGradients.primary            // Gradient primário
DSGradients.blue               // Gradient azul (perfil)
DSGradients.green              // Gradient verde (success)

// Semantic
DSGradients.success            // Sucesso
DSGradients.warning            // Aviso
DSGradients.error              // Erro

// Effects
DSGradients.shimmer            // Loading shimmer
DSGradients.glass              // Glassmorphism

// Custom
DSGradients.custom(
  .blue,
  opacity: 0.7,
  startPoint: .top,
  endPoint: .bottom
)
```

#### Uso em Views
```swift
Rectangle()
  .fill(DSGradients.primary)

Text("Hello")
  .dsBackgroundGradient(DSGradients.blue)
```

## Theme Management

### Theme.swift

Gerenciamento centralizado de light/dark mode.

```swift
// Singleton
Theme.shared

// Toggle tema
Theme.shared.toggleColorScheme()

// Current scheme
Theme.shared.colorScheme  // .light, .dark, ou nil (auto)

// Display
Theme.shared.displayName  // "Claro", "Escuro", "Automático"
Theme.shared.iconName     // "sun.max.fill", etc
```

#### Aplicar em View
```swift
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .dsPreferredColorScheme()  // Aplica tema
    }
  }
}
```

## Padrões de Uso

### Exemplo: Card com Design System

```swift
struct EventCard: View {
  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      Text("Título do Evento")
        .dsTitle3()
      
      Text("Descrição do evento")
        .dsBody()
      
      HStack {
        Text("R$ 99,00")
          .dsHeadline()
          .foregroundColor(.dsAccentGreen)
        
        Spacer()
        
        Button("Comprar") {
          // Action
        }
      }
    }
    .dsCardPadding()
    .background(DSColors.backgroundSecondary)
    .dsCornerRadius(DSRadius.card)
    .dsShadow(.sm)
  }
}
```

### Exemplo: Tela com Background Gradient

```swift
struct ProfileView: View {
  var body: some View {
    ScrollView {
      VStack(spacing: DSSpacing.sectionSpacing) {
        // Content
      }
      .dsScreenPadding()
    }
    .dsBackgroundGradient(DSGradients.backgroundMain)
  }
}
```

### Exemplo: Botão com Gradient

```swift
Button("Login") {
  // Action
}
.font(DSTypography.headline)
.foregroundColor(.white)
.padding(.horizontal, DSSpacing.lg)
.padding(.vertical, DSSpacing.md)
.background(DSGradients.primary)
.dsCornerRadius(DSRadius.buttonMedium)
```

## Convenções

### Nomenclatura
- **Tokens**: `DS{Category}` (ex: `DSColors`, `DSSpacing`)
- **Valores**: camelCase (ex: `textPrimary`, `cardPadding`)
- **Extensions**: prefixo `ds` (ex: `.dsTitle1()`, `.dsCardPadding()`)

### Organização
- **Tokens/**: Valores fundamentais (cores, tamanhos, espaços)
- **Theme/**: Gerenciamento de tema
- **Components/**: Componentes reutilizáveis (botões, cards, badges, etc.)
- **Utilities/**: View modifiers e helpers

### Princípios
1. **Consistência**: Use sempre os tokens definidos
2. **Semântica**: Prefira nomes semânticos (ex: `cardPadding` vs `md`)
3. **Adaptabilidade**: Todos os tokens suportam light/dark mode
4. **Extensibilidade**: Fácil adicionar novos tokens

## Migração do ThemeApp/

O DesignSystem substitui e melhora o `ThemeApp/` anterior:

| Antes (ThemeApp) | Agora (DesignSystem) |
|------------------|----------------------|
| `AppColors` | `DSColors` |
| `ThemeManager` | `Theme` |
| Sem tipografia | `DSTypography` |
| Sem espaçamento | `DSSpacing` |
| Poucos gradientes | `DSGradients` |

### Como Migrar

1. Importar DesignSystem:
```swift
import DesignSystem
```

2. Substituir referências:
```swift
// Antes
AppColors.primary

// Depois
DSColors.primary
```

3. Usar extensions:
```swift
// Antes
.foregroundColor(AppColors.primaryText)

// Depois
.foregroundColor(.dsTextPrimary)
// ou
.dsBody()  // Aplica fonte + cor
```

## Componentes Base

### 🔘 DSButton

Estilos de botões padronizados e reutilizáveis.

#### Button Styles
```swift
// Primary Button (gradient)
Button("Login") { }
  .dsPrimaryButton()

// Secondary Button (outline)
Button("Cancelar") { }
  .dsSecondaryButton()

// Tertiary Button (ghost/text)
Button("Ver Mais") { }
  .dsTertiaryButton()

// Destructive Button (vermelho)
Button("Excluir") { }
  .dsDestructiveButton()

// Compact Button (pequeno)
Button("Ok") { }
  .dsCompactButton(variant: .primary)
```

#### Icon Button
```swift
DSIconButton(
  icon: "heart.fill",
  variant: .primary
) {
  // Action
}
```

### 🃏 DSCard

Componentes de card para layouts consistentes.

#### Card Básico
```swift
DSCard {
  VStack(alignment: .leading, spacing: DSSpacing.sm) {
    Text("Título")
      .dsTitle3()
    Text("Descrição")
      .dsBody()
  }
}
```

#### Card com Header
```swift
DSHeaderCard(
  header: {
    Text("Título do Card")
      .dsHeadline()
  },
  content: {
    Text("Conteúdo do card")
  }
)
```

#### Card com Imagem
```swift
DSImageCard(
  imageURL: "https://...",
  imageHeight: 200
) {
  VStack(alignment: .leading) {
    Text("Título")
    Text("Descrição")
  }
}
```

#### Compact Card
```swift
DSCompactCard {
  HStack {
    Text("Info")
    Spacer()
    Text("Valor")
  }
}
```

### 🏷️ DSBadge

Badges, tags e indicadores de status.

#### Badge Básico
```swift
DSBadge("Novo", style: .primary, size: .medium)
DSBadge("Em Breve", style: .warning, size: .small)
DSBadge("Esgotado", style: .error, size: .large)
```

#### Status Badge (com dot)
```swift
DSStatusBadge(status: "Online", color: .green)
DSStatusBadge(status: "Processando", color: .orange)
```

#### Number Badge (notificações)
```swift
DSNumberBadge(count: 5)        // Exibe "5"
DSNumberBadge(count: 150, maxCount: 99)  // Exibe "99+"
```

#### Icon Badge
```swift
DSIconBadge(
  icon: "checkmark",
  style: .success,
  size: 32
)
```

#### Tag (pill-shaped, selecionável)
```swift
DSTag("Música", isSelected: true) {
  // Toggle selection
}
```

### 📭 DSEmptyState

Estados vazios e mensagens de erro.

#### Empty State Padrão
```swift
DSEmptyState(
  icon: "tray.fill",
  title: "Nenhum item encontrado",
  message: "Adicione novos itens para vê-los aqui.",
  actionTitle: "Adicionar Item"
) {
  // Action
}
```

#### Search Empty State
```swift
DSSearchEmptyState(searchTerm: "pizza")
```

#### Error State
```swift
DSErrorState(
  title: "Erro ao carregar",
  message: "Não foi possível carregar os dados."
) {
  // Retry action
}
```

#### No Connection State
```swift
DSNoConnectionState {
  // Retry action
}
```

#### Loading Empty
```swift
DSLoadingEmpty(icon: "hourglass", title: "Carregando...")
```

#### Compact Empty State (inline)
```swift
DSCompactEmptyState(
  icon: "list.bullet",
  message: "Nenhum resultado"
)
```

### ⏳ DSLoading

Indicadores de loading e skeletons.

#### Loading Indicator
```swift
DSLoadingIndicator(style: .spinner, size: .medium)
DSLoadingIndicator(style: .dots, size: .large)
DSLoadingIndicator(style: .pulse, size: .small)
```

#### Full Screen Loading
```swift
DSFullScreenLoading(message: "Carregando dados...")
```

#### Overlay Loading
```swift
ZStack {
  MyContent()
  if isLoading {
    DSOverlayLoading()
  }
}
```

#### Inline Loading
```swift
DSInlineLoading(message: "Salvando...")
```

#### Skeleton Views
```swift
// Skeleton de texto
DSSkeletonText(lines: 3, lineHeight: 20)

// Skeleton de imagem
DSSkeletonImage(width: 100, height: 100)

// Skeleton de círculo (avatar)
DSSkeletonCircle(size: 48)
```

#### Button Loading State
```swift
Button {
  // Action
} label: {
  if isLoading {
    DSButtonLoading()
  } else {
    Text("Salvar")
  }
}
.dsPrimaryButton()
```

### 📋 DSListCell

Células de lista padronizadas.

#### List Cell Básico
```swift
DSListCell(
  icon: "person.fill",
  iconColor: .blue,
  title: "Perfil",
  subtitle: "Editar informações",
  badge: "Novo",
  accessory: .chevron
) {
  // Action
}
```

#### Accessory Types
```swift
.none                    // Sem acessório
.chevron                 // Seta para direita
.checkmark               // Checkmark
.toggle($isEnabled)      // Toggle switch
.custom(AnyView(...))    // View customizada
```

#### Avatar List Cell
```swift
DSAvatarListCell(
  avatarURL: "https://...",
  avatarInitials: "JD",
  title: "João Silva",
  subtitle: "Vendedor verificado",
  badge: "Top",
  isVerified: true
) {
  // Action
}
```

#### Card List Cell (Full Width Card)
```swift
DSCardListCell(hasShadow: true) {
  HStack {
    Text("Evento")
    Spacer()
    Text("R$ 99")
  }
}
```

#### Divider
```swift
DSDivider(inset: DSSpacing.m)
```

#### Section Header
```swift
DSSectionHeader(
  title: "Meus Ingressos",
  actionTitle: "Ver Todos"
) {
  // Action
}
```

## View Modifiers & Utilities

### Corner Radius
```swift
.dsCornerRadius(DSRadius.card)
.dsCornerRadius(16, corners: [.topLeft, .topRight])
```

### Shadow
```swift
.dsLightShadow()     // Shadow leve
.dsMediumShadow()    // Shadow média
.dsStrongShadow()    // Shadow forte
.dsCardShadow()      // Shadow de card
```

### Border
```swift
.dsBorder(DSColors.primary, width: 2, radius: DSRadius.md)
```

### Card Style (all-in-one)
```swift
.dsCardStyle()  // background + corner radius + shadow
```

### Skeleton Loading
```swift
Text("Loading...")
  .dsSkeleton(isLoading: true, cornerRadius: DSRadius.sm)
```

## Animações e Microinterações

### 🎬 DSAnimations

Presets de animação e timing curves pré-definidos.

#### Timing Curves
```swift
DSAnimations.smoothEasing      // ease-in-out 0.3s
DSAnimations.quickEasing        // ease-out 0.2s
DSAnimations.slowEasing         // ease-in-out 0.5s
DSAnimations.smoothSpring       // Spring suave
DSAnimations.quickSpring        // Spring rápido
DSAnimations.bouncySpring       // Spring bouncy (feedbacks)
```

#### Durations
```swift
DSAnimations.instant    // 0.1s
DSAnimations.fast       // 0.2s
DSAnimations.standard   // 0.3s
DSAnimations.slow       // 0.5s
DSAnimations.verySlow   // 0.8s
```

#### View Extensions
```swift
// Fade
.dsFadeAnimation(isVisible: true)

// Slide
.dsSlideAnimation(isVisible: true, from: .bottom)

// Scale
.dsScaleAnimation(isVisible: true, scale: 0.8)

// Rotate
.dsRotateAnimation(angle: .degrees(45))

// Enter/Exit
.dsEnterAnimation(isVisible: true, delay: 0.1)
.dsExitAnimation(isVisible: false)

// Shimmer (loading)
.dsShimmerAnimation(isActive: true)

// Pulse
.dsPulseAnimation(isActive: true, scale: 1.1)

// Bounce
.dsBounceAnimation(isActive: true, intensity: 0.1)
```

#### Stagger Animation
```swift
DSStaggeredView(items, delay: 0.05) { item in
  ItemView(item: item)
}
```

### 🎯 DSMicroInteractions

Feedback de toque e interações hápticas.

#### Tap Feedback
```swift
// ButtonStyle com feedback
Button("Tap Me") { }
  .buttonStyle(DSTapFeedbackButtonStyle(style: .scale))

// View com feedback
.dsTapFeedback(style: .scale, intensity: 0.95)

// Estilos disponíveis
.scale      // Reduz escala ao toque
.opacity    // Reduz opacidade
.highlight  // Overlay branco
.ripple     // Efeito ripple
.bounce     // Bounce effect
```

#### Haptic Feedback
```swift
// Tipos de haptic
DSHapticFeedback.light()      // Impact leve
DSHapticFeedback.medium()      // Impact médio
DSHapticFeedback.heavy()       // Impact forte
DSHapticFeedback.success()     // Notificação sucesso
DSHapticFeedback.warning()     // Notificação aviso
DSHapticFeedback.error()       // Notificação erro
DSHapticFeedback.selection()   // Seleção

// Em Views
.dsHapticFeedback(.medium, onTap: true)
.dsInteractiveFeedback(tapStyle: .scale, hapticType: .light)
```

#### Pressable View
```swift
DSPressable(
  tapStyle: .scale,
  hapticType: .light
) {
  // Action
} content: {
  Text("Press Me")
}
```

#### Long Press
```swift
DSLongPressable(minimumDuration: 0.5) {
  // Action após long press
} content: {
  Text("Long Press Me")
}
```

#### Shake Animation
```swift
@State private var isShaking = false

Text("Error")
  .dsShakeable(isShaking: $isShaking)

// Trigger shake
isShaking = true
```

### 👆 DSSwipeGestures

Gestos de swipe personalizados.

#### Swipe to Delete
```swift
DSCard {
  Text("Swipe to delete")
}
.dsSwipeToDelete(onDelete: {
  // Delete action
})
```

#### Swipe to Favorite
```swift
DSCard {
  Text("Swipe to favorite")
}
.dsSwipeToFavorite(
  isFavorited: false,
  onToggle: {
    // Toggle favorite
  }
)
```

#### Swipe Actions Customizadas
```swift
.dsSwipeActions(
  leading: [
    DSSwipeAction(
      icon: "heart.fill",
      color: .red,
      action: { /* favorite */ }
    )
  ],
  trailing: [
    DSSwipeAction(
      icon: "trash.fill",
      color: .red,
      action: { /* delete */ }
    )
  ],
  threshold: 100
)
```

#### Swipeable View
```swift
DSSwipeable(
  leadingActions: [/* actions */],
  trailingActions: [/* actions */]
) {
  ContentView()
}
```

### 🔄 DSPullToRefresh

Pull-to-refresh customizado.

#### Pull to Refresh Modifier
```swift
ScrollView {
  ContentView()
}
.dsPullToRefresh(
  isRefreshing: $isRefreshing,
  onRefresh: {
    // Refresh action
  }
)
```

#### Refreshable ScrollView
```swift
DSRefreshableScrollView(
  isRefreshing: $isRefreshing,
  onRefresh: {
    // Refresh action
  }
) {
  ContentView()
}
```

#### Infinite Scroll
```swift
ScrollView {
  ContentView()
}
.dsInfiniteScroll(onLoadMore: {
  // Load more action
})
```

### 🎭 DSViewTransitions

Transições de view pré-definidas.

#### Tipos de Transição
```swift
.fade                    // Fade in/out
.slideFromBottom         // Slide do bottom
.slideFromTop            // Slide do top
.slideFromLeading        // Slide da esquerda
.slideFromTrailing       // Slide da direita
.scale                   // Scale in/out
.scaleWithFade           // Scale + fade
.move(edge)               // Move de uma edge
```

#### Uso
```swift
// Transição customizada
.dsTransition(.slideFromBottom)

// Transições específicas
.dsFadeTransition()
.dsSlideFromBottomTransition()
.dsScaleTransition()

// Page transition
.dsPageTransition(direction: .forward, isActive: true)

// Modal transition
.dsModalTransition(isPresented: true)

// Card transition
.dsCardTransition(isVisible: true, delay: 0.1)

// List item transition (stagger)
.dsListItemTransition(isVisible: true, index: 0, delay: 0.05)

// Tab transition
.dsTabTransition(isSelected: true)

// Hero transition
.dsHeroTransition(isActive: true)
```

#### Exemplo com if/else
```swift
if showDetail {
  DetailView()
    .dsTransition(.slideFromBottom)
} else {
  ListView()
    .dsTransition(.fade)
}
```

## Próximas Tasks

### Task 9.0 - Navegação Global
- [ ] Padronizar navegação entre Features
- [ ] Fluxos documentados
- [ ] Navigation stack global

## Referências

- **Aivent Mobile App UI Kit** (UI8)
- **iOS Human Interface Guidelines** (Apple)
- **makeanimated.dev** (inspiração de animações)
- **Material Design 3** (tokens e conceitos)

## Uso em Produção

```swift
// SocialApp target deve adicionar dependência:
dependencies: [
  .project(target: "DesignSystem", path: .relativeToRoot("DesignSystem"))
]
```

```swift
// Nas Views:
import DesignSystem

struct MyView: View {
  var body: some View {
    Text("Hello")
      .dsTitle1()
      .foregroundColor(.dsTextPrimary)
  }
}
```

---

## Status de Implementação

✅ **Task 6.0 - Design System Fundamentos** - COMPLETA
- 📦 5 arquivos de tokens criados
- 🎨 Sistema completo de design estabelecido
- 🌗 Suporte total a light/dark mode

✅ **Task 7.0 - Design System Componentes Base** - COMPLETA
- 🔘 DSButton com 5 estilos + Icon Button
- 🃏 DSCard com 4 variações
- 🏷️ DSBadge com 5 tipos diferentes
- 📭 DSEmptyState com 6 variações
- ⏳ DSLoading com 3 estilos + skeletons
- 📋 DSListCell com 3 tipos de células
- 🛠️ View modifiers (shadow, border, skeleton, etc.)
- 📖 Documentação completa com exemplos

✅ **Task 8.0 - Design System Animações** - COMPLETA
- 🎬 DSAnimations com presets e timing curves
- 🎯 DSMicroInteractions (tap feedback, haptic)
- 👆 DSSwipeGestures (swipe to delete, favorite, custom)
- 🔄 DSPullToRefresh (pull-to-refresh customizado)
- 🎭 DSViewTransitions (transições pré-definidas)
- 📖 Documentação completa com exemplos

