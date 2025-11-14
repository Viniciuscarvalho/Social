## status: pending

<task_context>
<domain>features/profile/components</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>swiftui|theme</dependencies>
</task_context>

# Tarefa 2.0: Implementar sistema de interesses selecionáveis

## Visão Geral

Criar componente reutilizável `InterestChip` para exibir e selecionar múltiplos interesses do usuário. Este componente será usado na tela de edição de perfil e deve suportar estado selecionado/não-selecionado com estilos distintos.

<requirements>
- Criar `InterestChip.swift` em `SocialApp/Sources/Commons/`
- Chip com ícone + texto
- Dois estados visuais: selecionado (borda roxa preenchida) e não-selecionado (borda cinza)
- Lista de 14 interesses conforme Figma
- Suportar seleção múltipla
- Animação suave na transição de estados
- Compatível com tema claro/escuro
</requirements>

## Subtarefas

- [ ] 2.1 Criar arquivo `InterestChip.swift` em Commons
- [ ] 2.2 Definir enum `InterestCategory` com todos os 14 interesses
- [ ] 2.3 Mapear ícones SF Symbols para cada interesse
- [ ] 2.4 Implementar view `InterestChip` com binding para seleção
- [ ] 2.5 Criar view container `InterestSelectionView` com grid layout
- [ ] 2.6 Adicionar campo `interests` ao User model (já existe, validar)
- [ ] 2.7 Testar interatividade e animações

## Detalhes de Implementação

### 2.2 Enum de Interesses
```swift
public enum InterestCategory: String, CaseIterable, Codable {
    case business = "Business"
    case arts = "Arts"
    case music = "Music"
    case health = "Health"
    case foodDrink = "Food & Drink"
    case gaming = "Gaming"
    case travel = "Travel & Adventure"
    case filmMedia = "Film & Media"
    case familyKids = "Family & Kids"
    case theatre = "Theatre & Performing Arts"
    case community = "Community & Charity"
    case shopping = "Shopping"
    case petEvents = "Pet & Animal Events"
    case books = "Books & Literature"
    
    var icon: String {
        switch self {
        case .business: return "briefcase.fill"
        case .arts: return "paintpalette.fill"
        case .music: return "music.note"
        case .health: return "heart.fill"
        case .foodDrink: return "fork.knife"
        case .gaming: return "gamecontroller.fill"
        case .travel: return "airplane"
        case .filmMedia: return "film.fill"
        case .familyKids: return "figure.2.and.child.holdinghands"
        case .theatre: return "theatermasks.fill"
        case .community: return "person.3.fill"
        case .shopping: return "bag.fill"
        case .petEvents: return "pawprint.fill"
        case .books: return "book.fill"
        }
    }
}
```

### 2.4 InterestChip View
```swift
public struct InterestChip: View {
    let interest: InterestCategory
    @Binding var isSelected: Bool
    
    public var body: some View {
        Button(action: { 
            withAnimation(.easeInOut(duration: 0.2)) {
                isSelected.toggle()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: interest.icon)
                    .font(.system(size: 14))
                Text(interest.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? AppColors.primary.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? AppColors.primary : AppColors.border, lineWidth: 1.5)
            )
            .foregroundColor(isSelected ? AppColors.primary : AppColors.primaryText)
        }
        .buttonStyle(.plain)
    }
}
```

### 2.5 Container com Grid
```swift
public struct InterestSelectionView: View {
    @Binding var selectedInterests: Set<String>
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    public var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(InterestCategory.allCases, id: \.self) { category in
                InterestChip(
                    interest: category,
                    isSelected: Binding(
                        get: { selectedInterests.contains(category.rawValue) },
                        set: { isSelected in
                            if isSelected {
                                selectedInterests.insert(category.rawValue)
                            } else {
                                selectedInterests.remove(category.rawValue)
                            }
                        }
                    )
                )
            }
        }
    }
}
```

## Critérios de Sucesso

- ✅ InterestChip renderiza corretamente com ícone e texto
- ✅ Tap toggle funciona com animação suave
- ✅ Estado selecionado visualmente distinto
- ✅ Grid layout se ajusta responsivamente
- ✅ Funciona em light/dark mode
- ✅ Código reutilizável e testável

## Arquivos relevantes
- `SocialApp/Sources/Commons/InterestChip.swift` (NOVO)
- `Domain/Sources/Models.swift` (User.interests já existe)
- `SocialApp/Sources/ThemeApp/AppColors.swift`


