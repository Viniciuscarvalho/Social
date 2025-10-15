import SwiftUI
import ComposableArchitecture

public struct ProfileView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Bindable var store: StoreOf<ProfileFeature>
    
    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            if store.isLoading && store.user == nil {
                ProgressView()
                    .foregroundColor(AppColors.primaryText)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header do perfil
                        profileHeaderView
                        
                        // Estatísticas do usuário
                        if store.user != nil {
                            userStatsSection
                        }
                        
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
            }
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(isPresented: $store.showingEditProfile.sending(\.setShowingEditProfile)) {
            editProfileSheet
        }
        .sheet(isPresented: $store.showingImagePicker.sending(\.setShowingImagePicker)) {
            imagePickerSheet
        }
        .alert("Erro", isPresented: .constant(store.error != nil)) {
            Button("OK") {
                store.send(.dismissError)
            }
        } message: {
            Text(store.error ?? "")
        }
    }
    
    @ViewBuilder
    private var profileHeaderView: some View {
        VStack(spacing: 16) {
            if let user = store.user {
                // Foto do perfil
                Button(action: { store.send(.changeProfileImageTapped) }) {
                    AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.primary)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppColors.cardBackground, lineWidth: 2)
                    )
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(AppColors.primary)
                            .clipShape(Circle())
                            .offset(x: 28, y: 28)
                    )
                }
                
                // Informações do usuário
                VStack(spacing: 4) {
                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryText)
                    
                    if let email = user.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    if let title = user.title {
                        Text(title)
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.primary.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button("Editar Perfil") {
                        store.send(.editProfileTapped)
                    }
                    .font(.subheadline)
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.primary, lineWidth: 1)
                            .fill(AppColors.cardBackground.opacity(0.1))
                    )
                }
            } else {
                VStack(spacing: 12) {
                    Circle()
                        .fill(AppColors.cardBackground.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    Text("Carregando perfil...")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    private var userStatsSection: some View {
        if let user = store.user {
            HStack(spacing: 30) {
                VStack {
                    Text("\(user.followersCount)")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    Text("Seguidores")
                        .font(.caption)
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                VStack {
                    Text("\(user.followingCount)")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    Text("Seguindo")
                        .font(.caption)
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                VStack {
                    Text("\(user.ticketsCount)")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    Text("Tickets")
                        .font(.caption)
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                if user.isVerified {
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primary)
                        
                        Text("Verificado")
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 4)
            )
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
                    iconColor: AppColors.primary,
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
                
                // Privacidade
                settingsRow(
                    icon: "hand.raised.fill",
                    iconColor: AppColors.warning,
                    title: "Privacidade e Segurança",
                    subtitle: "Gerencie suas configurações",
                    action: {
                        store.send(.privacySettingsTapped)
                    }
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    @ViewBuilder
    private var notificationsSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Notificações")
            
            VStack(spacing: 0) {
                // Push notifications
                toggleRow(
                    icon: "iphone",
                    iconColor: AppColors.secondary,
                    title: "Push",
                    subtitle: "Notificações no dispositivo",
                    isOn: $store.pushNotifications.sending(\.togglePushNotifications)
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 4)
            )
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
                    iconColor: AppColors.accentGreen,
                    title: "Meus Ingressos",
                    subtitle: "Visualizar compras realizadas",
                    action: {
                        store.send(.myTicketsTapped)
                    }
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Suporte
                settingsRow(
                    icon: "questionmark.circle.fill",
                    iconColor: AppColors.warning,
                    title: "Suporte",
                    subtitle: "Ajuda e perguntas frequentes",
                    action: {
                        store.send(.supportTapped)
                    }
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Sair
                Button(action: {
                    store.send(.signOutTapped)
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.error)
                            .frame(width: 28, height: 28)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sair")
                                .font(.body)
                                .foregroundColor(AppColors.error)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 4)
            )
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
                .foregroundColor(AppColors.primaryText)
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
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.tertiaryText)
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
                    .foregroundColor(AppColors.primaryText)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppColors.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private var editProfileSheet: some View {
        if let user = store.user {
            NavigationView {
                EditProfileView(user: user) { updatedUser in
                    store.send(.updateProfile(updatedUser))
                }
                .navigationTitle("Editar Perfil")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancelar") {
                            store.send(.setShowingEditProfile(false))
                        }
                        .foregroundColor(AppColors.primaryText)
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
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: 16) {
                Button("Câmera") {
                    // TODO: Implementar câmera
                    store.send(.setShowingImagePicker(false))
                }
                .font(.body)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(AppColors.primary)
                .cornerRadius(22)
                
                Button("Galeria") {
                    // TODO: Implementar galeria
                    store.send(.setShowingImagePicker(false))
                }
                .font(.body)
                .foregroundColor(AppColors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(AppColors.primary, lineWidth: 1)
                        .fill(AppColors.cardBackground)
                )
                
                Button("Cancelar") {
                    store.send(.setShowingImagePicker(false))
                }
                .font(.body)
                .foregroundColor(AppColors.secondaryText)
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
    let user: User
    let onSave: (User) -> Void
    
    @State private var tempName: String
    @State private var tempEmail: String
    @State private var tempTitle: String
    
    init(user: User, onSave: @escaping (User) -> Void) {
        self.user = user
        self.onSave = onSave
        self._tempName = State(initialValue: user.name)
        self._tempEmail = State(initialValue: user.email ?? "")
        self._tempTitle = State(initialValue: user.title ?? "")
    }
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            Form {
                Section("Informações Pessoais") {
                    TextField("Nome", text: $tempName)
                        .foregroundColor(AppColors.primaryText)
                    
                    TextField("Email", text: $tempEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .foregroundColor(AppColors.primaryText)
                    
                    TextField("Título/Profissão", text: $tempTitle)
                        .foregroundColor(AppColors.primaryText)
                }
                .listRowBackground(AppColors.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        var updatedUser = user
                        updatedUser.name = tempName
                        updatedUser.email = tempEmail.isEmpty ? nil : tempEmail
                        updatedUser.title = tempTitle.isEmpty ? nil : tempTitle
                        onSave(updatedUser)
                    }
                    .foregroundColor(AppColors.primary)
                    .disabled(tempName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ProfileView(
            store: Store(initialState: ProfileFeature.State()) {
                ProfileFeature()
            }
        )
        .environment(ThemeManager.shared)
    }
}
