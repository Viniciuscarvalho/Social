import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct ProfileView: View {
    @Bindable var store: StoreOf<ProfileFeature>
    
    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            DSGradients.backgroundMain
                .ignoresSafeArea()
            
            if store.isLoading && store.user == nil {
                DSFullScreenLoading(message: "Carregando perfil...")
            } else {
                ScrollView {
                    VStack(spacing: DSSpacing.l) {
                        // Header do perfil (cartão principal)
                        profileHeaderView
                        
                        // Card de Vendedor (se o usuário tem tickets)
                        if store.hasTickets, let user = store.user {
                            sellerCardView(user: user)
                        }
                        
                        // Menu principal (Tickets, Mais, Logout)
                        menuSection
                        
                        // Rodapé
                        footerView
                    }
                    .padding(DSSpacing.m)
                    .dsEnterAnimation(isVisible: true)
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
                .dsSlideFromBottomTransition()
        }
        .sheet(isPresented: $store.showingImagePicker.sending(\.setShowingImagePicker)) {
            imagePickerSheet
                .dsSlideFromBottomTransition()
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
            .dsSlideFromBottomTransition()
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
                    // Usar delegate pattern para navegação
                    store.send(.delegate(.navigateToEventDetail(eventId)))
                }
            )
            .dsSlideFromBottomTransition()
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
                            .foregroundColor(DSColors.primary)
                        }
                    }
            }
            .dsSlideFromBottomTransition()
        }
    }
    
    @ViewBuilder
    private var profileHeaderView: some View {
        ProfileHeaderView(
            user: store.user,
            onEditTapped: { store.send(.editProfileTapped) },
            onChangeImageTapped: { store.send(.changeProfileImageTapped) }
        )
    }
    
    @ViewBuilder
    private var menuSection: some View {
        ProfileMenuSection(
            onMyTicketsTapped: { store.send(.myTicketsTapped) },
            onFavoritesTapped: { store.send(.favoritesTapped) },
            onThemeSelectionTapped: { store.send(.themeSelectionTapped) },
            onSupportTapped: { store.send(.supportTapped) },
            onSignOutTapped: { store.send(.signOutTapped) }
        )
    }
    
    @ViewBuilder
    private func sellerCardView(user: User) -> some View {
        SellerCardView(user: user) {
            // Navegar para o perfil de vendedor do próprio usuário
            if let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") {
                store.send(.delegate(.navigateToSellerProfile(currentUserId)))
            }
        }
    }
    
    @ViewBuilder
    private var footerView: some View {
        ProfileFooterView()
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
                        .foregroundColor(DSColors.textPrimary)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var imagePickerSheet: some View {
        VStack(spacing: 20) {
            Text("Alterar Foto do Perfil")
                .font(DSTypography.headline())
                .foregroundColor(DSColors.textPrimary)
            
            VStack(spacing: 16) {
                Button("Câmera") {
                    // TODO: Implementar câmera
                    store.send(.setShowingImagePicker(false))
                }
                .font(.body)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                        .background(DSColors.primary)
                .cornerRadius(22)
                
                Button("Galeria") {
                    // TODO: Implementar galeria
                    store.send(.setShowingImagePicker(false))
                }
                .font(.body)
                .foregroundColor(DSColors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(DSColors.primary, lineWidth: 1)
                        .fill(DSColors.cardBackground)
                )
                
                Button("Cancelar") {
                    store.send(.setShowingImagePicker(false))
                }
                .font(.body)
                        .foregroundColor(DSColors.textSecondary)
            }
        }
        .padding()
        .presentationDetents([.height(200)])
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
            DSGradients.backgroundMain
                .ignoresSafeArea()
            
            Form {
                Section("Informações Pessoais") {
                    TextField("Nome", text: $tempName)
                        .foregroundColor(DSColors.textPrimary)
                    
                    TextField("Email", text: $tempEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .foregroundColor(DSColors.textPrimary)
                    
                    TextField("Título/Profissão", text: $tempTitle)
                        .foregroundColor(DSColors.textPrimary)
                }
                .listRowBackground(DSColors.cardBackground)
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
                    .foregroundColor(DSColors.primary)
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
        .environment(Theme.shared)
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
                    .foregroundColor(DSColors.textPrimary)
                
                Text("Comece a favoritar eventos que você gosta")
                    .font(.system(size: 15))
                        .foregroundColor(DSColors.textSecondary)
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
                    .fill(DSColors.backgroundTertiary)
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
                        .foregroundColor(DSColors.primary)
                } else {
                    Text("Data a definir")
                        .adaptiveCaption()
                }
                
                Text("Favoritado em \(favorite.favoriteDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                        .foregroundColor(DSColors.textTertiary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("R$ \(favorite.eventPrice, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(DSColors.primary)
                
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DSColors.error)
                        .padding(8)
                        .background(DSColors.error.opacity(0.1))
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
