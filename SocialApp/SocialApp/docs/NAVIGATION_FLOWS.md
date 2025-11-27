# Fluxos de Navegação Principais

Este documento descreve os principais fluxos de navegação do app, mapeando como o usuário navega entre diferentes Features.

## Índice de Fluxos

1. [Autenticação e Onboarding](#1-autenticação-e-onboarding)
2. [Explorar Eventos](#2-explorar-eventos)
3. [Visualizar e Comprar Ingressos](#3-visualizar-e-comprar-ingressos)
4. [Criar Ingresso](#4-criar-ingresso)
5. [Gerenciar Negociações](#5-gerenciar-negociações)
6. [Perfil e Configurações](#6-perfil-e-configurações)

---

## 1. Autenticação e Onboarding

### Fluxo Completo

```
SplashView
  ↓ (primeira vez)
OnboardingView
  ↓
WelcomeView
  ↓
SignUpView / SignInView
  ↓ (após signup)
SelectInterestsView
  ↓ (opcional)
VerificationView
  ↓
MainTabView (Home)
```

### Detalhamento

**1.1 Splash → Onboarding**
- **Trigger**: `auth.isFirstLaunch == true`
- **Action**: `auth(.onAppear)`
- **State**: `auth.isFirstLaunch`
- **View**: `SplashView` → `OnboardingView`

**1.2 Onboarding → Welcome**
- **Trigger**: Usuário completa onboarding
- **Action**: `auth(.onboardingCompleted)`
- **View**: `OnboardingView` → `WelcomeView`

**1.3 Welcome → Sign Up/In**
- **Trigger**: Usuário escolhe "Criar conta" ou "Entrar"
- **Action**: `auth(.signUpTapped)` ou `auth(.signInTapped)`
- **View**: `WelcomeView` → `SignUpView` / `SignInView`

**1.4 Sign Up → Interests**
- **Trigger**: Sign up bem-sucedido
- **Action**: `auth(.signUpResponse(.success))`
- **View**: `SignUpView` → `SelectInterestsView`

**1.5 Interests → Verification (Opcional)**
- **Trigger**: Usuário completa seleção de interesses
- **Action**: `auth(.interestsSelected)`
- **State**: `verification: VerificationFeature.State?`
- **View**: `SelectInterestsView` → `VerificationView` (se necessário)

**1.6 Verification → Main App**
- **Trigger**: Verificação completa (ou skip)
- **Action**: `verification(.verificationCompleted)`
- **State**: `auth.isAuthenticated = true`
- **View**: `VerificationView` → `MainTabView`

---

## 2. Explorar Eventos

### Fluxo Completo

```
HomeTab
  ↓ (toca evento)
EventDetailView (sheet)
  ↓ (toca "Ver Ingressos")
TicketsTab (filtrado por evento)
  ↓ (toca vendedor)
SellerProfileView (sheet)
  ↓ (toca "Ver Vendedores")
SellersListView (sheet)
```

### Detalhamento

**2.1 Home → Event Detail**
- **Trigger**: Usuário toca em card de evento
- **Action**: `homeFeature(.eventSelected(eventId))`
- **SocialAppFeature**: `navigateToEventDetail(eventId)`
- **State**: `selectedEventId = eventId`, `eventDetailFeature = State(eventId: eventId)`
- **View**: `HomeView` → `EventDetailView` (sheet)

**2.2 Event Detail → Tickets (Filtrado)**
- **Trigger**: Usuário toca "Ver Ingressos" no evento
- **Action**: `eventDetailFeature(.viewTicketsTapped)`
- **SocialAppFeature**: `navigateToEventTickets(eventId)`
- **State**: 
  - `selectedTab = .tickets`
  - `selectedEventId = nil` (fecha modal)
  - `ticketsListFeature.filterByEvent(eventId)`
- **View**: `EventDetailView` → `TicketsListView` (filtrado)

**2.3 Event Detail → Seller Profile**
- **Trigger**: Usuário toca em vendedor no evento
- **Action**: `eventDetailFeature(.sellerTapped(sellerId))`
- **SocialAppFeature**: `navigateToSellerProfile(sellerId)`
- **State**: `selectedSellerId = sellerId`, `sellerProfileFeature = State(sellerId: sellerId)`
- **View**: `EventDetailView` → `SellerProfileView` (sheet sobre EventDetail)

**2.4 Event Detail → Sellers List**
- **Trigger**: Usuário toca "Ver Todos os Vendedores"
- **Action**: `eventDetailFeature(.viewAllSellersTapped)`
- **SocialAppFeature**: `showSellersList(eventId, event)`
- **State**: `showingSellersList = true`, `sellersListFeature = State(eventId: eventId, event: event)`
- **View**: `EventDetailView` → `SellersListView` (sheet)

**2.5 Home → Recommended/Popular Events**
- **Trigger**: Usuário toca "Ver Todos" em Recommended/Popular
- **Action**: `homeFeature(.viewAllRecommended)` ou `homeFeature(.viewAllPopular)`
- **SocialAppFeature**: `showRecommendedEvents` ou `showPopularEvents`
- **State**: `showingRecommendedEvents = true` ou `showingPopularEvents = true`
- **View**: `HomeView` → `RecommendedEventsView` / `PopularEventsView` (sheet)

---

## 3. Visualizar e Comprar Ingressos

### Fluxo Completo

```
TicketsTab
  ↓ (toca ingresso)
TicketDetailView (sheet)
  ↓ (toca "Iniciar Negociação")
NegotiationsTab → NegotiationDetailView
  ↓ (ou "Comprar Agora")
Checkout (futuro)
```

### Detalhamento

**3.1 Tickets List → Ticket Detail**
- **Trigger**: Usuário toca em card de ingresso
- **Action**: `ticketsListFeature(.ticketSelected(ticketId))`
- **SocialAppFeature**: `navigateToTicketDetail(ticketId)`
- **State**: `selectedTicketId = ticketId`, `ticketDetailFeature = State(ticketId: ticketId)`
- **View**: `TicketsListView` → `TicketDetailView` (sheet)

**3.2 Ticket Detail → Negotiation (Nova)**
- **Trigger**: Usuário toca "Iniciar Negociação"
- **Action**: `ticketDetailFeature(.startNegotiationTapped)`
- **TicketDetailFeature**: Cria negociação via API
- **Delegate**: `delegate(.negotiationStarted(negotiationId))`
- **SocialAppFeature**: 
  - `selectedNegotiationId = negotiationId`
  - `selectedTab = .negotiations`
  - `selectedTicketId = nil` (fecha modal de ticket)
- **View**: `TicketDetailView` → `NegotiationsListView` → `NegotiationDetailView`

**3.3 Ticket Detail → Negotiation (Existente)**
- **Trigger**: Usuário toca "Ver Negociação"
- **Action**: `ticketDetailFeature(.viewNegotiationTapped)`
- **Delegate**: `delegate(.navigateToExistingNegotiation(negotiationId))`
- **SocialAppFeature**: 
  - `selectedNegotiationId = negotiationId`
  - `selectedTab = .negotiations`
- **View**: `TicketDetailView` → `NegotiationsListView` → `NegotiationDetailView`

**3.4 Tickets List → Filter by Event**
- **Trigger**: Navegação de Event Detail ou filtro manual
- **Action**: `ticketsListFeature(.filterByEvent(eventId))`
- **State**: `selectedFilter.eventId = eventId`
- **View**: `TicketsListView` (filtrado)

---

## 4. Criar Ingresso

### Fluxo Completo

```
MainTabView
  ↓ (toca Add button)
AddTicketView (fullscreen)
  ↓ (completa steps)
TicketReviewPublishView
  ↓ (publica)
TicketsTab (com novo ticket)
```

### Detalhamento

**4.1 Tab Bar → Add Ticket**
- **Trigger**: Usuário toca botão "+" na tab bar
- **Action**: `addTicketTapped`
- **SocialAppFeature**: `setShowingAddTicket(true)`
- **State**: `showingAddTicket = true`
- **View**: `MainTabView` → `AddTicketView` (fullscreen cover)

**4.2 Add Ticket → Select Event (Opcional)**
- **Trigger**: Navegação de Event Detail
- **Action**: `setAddTicketEventId(eventId)`
- **State**: `addTicket.eventId = eventId`
- **View**: `AddTicketView` (com evento pré-selecionado)

**4.3 Add Ticket Steps**
- **Step 1**: `TicketDetailsStepView` - Informações básicas
- **Step 2**: `TicketPricingStepView` - Preço e quantidade
- **Step 3**: `TicketValidityStepView` - Validade
- **Step 4**: `TicketMediaStepView` - Imagens
- **Step 5**: `TicketReviewPublishView` - Revisão e publicação

**4.4 Publish → Sync**
- **Trigger**: Usuário publica ingresso
- **Action**: `addTicket(.publishTicketResponse(.success(ticket)))`
- **SocialAppFeature**: 
  - `showingAddTicket = false`
  - `ticketsListFeature(.syncTicketCreated(ticket))`
  - `profileFeature(.refreshMyTickets)` (se for do usuário)
- **View**: `AddTicketView` → `TicketsListView` (com novo ticket)

---

## 5. Gerenciar Negociações

### Fluxo Completo

```
NegotiationsTab
  ↓ (toca negociação)
NegotiationDetailView (sheet)
  ↓ (responde pergunta)
AnswerQuestionView (sheet)
  ↓ (ou upload documento)
DocumentUploadView (sheet)
```

### Detalhamento

**5.1 Negotiations List → Detail**
- **Trigger**: Usuário toca em negociação
- **Action**: `negotiationsListFeature(.negotiationSelected(negotiationId))`
- **SocialAppFeature**: `selectedNegotiationId = negotiationId`
- **State**: `negotiationsListFeature.selectedNegotiationId = negotiationId`
- **View**: `NegotiationsListView` → `NegotiationDetailView` (sheet)

**5.2 Negotiation Detail → Answer Question**
- **Trigger**: Usuário toca em pergunta
- **Action**: `negotiationDetailsFeature(.questionTapped(questionId))`
- **State**: `showingAnswerQuestion = true`
- **View**: `NegotiationDetailView` → `AnswerQuestionView` (sheet)

**5.3 Negotiation Detail → Upload Document**
- **Trigger**: Usuário toca "Enviar Documento"
- **Action**: `negotiationDetailsFeature(.uploadDocumentTapped)`
- **State**: `showingDocumentUpload = true`
- **View**: `NegotiationDetailView` → `DocumentUploadView` (sheet)

**5.4 Negotiation Detail → Contact Reveal**
- **Trigger**: Negociação aprovada, usuário toca "Revelar Contato"
- **Action**: `negotiationDetailsFeature(.revealContactTapped)`
- **State**: `showingContactReveal = true`
- **View**: `NegotiationDetailView` → `ContactRevealView` (sheet)

---

## 6. Perfil e Configurações

### Fluxo Completo

```
ProfileTab
  ↓ (toca "Meus Ingressos")
MyTicketsView (sheet)
  ↓ (toca ingresso)
TicketDetailView (sheet)
  ↓ (ou "Editar Perfil")
EditProfileView (sheet)
```

### Detalhamento

**6.1 Profile → My Tickets**
- **Trigger**: Usuário toca "Meus Ingressos"
- **Action**: `profileFeature(.myTicketsTapped)`
- **SocialAppFeature**: `profileFeature(.setShowingMyTickets(true))`
- **State**: `profileFeature.showingMyTickets = true`
- **View**: `ProfileView` → `MyTicketsView` (sheet)

**6.2 My Tickets → Ticket Detail**
- **Trigger**: Usuário toca em ingresso
- **Action**: `myTicketsFeature(.ticketSelected(ticketId))`
- **SocialAppFeature**: 
  - `navigateToTicketDetail(ticketId)`
  - `profileFeature(.setShowingMyTickets(false))` (fecha sheet)
- **View**: `MyTicketsView` → `TicketDetailView` (sheet)

**6.3 Profile → Edit Profile**
- **Trigger**: Usuário toca "Editar Perfil"
- **Action**: `profileFeature(.editProfileTapped)`
- **State**: `profileFeature.showingEditProfile = true`
- **View**: `ProfileView` → `EditProfileView` (sheet)

**6.4 Profile → Favorites**
- **Trigger**: Usuário toca "Favoritos"
- **Action**: `profileFeature(.favoritesTapped)`
- **State**: `profileFeature.showingFavorites = true`
- **View**: `ProfileView` → `FavoritesView` (sheet)

**6.5 Profile → Settings**
- **Trigger**: Usuário toca "Configurações"
- **Action**: `profileFeature(.settingsTapped)`
- **State**: `profileFeature.showingSettings = true`
- **View**: `ProfileView` → `SettingsView` (sheet)

**6.6 Profile → Seller Profile (Outro usuário)**
- **Trigger**: Navegação de outra Feature
- **Action**: `navigateToSellerProfile(sellerId)`
- **State**: `selectedSellerId = sellerId`
- **View**: `ProfileView` → `SellerProfileView` (sheet)

---

## Fluxos Cross-Feature

### Ticket → Negotiation
```
TicketDetailView
  ↓ (inicia negociação)
NegotiationsTab → NegotiationDetailView
```

### Event → Tickets → Ticket Detail
```
EventDetailView
  ↓ (ver ingressos)
TicketsTab (filtrado)
  ↓ (toca ingresso)
TicketDetailView
```

### Profile → My Tickets → Ticket Detail
```
ProfileView
  ↓ (meus ingressos)
MyTicketsView
  ↓ (toca ingresso)
TicketDetailView
```

---

## Padrões de Navegação por Tipo

### Modal/Sheet Navigation
- **Uso**: Detalhes que aparecem sobre conteúdo principal
- **Exemplos**: EventDetail, TicketDetail, SellerProfile
- **Transição**: `.slideFromBottom`

### Fullscreen Cover
- **Uso**: Telas que ocupam toda a tela
- **Exemplos**: AddTicket, Authentication
- **Transição**: `.scaleWithFade`

### Tab Navigation
- **Uso**: Navegação entre seções principais
- **Exemplos**: Home, Tickets, Negotiations, Profile
- **Transição**: `.fade`

### Navigation Stack
- **Uso**: Navegação hierárquica dentro de uma Feature
- **Exemplos**: (Futuro) Settings → Privacy → Terms
- **Transição**: `.move(edge: .trailing)`

---

## Sincronização de Dados

### Quando Criar Ticket
1. Adiciona em `ticketsListFeature`
2. Atualiza `profileFeature.ticketsCount`
3. Recarrega `profileFeature.myTickets` (se for do usuário)

### Quando Deletar Ticket
1. Remove de `ticketsListFeature`
2. Atualiza `profileFeature.ticketsCount`
3. Recarrega `profileFeature.myTickets` (se for do usuário)

### Quando Criar Negociação
1. Adiciona em `negotiationsListFeature`
2. Atualiza badge count
3. Navega para `NegotiationDetailView`

---

## Referências

- [NAVIGATION_PATTERNS.md](./NAVIGATION_PATTERNS.md) - Padrões técnicos de navegação
- [PRESENTATION_LAYER.md](./PRESENTATION_LAYER.md) - Padrões de Presentation
- [Design System - Transitions](../DesignSystem/README.md#dsviewtransitions) - Transições disponíveis

---

✅ **Fluxos de navegação documentados**

📚 **Use este documento para entender como o usuário navega pelo app**

🎯 **Útil para**: Onboarding de novos desenvolvedores, testes de UX, planejamento de features

