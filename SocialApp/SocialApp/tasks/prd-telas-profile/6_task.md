## status: pending

<task_context>
<domain>features/profile/integration</domain>
<type>integration</type>
<scope>core_feature</scope>
<complexity>low</complexity>
<dependencies>tca|navigation</dependencies>
</task_context>

# Tarefa 6.0: Integrar navegação e state management

## Visão Geral

Garantir que todas as novas views (ProfileView redesenhado, EditProfileView com interesses, MoreView, MyTicketsView com QR) estejam corretamente integradas com o state management (TCA) e que a navegação flua suavemente entre todas as telas.

<requirements>
- Atualizar ProfileFeature com novos states e actions
- Garantir binding correto entre views e store
- Implementar navigation flow completo
- Adicionar loading states onde necessário
- Persistir interesses selecionados
- Sincronizar contagem de tickets após edições
- Testar fluxo completo: Profile → Edit → Save → More → Sub-views
</requirements>

## Subtarefas

- [ ] 6.1 Atualizar ProfileFeature.State com novos campos
- [ ] 6.2 Adicionar novas actions (favoritesTapped, moreMenuTapped, updateInterests)
- [ ] 6.3 Implementar reducers para novas actions
- [ ] 6.4 Conectar EditProfileView com InterestSelectionView via binding
- [ ] 6.5 Garantir persistência de interesses no backend/UserDefaults
- [ ] 6.6 Testar navegação entre todas as telas
- [ ] 6.7 Adicionar analytics/logging para tracking de ações

## Detalhes de Implementação

### 6.1 Atualizar ProfileFeature.State
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
    public var showingMore = false // ✅ NOVO
    public var selectedInterests: Set<String> = [] // ✅ NOVO
    
    public init(user: User? = nil) {
        self.user = user
        // Carregar interesses do user
        if let interests = user?.interests {
            self.selectedInterests = Set(interests)
        }
    }
}
```

### 6.2 Adicionar Novas Actions
```swift
public enum Action {
    case onAppear
    case loadUserProfile
    case loadTicketsCount
    case userProfileResponse(Result<User, NetworkError>)
    case ticketsCountResponse(Result<Int, NetworkError>)
    
    // UI Actions
    case editProfileTapped
    case changeProfileImageTapped
    case myTicketsTapped
    case myTicketsSheetClosed
    case favoritesTapped // ✅ NOVO
    case moreMenuTapped // ✅ NOVO
    case signOutTapped
    
    // Sheet management
    case setShowingEditProfile(Bool)
    case setShowingImagePicker(Bool)
    case setShowingMyTickets(Bool)
    case setShowingMore(Bool) // ✅ NOVO
    
    // Profile update
    case updateProfile(User)
    case updateInterests(Set<String>) // ✅ NOVO
    case updateProfileResponse(Result<User, NetworkError>)
    
    // Ticket management notifications
    case ticketDeleted
    case ticketCreated
    case refreshMyTickets
    
    case dismissError
}
```

### 6.3 Implementar Reducers
```swift
case .favoritesTapped:
    // TODO: Implementar navegação para Favorites
    print("📱 Navigate to Favorites")
    return .none

case .moreMenuTapped:
    state.showingMore = true
    return .none

case let .setShowingMore(showing):
    state.showingMore = showing
    return .none

case let .updateInterests(interests):
    state.selectedInterests = interests
    
    // Atualizar no user model
    if var user = state.user {
        user.interests = Array(interests)
        state.user = user
        
        // Salvar no backend
        return .run { send in
            do {
                let updated = try await profileClient.updateProfile(user)
                await send(.updateProfileResponse(.success(updated)))
            } catch {
                let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                await send(.updateProfileResponse(.failure(networkError)))
            }
        }
    }
    
    return .none

case let .updateProfile(user):
    state.user = user
    state.isLoading = true
    
    // Sincronizar interesses
    if let interests = user.interests {
        state.selectedInterests = Set(interests)
    }
    
    return .run { send in
        do {
            let updated = try await profileClient.updateProfile(user)
            await send(.updateProfileResponse(.success(updated)))
        } catch {
            let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
            await send(.updateProfileResponse(.failure(networkError)))
        }
    }
```

### 6.4 Binding em EditProfileView
```swift
struct EditProfileView: View {
    let user: User
    let onSave: (User) -> Void
    
    @State private var tempName: String
    @State private var tempEmail: String
    @State private var tempPhone: String
    @State private var selectedInterests: Set<String>
    
    init(user: User, onSave: @escaping (User) -> Void) {
        self.user = user
        self.onSave = onSave
        self._tempName = State(initialValue: user.name)
        self._tempEmail = State(initialValue: user.email)
        self._tempPhone = State(initialValue: user.phone ?? "")
        self._selectedInterests = State(initialValue: Set(user.interests ?? []))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Avatar section...
                
                // Form fields...
                
                // Interests section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Change Interests")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    InterestSelectionView(selectedInterests: $selectedInterests)
                }
                .padding(.horizontal, 20)
                
                // Save button
                Button(action: {
                    var updatedUser = user
                    updatedUser.name = tempName
                    updatedUser.email = tempEmail
                    updatedUser.phone = tempPhone.isEmpty ? nil : tempPhone
                    updatedUser.interests = Array(selectedInterests)
                    onSave(updatedUser)
                }) {
                    Text("Save")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.primary)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .disabled(tempName.isEmpty)
            }
        }
    }
}
```

### 6.5 Persistência Local (UserDefaults)
```swift
// Após salvar interesses com sucesso:
case let .updateProfileResponse(.success(user)):
    state.user = user
    state.isLoading = false
    state.showingEditProfile = false
    
    // Persistir localmente
    if let interests = user.interests {
        UserDefaults.standard.set(interests, forKey: "userInterests")
        print("💾 Interesses salvos: \(interests)")
    }
    
    return .none
```

## Critérios de Sucesso

- ✅ ProfileFeature.State contém todos os campos necessários
- ✅ Todas as actions estão implementadas
- ✅ Navegação entre telas funciona sem crashes
- ✅ Interesses são persistidos ao salvar perfil
- ✅ Loading states exibidos durante operações assíncronas
- ✅ Erros são tratados e exibidos ao usuário
- ✅ Bindings entre views e store funcionam corretamente
- ✅ Sheets e NavigationLinks abrem e fecham corretamente
- ✅ Contador de tickets atualiza após edições

## Arquivos relevantes
- `Projects/Features/Profile/ProfileFeature.swift`
- `Projects/Features/Profile/ProfileView.swift`
- `Projects/Features/Profile/MoreView.swift`
- `SocialApp/Sources/Dependencies/ProfileClient.swift`
- `Domain/Sources/Models.swift`


