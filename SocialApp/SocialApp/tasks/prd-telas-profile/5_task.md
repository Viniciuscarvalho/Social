## status: pending

<task_context>
<domain>features/profile/more</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>low</complexity>
<dependencies>swiftui|navigation</dependencies>
</task_context>

# Tarefa 5.0: Criar tela MoreView com opções de menu

## Visão Geral

Criar nova view `MoreView` acessível a partir do ProfileView, contendo 4 opções de menu (FAQs, Privacy Policy, Contact Us, Delete Account) e ilustração de festival na parte inferior, seguindo o layout do Figma.

<requirements>
- Criar arquivo `MoreView.swift` em `Projects/Features/Profile/`
- NavigationStack com header "More" e botão voltar
- 4 opções de menu com ícones e chevrons
- Delete Account em vermelho
- Ilustração de festival na parte inferior
- Navegação para sub-views (placeholder para FAQs, Privacy, Contact)
- Alert de confirmação para Delete Account
- Usar AppColors e tema consistente
</requirements>

## Subtarefas

- [ ] 5.1 Criar arquivo `MoreView.swift`
- [ ] 5.2 Implementar lista de opções com ícones
- [ ] 5.3 Adicionar ilustração de festival no footer
- [ ] 5.4 Criar placeholder views (FAQsView, PrivacyPolicyView, ContactUsView)
- [ ] 5.5 Implementar alerta de Delete Account
- [ ] 5.6 Integrar navegação no ProfileView
- [ ] 5.7 Testar fluxo completo de navegação

## Detalhes de Implementação

### 5.2 MoreView Principal
```swift
import SwiftUI
import ComposableArchitecture

public struct MoreView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Menu de opções
                    menuSection
                    
                    Spacer()
                    
                    // Ilustração de festival
                    festivalIllustration
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.primaryText)
                    }
                }
            }
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    // TODO: Implementar lógica de deleção
                    print("Account deletion confirmed")
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
        }
    }
    
    @ViewBuilder
    private var menuSection: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: FAQsView()) {
                menuRow(
                    icon: "questionmark.circle.fill",
                    iconColor: AppColors.primary,
                    title: "FAQs"
                )
            }
            
            Divider()
                .padding(.leading, 52)
            
            NavigationLink(destination: PrivacyPolicyView()) {
                menuRow(
                    icon: "hand.raised.fill",
                    iconColor: AppColors.secondary,
                    title: "Privacy Policy"
                )
            }
            
            Divider()
                .padding(.leading, 52)
            
            NavigationLink(destination: ContactUsView()) {
                menuRow(
                    icon: "info.circle.fill",
                    iconColor: AppColors.accentBlue,
                    title: "Contact Us"
                )
            }
            
            Divider()
                .padding(.leading, 52)
            
            Button(action: { showingDeleteAlert = true }) {
                menuRow(
                    icon: "trash.fill",
                    iconColor: AppColors.error,
                    title: "Delete Account",
                    isDestructive: true
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private func menuRow(
        icon: String,
        iconColor: Color,
        title: String,
        isDestructive: Bool = false
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
            
            Text(title)
                .font(.body)
                .foregroundColor(isDestructive ? AppColors.error : AppColors.primaryText)
            
            Spacer()
            
            if !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private var festivalIllustration: some View {
        Image("empty_events")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 300)
            .padding(.vertical, 40)
    }
}
```

### 5.4 Placeholder Views
```swift
struct FAQsView: View {
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary)
                
                Text("FAQs")
                    .font(.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Frequently Asked Questions coming soon")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .navigationTitle("FAQs")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.title)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Your privacy is important to us...")
                        .font(.body)
                        .foregroundColor(AppColors.secondaryText)
                }
                .padding()
            }
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContactUsView: View {
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.accentBlue)
                
                Text("Contact Us")
                    .font(.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text("support@socialapp.com")
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
                
                Button(action: {
                    // Open email client
                    if let url = URL(string: "mailto:support@socialapp.com") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Send Email")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
        }
        .navigationTitle("Contact Us")
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

### 5.6 Integração no ProfileView
```swift
// Em ProfileView, adicionar NavigationLink para MoreView:
.sheet(isPresented: $store.showingMore.sending(\.setShowingMore)) {
    MoreView()
}

// Ou usar NavigationLink se estiver em NavigationStack:
NavigationLink(destination: MoreView()) {
    settingsRow(
        icon: "ellipsis.circle.fill",
        iconColor: AppColors.secondary,
        title: "More",
        subtitle: "Configurações e suporte",
        action: {}
    )
}
```

## Critérios de Sucesso

- ✅ MoreView exibe 4 opções de menu corretamente
- ✅ Navegação para sub-views funciona
- ✅ Delete Account mostra alerta de confirmação
- ✅ Ilustração aparece na parte inferior
- ✅ Botão voltar funciona corretamente
- ✅ Estilo consistente com resto do app
- ✅ Tema claro/escuro aplicado
- ✅ Sem erros de compilação

## Arquivos relevantes
- `Projects/Features/Profile/MoreView.swift` (NOVO)
- `Projects/Features/Profile/ProfileView.swift`
- `Projects/Features/Profile/ProfileFeature.swift`
- `SocialApp/Resources/Assets.xcassets/empty_events.imageset/`


