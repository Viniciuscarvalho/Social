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
                        // Header do perfil (cartão principal)
                        profileHeaderView
                        
                        // Card de Vendedor (se o usuário tem tickets)
                        if let user = store.user, user.ticketsCount > 0 {
                            sellerCardView(user: user)
                        }
                        
                        // Menu principal (Tickets, Mais, Logout)
                        menuSection
                        
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
        .sheet(isPresented: $store.showingFavorites.sending(\.setShowingFavorites)) {
            FavoritesViewWrapper(
                onEventSelected: { eventId in
                    store.send(.setShowingFavorites(false))
                    // Notificar SocialAppFeature para navegar para detalhe do evento
                    // Usar o mesmo padrão que outros lugares do app
                    if let eventIdString = UUID(uuidString: eventId.uuidString.lowercased()) {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("NavigateToEventDetail"),
                            object: nil,
                            userInfo: ["eventId": eventIdString]
                        )
                    }
                }
            )
        }
        .sheet(isPresented: $store.showingThemeSelection.sending(\.setShowingThemeSelection)) {
            NavigationStack {
                ThemeToggleView()
                    .navigationTitle("Aparência")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Concluído") {
                                store.send(.setShowingThemeSelection(false))
                            }
                            .foregroundColor(AppColors.primary)
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    private var profileHeaderView: some View {
        VStack(spacing: 16) {
            if let user = store.user {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.cardBackground)
                        .shadow(color: AppColors.cardShadow.opacity(0.12), radius: 12, x: 0, y: 6)
                    
                    HStack(spacing: 16) {
                        // Avatar
                        Button(action: { store.send(.changeProfileImageTapped) }) {
                            ZStack(alignment: .bottomTrailing) {
                                AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(AppColors.primary)
                                }
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(AppColors.primary)
                                    .clipShape(Circle())
                            }
                        }
                        
                        // Nome e email
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Editar
                        Button(action: { store.send(.editProfileTapped) }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(AppColors.primary)
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Editar perfil")
                    }
                    .padding(16)
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
    private var menuSection: some View {
        VStack(spacing: 12) {
            // Tickets
            menuRow(
                icon: "qrcode",
                iconTint: AppColors.accentGreen,
                title: "Ingressos",
                subtitle: "Seus ingressos e QR Codes"
            ) {
                store.send(.myTicketsTapped)
            }
            
            // Favoritos
            menuRow(
                icon: "heart.fill",
                iconTint: Color.pink,
                title: "Meus Favoritos",
                subtitle: "Eventos que você favoritou"
            ) {
                store.send(.favoritesTapped)
            }
            
            // Seleção de Tema
            themeSelectionRow
            
            // Mais (usando ação de suporte existente)
            menuRow(
                icon: "ellipsis.circle.fill",
                iconTint: AppColors.secondary,
                title: "More",
                subtitle: "FAQ, Política de Privacidade e contato"
            ) {
                store.send(.supportTapped)
            }
            
            // Logout
            Button(action: { store.send(.signOutTapped) }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.error.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.error)
                    }
                    
                    Text("Logout")
                        .font(.body.weight(.semibold))
                        .foregroundColor(AppColors.error)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.tertiaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.cardBackground)
                        .shadow(color: AppColors.cardShadow.opacity(0.08), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private func sellerCardView(user: User) -> some View {
        Button(action: {
            // Navegar para o perfil de vendedor do próprio usuário
            if let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") {
                store.send(.navigateToSellerProfile(currentUserId))
            }
        }) {
            HStack(spacing: 16) {
                // Ícone de vendedor
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.primary.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                }
                
                // Informações
                VStack(alignment: .leading, spacing: 4) {
                    Text("Perfil de Vendedor")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("\(user.ticketsCount) ingresso\(user.ticketsCount == 1 ? "" : "s") disponível\(user.ticketsCount == 1 ? "" : "eis")")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var themeSelectionRow: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.primary.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Aparência")
                        .font(.body.weight(.semibold))
                        .foregroundColor(AppColors.primaryText)
                    Text("Tema: \(themeManager.displayName)")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .shadow(color: AppColors.cardShadow.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                store.send(.themeSelectionTapped)
            }
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
    private func menuRow(
        icon: String,
        iconTint: Color,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconTint.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconTint)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
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
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .shadow(color: AppColors.cardShadow.opacity(0.08), radius: 8, x: 0, y: 4)
            )
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
        default:
            return "gear"
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
        self._tempEmail = State(initialValue: user.email)
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
                        updatedUser.email = tempEmail
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

// MARK: - FavoritesViewWrapper

private struct FavoritesViewWrapper: View {
    let onEventSelected: (UUID) -> Void
    @State private var favoritesStore: StoreOf<FavoritesFeature>?
    
    var body: some View {
        Group {
            if let store = favoritesStore {
                FavoritesViewCustom(store: store, onEventSelected: onEventSelected)
            } else {
                ProgressView()
                    .onAppear {
                        favoritesStore = Store(
                            initialState: FavoritesFeature.State(),
                            reducer: { FavoritesFeature() }
                        )
                    }
            }
        }
    }
}

// MARK: - FavoritesViewCustom

private struct FavoritesViewCustom: View {
    @Bindable var store: StoreOf<FavoritesFeature>
    let onEventSelected: (UUID) -> Void
    
    var body: some View {
        NavigationStack {
            Group {
                if store.isLoading {
                    ProgressView("Carregando favoritos...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if store.favoriteEvents.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(store.favoriteEvents, id: \.eventId) { favorite in
                                FavoriteEventCardCustom(favorite: favorite) {
                                    if let eventId = UUID(uuidString: favorite.eventId) {
                                        onEventSelected(eventId)
                                    }
                                } onRemove: {
                                    store.send(.removeFromFavorites(favorite.eventId))
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                store.send(.loadFavorites)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.pink)
            }
            
            VStack(spacing: 8) {
                Text("Nenhum favorito ainda")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Comece a favoritar eventos que você gosta")
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - FavoriteEventCardCustom

private struct FavoriteEventCardCustom: View {
    let favorite: FavoriteEvent
    let action: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: favorite.eventImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(AppColors.tertiaryBackground)
            }
            .frame(width: 80, height: 80)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(favorite.eventName)
                    .adaptiveHeadline()
                    .lineLimit(2)
                
                Text(favorite.eventLocation)
                    .adaptiveSubheadline()
                
                if let eventDate = favorite.eventDate {
                    Text(eventDate, style: .date)
                        .font(.caption)
                        .foregroundColor(AppColors.primary)
                } else {
                    Text("Data a definir")
                        .adaptiveCaption()
                }
                
                Text("Favoritado em \(favorite.favoriteDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundColor(AppColors.tertiaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("R$ \(favorite.eventPrice, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
                
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.favoriteRed)
                        .padding(8)
                        .background(AppColors.favoriteRed.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .adaptiveCardStyle()
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
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
