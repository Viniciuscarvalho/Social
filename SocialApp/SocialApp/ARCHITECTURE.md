# 🏗️ Arquitetura do SocialApp - Integração com Supabase

## 📊 Visão Geral da Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                       SwiftUI Views                          │
│  (AuthenticationView, ProfileView, EventsView, etc.)        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  TCA Features (Reducers)                     │
│  (AuthFeature, ProfileFeature, EventsFeature, etc.)         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   Dependency Clients                         │
│  (AuthClient, ProfileClient, EventsClient, etc.)            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   SupabaseManager                            │
│             (Singleton para Supabase Client)                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                      Supabase                                │
│         (Backend, Database, Auth, Storage)                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Camadas da Aplicação

### 1. **Presentation Layer (SwiftUI Views)**
- **Responsabilidade**: UI e interação com o usuário
- **Tecnologia**: SwiftUI
- **Exemplos**: 
  - `AuthenticationView.swift`
  - `ProfileView.swift`
  - `EventsView.swift`

### 2. **Business Logic Layer (TCA Features)**
- **Responsabilidade**: Lógica de negócio, gerenciamento de estado
- **Tecnologia**: The Composable Architecture (TCA)
- **Exemplos**:
  - `AuthFeature.swift`
  - `ProfileFeature.swift`
  - `EventsFeature.swift`

### 3. **Data Access Layer (Dependency Clients)**
- **Responsabilidade**: Comunicação com backend, cache, persistência
- **Tecnologia**: TCA Dependencies
- **Arquivos**:
  - ✅ `AuthClient.swift` - Autenticação com Supabase
  - ✅ `ProfileClient.swift` - Gerenciamento de perfis
  - ✅ `EventsClient.swift` - Gerenciamento de eventos
  - ✅ `TicketsClient.swift` - Gerenciamento de tickets
  - ✅ `FavoritesClient.swift` - Gerenciamento de favoritos
  - ✅ `UserClient.swift` - Gerenciamento de usuários

### 4. **Infrastructure Layer**
- **Responsabilidade**: Configuração, networking, storage
- **Componentes**:
  - `SupabaseManager.swift` - Singleton para Supabase
  - `NetworkService.swift` - Fallback para APIs REST (se necessário)

---

## 📦 Estrutura de Arquivos Recomendada

```
SocialApp/
├── Domain/
│   └── Sources/
│       └── Models.swift              # User, Event, Ticket, Profile, etc.
│
├── Projects/
│   └── Features/
│       ├── Login/
│       │   └── Auth/
│       │       ├── AuthFeature.swift
│       │       ├── Views/
│       │       │   ├── AuthenticationView.swift
│       │       │   ├── SignInView.swift
│       │       │   └── SignUpView.swift
│       │       └── SupabaseManager.swift  # ✅ MANTER
│       │
│       ├── Profile/
│       │   ├── ProfileFeature.swift
│       │   └── ProfileView.swift
│       │
│       ├── Events/
│       │   ├── EventsFeature.swift
│       │   └── EventsView.swift
│       │
│       └── TicketsList/
│           ├── TicketsListFeature.swift
│           └── TicketsListView.swift
│
└── SocialApp/
    └── Sources/
        ├── Dependencies/
        │   ├── AuthClient.swift       # ✅ ATUALIZADO (usa Supabase)
        │   ├── ProfileClient.swift    # ✅ NOVO
        │   ├── EventsClient.swift     # ✅ ATUALIZAR (usar Supabase)
        │   ├── TicketsClient.swift    # ✅ ATUALIZAR (usar Supabase)
        │   ├── FavoritesClient.swift  # ✅ ATUALIZAR (usar Supabase)
        │   └── UserClient.swift       # ✅ ATUALIZAR (usar Supabase)
        │
        └── Services/
            ├── EventRepository.swift  # ❌ PODE REMOVER (lógica vai para EventsClient)
            └── NetworkService.swift   # ✅ MANTER (fallback)
```

---

## 🔄 Fluxo de Dados

### Exemplo: Login de Usuário

```
1. User taps "Entrar" em SignInView
   │
   ▼
2. SignInView dispara Action: .signInButtonTapped
   │
   ▼
3. AuthFeature recebe action e chama authClient.signIn()
   │
   ▼
4. AuthClient faz request para Supabase via SupabaseManager
   │
   ▼
5. Supabase retorna Session + User
   │
   ▼
6. AuthClient busca Profile do usuário
   │
   ▼
7. AuthClient converte Profile → User (modelo do app)
   │
   ▼
8. AuthClient retorna AuthResponse
   │
   ▼
9. AuthFeature atualiza state com usuário logado
   │
   ▼
10. SignInView re-renderiza e navega para HomeView
```

---

## ✅ Decisões de Arquitetura

### 1. **Usar AuthClient em vez de AuthManager**
**Decisão**: ✅ Usar `AuthClient` (TCA pattern)  
**Razão**: 
- Consistente com arquitetura TCA
- Testável via `testValue`
- Dependency injection built-in
- Melhor separação de responsabilidades

### 2. **Criar ProfileClient separado**
**Decisão**: ✅ Criar `ProfileClient`  
**Razão**:
- Separação de concerns (Auth ≠ Profile)
- Permite testar independentemente
- Facilita reutilização em diferentes features

### 3. **EventRepository vs EventsClient**
**Decisão**: ✅ Usar `EventsClient`, remover `EventRepository`  
**Razão**:
- `EventRepository` usa `@Published` (não é TCA)
- `EventsClient` segue padrão TCA
- Evita mistura de paradigmas (Observation + TCA)

### 4. **SupabaseManager como Singleton**
**Decisão**: ✅ Manter `SupabaseManager` como singleton  
**Razão**:
- Gerencia conexão única com Supabase
- Compartilhado entre todos os Clients
- Fácil de configurar e testar

---

## 🗂️ Modelos de Dados

### Relação entre Modelos

```
Supabase (Database)     →     App (Swift)
─────────────────────────────────────────
auth.users              →     (gerenciado pelo Supabase)
profiles                →     Profile
events                  →     Event
tickets                 →     Ticket
favorite_events         →     FavoriteEvent
favorite_tickets        →     (não usado diretamente)
```

### Conversão Profile → User

O app usa `User` internamente para compatibilidade com código existente:

```swift
Profile (Supabase) → User (App)
{                     {
  id: UUID              id: String (UUID.uuidString)
  name: String          name: String
  email: String         email: String
  avatar_url: String?   profileImageURL: String?
  ...                   ...
}                     }
```

---

## 🧪 Testing Strategy

### 1. **Unit Tests (Reducers)**
```swift
let store = TestStore(initialState: AuthFeature.State()) {
    AuthFeature()
} withDependencies: {
    $0.authClient = .testValue
}

await store.send(.signInButtonTapped) {
    $0.isLoading = true
}
```

### 2. **Integration Tests (Clients)**
```swift
let client = AuthClient.liveValue
let response = try await client.signIn(
    email: "test@example.com",
    password: "password"
)
XCTAssertNotNil(response.user)
```

### 3. **UI Tests**
```swift
let app = XCUIApplication()
app.launch()
app.textFields["Email"].tap()
app.textFields["Email"].typeText("test@example.com")
// ...
```

---

## 🚀 Plano de Migração

### Fase 1: Setup Supabase ✅
- [x] Criar projeto no Supabase
- [x] Configurar database schema
- [x] Configurar RLS policies
- [x] Criar triggers
- [x] Configurar storage

### Fase 2: Atualizar Clients 🔄
- [x] Atualizar `AuthClient` para usar Supabase
- [x] Criar `ProfileClient`
- [ ] Atualizar `EventsClient` para usar Supabase
- [ ] Atualizar `TicketsClient` para usar Supabase
- [ ] Atualizar `FavoritesClient` para usar Supabase
- [ ] Atualizar `UserClient` para usar Supabase

### Fase 3: Remover Código Antigo ⏳
- [ ] Remover `AuthManager.swift`
- [ ] Remover `EventRepository.swift`
- [ ] Remover chamadas antigas de API (se houver)

### Fase 4: Testing 🧪
- [ ] Testar fluxo de autenticação
- [ ] Testar CRUD de eventos
- [ ] Testar CRUD de tickets
- [ ] Testar favoritos
- [ ] Testar upload de avatar

### Fase 5: Deploy 🚀
- [ ] Configurar variáveis de ambiente
- [ ] Deploy para TestFlight
- [ ] Monitoring e logs
- [ ] Rollout gradual

---

## 📝 Checklist de Implementação

### Para cada Client:

- [ ] Criar interface no Client (funções com `@Sendable`)
- [ ] Implementar `liveValue` usando Supabase
- [ ] Implementar `testValue` para testes
- [ ] Adicionar logs de debug
- [ ] Tratar erros apropriadamente
- [ ] Converter modelos Supabase → modelos do app
- [ ] Atualizar Feature para usar novo Client
- [ ] Escrever testes unitários
- [ ] Escrever testes de integração

---

## 🛡️ Segurança

### Boas Práticas:

1. **Nunca expor chaves do Supabase no código**
   - Use variáveis de ambiente
   - Use `.gitignore` para arquivos de config

2. **Row Level Security (RLS)**
   - Sempre habilitar RLS nas tabelas
   - Criar policies específicas por caso de uso

3. **Validação de dados**
   - Validar no client
   - Validar no servidor (Supabase functions)

4. **Tokens**
   - Armazenar de forma segura (Keychain)
   - Renovar tokens automaticamente

---

## 📚 Referências

- [Supabase Swift Docs](https://github.com/supabase-community/supabase-swift)
- [TCA Documentation](https://pointfreeco.github.io/swift-composable-architecture/)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)

