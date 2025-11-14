## status: pending

<task_context>
<domain>features/profile/assets</domain>
<type>implementation</type>
<scope>ui_polish</scope>
<complexity>low</complexity>
<dependencies>assets|design</dependencies>
</task_context>

# Tarefa 7.0: Adicionar ilustrações e assets finais

## Visão Geral

Verificar e adicionar/otimizar todos os assets visuais necessários para as telas de perfil: ilustração de festival, ícones customizados, e garantir que todas as imagens estão otimizadas para light/dark mode com resolução adequada (@1x, @2x, @3x).

<requirements>
- Verificar se ilustração `empty_events` serve para footer
- Criar/adicionar novas ilustrações se necessário
- Otimizar tamanho de imagens
- Garantir suporte a @1x, @2x, @3x
- Adicionar ícones customizados se necessário (ou usar SF Symbols)
- Documentar usage de cada asset
- Testar renderização em diferentes dispositivos
</requirements>

## Subtarefas

- [ ] 7.1 Auditar assets existentes em `Assets.xcassets`
- [ ] 7.2 Verificar ilustração `empty_events` para uso no footer
- [ ] 7.3 Adicionar variantes light/dark se necessário
- [ ] 7.4 Criar/adicionar avatar placeholder personalizado
- [ ] 7.5 Otimizar tamanho de imagens (compression sem perda de qualidade)
- [ ] 7.6 Documentar assets no README ou CONVENTIONS
- [ ] 7.7 Testar em iPhone SE, iPhone 14, iPhone 14 Pro Max

## Detalhes de Implementação

### 7.1 Assets Audit
```
Verificar em Assets.xcassets:
✅ empty_events.imageset → Usar no footer de Profile e More
✅ social_brand.imageset → Logo do app
✅ backgroundImage.imageset → Background genérico
❓ profile_placeholder.imageset → Criar se não existir
❓ festival_illustration.imageset → Adicionar versão colorida se disponível
```

### 7.2 Ilustração de Festival
```swift
// Em ProfileView e MoreView:
@ViewBuilder
private var festivalIllustration: some View {
    Image("empty_events") // ou "festival_illustration" se nova
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: 300)
        .padding(.vertical, 40)
        .accessibilityLabel("Festival illustration")
}
```

### 7.3 Variantes Light/Dark
Se a ilustração precisar de variantes, adicionar no Contents.json:
```json
{
  "images" : [
    {
      "filename" : "festival_light.png",
      "idiom" : "universal",
      "scale" : "1x",
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "light"
        }
      ]
    },
    {
      "filename" : "festival_dark.png",
      "idiom" : "universal",
      "scale" : "1x",
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ]
    }
  ]
}
```

### 7.4 Avatar Placeholder
Criar `profile_placeholder.imageset` se não existir:
```swift
// Usage em ProfileView e EditProfileView:
AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    Image("profile_placeholder") // ou usar SF Symbol
        .resizable()
        .aspectRatio(contentMode: .fill)
        .foregroundColor(AppColors.secondaryText)
}
.frame(width: 120, height: 120)
.clipShape(Circle())
```

### 7.5 Otimização de Imagens
- Usar ImageOptim ou similar para comprimir PNGs
- Target: < 100KB por imagem
- Manter qualidade visual
- Preferir vectores (PDF) quando possível

### 7.6 Documentação
Criar `SocialApp/Resources/Assets.xcassets/README.md`:
```markdown
# Assets Guide

## Illustrations
- `empty_events` - Festival illustration para empty states e footers
- `social_brand` - Logo da aplicação
- `backgroundImage` - Background genérico

## Icons
- Usar SF Symbols sempre que possível
- Custom icons apenas se necessário

## Guidelines
- Sempre adicionar @1x, @2x, @3x
- Considerar variantes light/dark
- Comprimir com ImageOptim antes de adicionar
- Max size: 100KB por image
```

### 7.7 Testes de Renderização
```swift
// No Preview:
#Preview("Profile - Light") {
    ProfileView(store: Store(initialState: ProfileFeature.State()) {
        ProfileFeature()
    })
    .environment(ThemeManager.shared)
    .preferredColorScheme(.light)
}

#Preview("Profile - Dark") {
    ProfileView(store: Store(initialState: ProfileFeature.State()) {
        ProfileFeature()
    })
    .environment(ThemeManager.shared)
    .preferredColorScheme(.dark)
}

#Preview("Profile - Small Device") {
    ProfileView(store: Store(initialState: ProfileFeature.State()) {
        ProfileFeature()
    })
    .environment(ThemeManager.shared)
    .previewDevice("iPhone SE (3rd generation)")
}
```

## Critérios de Sucesso

- ✅ Todas as imagens necessárias estão presentes
- ✅ Ilustração de festival renderiza corretamente
- ✅ Assets otimizados (< 100KB cada)
- ✅ Suporte a @1x, @2x, @3x
- ✅ Variantes light/dark funcionam
- ✅ Renderização adequada em diferentes tamanhos de tela
- ✅ Documentação de assets completa
- ✅ Sem warnings de assets faltando no Xcode

## Arquivos relevantes
- `SocialApp/Resources/Assets.xcassets/`
- `SocialApp/Resources/Assets.xcassets/empty_events.imageset/`
- `SocialApp/Resources/Assets.xcassets/README.md` (NOVO)
- `Projects/Features/Profile/ProfileView.swift`
- `Projects/Features/Profile/MoreView.swift`


