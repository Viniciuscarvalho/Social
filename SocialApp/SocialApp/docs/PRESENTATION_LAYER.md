# Camada de Presentation - Padrões e Organização

## Visão Geral

A camada de **Presentation** é responsável por toda a lógica de apresentação e UI do app, usando **The Composable Architecture (TCA)** para state management e **SwiftUI** para interface.

## Princípios Fundamentais

### 1. Separação de Responsabilidades

```
Feature/
├── [Name]Feature.swift      → State, Action, Reducer (lógica TCA)
├── Views/
│   ├── [Name]View.swift     → View principal
│   ├── [Name]Cell.swift     → Células e subviews
│   └── Components/          → Componentes específicos da feature
└── README.md (opcional)     → Documentação da feature
```

### 2. Feature vs View

#### Feature (Reducer)
- **Responsabilidade**: Lógica de negócio e state management
- **Contém**:
  - `State`: Estado observável da feature
  - `Action`: Todas as ações possíveis
  - `Reducer`: Lógica de transformação de estado
  - Dependencies: Injeção de clients (@Dependency)
- **NÃO contém**: Código SwiftUI, layouts, UI components

#### Views
- **Responsabilidade**: Renderização visual e interação do usuário
- **Contém**:
  - Componentes SwiftUI
  - Layouts e estrutura visual
  - Uso de componentes do Design System
- **NÃO contém**: Lógica de negócio, chamadas de API, transformações de dados

## Estrutura de uma Feature TCA

### Template de Feature

```swift
import ComposableArchitecture
import Domain
import DesignSystem

@Reducer
public struct ProfileFeature {
  
  // MARK: - State
  
  @ObservableState
  public struct State: Equatable {
    // Domain models (não DTOs!)
    public var user: User?
    
    // UI state
    public var isLoading = false
    public var errorMessage: String?
    
    // Navigation state
    public var showingEditProfile = false
    
    // Derived state (computed properties)
    public var displayName: String {
      user?.name ?? "Usuário"
    }
    
    public init(user: User? = nil) {
      self.user = user
    }
  }
  
  // MARK: - Action
  
  public enum Action: Equatable {
    // Lifecycle
    case onAppear
    case onDisappear
    
    // Data loading
    case loadProfile
    case profileResponse(Result<User, NetworkError>)
    
    // User interactions
    case editButtonTapped
    case saveButtonTapped
    
    // Navigation
    case setShowingEditProfile(Bool)
    
    // Error handling
    case dismissError
  }
  
  // MARK: - Dependencies
  
  @Dependency(\.profileClient) var profileClient
  
  public init() {}
  
  // MARK: - Reducer
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      
      case .onAppear:
        return .run { send in
          await send(.loadProfile)
        }
      
      case .loadProfile:
        state.isLoading = true
        state.errorMessage = nil
        return .run { send in
          do {
            let user = try await profileClient.fetchProfile()
            await send(.profileResponse(.success(user)))
          } catch {
            let networkError = error as? NetworkError ?? .unknown(error.localizedDescription)
            await send(.profileResponse(.failure(networkError)))
          }
        }
      
      case let .profileResponse(.success(user)):
        state.isLoading = false
        state.user = user
        return .none
      
      case let .profileResponse(.failure(error)):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
      
      case .editButtonTapped:
        state.showingEditProfile = true
        return .none
      
      case let .setShowingEditProfile(isShowing):
        state.showingEditProfile = isShowing
        return .none
      
      case .dismissError:
        state.errorMessage = nil
        return .none
      
      default:
        return .none
      }
    }
  }
}
```

### Template de View

```swift
import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct ProfileView: View {
  
  let store: StoreOf<ProfileFeature>
  
  public init(store: StoreOf<ProfileFeature>) {
    self.store = store
  }
  
  public var body: some View {
    // Use @Bindable para binding em sheets/alerts
    @Bindable var store = self.store
    
    ScrollView {
      VStack(spacing: DSSpacing.l) {
        if store.isLoading {
          DSLoadingIndicator()
        } else if let user = store.user {
          profileContent(user: user)
        } else if store.errorMessage != nil {
          errorContent
        }
      }
      .dsScreenPadding()
    }
    .dsBackgroundGradient(DSGradients.backgroundMain)
    .onAppear {
      store.send(.onAppear)
    }
    .sheet(isPresented: $store.showingEditProfile) {
      EditProfileView(user: store.user)
    }
  }
  
  // MARK: - Subviews
  
  @ViewBuilder
  private func profileContent(user: User) -> some View {
    VStack(spacing: DSSpacing.m) {
      // Avatar
      AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
        image.resizable().aspectRatio(contentMode: .fill)
      } placeholder: {
        DSSkeletonCircle(size: 100)
      }
      .frame(width: 100, height: 100)
      .clipShape(Circle())
      
      // Nome
      Text(user.name)
        .font(DSTypography.title2(weight: .bold))
        .foregroundColor(DSColors.textPrimary)
      
      // Bio
      if let bio = user.bio {
        Text(bio)
          .font(DSTypography.body())
          .foregroundColor(DSColors.textSecondary)
          .multilineTextAlignment(.center)
      }
      
      // Botão editar
      Button("Editar Perfil") {
        store.send(.editButtonTapped)
      }
      .dsPrimaryButton()
    }
  }
  
  @ViewBuilder
  private var errorContent: some View {
    DSErrorState(
      message: store.errorMessage ?? "Erro ao carregar perfil"
    ) {
      store.send(.loadProfile)
    }
  }
}
```

## Boas Práticas

### 1. State Management

✅ **BOM**
```swift
@ObservableState
public struct State: Equatable {
  public var user: User?  // Tipo do Domain
  public var isLoading = false
  public var errorMessage: String?
}
```

❌ **RUIM**
```swift
public struct State: Equatable {
  public var apiResponse: APIUserResponse?  // DTO da API!
  public var loading: Bool = false  // Inconsistente
  var error: String?  // Sem public
}
```

### 2. Actions

✅ **BOM**
```swift
public enum Action: Equatable {
  // Lifecycle
  case onAppear
  
  // Data loading
  case loadProfile
  case profileResponse(Result<User, NetworkError>)
  
  // User interactions
  case editButtonTapped
  case saveProfile(User)
}
```

❌ **RUIM**
```swift
public enum Action {  // Sem Equatable!
  case appear  // Inconsistente com onAppear
  case load
  case response(User)  // Sem Result!
  case button1  // Nome pouco descritivo
}
```

### 3. Derived State

Use computed properties para estado derivado:

✅ **BOM**
```swift
@ObservableState
public struct State: Equatable {
  public var tickets: [Ticket] = []
  
  public var displayTickets: [Ticket] {
    tickets.filter { $0.status != .cancelled }
  }
  
  public var hasTickets: Bool {
    !displayTickets.isEmpty
  }
}
```

❌ **RUIM**
```swift
public struct State: Equatable {
  public var tickets: [Ticket] = []
  public var displayTickets: [Ticket] = []  // Duplicação!
  public var hasTickets: Bool = false  // Pode desincronizar!
}
```

### 4. Error Handling

✅ **BOM**
```swift
case let .profileResponse(.failure(error)):
  state.isLoading = false
  state.errorMessage = error.localizedDescription
  return .none
```

❌ **RUIM**
```swift
case let .profileResponse(.failure(error)):
  print("Erro: \(error)")  // Erro perdido!
  return .none
```

### 5. Uso do Design System

✅ **BOM**
```swift
Button("Salvar") {
  store.send(.saveButtonTapped)
}
.dsPrimaryButton()

Text(user.name)
  .font(DSTypography.title2(weight: .bold))
  .foregroundColor(DSColors.textPrimary)

DSCard {
  // Conteúdo
}
```

❌ **RUIM**
```swift
Button("Salvar") {
  store.send(.saveButtonTapped)
}
.font(.system(size: 16, weight: .bold))
.foregroundColor(.blue)
.padding()
.background(Color.blue.gradient)
.cornerRadius(12)

// Reimplementando componentes ao invés de usar DS!
```

## Dependências e Clients

### Clients TCA

Os clients devem estar em `SocialApp/Sources/Dependencies` e usar a camada Data:

```swift
import Dependencies
import Data
import Domain

struct ProfileClient {
  var fetchProfile: @Sendable () async throws -> User
  var updateProfile: @Sendable (User) async throws -> User
}

extension ProfileClient: DependencyKey {
  static let liveValue = Self(
    fetchProfile: {
      let networkService = NetworkService.shared
      let response: APISingleResponse<APIUserResponse> = try await networkService.request(
        endpoint: "/users/me",
        method: .get
      )
      // Mapear DTO para Domain
      return response.data.toUser()
    },
    updateProfile: { user in
      // Implementação
      // ...
    }
  )
  
  static let testValue = Self(
    fetchProfile: { User.mock },
    updateProfile: { user in user }
  )
}

extension DependencyValues {
  var profileClient: ProfileClient {
    get { self[ProfileClient.self] }
    set { self[ProfileClient.self] = newValue }
  }
}
```

### Injeção de Dependências

```swift
@Reducer
public struct ProfileFeature {
  @Dependency(\.profileClient) var profileClient
  @Dependency(\.ticketsClient) var ticketsClient
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .loadProfile:
        return .run { send in
          let user = try await profileClient.fetchProfile()
          await send(.profileResponse(.success(user)))
        }
      }
    }
  }
}
```

## Navegação

### Sheets e Fullscreen Covers

```swift
@ObservableState
public struct State: Equatable {
  public var showingEditProfile = false
  public var showingSettings = false
}

public enum Action: Equatable {
  case setShowingEditProfile(Bool)
  case setShowingSettings(Bool)
}

// Na View:
.sheet(isPresented: $store.showingEditProfile) {
  EditProfileView()
}
.fullScreenCover(isPresented: $store.showingSettings) {
  SettingsView()
}
```

### Navigation Stack (iOS 16+)

```swift
@ObservableState
public struct State: Equatable {
  public var path: [Destination] = []
  
  public enum Destination: Equatable {
    case ticketDetail(Ticket)
    case sellerProfile(String)
  }
}

public enum Action: Equatable {
  case navigate(State.Destination)
  case popToRoot
}
```

## Testes

### Testes de Reducers

```swift
import ComposableArchitecture
import XCTest

@MainActor
final class ProfileFeatureTests: XCTestCase {
  
  func testLoadProfile() async {
    let store = TestStore(
      initialState: ProfileFeature.State()
    ) {
      ProfileFeature()
    } withDependencies: {
      $0.profileClient.fetchProfile = { .mock }
    }
    
    await store.send(.loadProfile) {
      $0.isLoading = true
    }
    
    await store.receive(.profileResponse(.success(.mock))) {
      $0.isLoading = false
      $0.user = .mock
    }
  }
}
```

## Migração de Features Existentes

### Checklist de Migração

- [ ] Separar Feature de Views
- [ ] Migrar para tipos do Domain (não DTOs)
- [ ] Substituir componentes custom por componentes DS
- [ ] Adicionar proper error handling
- [ ] Usar @ObservableState
- [ ] Adicionar computed properties para derived state
- [ ] Documentar navegação e dependências
- [ ] Testar funcionalidade

### Passos para Migração

1. **Analisar Feature Atual**
   - Identificar lógica na View
   - Mapear estado e ações
   - Identificar componentes UI customizados

2. **Refatorar Feature**
   - Mover lógica da View para Reducer
   - Usar tipos do Domain
   - Adicionar proper error handling

3. **Refatorar Views**
   - Usar componentes do Design System
   - Remover lógica de negócio
   - Simplificar estrutura

4. **Testar**
   - Compilar sem erros
   - Testar funcionalidade
   - Verificar integração

## Referências

- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [Design System - README](../DesignSystem/README.md)
- [Domain Layer - README](../Domain/README.md)
- [Data Layer - README](../Data/README.md)

## Exemplos Completos

Ver Features migradas:
- `Projects/Features/Profile/` - Feature piloto migrada
- (Outras features serão migradas incrementalmente)

---

✅ **Padrão de Presentation estabelecido para o projeto**

📚 **Use este guia como referência para criar ou migrar Features**

🎯 **Próximas migrações**: Task 10.0 - Migração Incremental por Contexto

