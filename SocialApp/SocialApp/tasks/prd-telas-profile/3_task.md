## status: pending

<task_context>
<domain>features/profile/edit</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>swiftui|tca|components</dependencies>
</task_context>

# Tarefa 3.0: Atualizar EditProfileView com foto grande e interesses

## Visão Geral

Redesenhar completamente a tela de edição de perfil para seguir o layout do Figma: avatar grande no topo com botão de câmera, inputs de nome/telefone/email, e seção "Change Interests" com chips selecionáveis. Substituir o Form por VStack com campos customizados.

<requirements>
- Avatar grande (120x120) no topo centralizado
- Botão de câmera sobreposto no avatar (canto inferior direito)
- Input de nome (TextField simples)
- Input de telefone com country code (+1 dropdown)
- Input de email
- Seção "Change Interests" usando InterestSelectionView
- Botão Save grande e roxo na base
- Scrollable quando teclado aparece
- Salvar interesses no User model
</requirements>

## Subtarefas

- [ ] 3.1 Redesenhar layout do avatar grande com botão de câmera
- [ ] 3.2 Substituir Form por VStack com TextFields customizados
- [ ] 3.3 Implementar PhoneInput com country code picker
- [ ] 3.4 Adicionar seção "Change Interests" com InterestSelectionView
- [ ] 3.5 Redesenhar botão Save na base
- [ ] 3.6 Atualizar ProfileFeature para salvar interesses
- [ ] 3.7 Adicionar state `selectedInterests` no ProfileFeature
- [ ] 3.8 Testar scroll e responsividade com teclado

## Detalhes de Implementação

### 3.1 Novo Layout de Avatar
```swift
VStack(spacing: 0) {
    // Avatar grande no topo
    ZStack(alignment: .bottomTrailing) {
        AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Circle()
                .fill(AppColors.glassBackground)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.secondaryText)
                )
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(AppColors.primary.opacity(0.3), lineWidth: 3)
        )
        
        // Botão de câmera
        Button(action: { /* picker */ }) {
            Image(systemName: "camera.fill")
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(AppColors.primary)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppColors.background, lineWidth: 2)
                )
        }
        .offset(x: -5, y: -5)
    }
    .padding(.top, 24)
    .padding(.bottom, 32)
    
    // Form fields...
}
```

### 3.3 Phone Input
```swift
HStack(spacing: 12) {
    // Country Code Picker (simplificado)
    Menu {
        Button("+1") { countryCode = "+1" }
        Button("+55") { countryCode = "+55" }
        Button("+44") { countryCode = "+44" }
    } label: {
        HStack(spacing: 4) {
            Text(countryCode)
                .font(.body)
            Image(systemName: "chevron.down")
                .font(.caption)
        }
        .foregroundColor(AppColors.primaryText)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
    
    // Phone Number Field
    TextField("1234567890", text: $phoneNumber)
        .keyboardType(.phonePad)
        .font(.body)
        .foregroundColor(AppColors.primaryText)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
}
```

### 3.4 Seção de Interesses
```swift
VStack(alignment: .leading, spacing: 16) {
    Text("Change Interests")
        .font(.headline)
        .foregroundColor(AppColors.primaryText)
    
    InterestSelectionView(selectedInterests: $selectedInterests)
}
.padding(.horizontal, 20)
.padding(.vertical, 16)
```

### 3.5 Botão Save
```swift
Button(action: {
    var updatedUser = user
    updatedUser.name = tempName
    updatedUser.email = tempEmail
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
.padding(.bottom, 20)
.disabled(tempName.isEmpty)
```

### 3.6 ProfileFeature Update
```swift
case let .updateProfile(user):
    state.user = user
    state.isLoading = true
    
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

## Critérios de Sucesso

- ✅ Avatar grande exibido corretamente no topo
- ✅ Botão de câmera posicionado sobre o avatar
- ✅ Phone input com country code funcional
- ✅ Chips de interesses renderizam e são selecionáveis
- ✅ Botão Save persiste mudanças (nome, email, phone, interesses)
- ✅ Scroll funciona com teclado aberto
- ✅ Validação de campos obrigatórios
- ✅ Loading state durante save
- ✅ Tema claro/escuro aplicado

## Arquivos relevantes
- `Projects/Features/Profile/ProfileView.swift` (EditProfileView section)
- `Projects/Features/Profile/ProfileFeature.swift`
- `SocialApp/Sources/Commons/InterestChip.swift` (da tarefa 2.0)
- `Domain/Sources/Models.swift`
- `SocialApp/Sources/Dependencies/ProfileClient.swift`


