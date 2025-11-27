# Template de Feature TCA

Use este template como base para criar novas Features ou migrar Features existentes.

## Estrutura de Diretórios

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

## Feature.swift

```swift
import ComposableArchitecture
import Domain
import DesignSystem

@Reducer
public struct [FeatureName]Feature {
  
  // MARK: - State
  
  @ObservableState
  public struct State: Equatable {
    // Domain models
    public var data: [ModelType] = []
    
    // UI state
    public var isLoading = false
    public var errorMessage: String?
    
    // Navigation state
    public var selectedItem: ModelType?
    public var showingDetail = false
    
    // Derived state
    public var hasData: Bool {
      !data.isEmpty
    }
    
    public init() {}
  }
  
  // MARK: - Action
  
  public enum Action: Equatable {
    // Lifecycle
    case onAppear
    case onDisappear
    
    // Data loading
    case loadData
    case dataResponse(Result<[ModelType], NetworkError>)
    
    // User interactions
    case itemTapped(ModelType)
    case refreshRequested
    
    // Navigation
    case setShowingDetail(Bool)
    case setSelectedItem(ModelType?)
    
    // Error handling
    case dismissError
  }
  
  // MARK: - Dependencies
  
  @Dependency(\.dataClient) var dataClient
  
  public init() {}
  
  // MARK: - Reducer
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      
      case .onAppear:
        guard state.data.isEmpty else { return .none }
        return .run { send in
          await send(.loadData)
        }
      
      case .loadData:
        state.isLoading = true
        state.errorMessage = nil
        return .run { send in
          do {
            let data = try await dataClient.fetchData()
            await send(.dataResponse(.success(data)))
          } catch {
            let networkError = error as? NetworkError ?? .unknown(error.localizedDescription)
            await send(.dataResponse(.failure(networkError)))
          }
        }
      
      case let .dataResponse(.success(data)):
        state.isLoading = false
        state.data = data
        return .none
      
      case let .dataResponse(.failure(error)):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
      
      case let .itemTapped(item):
        state.selectedItem = item
        state.showingDetail = true
        return .none
      
      case .refreshRequested:
        return .run { send in
          await send(.loadData)
        }
      
      case let .setShowingDetail(isShowing):
        state.showingDetail = isShowing
        if !isShowing {
          state.selectedItem = nil
        }
        return .none
      
      case let .setSelectedItem(item):
        state.selectedItem = item
        return .none
      
      case .dismissError:
        state.errorMessage = nil
        return .none
      
      case .onDisappear:
        return .none
      }
    }
  }
}

// MARK: - Helper Extensions

extension [FeatureName]Feature.State {
  // Adicione computed properties complexas aqui
}
```

## View.swift

```swift
import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct [FeatureName]View: View {
  
  let store: StoreOf<[FeatureName]Feature>
  
  public init(store: StoreOf<[FeatureName]Feature>) {
    self.store = store
  }
  
  public var body: some View {
    @Bindable var store = self.store
    
    contentView
      .onAppear {
        store.send(.onAppear)
      }
      .onDisappear {
        store.send(.onDisappear)
      }
      .sheet(isPresented: $store.showingDetail) {
        if let item = store.selectedItem {
          DetailView(item: item)
        }
      }
      .alert(
        "Erro",
        isPresented: .constant(store.errorMessage != nil),
        actions: {
          Button("OK") {
            store.send(.dismissError)
          }
        },
        message: {
          if let error = store.errorMessage {
            Text(error)
          }
        }
      )
  }
  
  // MARK: - Content View
  
  @ViewBuilder
  private var contentView: some View {
    if store.isLoading {
      loadingView
    } else if store.hasData {
      dataView
    } else if store.errorMessage != nil {
      errorView
    } else {
      emptyView
    }
  }
  
  // MARK: - Subviews
  
  @ViewBuilder
  private var loadingView: some View {
    DSFullScreenLoading(message: "Carregando...")
  }
  
  @ViewBuilder
  private var dataView: some View {
    ScrollView {
      LazyVStack(spacing: DSSpacing.m) {
        ForEach(store.data) { item in
          ItemCell(item: item) {
            store.send(.itemTapped(item))
          }
        }
      }
      .padding(DSSpacing.m)
    }
    .refreshable {
      store.send(.refreshRequested)
    }
  }
  
  @ViewBuilder
  private var errorView: some View {
    DSErrorState(
      message: store.errorMessage ?? "Erro desconhecido"
    ) {
      store.send(.refreshRequested)
    }
  }
  
  @ViewBuilder
  private var emptyView: some View {
    DSEmptyState(
      icon: "tray.fill",
      title: "Nenhum item",
      message: "Não há itens para exibir"
    )
  }
}

// MARK: - Item Cell

struct ItemCell: View {
  let item: ModelType
  let action: () -> Void
  
  var body: some View {
    DSCard {
      HStack {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
          Text(item.title)
            .font(DSTypography.headline())
            .foregroundColor(DSColors.textPrimary)
          
          Text(item.subtitle)
            .font(DSTypography.body())
            .foregroundColor(DSColors.textSecondary)
        }
        
        Spacer()
        
        Image(systemName: "chevron.right")
          .foregroundColor(DSColors.textTertiary)
      }
    }
    .onTapGesture {
      action()
    }
  }
}

// MARK: - Previews

#if DEBUG
#Preview {
  [FeatureName]View(
    store: Store(
      initialState: [FeatureName]Feature.State()
    ) {
      [FeatureName]Feature()
    }
  )
}
#endif
```

## Client (Dependencies)

```swift
// Em SocialApp/Sources/Dependencies/[FeatureName]Client.swift

import Dependencies
import Data
import Domain
import Foundation

struct [FeatureName]Client {
  var fetchData: @Sendable () async throws -> [ModelType]
  var updateItem: @Sendable (ModelType) async throws -> ModelType
  var deleteItem: @Sendable (String) async throws -> Void
}

extension [FeatureName]Client: DependencyKey {
  static let liveValue = Self(
    fetchData: {
      let networkService = NetworkService.shared
      let response: APIListResponse<APIModelResponse> = try await networkService.request(
        endpoint: "/items",
        method: .get
      )
      // Mapear DTOs para Domain
      return response.data.map { $0.toDomain() }
    },
    updateItem: { item in
      let networkService = NetworkService.shared
      let body = UpdateItemRequest(from: item)
      let response: APISingleResponse<APIModelResponse> = try await networkService.request(
        endpoint: "/items/\(item.id)",
        method: .put,
        body: body
      )
      return response.data.toDomain()
    },
    deleteItem: { id in
      let networkService = NetworkService.shared
      let _: APIErrorResponse = try await networkService.request(
        endpoint: "/items/\(id)",
        method: .delete
      )
    }
  )
  
  static let testValue = Self(
    fetchData: { [.mock, .mock] },
    updateItem: { item in item },
    deleteItem: { _ in }
  )
  
  static let previewValue = testValue
}

extension DependencyValues {
  var [featureName]Client: [FeatureName]Client {
    get { self[[FeatureName]Client.self] }
    set { self[[FeatureName]Client.self] = newValue }
  }
}
```

## Project.swift (Tuist)

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
        .project(target: "Domain", path: .relativeToRoot("Domain")),
        .project(target: "DesignSystem", path: .relativeToRoot("DesignSystem")),
        .external(name: "ComposableArchitecture")
      ]
    )
  ]
)
```

## Checklist de Implementação

### Setup Inicial
- [ ] Criar estrutura de diretórios
- [ ] Configurar Project.swift com dependências
- [ ] Criar State inicial com tipos do Domain

### Feature (Reducer)
- [ ] Definir State com @ObservableState
- [ ] Definir Actions (lifecycle, data, UI, navigation)
- [ ] Implementar Reducer com proper error handling
- [ ] Adicionar @Dependency para clients necessários
- [ ] Adicionar computed properties para derived state

### Views
- [ ] Criar View principal usando componentes DS
- [ ] Implementar diferentes estados (loading, data, empty, error)
- [ ] Adicionar navigation (sheets, fullscreen, navigation stack)
- [ ] Implementar cells/subviews reutilizáveis
- [ ] Adicionar gestures e interactions

### Client
- [ ] Criar client em SocialApp/Sources/Dependencies
- [ ] Implementar métodos usando DTOs da camada Data
- [ ] Mapear DTOs para tipos do Domain
- [ ] Adicionar testValue e previewValue
- [ ] Registrar em DependencyValues

### Testing
- [ ] Compilar sem erros
- [ ] Testar todos os fluxos principais
- [ ] Testar navegação
- [ ] Testar error handling
- [ ] (Opcional) Adicionar testes unitários

### Documentação
- [ ] Adicionar comentários no código
- [ ] (Opcional) Criar README.md da feature
- [ ] Documentar casos especiais

## Exemplos

### Loading State
```swift
if store.isLoading {
  DSLoadingIndicator(size: .large)
}
```

### Empty State
```swift
if store.data.isEmpty && !store.isLoading {
  DSEmptyState(
    icon: "tray.fill",
    title: "Nenhum item",
    message: "Adicione novos itens"
  )
}
```

### Error Handling
```swift
.alert(
  "Erro",
  isPresented: .constant(store.errorMessage != nil),
  actions: {
    Button("Tentar Novamente") {
      store.send(.refreshRequested)
    }
    Button("Cancelar", role: .cancel) {
      store.send(.dismissError)
    }
  },
  message: {
    if let error = store.errorMessage {
      Text(error)
    }
  }
)
```

### Pull to Refresh
```swift
.refreshable {
  store.send(.refreshRequested)
}
```

### Navigation Sheet
```swift
.sheet(isPresented: $store.showingDetail) {
  if let item = store.selectedItem {
    DetailView(item: item)
  }
}
```

## Notas Importantes

1. **Sempre use tipos do Domain**, nunca DTOs de API
2. **Use componentes do Design System**, não crie custom components básicos
3. **Mantenha Views enxutas**, lógica deve estar no Reducer
4. **Use @ObservableState** para state observation
5. **Implemente proper error handling** com Result types
6. **Adicione computed properties** para derived state
7. **Teste todos os fluxos** antes de considerar completo

## Referências

- [PRESENTATION_LAYER.md](./PRESENTATION_LAYER.md) - Padrões detalhados
- [Design System README](../DesignSystem/README.md) - Componentes disponíveis
- [TCA Documentation](https://github.com/pointfreeco/swift-composable-architecture) - Framework oficial

---

✅ **Use este template para criar Features consistentes e bem organizadas**

