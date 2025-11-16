import ComposableArchitecture
import Foundation

@Reducer
public struct NegotiationDetailsFeature {
    @ObservableState
    public struct State: Equatable {
        var negotiationId: String
        var negotiation: Negotiation?
        var isLoading: Bool = false
        var isUpdating: Bool = false
        var showingContactReveal: Bool = false
        var showingRejectSheet: Bool = false
        var rejectionReason: String = ""
        var errorMessage: String?
        var showingErrorAlert: Bool = false
        
        // Estado do vendedor revelado
        var revealedSeller: User?
        var isRevealingContact: Bool = false
        
        // Perguntas e documentos
        var questions: [NegotiationQuestion] = []
        var documents: [NegotiationDocument] = []
        var isLoadingQuestions: Bool = false
        var isLoadingDocuments: Bool = false
        var isSendingMessage: Bool = false
        var showingQuestionSelection: Bool = false
        var showingDocumentUpload: Bool = false
        var isUploadingDocument: Bool = false
        var uploadProgress: Double = 0.0
        
        public init(negotiationId: String) {
            self.negotiationId = negotiationId
        }
        
        public init(negotiation: Negotiation) {
            self.negotiationId = negotiation.id
            self.negotiation = negotiation
        }
        
        var currentUserId: String {
            UserDefaults.standard.string(forKey: "currentUserId") ?? ""
        }
        
        var isBuyer: Bool {
            guard let negotiation = negotiation else { return false }
            return negotiation.buyerId == currentUserId
        }
        
        var isSeller: Bool {
            guard let negotiation = negotiation else { return false }
            return negotiation.sellerId == currentUserId
        }
        
        var canApprove: Bool {
            guard let negotiation = negotiation else { return false }
            return isSeller && negotiation.status == .pending && !isUpdating
        }
        
        var canReject: Bool {
            guard let negotiation = negotiation else { return false }
            return isSeller && negotiation.status == .pending && !isUpdating
        }
        
        var canRevealContact: Bool {
            guard let negotiation = negotiation else { return false }
            return isBuyer && negotiation.status == .approved && !negotiation.isExpired
        }
        
        var canCancel: Bool {
            guard let negotiation = negotiation else { return false }
            return (isBuyer || isSeller) && 
                   (negotiation.status == .pending || negotiation.status == .approved) && 
                   !isUpdating
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case loadNegotiation
        case negotiationResponse(Result<Negotiation, NetworkError>)
        case approveNegotiation
        case rejectNegotiation
        case showRejectSheet
        case hideRejectSheet
        case cancelNegotiation
        case updateResponse(Result<Negotiation, NetworkError>)
        case revealContact
        case revealContactResponse(Result<User, NetworkError>)
        case hideContactReveal
        case dismissErrorAlert
        
        // Perguntas e respostas
        case loadQuestions
        case questionsResponse(Result<[NegotiationQuestion], NetworkError>)
        case loadDocuments
        case documentsResponse(Result<[NegotiationDocument], NetworkError>)
        case sendMessage(String) // Envia pergunta ou resposta
        case messageSent(Result<NegotiationQuestion, NetworkError>)
        case answerQuestion(String, String) // questionId, answerText
        case answerSent(Result<NegotiationAnswer, NetworkError>)
        case markAsRead
        case markAsReadResponse(Result<Void, NetworkError>)
        case showQuestionSelection
        case hideQuestionSelection
        case showDocumentUpload
        case hideDocumentUpload
        case uploadDocument(Data, DocumentType) // imageData, documentType
        case documentUploaded(Result<NegotiationDocument, NetworkError>)
        case deleteDocument(String) // documentId
        case documentDeleted(Result<Void, NetworkError>)
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case negotiationUpdated(Negotiation)
            case negotiationRead(String) // negotiationId
            case dismiss
        }
    }
    
    @Dependency(\.negotiationClient) var negotiationClient
    @Dependency(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Se já temos a negociação, apenas carrega perguntas e documentos
                if state.negotiation != nil {
                    return .run { send in
                        await send(.loadQuestions)
                        await send(.loadDocuments)
                        await send(.markAsRead)
                    }
                } else {
                    return .run { send in
                        await send(.loadNegotiation)
                    }
                }
                
            case .loadNegotiation:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        let negotiation = try await negotiationClient.fetchNegotiation(negotiationId)
                        await send(.negotiationResponse(.success(negotiation)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.negotiationResponse(.failure(networkError)))
                    }
                }
                
            case let .negotiationResponse(.success(negotiation)):
                state.isLoading = false
                state.negotiation = negotiation
                print("✅ Negociação carregada: \(negotiation.id) - Status: \(negotiation.status.displayName)")
                
                // Carrega perguntas e documentos após carregar negociação
                // Marca como lido se houver perguntas não respondidas
                let shouldMarkAsRead = negotiation.hasUnreadQuestions
                
                return .run { send in
                    await send(.loadQuestions)
                    await send(.loadDocuments)
                    if shouldMarkAsRead {
                        await send(.markAsRead)
                    }
                }
                
            case let .negotiationResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao carregar negociação: \(error.userFriendlyMessage)")
                return .none
                
            case .approveNegotiation:
                guard state.canApprove else { return .none }
                
                state.isUpdating = true
                state.errorMessage = nil
                
                let request = UpdateNegotiationRequest(status: .approved)
                
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        let negotiation = try await negotiationClient.updateNegotiation(negotiationId, request)
                        await send(.updateResponse(.success(negotiation)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.updateResponse(.failure(networkError)))
                    }
                }
                
            case .showRejectSheet:
                state.showingRejectSheet = true
                return .none
                
            case .hideRejectSheet:
                state.showingRejectSheet = false
                state.rejectionReason = ""
                return .none
                
            case .rejectNegotiation:
                guard state.canReject else { return .none }
                guard !state.rejectionReason.isEmpty else {
                    state.errorMessage = "Por favor, informe o motivo da recusa"
                    state.showingErrorAlert = true
                    return .none
                }
                
                state.isUpdating = true
                state.errorMessage = nil
                state.showingRejectSheet = false
                
                let request = UpdateNegotiationRequest(
                    status: .rejected,
                    rejectionReason: state.rejectionReason
                )
                
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        let negotiation = try await negotiationClient.updateNegotiation(negotiationId, request)
                        await send(.updateResponse(.success(negotiation)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.updateResponse(.failure(networkError)))
                    }
                }
                
            case .cancelNegotiation:
                guard state.canCancel else { return .none }
                
                state.isUpdating = true
                state.errorMessage = nil
                
                let request = UpdateNegotiationRequest(status: .cancelled)
                
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        let negotiation = try await negotiationClient.updateNegotiation(negotiationId, request)
                        await send(.updateResponse(.success(negotiation)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.updateResponse(.failure(networkError)))
                    }
                }
                
            case let .updateResponse(.success(negotiation)):
                state.isUpdating = false
                state.negotiation = negotiation
                state.rejectionReason = ""
                print("✅ Negociação atualizada: \(negotiation.status.displayName)")
                
                return .run { send in
                    await send(.delegate(.negotiationUpdated(negotiation)))
                }
                
            case let .updateResponse(.failure(error)):
                state.isUpdating = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao atualizar negociação: \(error.userFriendlyMessage)")
                return .none
                
            case .revealContact:
                guard state.canRevealContact else {
                    state.errorMessage = "Não é possível revelar o contato neste momento"
                    state.showingErrorAlert = true
                    return .none
                }
                
                state.isRevealingContact = true
                state.errorMessage = nil
                
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        // ✅ Autenticação biométrica antes de revelar contato
                        print("🔐 Solicitando autenticação biométrica...")
                        let authenticated = try await BiometricAuthService.shared.authenticate(
                            reason: "Autentique-se para revelar os dados de contato do vendedor",
                            fallbackTitle: "Usar Senha"
                        )
                        
                        guard authenticated else {
                            throw BiometricAuthService.BiometricError.authenticationFailed
                        }
                        
                        print("✅ Autenticação bem-sucedida, revelando contato...")
                        let seller = try await negotiationClient.revealContact(negotiationId)
                        await send(.revealContactResponse(.success(seller)))
                    } catch let error as BiometricAuthService.BiometricError {
                        let errorMessage = error.errorDescription ?? "Falha na autenticação"
                        print("❌ Erro na autenticação biométrica: \(errorMessage)")
                        let networkError = NetworkError.unknown(errorMessage)
                        await send(.revealContactResponse(.failure(networkError)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.revealContactResponse(.failure(networkError)))
                    }
                }
                
            case let .revealContactResponse(.success(seller)):
                state.isRevealingContact = false
                state.revealedSeller = seller
                state.showingContactReveal = true
                print("✅ Contato revelado: \(seller.name)")
                return .none
                
            case let .revealContactResponse(.failure(error)):
                state.isRevealingContact = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao revelar contato: \(error.userFriendlyMessage)")
                return .none
                
            case .hideContactReveal:
                state.showingContactReveal = false
                // Limpa dados sensíveis da memória
                state.revealedSeller = nil
                return .none
                
            case .dismissErrorAlert:
                state.showingErrorAlert = false
                state.errorMessage = nil
                return .none
                
            // MARK: - Questions and Answers
            case .loadQuestions:
                state.isLoadingQuestions = true
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        let questions = try await negotiationClient.fetchQuestions(negotiationId)
                        await send(.questionsResponse(.success(questions)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.questionsResponse(.failure(networkError)))
                    }
                }
                
            case let .questionsResponse(.success(questions)):
                state.isLoadingQuestions = false
                state.questions = questions
                // Atualiza negociação com perguntas
                if var negotiation = state.negotiation {
                    negotiation.questions = questions
                    state.negotiation = negotiation
                }
                print("✅ \(questions.count) perguntas carregadas")
                return .none
                
            case let .questionsResponse(.failure(error)):
                state.isLoadingQuestions = false
                print("❌ Erro ao carregar perguntas: \(error.userFriendlyMessage)")
                // Não mostra erro para o usuário, apenas loga
                return .none
                
            case .loadDocuments:
                state.isLoadingDocuments = true
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        let documents = try await negotiationClient.fetchDocuments(negotiationId)
                        await send(.documentsResponse(.success(documents)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.documentsResponse(.failure(networkError)))
                    }
                }
                
            case let .documentsResponse(.success(documents)):
                state.isLoadingDocuments = false
                state.documents = documents
                // Atualiza negociação com documentos
                if var negotiation = state.negotiation {
                    negotiation.documents = documents
                    state.negotiation = negotiation
                }
                print("✅ \(documents.count) documentos carregados")
                return .none
                
            case let .documentsResponse(.failure(error)):
                state.isLoadingDocuments = false
                print("❌ Erro ao carregar documentos: \(error.userFriendlyMessage)")
                return .none
                
            case let .sendMessage(messageText):
                guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return .none
                }
                
                state.isSendingMessage = true
                
                // Determina se é comprador (envia pergunta) ou vendedor (envia resposta)
                if state.isBuyer {
                    // Comprador envia pergunta
                    let request = CreateQuestionRequest(
                        questionText: messageText,
                        category: .other // Por enquanto sempre "other", pode melhorar depois
                    )
                    
                    return .run { [negotiationId = state.negotiationId] send in
                        do {
                            let question = try await negotiationClient.createQuestion(negotiationId, request)
                            await send(.messageSent(.success(question)))
                        } catch {
                            let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                            await send(.messageSent(.failure(networkError)))
                        }
                    }
                } else {
                    // Vendedor responde última pergunta não respondida
                    guard let unansweredQuestion = state.questions.first(where: { !$0.isAnswered }) else {
                        state.errorMessage = "Não há perguntas pendentes para responder"
                        state.showingErrorAlert = true
                        state.isSendingMessage = false
                        return .none
                    }
                    
                    return .run { [negotiationId = state.negotiationId, questionId = unansweredQuestion.id] send in
                        do {
                            let answer = try await negotiationClient.answerQuestion(negotiationId, questionId, messageText)
                            // Recarrega perguntas para atualizar com a resposta
                            let questions = try await negotiationClient.fetchQuestions(negotiationId)
                            await send(.questionsResponse(.success(questions)))
                            await send(.answerSent(.success(answer)))
                        } catch {
                            let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                            await send(.answerSent(.failure(networkError)))
                        }
                    }
                }
                
            case let .messageSent(.success(question)):
                state.isSendingMessage = false
                // Recarrega perguntas para incluir a nova
                return .run { [negotiationId = state.negotiationId] send in
                    await send(.loadQuestions)
                }
                
            case let .messageSent(.failure(error)):
                state.isSendingMessage = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao enviar mensagem: \(error.userFriendlyMessage)")
                return .none
                
            case let .answerQuestion(questionId, answerText):
                guard !answerText.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return .none
                }
                
                state.isSendingMessage = true
                
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        let answer = try await negotiationClient.answerQuestion(negotiationId, questionId, answerText)
                        // Recarrega perguntas para atualizar com a resposta
                        let questions = try await negotiationClient.fetchQuestions(negotiationId)
                        await send(.questionsResponse(.success(questions)))
                        await send(.answerSent(.success(answer)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.answerSent(.failure(networkError)))
                    }
                }
                
            case let .answerSent(.success(_)):
                state.isSendingMessage = false
                print("✅ Resposta enviada")
                return .none
                
            case let .answerSent(.failure(error)):
                state.isSendingMessage = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao enviar resposta: \(error.userFriendlyMessage)")
                return .none
                
            case .markAsRead:
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        try await negotiationClient.markAsRead(negotiationId)
                        await send(.markAsReadResponse(.success(())))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.markAsReadResponse(.failure(networkError)))
                    }
                }
                
            case .markAsReadResponse(.success):
                // Atualiza estado local - marca todas as perguntas como lidas
                if var negotiation = state.negotiation {
                    negotiation.questions?.forEach { question in
                        var updatedQuestion = question
                        updatedQuestion.isRead = true
                    }
                    state.negotiation = negotiation
                }
                
                // Notifica via NotificationCenter para atualizar badge global
                NotificationCenter.default.post(
                    name: NSNotification.Name("NegotiationRead"),
                    object: nil,
                    userInfo: ["negotiationId": state.negotiationId]
                )
                
                // Também envia delegate para compatibilidade
                return .send(.delegate(.negotiationRead(state.negotiationId)))
                
            case .markAsReadResponse(.failure):
                // Silenciar erro - não crítico
                return .none
                
            case .showQuestionSelection:
                state.showingQuestionSelection = true
                return .none
                
            case .hideQuestionSelection:
                state.showingQuestionSelection = false
                return .none
                
            case .showDocumentUpload:
                state.showingDocumentUpload = true
                return .none
                
            case .hideDocumentUpload:
                state.showingDocumentUpload = false
                return .none
                
            case let .uploadDocument(imageData, documentType):
                // Validação: máximo 2 documentos
                if state.documents.count >= 2 {
                    state.errorMessage = "Você pode enviar no máximo 2 documentos por negociação."
                    state.showingErrorAlert = true
                    return .none
                }
                
                state.isUploadingDocument = true
                state.uploadProgress = 0.0
                
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        // Por enquanto, usa o método mockado do NegotiationClient
                        // TODO: Implementar upload real com progresso quando NetworkService suportar multipart
                        let document = try await negotiationClient.uploadDocument(
                            negotiationId,
                            imageData,
                            documentType.rawValue
                        )
                        await send(.documentUploaded(.success(document)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.documentUploaded(.failure(networkError)))
                    }
                }
                
            case let .documentUploaded(.success(document)):
                state.isUploadingDocument = false
                state.uploadProgress = 1.0
                state.documents.append(document)
                // Atualiza negociação com novo documento
                if var negotiation = state.negotiation {
                    negotiation.documents = state.documents
                    state.negotiation = negotiation
                }
                // Recarrega documentos para garantir sincronização
                return .run { send in
                    await send(.loadDocuments)
                }
                
            case let .documentUploaded(.failure(error)):
                state.isUploadingDocument = false
                state.uploadProgress = 0.0
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao fazer upload: \(error.userFriendlyMessage)")
                return .none
                
            case let .deleteDocument(documentId):
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        try await negotiationClient.deleteDocument(negotiationId, documentId)
                        await send(.documentDeleted(.success(())))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.documentDeleted(.failure(networkError)))
                    }
                }
                
            case .documentDeleted(.success):
                // Recarrega documentos após deletar
                return .run { send in
                    await send(.loadDocuments)
                }
                
            case let .documentDeleted(.failure(error)):
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao deletar documento: \(error.userFriendlyMessage)")
                return .none
                
            case .binding:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

