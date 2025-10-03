import SwiftUI

public struct ProfileView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var user = User(name: "João Silva", title: "Entusiasta de Eventos", email: "joao.silva@email.com")
    @State private var showingImagePicker = false
    @State private var notificationsEnabled = true
    @State private var emailNotifications = true
    @State private var pushNotifications = false
    @State private var showingEditProfile = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header do perfil
                profileHeaderView
                
                // Estatísticas do usuário
                userStatsSection
                
                // Seção de configurações
                settingsSection
                
                // Seção de notificações
                notificationsSection
                
                // Seção de conta
                accountSection
                
                // Rodapé
                footerView
            }
            .padding()
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingEditProfile) {
            editProfileSheet
        }
        .sheet(isPresented: $showingImagePicker) {
            imagePickerSheet
        }
    }
    
    @ViewBuilder
    private var profileHeaderView: some View {
        VStack(spacing: 16) {
            // Foto do perfil
            Button(action: { showingImagePicker = true }) {
                AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .offset(x: 28, y: 28)
                )
            }
            
            // Informações do usuário
            VStack(spacing: 4) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let email = user.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let title = user.title {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Button("Editar Perfil") {
                    showingEditProfile = true
                }
                .buttonStyle(.bordered)
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    private var userStatsSection: some View {
        HStack(spacing: 20) {
            userStatItem(title: "Ingressos", value: "\(user.ticketsCount)", color: .blue)
            userStatItem(title: "Seguidores", value: "\(user.followersCount)", color: .green)
            userStatItem(title: "Seguindo", value: "\(user.followingCount)", color: .purple)
            
            if user.isVerified {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                    
                    Text("Verificado")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func userStatItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var settingsSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Configurações")
            
            VStack(spacing: 0) {
                // Botão de aparência
                settingsRow(
                    icon: themeIcon,
                    iconColor: .blue,
                    title: "Aparência",
                    subtitle: themeManager.displayName,
                    action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeManager.toggleColorScheme()
                        }
                    }
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Idioma
                settingsRow(
                    icon: "globe",
                    iconColor: .green,
                    title: "Idioma",
                    subtitle: "Português (Brasil)",
                    action: {
                        // Implementar mudança de idioma
                    }
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Privacidade
                settingsRow(
                    icon: "hand.raised.fill",
                    iconColor: .orange,
                    title: "Privacidade e Segurança",
                    subtitle: "Gerencie suas configurações",
                    action: {
                        // Implementar configurações de privacidade
                    }
                )
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private var notificationsSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Notificações")
            
            VStack(spacing: 0) {
                // Notificações gerais
                toggleRow(
                    icon: "bell.fill",
                    iconColor: .red,
                    title: "Notificações",
                    subtitle: "Receber alertas sobre eventos",
                    isOn: $notificationsEnabled
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Notificações por email
                toggleRow(
                    icon: "envelope.fill",
                    iconColor: .blue,
                    title: "Email",
                    subtitle: "Newsletters e ofertas especiais",
                    isOn: $emailNotifications
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Push notifications
                toggleRow(
                    icon: "iphone",
                    iconColor: .purple,
                    title: "Push",
                    subtitle: "Notificações no dispositivo",
                    isOn: $pushNotifications
                )
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private var accountSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Conta")
            
            VStack(spacing: 0) {
                // Meus ingressos
                settingsRow(
                    icon: "ticket.fill",
                    iconColor: .green,
                    title: "Meus Ingressos",
                    subtitle: "Visualizar compras realizadas",
                    action: {
                        // Navegar para meus ingressos
                    }
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Favoritos
                settingsRow(
                    icon: "heart.fill",
                    iconColor: .pink,
                    title: "Favoritos",
                    subtitle: "Eventos e ingressos salvos",
                    action: {
                        // Navegar para favoritos
                    }
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Suporte
                settingsRow(
                    icon: "questionmark.circle.fill",
                    iconColor: .orange,
                    title: "Suporte",
                    subtitle: "Ajuda e perguntas frequentes",
                    action: {
                        // Abrir suporte
                    }
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Sair
                Button(action: {
                    // Implementar logout
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                            .frame(width: 28, height: 28)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sair")
                                .font(.body)
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private var footerView: some View {
        VStack(spacing: 8) {
            Text("Versão 1.0.0")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("© 2025 SocialApp")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func toggleRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private var editProfileSheet: some View {
        NavigationView {
            EditProfileView(user: $user)
                .navigationTitle("Editar Perfil")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancelar") {
                            showingEditProfile = false
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Salvar") {
                            showingEditProfile = false
                            // Implementar salvamento
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    private var imagePickerSheet: some View {
        VStack(spacing: 20) {
            Text("Alterar Foto do Perfil")
                .font(.headline)
            
            VStack(spacing: 16) {
                Button("Câmera") {
                    // Implementar câmera
                    showingImagePicker = false
                }
                .buttonStyle(.bordered)
                
                Button("Galeria") {
                    // Implementar galeria
                    showingImagePicker = false
                }
                .buttonStyle(.bordered)
                
                Button("Cancelar") {
                    showingImagePicker = false
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .presentationDetents([.height(200)])
    }
    
    private var themeIcon: String {
        switch themeManager.colorScheme {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .none:
            return "circle.lefthalf.striped.horizontal"
        }
    }
}

struct EditProfileView: View {
    @Binding var user: User
    @State private var tempName: String
    @State private var tempEmail: String
    @State private var tempTitle: String
    
    init(user: Binding<User>) {
        self._user = user
        self._tempName = State(initialValue: user.wrappedValue.name)
        self._tempEmail = State(initialValue: user.wrappedValue.email ?? "")
        self._tempTitle = State(initialValue: user.wrappedValue.title ?? "")
    }
    
    var body: some View {
        Form {
            Section("Informações Pessoais") {
                TextField("Nome", text: $tempName)
                TextField("Email", text: $tempEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                TextField("Título/Profissão", text: $tempTitle)
            }
        }
        .onDisappear {
            user.name = tempName
            user.email = tempEmail.isEmpty ? nil : tempEmail
            user.title = tempTitle.isEmpty ? nil : tempTitle
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
            .environment(ThemeManager.shared)
    }
}
