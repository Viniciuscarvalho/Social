import SwiftUI
import ComposableArchitecture

public struct ProfileView: View {
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
                        profileHeaderView
                        
                        if store.user != nil {
                            userStatsSection
                        }
                        
                        mainMenuSection
                        
                        illustrationView
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
        .sheet(isPresented: $store.showingMore.sending(\.setShowingMore)) {
            NavigationStack {
                MoreView()
            }
        }
        .alert("Erro", isPresented: .constant(store.error != nil)) {
            Button("OK") {
                store.send(.dismissError)
            }
        } message: {
            Text(store.error ?? "")
        }
        .sheet(isPresented: $store.showingMyTickets.sending(\.setShowingMyTickets)) {
            MyTicketsViewWrapper(
                profileStore: store,
                currentUserId: UserDefaults.standard.string(forKey: "currentUserId") ?? store.user?.id
            )
        }
        .onChange(of: store.showingMyTickets) { oldValue, newValue in
            // Quando a modal de MyTickets fecha (newValue = false), recarrega a contagem
            if oldValue && !newValue {
                store.send(.myTicketsSheetClosed)
            }
        }
    }
    
    @ViewBuilder
    private var profileHeaderView: some View {
        VStack(spacing: 16) {
            if let user = store.user {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(AppColors.profileGradient)
                        .shadow(color: AppColors.cardShadow.opacity(0.3), radius: 16, x: 0, y: 12)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top, spacing: 16) {
                            profileAvatarView(for: user)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(user.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(Color.white.opacity(0.85))
                                
                                if let title = user.title {
                                    Text(title)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }
                            
                            Spacer()
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .padding(20)
                    
                    editProfileIconButton
                }
            } else {
                VStack(spacing: 12) {
                    Circle()
                        .fill(AppColors.cardBackground.opacity(0.3))
                        .frame(width: 100, height: 100)
                    
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
                statItem(value: "\(user.followersCount)", label: "Seguidores")
                statItem(value: "\(user.followingCount)", label: "Seguindo")
                statItem(value: "\(store.user?.ticketsCount ?? store.ticketsCount)", label: "Ingressos")
                
                if user.isVerified {
                    VStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppColors.primary)
                        Text("Verificado")
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
                    .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 6)
            )
        }
    }
    
    @ViewBuilder
    private var mainMenuSection: some View {
        VStack(spacing: 0) {
            menuButton(
                icon: "ticket.fill",
                iconColor: AppColors.accentGreen,
                title: "Meus Tickets",
                subtitle: "Gerencie seus ingressos"
            ) {
                store.send(.myTicketsTapped)
            }
            
            dividerInset
            
            menuButton(
                icon: "heart.fill",
                iconColor: AppColors.favoriteRed,
                title: "My Favorite",
                subtitle: "Eventos que você curtiu"
            ) {
                store.send(.favoritesTapped)
            }
            
            dividerInset
            
            menuButton(
                icon: "ellipsis.circle.fill",
                iconColor: AppColors.secondary,
                title: "More",
                subtitle: "FAQs, suporte e mais"
            ) {
                store.send(.moreMenuTapped)
            }
            
            dividerInset
            
            logoutButton
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.cardShadow.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private func menuButton(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            menuRow(icon: icon, iconColor: iconColor, title: title, subtitle: subtitle, isDestructive: false)
        }
        .buttonStyle(.plain)
    }
    
    private func menuRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        isDestructive: Bool
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(isDestructive ? AppColors.error : iconColor)
                .frame(width: 32, height: 32)
                .background((isDestructive ? AppColors.error : iconColor).opacity(0.12))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundColor(isDestructive ? AppColors.error : AppColors.primaryText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            if !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var logoutButton: some View {
        Button(action: {
            store.send(.signOutTapped)
        }) {
            menuRow(
                icon: "rectangle.portrait.and.arrow.right",
                iconColor: AppColors.error,
                title: "Logout",
                subtitle: "Saia da sua conta com segurança",
                isDestructive: true
            )
        }
        .buttonStyle(.plain)
    }
    
    private var dividerInset: some View {
        Divider()
            .padding(.leading, 72)
    }
    
    @ViewBuilder
    private var illustrationView: some View {
        Image("empty_events")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .padding(.top, 8)
            .accessibilityHidden(true)
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(AppColors.primaryText)
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func profileAvatarView(for user: User) -> some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
            )
            
            Button(action: {
                store.send(.changeProfileImageTapped)
            }) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(AppColors.primary)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .offset(x: 6, y: 6)
        }
    }
    
    private var editProfileIconButton: some View {
        Button(action: {
            store.send(.editProfileTapped)
        }) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.primary)
                .padding(12)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding(20)
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
    
}

struct EditProfileView: View {
    private enum FocusField {
        case name, email, title
    }
    
    let user: User
    let onSave: (User) -> Void
    
    @State private var tempName: String
    @State private var tempEmail: String
    @State private var tempTitle: String
    @State private var selectedInterests: Set<String>
    @FocusState private var focusedField: FocusField?
    
    init(user: User, onSave: @escaping (User) -> Void) {
        self.user = user
        self.onSave = onSave
        self._tempName = State(initialValue: user.name)
        self._tempEmail = State(initialValue: user.email)
        self._tempTitle = State(initialValue: user.title ?? "")
        self._selectedInterests = State(initialValue: Set(user.interests ?? []))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                avatarSection
                personalInfoSection
                interestsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 120)
        }
        .background(AppColors.backgroundGradient.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            saveButton
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Fechar") {
                    focusedField = nil
                }
                .foregroundColor(AppColors.primary)
            }
        }
    }
    
    private var avatarSection: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(AppColors.cardBackground)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 48))
                                .foregroundColor(AppColors.secondaryText)
                        )
                }
                .frame(width: 140, height: 140)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppColors.cardBackground, lineWidth: 4)
                )
                
                Button {
                    // TODO: Integrar picker de fotos
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .offset(x: -8, y: -8)
            }
            
            VStack(spacing: 6) {
                Text(user.name)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(AppColors.primaryText)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
    }
    
    private var personalInfoSection: some View {
        VStack(spacing: 16) {
            inputField(
                title: "Nome completo",
                text: $tempName,
                placeholder: "John Doe",
                keyboard: .default,
                focus: .name
            )
            
            inputField(
                title: "Email",
                text: $tempEmail,
                placeholder: "johndoe@email.com",
                keyboard: .emailAddress,
                textContentType: .emailAddress,
                focus: .email,
                capitalization: .none
            )
            
            inputField(
                title: "Título / Profissão",
                text: $tempTitle,
                placeholder: "Event Planner",
                focus: .title
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.cardBackground)
        )
    }
    
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Change Interests")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            InterestSelectionView(selectedInterests: $selectedInterests)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.cardBackground)
        )
    }
    
    private var saveButton: some View {
        Button {
            var updatedUser = user
            updatedUser.name = tempName
            updatedUser.email = tempEmail
            updatedUser.title = tempTitle.isEmpty ? nil : tempTitle
            updatedUser.interests = Array(selectedInterests)
            onSave(updatedUser)
        } label: {
            Text("Save")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(tempName.isEmpty ? AppColors.primary.opacity(0.5) : AppColors.primary)
                .cornerRadius(18)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
        }
        .disabled(tempName.isEmpty)
        .background(AppColors.backgroundGradient.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func inputField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        keyboard: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        focus: FocusField? = nil,
        capitalization: TextInputAutocapitalization = .sentences
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppColors.secondaryText)
            
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textContentType(textContentType)
                .autocapitalization(capitalization)
                .autocorrectionDisabled()
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppColors.secondaryBackground)
                .cornerRadius(16)
                .focused($focusedField, equals: focus)
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

// MARK: - MyTicketsViewWrapper

private struct MyTicketsViewWrapper: View {
    @Bindable var profileStore: StoreOf<ProfileFeature>
    let currentUserId: String?
    @State private var myTicketsStore: StoreOf<MyTicketsFeature>?
    
    var body: some View {
        Group {
            if let store = myTicketsStore {
                MyTicketsView(store: store) {
                    // Navegação: fechar sheet e mudar para tab de eventos
                    profileStore.send(.setShowingMyTickets(false))
                    // Usar NotificationCenter para comunicar com SocialAppFeature
                    NotificationCenter.default.post(
                        name: NSNotification.Name("NavigateToEventsTab"),
                        object: nil
                    )
                }
                .onReceive(
                    NotificationCenter.default.publisher(for: NSNotification.Name("TicketDeleted"))
                ) { notification in
                    // Quando um ticket é deletado, sincronizar com MyTicketsFeature
                    if let ticketId = notification.userInfo?["ticketId"] as? String {
                        print("📢 MyTicketsViewWrapper: Recebeu notificação de ticket deletado: \(ticketId)")
                        store.send(.syncTicketDeleted(ticketId))
                    }
                    // Também notifica o ProfileFeature para atualizar contador
                    profileStore.send(.ticketDeleted)
                }
            } else {
                ProgressView()
                    .onAppear {
                        // Criar store uma vez e manter durante o ciclo de vida da view
                        myTicketsStore = Store(
                            initialState: MyTicketsFeature.State(currentUserId: currentUserId),
                            reducer: { MyTicketsFeature() }
                        )
                    }
            }
        }
    }
}
