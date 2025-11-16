# Tech Spec — Telas de Empty State e Sucesso

## Resumo Executivo

Implementação de componentes reutilizáveis de empty state e sucesso seguindo a arquitetura TCA (The Composable Architecture) existente. Os componentes serão integrados nas views existentes para melhorar a experiência do usuário em estados específicos do aplicativo.

## Arquitetura do Sistema

### Visão Geral dos Componentes

A implementação seguirá a estrutura existente do projeto:
- **Views**: SwiftUI views em `Projects/Features/[Feature]/Sources/`
- **Features**: Reducers TCA em cada módulo de feature
- **Commons**: Componentes reutilizáveis em `SocialApp/Sources/Commons/`
- **Cores/Temas**: `SocialApp/Sources/ThemeApp/AppColors.swift`

### Estrutura de Arquivos

```
Projects/Features/
├── Events/Sources/
│   ├── SearchView.swift (atualizar noResultsView)
│   └── Favorites/FavoritesView.swift (atualizar empty state)
├── TicketsList/Sources/
│   ├── MyTicketsView.swift (atualizar emptyStateView)
│   ├── AddTicketView.swift (adicionar empty state inicial e tela de sucesso)
└── Login/Views/
    └── SignInView.swift (atualizar ForgotPasswordView.successStepContent)

SocialApp/Sources/
└── Commons/
    └── ErrorView.swift (já possui EmptyStateView - pode ser estendido ou criar variações)
```

## Design de Implementação

### Componentes Reutilizáveis

#### 1. SuccessView (Novo Componente)
```swift
public struct SuccessView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let message: String
    let buttonTitle: String
    let buttonAction: () -> Void
    
    public init(
        icon: String = "checkmark.circle.fill",
        iconColor: Color = .green,
        title: String,
        message: String,
        buttonTitle: String,
        buttonAction: @escaping () -> Void
    )
}
```

**Localização**: `SocialApp/Sources/Commons/SuccessView.swift`

**Características**:
- Ícone circular com fundo colorido (configurável)
- Título em negrito
- Mensagem em texto secundário
- Botão de ação primário
- Layout centralizado verticalmente

#### 2. EmptyStateView (Existente - Estender)
O arquivo `SocialApp/Sources/Commons/ErrorView.swift` já possui um `EmptyStateView`. Será utilizado e possivelmente estendido para casos específicos.

**Arquivo existente**: Linhas 125-177 de `ErrorView.swift`

**Melhorias/Extensões**:
- Suporte a ícones customizados (SF Symbols e assets)
- Diferentes tamanhos de ícone
- Layout otimizado para diferentes contextos

### Interfaces Principais

#### 1. SearchView - noResultsView
**Arquivo**: `Projects/Features/Events/Sources/SearchView.swift`
**Linhas**: 177-194 (já existe, precisa ser atualizado)

**Atualização**:
- Ícone: `magnifyingglass` em círculo cinza claro
- Título: "Nenhum Resultado Encontrado" (localizado)
- Mensagem: "Tente uma palavra-chave diferente ou filtro para encontrar eventos incríveis perto de você" (localizado)
- Sem botão de ação (depende do contexto)

#### 2. MyTicketsView - emptyStateView
**Arquivo**: `Projects/Features/TicketsList/Sources/MyTicketsView.swift`
**Linhas**: 62-81 (já existe, precisa ser atualizado)

**Atualização**:
- Adicionar tabs "Upcoming" e "Past Ticket"
- Ícone: `ticket.fill` (amarelo/preto conforme design)
- Título dinâmico baseado na tab selecionada
- Mensagem explicativa
- Botão "Browse Events" que navega para a tela de eventos

**Nova estrutura**:
```swift
private var emptyStateView: some View {
    VStack(spacing: 24) {
        // Tabs para Upcoming/Past
        HStack(spacing: 12) {
            TabButton(title: "Upcoming", isSelected: selectedTab == .upcoming)
            TabButton(title: "Past Ticket", isSelected: selectedTab == .past)
        }
        
        // Empty state content
        EmptyStateView(...)
    }
}
```

#### 3. FavoritesView - Empty State
**Arquivo**: `Projects/Features/Events/Sources/Favorites/FavoritesView.swift`
**Linhas**: 18-29 (usa ContentUnavailableView, precisa ser customizado)

**Atualização**:
- Substituir `ContentUnavailableView` por `EmptyStateView` customizado
- Ícone: `heart.fill` (rosa/preto conforme design)
- Título: "Nenhum Favorito Ainda"
- Mensagem: "Toque no ícone de coração para salvar eventos que você ama e acessá-los a qualquer momento aqui"
- Botão "Adicionar" que navega para eventos

#### 4. AddTicketView - Empty State Inicial
**Arquivo**: `Projects/Features/TicketsList/Sources/AddTicketView.swift`

**Nova implementação**:
- Adicionar step inicial `.welcome` ao enum `TicketCreationStep`
- View inicial exibida antes do fluxo de criação
- Ícone: `calendar` (calendário conforme design)
- Título: "Anunciar Ingresso"
- Mensagem: "Configure seu ingresso em minutos — personalize detalhes, preços e publique!"
- Botão "Anunciar Ingresso" para iniciar o fluxo

**Modificação no enum**:
```swift
public enum TicketCreationStep: Int, CaseIterable, Equatable {
    case welcome = -1  // Novo step inicial
    case details = 0
    // ... resto
}
```

#### 5. AddTicketView - Tela de Sucesso
**Arquivo**: `Projects/Features/TicketsList/Sources/AddTicketView.swift`

**Nova implementação**:
- Adicionar step `.success` ao enum `TicketCreationStep`
- View de sucesso exibida após publicação
- Usar `SuccessView` component
- Ícone: `calendar` com checkmark verde
- Título: "Anunciar Ingresso Está Pronto!"
- Mensagem: "Os detalhes do seu ingresso estão configurados. Revise e publique para disponibilizar para compradores."
- Botão "Confirmar & Publicar" ou "Concluir"

**Modificação no Feature**:
- Adicionar state `publishSuccess: Bool = false`
- Ao publicar com sucesso, navegar para step `.success`
- Após ação no botão, fechar o modal

#### 6. ForgotPasswordView - Tela de Sucesso
**Arquivo**: `Projects/Features/Login/Views/SignInView.swift`
**Linhas**: 410-449 (já existe, precisa ser atualizado)

**Atualização**:
- Usar `SuccessView` component para consistência
- Ícone: `checkmark.circle.fill` verde em círculo
- Título: "Successful"
- Mensagem: "Sua nova senha foi definida com sucesso!"
- Botão "Done" que fecha o modal

### Modelos de Dados

Não requer novos modelos. Os estados são gerenciados pelas Features existentes.

**Estados adicionados/atualizados**:
```swift
// AddTicketFeature.State
var showWelcome: Bool = false  // Novo
var publishSuccess: Bool = false  // Já existe

// MyTicketsFeature.State
enum TicketTab {
    case upcoming
    case past
}
var selectedTab: TicketTab = .upcoming  // Novo
```

### Endpoints de API

Não requer alterações em APIs. Apenas mudanças na UI.

## Pontos de Integração

### Navegação

1. **MyTicketsView → EventsView**:
   - Botão "Browse Events" deve navegar para a aba de eventos
   - Usar o sistema de navegação existente (TabView ou NavigationLink)

2. **FavoritesView → EventsView**:
   - Botão "Add" deve navegar para a aba de eventos
   - Mesmo padrão acima

3. **AddTicketView Welcome → Details**:
   - Botão "Anunciar Ingresso" deve avançar para step `.details`

4. **AddTicketView Success → Close**:
   - Botão "Concluir" deve fechar o modal e atualizar listas

### Localização (String Catalog)

**Novas chaves a adicionar**:

```xcstrings
"empty_state.search.no_results.title" = "Nenhum Resultado Encontrado";
"empty_state.search.no_results.message" = "Tente uma palavra-chave diferente ou filtro para encontrar eventos incríveis perto de você";

"empty_state.tickets.no_upcoming.title" = "Nenhum Ingresso Futuro";
"empty_state.tickets.no_upcoming.message" = "Você não tem eventos futuros. Encontre eventos emocionantes e compre seus ingressos hoje!";
"empty_state.tickets.no_past.title" = "Nenhum Ingresso Passado";
"empty_state.tickets.browse_events" = "Navegar Eventos";

"empty_state.favorites.title" = "Nenhum Favorito Ainda";
"empty_state.favorites.message" = "Toque no ícone de coração para salvar eventos que você ama e acessá-los a qualquer momento aqui.";
"empty_state.favorites.add_button" = "Adicionar";

"empty_state.announce_ticket.title" = "Anunciar Ingresso";
"empty_state.announce_ticket.message" = "Configure seu ingresso em minutos — personalize detalhes, preços e publique!";
"empty_state.announce_ticket.button" = "Anunciar Ingresso";

"success.announce_ticket.title" = "Anunciar Ingresso Está Pronto!";
"success.announce_ticket.message" = "Os detalhes do seu ingresso estão configurados. Revise e publique para disponibilizar para compradores.";
"success.announce_ticket.button" = "Confirmar & Publicar";

"success.password_reset.title" = "Bem-sucedido";
"success.password_reset.message" = "Sua nova senha foi definida com sucesso!";
"success.password_reset.button" = "Concluir";
```

**Arquivo**: `SocialApp/Resources/Localizable.xcstrings`

## Abordagem de Testes

### Testes Unitários

1. **SuccessView Component**:
   - Verificar renderização de todos os elementos
   - Testar ação do botão
   - Testar diferentes configurações de ícone e cor

2. **EmptyStateView Variations**:
   - Verificar renderização com diferentes ícones
   - Testar com/sem botão de ação
   - Testar mensagens longas

### Testes de Integração

1. **MyTicketsView**:
   - Verificar exibição de empty state quando não há ingressos
   - Testar navegação entre tabs Upcoming/Past
   - Testar botão "Browse Events"

2. **SearchView**:
   - Verificar exibição quando busca retorna vazio
   - Verificar que não aparece quando busca está vazia

3. **AddTicketView**:
   - Verificar exibição da tela inicial
   - Verificar navegação após sucesso de publicação

### Snapshot Tests

Criar snapshots para:
- Todas as variações de `SuccessView`
- Todas as variações de `EmptyStateView`
- Telas completas com empty states

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. **Criar componente SuccessView reutilizável** (base para todas as telas de sucesso)
   - Arquivo: `SocialApp/Sources/Commons/SuccessView.swift`
   - Testes unitários básicos

2. **Atualizar EmptyStateView existente** (se necessário)
   - Melhorar flexibilidade do componente
   - Adicionar suporte a diferentes estilos

3. **Implementar empty state de busca** (mais simples)
   - Atualizar `SearchView.noResultsView`
   - Adicionar localizações

4. **Implementar empty state de favoritos** (simples)
   - Atualizar `FavoritesView`
   - Adicionar botão de ação

5. **Implementar empty state de Meus Ingressos** (médio - requer tabs)
   - Adicionar tabs ao `MyTicketsView`
   - Atualizar empty state com tabs
   - Implementar navegação

6. **Implementar empty state inicial de Anunciar Ingresso** (médio)
   - Adicionar step `.welcome` ao enum
   - Criar view inicial
   - Integrar no fluxo

7. **Implementar tela de sucesso de Anunciar Ingresso** (médio)
   - Adicionar step `.success` ao enum
   - Usar `SuccessView` component
   - Integrar no fluxo de publicação

8. **Atualizar tela de sucesso de reset de senha** (simples)
   - Substituir view atual por `SuccessView`
   - Ajustar mensagens

9. **Adicionar todas as localizações** (String Catalog)
   - Adicionar todas as chaves necessárias

10. **Testes e ajustes finais**
    - Testes unitários e de integração
    - Ajustes visuais e de acessibilidade

### Dependências Técnicas

- Nenhuma dependência externa adicional
- Utilizar apenas SwiftUI e TCA (já presentes)
- SF Symbols para ícones (sistema)

## Considerações Técnicas

### Decisões Principais

1. **Reutilização de EmptyStateView existente**:
   - Decisão: Estender o componente existente em `ErrorView.swift` ao invés de criar novo
   - Justificativa: Evitar duplicação e manter consistência
   - Alternativa rejeitada: Criar novo componente do zero

2. **Criar SuccessView separado**:
   - Decisão: Criar componente dedicado para telas de sucesso
   - Justificativa: Diferente do empty state (feedback positivo vs ausência de conteúdo)
   - Permite estilização específica para sucesso

3. **Tabs em MyTicketsView**:
   - Decisão: Implementar tabs localmente na view
   - Justificativa: Simplicidade, não requer novo Feature
   - Alternativa rejeitada: Criar novo Feature para gerenciar tabs

4. **Step adicional em AddTicketView**:
   - Decisão: Adicionar steps `.welcome` e `.success` ao enum existente
   - Justificativa: Manter consistência com fluxo existente
   - Requer ajuste no StepProgressView para não mostrar welcome

### Riscos Conhecidos

1. **Conflito com funcionalidades existentes**:
   - Risco: Adicionar steps pode quebrar lógica existente
   - Mitigação: Testes extensivos e revisão cuidadosa do fluxo

2. **Navegação entre features**:
   - Risco: Botões em empty states podem requerer navegação complexa
   - Mitigação: Usar sistema de navegação existente (TabView state ou NavigationLink)

3. **Performance de múltiplos empty states**:
   - Risco: Múltiplas views podem impactar performance
   - Mitigação: Empty states são leves, usar lazy loading quando necessário

### Requisitos Especiais

- **Acessibilidade**: 
  - Todas as views devem suportar Dynamic Type
  - VoiceOver labels adequados
  - Contraste WCAG AA

- **Localização**:
  - Todos os textos devem usar String Catalog
  - Suporte inicial para pt-BR, preparado para futuras traduções

### Conformidade com Padrões

- Seguir padrões de código SwiftUI existentes no projeto
- Manter estrutura TCA (Reducer pattern)
- Usar AppColors para cores (não hardcoded)
- Componentes públicos quando em Commons (para reutilização)

### Arquivos Relevantes

**Views**:
- `Projects/Features/Events/Sources/SearchView.swift`
- `Projects/Features/Events/Sources/Favorites/FavoritesView.swift`
- `Projects/Features/TicketsList/Sources/MyTicketsView.swift`
- `Projects/Features/TicketsList/Sources/AddTicketView.swift`
- `Projects/Features/Login/Views/SignInView.swift` (ForgotPasswordView)

**Features**:
- `Projects/Features/TicketsList/Sources/AddTicketFeature.swift`
- `Projects/Features/TicketsList/Sources/MyTicketsFeature.swift`

**Commons**:
- `SocialApp/Sources/Commons/ErrorView.swift` (EmptyStateView)
- `SocialApp/Sources/Commons/SuccessView.swift` (novo)

**Temas**:
- `SocialApp/Sources/ThemeApp/AppColors.swift`

**Localização**:
- `SocialApp/Resources/Localizable.xcstrings`


