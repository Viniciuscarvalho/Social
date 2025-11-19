import SwiftUI
import ComposableArchitecture

public struct NegotiationsListView: View {
    @Bindable var store: StoreOf<NegotiationsListFeature>
    
    public init(store: StoreOf<NegotiationsListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            if store.isLoading && store.negotiations.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if store.negotiations.isEmpty {
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
        VStack(spacing: 24) {
            Spacer()
            
            // Ícone de calendário com grid (como na imagem)
            ZStack {
                Circle()
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.89))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "calendar")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.85, green: 0.75, blue: 0.65))
            }
            .padding(.bottom, 8)
            
            Text("Nenhuma Conversa Ainda")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            Text("Inicie uma nova conversa para conectar e obter respostas instantaneamente.")
                .font(.system(size: 15))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                // TODO: Navegar para iniciar negociação
            } label: {
                Text("Iniciar Conversa")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.5, green: 0.3, blue: 0.9)) // Purple como na imagem
                    )
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    // MARK: - Negotiations List
    
    private var negotiationsList: some View {
        List {
            ForEach(store.negotiations) { negotiation in
                NegotiationCard(
                    negotiation: negotiation,
                    onTap: {
                        store.send(.negotiationSelected(negotiation.id))
                    }
                )
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
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
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile Picture
                AsyncImage(url: URL(string: otherPerson.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Text(String(otherPerson.name.prefix(1)))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(otherPerson.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Timestamp
                        Text(timeAgo)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        // Unread indicator (blue dot como na imagem)
                        if hasUnread {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                                .padding(.leading, 4)
                        }
                    }
                    
                    // Last message preview
                    Text(lastMessagePreview)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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

