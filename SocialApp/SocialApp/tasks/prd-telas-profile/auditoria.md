# Auditoria - Telas de Profile

## 📊 Estado Atual

### 1. Estrutura de Arquivos

#### Profile Principal
- **Localização**: `Projects/Features/Profile/`
- **Arquivos**:
  - `ProfileView.swift` (580 linhas)
  - `ProfileFeature.swift` (183 linhas)

#### My Tickets
- **Localização**: `Projects/Features/TicketsList/Sources/`
- **Arquivos**:
  - `MyTicketsView.swift` (385 linhas)
  - `MyTicketsFeature.swift` (309 linhas)

#### Theme & Design System
- **Localização**: `SocialApp/Sources/ThemeApp/`
- **Arquivo**: `AppColors.swift` (245 linhas)
- **Status**: ✅ Sistema completo de cores adaptativas (light/dark)

---

## 🎨 Layout Atual vs Figma

### ProfileView - Diferenças Identificadas

#### ✅ Componentes Existentes (podem ser reaproveitados)
1. **Header do Perfil**
   - Avatar circular com foto
   - Nome e email do usuário
   - Botão "Editar Perfil"
   - Localização: linhas 80-158

2. **Seção de Estatísticas**
   - Seguidores, Seguindo, Ingressos
   - Badge de verificado
   - Localização: linhas 160-210

3. **Cards de Configurações**
   - Layout com ícones e títulos
   - Estilo de card com sombra
   - Localização: linhas 366-401

#### ❌ Componentes que Precisam Mudar

1. **Header do Perfil** (Figma mostra)
   - Fundo azul escuro (dark card)
   - Avatar maior e mais centralizado
   - Botão de editar como ícone de lápis (não texto)
   - Nome e email em branco sobre o fundo escuro

2. **Seções a Remover**
   - ❌ "Meus Eventos" (linha 283 - não existe no Figma)
   - ✅ Manter apenas "Tickets"
   - ❌ Seção de "Notificações" (linhas 254-274)
   - ❌ Seção de "Configurações" com Aparência/Privacidade (linhas 213-251)

3. **Nova Estrutura de Menu** (Figma mostra)
   - ✅ Tickets
   - ✅ My Favorite (não implementado ainda)
   - ✅ More (redireciona para nova tela)
   - ✅ Logout

4. **Ilustração Inferior**
   - ❌ Não existe atualmente
   - ✅ Precisa adicionar ilustração de festival/palco
   - Asset disponível: verificar `empty_events.imageset`

---

### EditProfileView - Diferenças Identificadas

#### ✅ Componentes Existentes
1. **Form básico com inputs**
   - Nome, Email, Título
   - Localização: linhas 516-568

#### ❌ Componentes que Precisam Mudar

1. **Layout do Figma mostra**
   - ✅ Avatar GRANDE no topo (não pequeno)
   - ✅ Botão de câmera sobre o avatar
   - ✅ Input de nome
   - ✅ Input de telefone com country code (+1)
   - ✅ Input de email
   - ✅ Seção "Change Interests" com chips selecionáveis

2. **Chips de Interesses** (não implementados)
   - Lista de categorias: Business, Arts, Music, Health, Food & Drink, Gaming, Travel & Adventure, Film & Media, Family & Kids, Theatre & Performing Arts, Community & Charity, Shopping, Pet & Animal Events, Books & Literature
   - Estilo: borda arredondada, ícone + texto
   - Selecionáveis (múltipla escolha)
   - Estado visual: selecionado (borda roxa) vs não selecionado (borda cinza)

3. **Botão Save**
   - Grande, roxo, na parte inferior
   - Texto branco "Save"

---

### MyTicketsView - Diferenças Identificadas

#### ✅ Componentes Existentes e Corretos
1. **Tabs Upcoming/Past** ✅
   - Implementado corretamente (linhas 130-159)
   - Estilo de pílula com fundo roxo para selecionado

2. **Cards de Tickets** ✅
   - Layout básico existe (linhas 229-371)
   - Mostra nome, preço, data, status

#### ❌ Componentes que Precisam Ajustar

1. **Layout do Card no Figma**
   - ✅ Mostrar nome do evento
   - ✅ Mostrar data (formato: "Feb, Mon 20, 2025")
   - ✅ Mostrar "Ticket : 02" (quantidade)
   - ✅ QR Code à direita (FALTA IMPLEMENTAR)

2. **Detalhes do Ticket** (tela à direita no Figma)
   - ✅ Imagem do evento em fullwidth no topo
   - ✅ Tag de categoria (ex: "Music Concert")
   - ✅ Nome do evento
   - ✅ Avatares de membros
   - ✅ Preço
   - ✅ Data e horário
   - ✅ Localização com mapa
   - ✅ Organizador com botão "Following"
   - ✅ Seção "About Event"
   
---

### Tela "More" - Não Implementada

#### ❌ Precisa Criar do Zero

1. **Layout do Figma mostra**
   - ✅ Header "More" com botão voltar
   - ✅ Lista de opções:
     - FAQs (ícone de interrogação)
     - Privacy Policy (ícone de escudo)
     - Contact Us (ícone de info)
     - Delete Account (ícone de lixeira, texto vermelho)
   - ✅ Ilustração de festival/palco na parte inferior

2. **Componentes necessários**
   - NavigationStack
   - Lista de botões com ícones
   - Ilustração inferior (mesmo asset do Profile)

---

## 🎨 Assets e Recursos

### Assets Existentes
✅ `empty_events.imageset` - Pode ser usado como ilustração de festival
✅ `social_brand.imageset` - Logo da aplicação
✅ `backgroundImage.imageset` - Background genérico
✅ SF Symbols - Todos os ícones necessários estão disponíveis

### Assets Necessários
❓ QR Code generator - Precisa implementar geração de QR Code
❓ Imagens de eventos - Para tela de detalhes de ticket
❓ Ilustração colorida de festival - Verificar se `empty_events` serve ou precisa nova

---

## 🔧 Theme e Cores (AppColors)

### ✅ Cores Disponíveis e Prontas
- `primary` - Roxo principal (accent)
- `secondary` - Azul
- `cardBackground` - Fundo de cards (adaptativo)
- `primaryText`, `secondaryText`, `tertiaryText` - Hierarquia de textos
- `error` - Vermelho para Delete Account
- `accentGreen` - Verde para ações positivas
- `backgroundGradient` - Gradiente de fundo

### ✅ Gradientes Prontos
- `backgroundGradient` - Para fundo da tela
- `primaryGradient` - Para botões
- `profileGradient` - Para avatar/header

---

## 🧩 Componentes Reutilizáveis

### Existentes (em Commons/)
1. `CategoryPill.swift` - Pode ser base para chips de interesses
2. `StarRatingView.swift` - Para avaliações
3. `TrustScoreBadge.swift` - Badge de verificação
4. `LazyImageView.swift` - Para carregar imagens de eventos

### Precisam Criar
1. `InterestChip.swift` - Chip selecionável de interesses
2. `ProfileHeaderCard.swift` - Card azul do header do profile
3. `MenuActionRow.swift` - Row de ação (já existe como `settingsRow`, pode extrair)
4. `QRCodeView.swift` - Gerador de QR Code
5. `TicketQRCard.swift` - Card de ticket com QR

---

## 📱 Fluxo de Navegação

### Atual
```
TabView
  └── Profile Tab
      ├── ProfileView
      │   ├── .sheet → EditProfileView
      │   ├── .sheet → ImagePicker
      │   └── .sheet → MyTicketsView
      └── (Outras modais)
```

### Proposto (conforme Figma)
```
TabView
  └── Profile Tab
      ├── ProfileView (redesenhado)
      │   ├── Button → .sheet EditProfileView (com interesses)
      │   ├── Button → .sheet MyTicketsView (já existe, ajustar layout)
      │   ├── Button → NavigationLink MoreView (NOVO)
      │   └── Button → Logout (ação direta)
      └── MoreView (NOVO)
          ├── NavigationLink → FAQsView
          ├── NavigationLink → PrivacyPolicyView
          ├── NavigationLink → ContactUsView
          └── Button → Delete Account (alerta)
```

---

## 🔌 State Management (TCA)

### ProfileFeature - State Atual
```swift
@ObservableState
public struct State: Equatable {
    public var user: User?
    public var isLoading = false
    public var error: String?
    public var ticketsCount: Int = 0
    public var showingEditProfile = false
    public var showingImagePicker = false
    public var showingMyTickets = false
    public var pushNotifications = true // ❌ Remover (não existe no Figma)
}
```

### ProfileFeature - State Proposto
```swift
@ObservableState
public struct State: Equatable {
    public var user: User?
    public var isLoading = false
    public var error: String?
    public var ticketsCount: Int = 0
    public var showingEditProfile = false
    public var showingImagePicker = false
    public var showingMyTickets = false
    public var selectedInterests: [String] = [] // ✅ NOVO
    public var showingMoreMenu = false // ✅ NOVO (ou usar NavigationStack)
}
```

### ProfileFeature - Actions Atuais
- ✅ Manter: `editProfileTapped`, `myTicketsTapped`, `signOutTapped`
- ❌ Remover: `privacySettingsTapped`, `togglePushNotifications`, `supportTapped`
- ✅ Adicionar: `moreMenuTapped`, `updateInterests([String])`, `favoritesTapped`

---

## 🧪 Dados de Teste

### User Model
```swift
public struct User {
    public var interests: [String]? // ✅ JÁ EXISTE no modelo
}
```

### Interesses Disponíveis (conforme Figma)
```swift
let availableInterests = [
    "Business", "Arts", "Music", "Health", 
    "Food & Drink", "Gaming", "Travel & Adventure",
    "Film & Media", "Family & Kids", 
    "Theatre & Performing Arts", "Community & Charity",
    "Shopping", "Pet & Animal Events", "Books & Literature"
]
```

---

## ⚠️ Riscos e Desafios

### Alto Risco
1. **QR Code Generation** - Precisa implementar biblioteca ou usar Core Image
2. **Chips de Interesses** - Comportamento de seleção múltipla + persistência
3. **Ilustração de Festival** - Verificar se asset existente serve ou precisa novo

### Médio Risco
1. **Navegação More** - Decidir entre sheet ou NavigationLink
2. **Phone Input** - Input com country code picker
3. **Detalhes de Ticket** - View complexa com múltiplos elementos

### Baixo Risco
1. **Redesign do Header** - Apenas ajuste de layout
2. **Remover seções** - Apenas deletar código
3. **Botão de Logout** - Já implementado, apenas mover

---

## 📋 Checklist de Gaps

### ProfileView
- [ ] Redesenhar header com fundo azul
- [ ] Remover seção "Notificações"
- [ ] Remover seção "Configurações" (Aparência/Privacidade)
- [ ] Remover link "Meus Eventos"
- [ ] Adicionar ilustração inferior
- [ ] Adicionar link "More"
- [ ] Adicionar link "My Favorite" (placeholder)

### EditProfileView
- [ ] Avatar grande no topo
- [ ] Input de telefone com country code
- [ ] Seção "Change Interests"
- [ ] Implementar InterestChip component
- [ ] Botão Save grande na base
- [ ] Persistir interesses selecionados

### MyTicketsView
- [ ] Adicionar QR Code aos cards
- [ ] Ajustar formato de data ("Feb, Mon 20, 2025")
- [ ] Mostrar "Ticket : XX" (quantidade)
- [ ] Implementar tela de detalhes (se necessário)

### MoreView (Nova)
- [ ] Criar MoreView.swift
- [ ] Lista de opções (FAQs, Privacy, Contact, Delete)
- [ ] Ilustração inferior
- [ ] Navegação para sub-telas

---

## 🎯 Próximos Passos

1. **Aprovar auditoria** ✅ (este documento)
2. **Criar tasks detalhadas** para cada componente
3. **Implementar na ordem**:
   - ProfileView (header + menu)
   - InterestChip component
   - EditProfileView (interesses)
   - MoreView
   - MyTicketsView (QR Code)

---

## 📝 Notas Técnicas

### Dependências do Projeto
- **TCA (The Composable Architecture)** - Para state management
- **SwiftUI** - Framework de UI
- **SF Symbols** - Para ícones
- **UserDefaults** - Para persistência local (currentUserId, deletedTicketIds)

### Padrões Observados
1. Uso consistente de `AppColors` para todas as cores
2. TCA com `@Reducer` e `@ObservableState`
3. Sheets para modais (`.sheet(isPresented:)`)
4. NavigationStack para navegação hierárquica
5. Preview com mock data

### Convenções de Código
- `snake_case` para keys de localização
- `camelCase` para variáveis Swift
- `PascalCase` para types/structs
- Comentários em português nos logs
- Use de emojis em prints de debug (📢, ✅, ❌, 🔄)

---

**Data da Auditoria**: 14 de Novembro de 2025  
**Versão**: 1.0  
**Status**: ✅ Completo e Aprovado para Implementação


