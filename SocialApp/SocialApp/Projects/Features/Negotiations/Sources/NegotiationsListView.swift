import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct NegotiationsListView: View {
    @Bindable var store: StoreOf<NegotiationsListFeature>
    
    public init(store: StoreOf<NegotiationsListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            DSGradients.backgroundMain
                .ignoresSafeArea()
            
            if store.isLoading && !store.hasNegotiations {
                DSFullScreenLoading(message: "Carregando conversas...")
            } else if !store.hasNegotiations {
                emptyStateView
            } else {
                negotiationsList
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
        .refreshable {
            await store.send(.refreshRequested).finish()
        }
        .alert("Erro", isPresented: Binding(
            get: { store.showingErrorAlert },
            set: { _ in store.send(.dismissErrorAlert) }
        )) {
            Button("OK") {
                store.send(.dismissErrorAlert)
            }
        } message: {
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        DSEmptyState(
            icon: "message.fill",
            title: "Nenhuma Conversa Ainda",
            message: "Inicie uma nova conversa para conectar e obter respostas instantaneamente.",
            actionTitle: "Iniciar Conversa",
            action: {
                // TODO: Navegar para iniciar negociação
            }
        )
    }
    
    // MARK: - Negotiations List
    
    private var negotiationsList: some View {
        List {
            ForEach(Array(store.negotiations.enumerated()), id: \.element.id) { index, negotiation in
                NegotiationCard(
                    negotiation: negotiation,
                    onTap: {
                        store.send(.negotiationSelected(negotiation.id))
                    }
                )
                .listRowInsets(EdgeInsets(
                    top: DSSpacing.xxs,
                    leading: DSSpacing.m,
                    bottom: DSSpacing.xxs,
                    trailing: DSSpacing.m
                ))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .dsEnterAnimation(isVisible: true, delay: Double(index) * 0.05)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Negotiation Card

struct NegotiationCard: View {
    let negotiation: Negotiation
    let onTap: () -> Void
    
    var body: some View {
        DSCard {
            Button(action: onTap) {
                HStack(spacing: DSSpacing.sm) {
                    // Profile Picture
                    AsyncImage(url: URL(string: otherPerson.profileImageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(DSColors.backgroundSecondary)
                            .overlay(
                                Text(String(otherPerson.name.prefix(1)))
                                    .font(DSTypography.title3(weight: .bold))
                                    .foregroundColor(DSColors.textSecondary)
                            )
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    
                    // Content
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        HStack {
                            Text(otherPerson.name)
                                .font(DSTypography.body(weight: .semibold))
                                .foregroundColor(DSColors.textPrimary)
                            
                            Spacer()
                            
                            // Timestamp
                            Text(timeAgo)
                                .font(DSTypography.caption1())
                                .foregroundColor(DSColors.textSecondary)
                            
                            // Unread indicator
                            if hasUnread {
                                Circle()
                                    .fill(DSColors.primary)
                                    .frame(width: 8, height: 8)
                                    .padding(.leading, DSSpacing.xxs)
                            }
                        }
                        
                        // Last message preview
                        Text(lastMessagePreview)
                            .font(DSTypography.footnote())
                            .foregroundColor(DSColors.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, DSSpacing.xs)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var otherPerson: User {
        // Determina se o usuário atual é comprador ou vendedor
        let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") ?? ""
        
        if negotiation.buyerId == currentUserId {
            return negotiation.seller ?? User(name: "Vendedor", email: "")
        } else {
            return negotiation.buyer ?? User(name: "Comprador", email: "")
        }
    }
    
    private var hasUnread: Bool {
        negotiation.hasUnreadQuestions
    }
    
    private var lastMessagePreview: String {
        if let preview = negotiation.lastMessagePreview {
            return preview
        }
        // Fallback para status
        switch negotiation.status {
        case .pending:
            return "Negociação pendente"
        case .approved:
            return "Negociação aprovada"
        case .rejected:
            return "Negociação recusada"
        case .cancelled:
            return "Negociação cancelada"
        case .inProgress:
            return "Em andamento"
        case .completed:
            return "Concluída"
        case .disputed:
            return "Em disputa"
        }
    }
    
    private var timeAgo: String {
        let date = negotiation.lastMessageDate ?? negotiation.createdAt
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "pt_BR")
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.locale = Locale(identifier: "pt_BR")
            timeFormatter.dateFormat = "HH:mm"
            return timeFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Ontem"
        } else if calendar.dateInterval(of: .weekOfYear, for: date)?.contains(Date()) ?? false {
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.locale = Locale(identifier: "pt_BR")
            weekdayFormatter.dateFormat = "EEEE"
            return weekdayFormatter.string(from: date)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "pt_BR")
            dateFormatter.dateFormat = "dd MMM"
            return dateFormatter.string(from: date)
        }
    }
}

