import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct NegotiationDetailsView: View {
    @Bindable var store: StoreOf<NegotiationDetailsFeature>
    @Environment(\.dismiss) private var dismiss
    
    public init(store: StoreOf<NegotiationDetailsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            if store.isLoading {
                DSFullScreenLoading(message: "Carregando negociação...")
            } else if let negotiation = store.negotiation {
                VStack(spacing: 24) {
                    // Status Badge
                    statusBadge(negotiation)
                    
                    // Máquina de Estados Visual
                    NegotiationStateMachineView(negotiation: negotiation)
                    
                    // Informações do ingresso
                    if let ticket = negotiation.ticket {
                        ticketInfoSection(ticket, negotiation: negotiation)
                    }
                    
                    // Detalhes da negociação
                    negotiationDetailsSection(negotiation)
                    
                    // Informações do comprador/vendedor
                    if store.isSeller, let buyer = negotiation.buyer {
                        userInfoSection(buyer, role: "Comprador")
                    }
                    
                    if store.isBuyer, let seller = negotiation.seller {
                        userInfoSection(seller, role: "Vendedor")
                    }
                    
                    // Seção de Perguntas e Respostas
                    questionsSection
                    
                    // Seção de Documentos
                    documentsSection
                    
                    // Botões de ação
                    actionButtons(negotiation)
                }
                .padding(DSSpacing.m)
            }
        }
        .background(DSGradients.backgroundMain.ignoresSafeArea())
        .navigationTitle("Detalhes da Negociação")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
        .sheet(isPresented: $store.showingRejectSheet) {
            rejectSheet
        }
        .sheet(isPresented: $store.showingContactReveal) {
            ContactRevealView(store: store)
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
    
    // MARK: - Status Badge
    
    private func statusBadge(_ negotiation: Negotiation) -> some View {
        HStack {
            Spacer()
            
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: negotiation.status.iconName)
                    .font(DSTypography.body(weight: .semibold))
                
                Text(negotiation.status.displayName)
                    .font(DSTypography.footnote(weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, DSSpacing.m)
            .padding(.vertical, DSSpacing.sm)
            .background(
                Capsule()
                    .fill(statusColor(negotiation.status))
            )
            
            Spacer()
        }
    }
    
    private func statusColor(_ status: NegotiationStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        case .cancelled: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .disputed: return .red
        }
    }
    
    // MARK: - Ticket Info Section
    
    private func ticketInfoSection(_ ticket: Ticket, negotiation: Negotiation) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text(ticket.name)
                    .font(DSTypography.title3(weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Preço do Ingresso")
                            .font(DSTypography.caption1())
                            .foregroundColor(DSColors.textTertiary)
                        
                        Text("R$ \(String(format: "%.2f", ticket.price))")
                            .font(DSTypography.body(weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    if let proposedPrice = negotiation.proposedPrice {
                        VStack(alignment: .trailing) {
                            Text("Preço Proposto")
                                .font(DSTypography.caption1())
                                .foregroundColor(DSColors.textTertiary)
                            
                            Text("R$ \(String(format: "%.2f", proposedPrice))")
                                .font(DSTypography.body(weight: .semibold))
                                .foregroundColor(DSColors.primary)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Negotiation Details Section
    
    private func negotiationDetailsSection(_ negotiation: Negotiation) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Informações da Negociação")
                    .font(DSTypography.body(weight: .semibold))
                    .foregroundColor(DSColors.textPrimary)
                
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    detailRow(icon: "clock.fill", title: "Criada em", value: negotiation.createdAt.formatted(date: .abbreviated, time: .shortened))
                    
                    if let approvedAt = negotiation.approvedAt {
                        detailRow(icon: "checkmark.circle.fill", title: "Aprovada em", value: approvedAt.formatted(date: .abbreviated, time: .shortened))
                    }
                    
                    if let validUntil = negotiation.validUntil {
                        detailRow(icon: "hourglass", title: "Válida até", value: validUntil.formatted(date: .abbreviated, time: .shortened))
                    }
                    
                    if let rejectionReason = negotiation.rejectionReason {
                        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                            Text("Motivo da Recusa:")
                                .font(DSTypography.caption1(weight: .semibold))
                                .foregroundColor(DSColors.textSecondary)
                            
                            Text(rejectionReason)
                                .font(DSTypography.footnote())
                                .foregroundColor(DSColors.textPrimary)
                                .padding(DSSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DSRadius.small)
                                        .fill(Color.red.opacity(0.1))
                                )
                        }
                    }
                }
            }
        }
    }
    
    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(DSColors.primary)
                .frame(width: 20)
            
            Text(title)
                .font(DSTypography.footnote())
                .foregroundColor(DSColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(DSTypography.footnote(weight: .medium))
                .foregroundColor(DSColors.textPrimary)
        }
    }
    
    // MARK: - User Info Section
    
    private func userInfoSection(_ user: User, role: String) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text(role)
                    .font(DSTypography.body(weight: .semibold))
                    .foregroundColor(DSColors.textPrimary)
                
                HStack(spacing: DSSpacing.sm) {
                    // Avatar
                    Circle()
                        .fill(DSColors.primary.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(String(user.name.prefix(1)))
                                .font(DSTypography.title3(weight: .bold))
                                .foregroundColor(DSColors.primary)
                        )
                    
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text(user.name)
                            .font(DSTypography.body(weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                        
                        if user.isVerified {
                            HStack(spacing: DSSpacing.xxs) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(DSColors.success)
                                Text("Verificado")
                                    .font(DSTypography.caption1())
                                    .foregroundColor(DSColors.textSecondary)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Questions Section
    
    private var questionsSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                HStack {
                    Text("Perguntas e Respostas")
                        .font(DSTypography.title3(weight: .bold))
                        .foregroundColor(DSColors.textPrimary)
                    
                    Spacer()
                    
                    if !store.questions.isEmpty {
                        Text("\(store.questions.count)")
                            .font(DSTypography.footnote(weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xxs)
                            .background(
                                Capsule()
                                    .fill(DSColors.primary)
                            )
                    }
                }
                
                // Seção de perguntas pendentes (apenas para vendedor)
                if store.isSeller {
                    let unansweredQuestions = store.questions.filter { !$0.isAnswered }
                    if !unansweredQuestions.isEmpty {
                        unansweredQuestionsSection(unansweredQuestions)
                    }
                }
                
                if store.isLoadingQuestions {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.m)
                } else if store.questions.isEmpty {
                    emptyQuestionsState
                } else {
                    VStack(spacing: DSSpacing.sm) {
                        ForEach(Array(store.questions.enumerated()), id: \.element.id) { index, question in
                            QuestionCard(question: question)
                                .dsEnterAnimation(isVisible: true, delay: Double(index) * 0.05)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Unanswered Questions Section
    
    @State private var selectedQuestionForAnswer: NegotiationQuestion?
    
    private func unansweredQuestionsSection(_ questions: [NegotiationQuestion]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    
                    Text("Perguntas Pendentes")
                        .font(DSTypography.body(weight: .semibold))
                        .foregroundColor(DSColors.textPrimary)
                }
                
                Spacer()
                
                Text("\(questions.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.orange)
                    )
            }
            
            VStack(spacing: 8) {
                ForEach(questions) { question in
                    unansweredQuestionCard(question)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .sheet(item: $selectedQuestionForAnswer) { question in
            AnswerQuestionView(question: question, store: store)
        }
    }
    
    private func unansweredQuestionCard(_ question: NegotiationQuestion) -> some View {
        Button {
            selectedQuestionForAnswer = question
        } label: {
            HStack(spacing: DSSpacing.sm) {
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(question.questionText)
                        .font(DSTypography.footnote(weight: .medium))
                        .foregroundColor(DSColors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(formatDate(question.createdAt))
                            .font(DSTypography.caption1())
                    }
                    .foregroundColor(DSColors.textTertiary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(DSColors.primary)
            }
            .padding(DSSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.small)
                    .fill(DSColors.cardBackground)
            )
        }
        .buttonStyle(.plain)
        .dsTapFeedback()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "pt_BR")
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.locale = Locale(identifier: "pt_BR")
            timeFormatter.dateFormat = "HH:mm"
            return "Hoje às \(timeFormatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.locale = Locale(identifier: "pt_BR")
            timeFormatter.dateFormat = "HH:mm"
            return "Ontem às \(timeFormatter.string(from: date))"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "pt_BR")
            dateFormatter.dateFormat = "dd/MM/yyyy"
            return dateFormatter.string(from: date)
        }
    }
    
    // MARK: - Documents Section
    
    private var documentsSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                HStack {
                    Text("Documentos")
                        .font(DSTypography.title3(weight: .bold))
                        .foregroundColor(DSColors.textPrimary)
                    
                    Spacer()
                    
                    if !store.documents.isEmpty {
                        Text("\(store.documents.count)")
                            .font(DSTypography.footnote(weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xxs)
                            .background(
                                Capsule()
                                    .fill(DSColors.primary)
                            )
                    }
                }
                
                if store.isLoadingDocuments {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.m)
                } else {
                    DocumentGalleryView(
                        documents: store.documents,
                        onDelete: store.isSeller ? { document in
                            store.send(.deleteDocument(document.id))
                        } : nil
                    )
                }
            }
        }
    }
    
    // MARK: - Empty Questions State
    
    private var emptyQuestionsState: some View {
        DSEmptyState(
            icon: "questionmark.circle",
            title: "Nenhuma pergunta ainda",
            message: store.isBuyer ? "Faça perguntas sobre o ingresso para obter mais informações" : "O comprador ainda não fez perguntas"
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.xxl)
    }
    
    // MARK: - Action Buttons
    
    @ViewBuilder
    private func actionButtons(_ negotiation: Negotiation) -> some View {
        VStack(spacing: 12) {
            // Botões para vendedor
            if store.canApprove {
                Button {
                    store.send(.approveNegotiation)
                } label: {
                    HStack {
                        if store.isUpdating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        }
                        Image(systemName: "checkmark.circle.fill")
                        Text("Aprovar Negociação")
                            .font(DSTypography.body(weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(DSColors.success)
                    .dsCornerRadius(DSRadius.medium)
                }
                .disabled(store.isUpdating)
                .dsTapFeedback()
            }
            
            if store.canReject {
                Button {
                    store.send(.showRejectSheet)
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Recusar Negociação")
                            .font(DSTypography.body(weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(DSColors.error)
                    .dsCornerRadius(DSRadius.medium)
                }
                .disabled(store.isUpdating)
                .dsTapFeedback()
            }
            
            // Botão para comprador revelar contato
            if store.canRevealContact {
                Button {
                    store.send(.revealContact)
                } label: {
                    HStack {
                        if store.isRevealingContact {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        }
                        Image(systemName: "lock.open.fill")
                        Text("Revelar Dados de Contato")
                            .font(DSTypography.body(weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(DSColors.primary)
                    .dsCornerRadius(DSRadius.medium)
                }
                .disabled(store.isRevealingContact)
                .dsTapFeedback()
            }
            
            // Botão de cancelar
            if store.canCancel {
                Button {
                    store.send(.cancelNegotiation)
                } label: {
                    HStack {
                        Image(systemName: "slash.circle")
                        Text("Cancelar Negociação")
                            .font(DSTypography.body(weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(DSColors.error)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.medium)
                            .stroke(DSColors.error, lineWidth: 1.5)
                    )
                }
                .disabled(store.isUpdating)
                .dsTapFeedback()
            }
        }
    }
    
    // MARK: - Reject Sheet
    
    private var rejectSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Informe o motivo da recusa para que o comprador possa entender melhor.")
                    .font(DSTypography.footnote())
                    .foregroundColor(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.m)
                
                TextEditor(text: $store.rejectionReason)
                    .frame(height: 150)
                    .padding(DSSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.medium)
                            .stroke(DSColors.border, lineWidth: 1)
                    )
                    .padding(.horizontal, DSSpacing.m)
                
                Button {
                    store.send(.rejectNegotiation)
                } label: {
                    Text("Confirmar Recusa")
                        .font(DSTypography.body(weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(DSColors.error)
                        .dsCornerRadius(DSRadius.medium)
                }
                .padding(.horizontal, DSSpacing.m)
                .disabled(store.rejectionReason.isEmpty)
                .dsTapFeedback()
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Recusar Negociação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        store.send(.hideRejectSheet)
                    }
                }
            }
        }
    }
    
    // MARK: - Contact Reveal Sheet
    
    @ViewBuilder
    private var contactRevealSheet: some View {
        if let seller = store.revealedSeller {
            NavigationView {
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .padding(.top, 40)
                    
                    Text("Dados de Contato Revelados")
                        .font(DSTypography.title2(weight: .bold))
                        .foregroundColor(DSColors.textPrimary)
                    
                    Text("Entre em contato com o vendedor para finalizar a negociação.")
                        .font(DSTypography.footnote())
                        .foregroundColor(DSColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DSSpacing.m)
                    
                    VStack(spacing: DSSpacing.m) {
                        // Nome
                        contactInfoRow(icon: "person.fill", title: "Nome", value: seller.name)
                        
                        // E-mail
                        contactInfoRow(icon: "envelope.fill", title: "E-mail", value: seller.email)
                        
                        // TODO: Adicionar telefone quando disponível
                    }
                    .padding(DSSpacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.large)
                            .fill(DSColors.cardBackground)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, DSSpacing.m)
                    
                    Spacer()
                    
                    Button {
                        store.showingContactReveal = false
                    } label: {
                        Text("Fechar")
                            .font(DSTypography.body(weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .background(DSColors.primary)
                            .dsCornerRadius(DSRadius.medium)
                    }
                    .padding(.horizontal, DSSpacing.m)
                    .padding(.bottom, DSSpacing.m)
                    .dsTapFeedback()
                }
                .navigationTitle("Contato")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    private func contactInfoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(DSColors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(title)
                    .font(DSTypography.caption1())
                    .foregroundColor(DSColors.textTertiary)
                
                Text(value)
                    .font(DSTypography.footnote(weight: .medium))
                    .foregroundColor(DSColors.textPrimary)
            }
            
            Spacer()
            
            // Action buttons based on contact type
            HStack(spacing: DSSpacing.sm) {
                // Copy button
                Button {
                    DeepLinkService.shared.copyToClipboard(value)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14))
                        .foregroundColor(DSColors.primary)
                }
                .dsTapFeedback()
                
                // Deep link buttons
                if title == "Telefone" || title == "Phone" {
                    Menu {
                        Button {
                            DeepLinkService.shared.openWhatsApp(phoneNumber: value)
                        } label: {
                            Label("WhatsApp", systemImage: "message.fill")
                        }
                        
                        Button {
                            DeepLinkService.shared.makePhoneCall(phoneNumber: value)
                        } label: {
                            Label("Ligar", systemImage: "phone.fill")
                        }
                        
                        Button {
                            DeepLinkService.shared.sendSMS(phoneNumber: value)
                        } label: {
                            Label("SMS", systemImage: "message.badge.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 14))
                            .foregroundColor(DSColors.primary)
                    }
                } else if title == "E-mail" || title == "Email" {
                    Button {
                        DeepLinkService.shared.openEmail(email: value)
                    } label: {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 14))
                            .foregroundColor(DSColors.primary)
                    }
                    .dsTapFeedback()
                }
            }
        }
        .padding(.vertical, DSSpacing.xs)
    }
}

