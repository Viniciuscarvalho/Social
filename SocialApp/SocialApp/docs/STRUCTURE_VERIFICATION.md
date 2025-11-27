# Verificação de Estrutura das Features

## Data: 27 de novembro de 2025

## Resumo

Verificação da estrutura de pastas das Features comparada com os padrões estabelecidos em `PRESENTATION_LAYER.md` e `FEATURE_TEMPLATE.md`.

## Padrão Esperado

De acordo com `FEATURE_TEMPLATE.md` e `PRESENTATION_LAYER.md`:

```
Projects/Features/[FeatureName]/
├── Project.swift (Tuist)
├── Sources/
│   ├── [FeatureName]Feature.swift
│   └── Views/
│       ├── [FeatureName]View.swift
│       ├── [FeatureName]Cell.swift (se necessário)
│       └── Components/ (componentes específicos da feature)
└── README.md (opcional)
```

## Estrutura Atual vs Padrão

### ✅ Features com Estrutura Correta

1. **Events**
   - ✅ `Project.swift` presente
   - ✅ `Sources/` com estrutura organizada
   - ✅ `Sources/EventsFeature.swift`
   - ✅ `Sources/EventsView.swift`
   - ✅ `Sources/Components/` para componentes específicos
   - ✅ `Sources/Details/` para sub-features
   - ✅ `Sources/Favorites/` para sub-features

2. **Negotiations**
   - ✅ `Sources/` com estrutura organizada
   - ✅ `Sources/NegotiationsListFeature.swift`
   - ✅ `Sources/NegotiationsListView.swift`
   - ✅ `Sources/NegotiationDetailsFeature.swift`
   - ✅ `Sources/NegotiationDetailsView.swift`

3. **SellerProfile**
   - ✅ `Sources/SellerProfileFeature.swift`
   - ✅ `Sources/SellerProfileView.swift`

4. **SellersList**
   - ✅ `Sources/SellersListFeature.swift`
   - ✅ `Sources/SellersListView.swift`

5. **TicketDetail**
   - ✅ `Sources/TicketDetailFeature.swift`
   - ✅ `Sources/TicketDetailView.swift`

6. **TicketsList**
   - ✅ `Sources/TicketsListFeature.swift`
   - ✅ `Sources/TicketsListView.swift`
   - ✅ `Sources/AddTicketFeature.swift`
   - ✅ `Sources/AddTicketView.swift`
   - ✅ `Sources/MyTicketsFeature.swift`
   - ✅ `Sources/MyTicketsView.swift`
   - ✅ Subviews organizadas

7. **Verification**
   - ✅ `Sources/VerificationFeature.swift`
   - ✅ `Sources/VerificationView.swift`
   - ✅ Sub-features organizadas

### ⚠️ Features com Estrutura Inconsistente

1. **Profile**
   - ⚠️ Arquivos na raiz ao invés de `Sources/`
   - ⚠️ Falta `Project.swift`
   - Estrutura atual:
     ```
     Profile/
     ├── ProfileFeature.swift
     ├── ProfileView.swift
     ├── ProfileHeaderView.swift
     ├── ProfileFooterView.swift
     ├── ProfileMenuSection.swift
     └── SellerCardView.swift
     ```
   - Estrutura esperada:
     ```
     Profile/
     ├── Project.swift
     ├── Sources/
     │   ├── ProfileFeature.swift
     │   └── Views/
     │       ├── ProfileView.swift
     │       ├── ProfileHeaderView.swift
     │       ├── ProfileFooterView.swift
     │       ├── ProfileMenuSection.swift
     │       └── SellerCardView.swift
     ```

2. **Home**
   - ⚠️ Arquivos na raiz ao invés de `Sources/`
   - ⚠️ Falta `Project.swift`
   - Estrutura atual:
     ```
     Home/
     ├── HomeFeature.swift
     └── HomeView.swift
     ```
   - Estrutura esperada:
     ```
     Home/
     ├── Project.swift
     ├── Sources/
     │   ├── HomeFeature.swift
     │   └── Views/
     │       └── HomeView.swift
     ```

3. **Login**
   - ⚠️ Estrutura diferente do padrão
   - ⚠️ Falta `Project.swift`
   - Estrutura atual:
     ```
     Login/
     ├── Auth/
     │   ├── AuthFeature.swift
     │   └── SupabaseManager.swift
     └── Views/
         ├── AuthenticationView.swift
         ├── SignInView.swift
         ├── SignUpView.swift
         └── ...
     ```
   - Estrutura esperada:
     ```
     Login/
     ├── Project.swift
     ├── Sources/
     │   ├── AuthFeature.swift
     │   └── Views/
     │       ├── AuthenticationView.swift
     │       ├── SignInView.swift
     │       └── ...
     ```

## Features que Ainda Usam AppColors

### Features Pendentes de Migração

1. **Login/AuthFeature**
   - ❌ `SignInView.swift` - 3 ocorrências
   - ❌ `SignUpView.swift` - 1 ocorrência
   - ❌ `WelcomeView.swift` - 1 ocorrência
   - ❌ `OnboardingView.swift` - 2 ocorrências
   - ❌ `SelectInterestsView.swift` - 3 ocorrências
   - ❌ `SplashView.swift` - 1 ocorrência

2. **FavoritesFeature**
   - ❌ `FavoritesView.swift` - 9 ocorrências

3. **AddTicketFeature**
   - ❌ `AddTicketView.swift` - 1 ocorrência
   - ❌ `TicketDetailsStepView.swift` - Usa AppColors
   - ❌ `TicketMediaStepView.swift` - Usa AppColors
   - ❌ `TicketPricingStepView.swift` - Usa AppColors
   - ❌ `TicketValidityStepView.swift` - Usa AppColors
   - ❌ `TicketReviewPublishView.swift` - Usa AppColors

4. **MyTicketsFeature**
   - ❌ `MyTicketsView.swift` - Usa AppColors

5. **EventDetailFeature**
   - ⚠️ Precisa verificar se usa AppColors

6. **HomeFeature**
   - ⚠️ Precisa verificar se usa AppColors

## Recomendações

### 1. Reorganizar Estrutura de Pastas

#### Profile Feature
```bash
# Mover arquivos para Sources/
mkdir -p Projects/Features/Profile/Sources/Views
mv Projects/Features/Profile/*.swift Projects/Features/Profile/Sources/
mv Projects/Features/Profile/Sources/ProfileView.swift Projects/Features/Profile/Sources/Views/
mv Projects/Features/Profile/Sources/*View.swift Projects/Features/Profile/Sources/Views/
```

#### Home Feature
```bash
# Mover arquivos para Sources/
mkdir -p Projects/Features/Home/Sources/Views
mv Projects/Features/Home/*.swift Projects/Features/Home/Sources/
mv Projects/Features/Home/Sources/HomeView.swift Projects/Features/Home/Sources/Views/
```

#### Login Feature
```bash
# Reorganizar estrutura
mkdir -p Projects/Features/Login/Sources/Views
mv Projects/Features/Login/Auth/*.swift Projects/Features/Login/Sources/
mv Projects/Features/Login/Views/*.swift Projects/Features/Login/Sources/Views/
```

### 2. Criar Project.swift para Features Faltantes

Todas as features devem ter um `Project.swift` seguindo o padrão:

```swift
import ProjectDescription

let project = Project(
    name: "[FeatureName]",
    targets: [
        .target(
            name: "[FeatureName]",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.[FeatureName]",
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Domain", path: "../../../Domain"),
                .project(target: "DesignSystem", path: "../../../DesignSystem"),
                .external(name: "ComposableArchitecture")
            ]
        )
    ]
)
```

### 3. Migrar Features Pendentes

Ordem sugerida:
1. **HomeFeature** - Simples, boa para começar
2. **EventDetailFeature** - Importante, relacionada a Events
3. **FavoritesFeature** - Relacionada a Events
4. **AddTicketFeature** - Complexa, multi-step
5. **MyTicketsFeature** - Relacionada a TicketsList
6. **AuthFeature** - Complexa, última

## Checklist de Verificação

### Estrutura de Pastas
- [ ] Profile tem `Sources/` e `Project.swift`
- [ ] Home tem `Sources/` e `Project.swift`
- [ ] Login tem estrutura reorganizada e `Project.swift`
- [ ] Todas as features seguem padrão `Sources/[Feature]Feature.swift`

### Migração de Design System
- [ ] HomeFeature migrada
- [ ] EventDetailFeature migrada
- [ ] FavoritesFeature migrada
- [ ] AddTicketFeature migrada
- [ ] MyTicketsFeature migrada
- [ ] AuthFeature migrada

### Project.swift
- [ ] Profile tem `Project.swift`
- [ ] Home tem `Project.swift`
- [ ] Login tem `Project.swift`
- [ ] Todas as features têm `Project.swift` com dependências corretas

## Conclusão

### Status Atual
- ✅ **10 features migradas** para Design System
- ⚠️ **6 features pendentes** de migração
- ⚠️ **3 features** com estrutura de pastas inconsistente
- ⚠️ **Apenas 1 feature** tem `Project.swift` (Events)

### Próximos Passos
1. Reorganizar estrutura de pastas (Profile, Home, Login)
2. Criar `Project.swift` para todas as features
3. Migrar features pendentes para Design System
4. Atualizar lista de progresso

---

**Última atualização**: 27 de novembro de 2025

