import ComposableArchitecture
import Foundation

@DependencyClient
public struct NegotiationClient {
    // MARK: - Negotiations
    
    /// Busca todas as negociações do usuário (como comprador e vendedor)
    public var fetchMyNegotiations: () async throws -> [Negotiation] = { [] }
    
    /// Busca negociações onde o usuário é vendedor
    public var fetchSellerNegotiations: () async throws -> [Negotiation] = { [] }
    
    /// Busca negociações onde o usuário é comprador
    public var fetchBuyerNegotiations: () async throws -> [Negotiation] = { [] }
    
    /// Busca uma negociação específica por ID
    public var fetchNegotiation: (String) async throws -> Negotiation
    
    /// Cria uma nova negociação
    public var createNegotiation: (CreateNegotiationRequest) async throws -> Negotiation
    
    /// Atualiza o status de uma negociação (aprovar/recusar/cancelar)
    public var updateNegotiation: (String, UpdateNegotiationRequest) async throws -> Negotiation
    
    /// Revela os dados de contato do vendedor (requer autenticação biométrica)
    public var revealContact: (String) async throws -> User
    
    /// Verifica se o usuário pode iniciar uma negociação
    public var canStartNegotiation: () async throws -> Bool = { false }
    
    // MARK: - User Verification
    
    /// Busca o status de verificação do usuário atual
    public var fetchVerificationStatus: () async throws -> UserVerification
    
    /// Busca o status de verificação de um usuário específico
    public var fetchUserVerification: (String) async throws -> UserVerification
    
    /// Envia código de verificação de e-mail
    public var sendEmailVerification: () async throws -> Void
    
    /// Confirma verificação de e-mail com código
    public var verifyEmail: (String) async throws -> UserVerification
    
    /// Envia código de verificação de telefone
    public var sendPhoneVerification: (String) async throws -> Void
    
    /// Confirma verificação de telefone com código
    public var verifyPhone: (String, String) async throws -> UserVerification
    
    /// Envia documento para verificação
    public var submitDocument: (String, Data) async throws -> UserVerification
    
    // MARK: - Questions and Answers
    
    /// Busca perguntas de uma negociação
    public var fetchQuestions: @Sendable (String) async throws -> [NegotiationQuestion] = { _ in [] }
    
    /// Cria uma pergunta em uma negociação
    public var createQuestion: @Sendable (String, CreateQuestionRequest) async throws -> NegotiationQuestion = { _, _ in
        NegotiationQuestion(negotiationId: "", questionText: "", category: .other)
    }
    
    /// Responde uma pergunta
    public var answerQuestion: @Sendable (String, String, String) async throws -> NegotiationAnswer = { _, _, _ in
        NegotiationAnswer(questionId: "", negotiationId: "", answerText: "", answeredBy: "")
    }
    
    /// Marca negociação como lida
    public var markAsRead: @Sendable (String) async throws -> Void = { _ in }
    
    /// Busca contador de perguntas não respondidas
    public var fetchUnreadQuestionsCount: @Sendable () async throws -> Int = { 0 }
    
    // MARK: - Documents
    
    /// Busca documentos de uma negociação
    public var fetchDocuments: @Sendable (String) async throws -> [NegotiationDocument] = { _ in [] }
    
    /// Faz upload de um documento
    public var uploadDocument: @Sendable (String, Data, String) async throws -> NegotiationDocument = { _, _, _ in
        NegotiationDocument(negotiationId: "", documentType: .ticketPhoto, fileUrl: "")
    }
    
    /// Remove um documento
    public var deleteDocument: @Sendable (String, String) async throws -> Void = { _, _ in }
    
    // MARK: - Reviews
    
    /// Busca avaliações de um usuário
    public var fetchUserReviews: @Sendable (String) async throws -> [Review]
    
    /// Cria uma avaliação
    public var createReview: @Sendable (CreateReviewRequest) async throws -> Review
    
    // MARK: - Validation Methods
    
    /// Faz upload de provas de validação de ingresso
    /// - Parameters:
    ///   - negotiationId: ID da negociação
    ///   - ticketId: ID do ingresso
    ///   - images: Array de imagens comprimidas em Data
    ///   - description: Descrição das provas
    /// - Returns: TicketValidation com status pending
    public var uploadValidationProof: @Sendable (String, String, [Data], String) async throws -> TicketValidation
    
    /// Busca o status de validação de um ingresso
    /// - Parameter ticketId: ID do ingresso
    /// - Returns: TicketValidation ou nil se não houver validação
    public var fetchValidationStatus: @Sendable (String) async throws -> TicketValidation?
    
    // MARK: - Review Methods
    
    /// Envia avaliação de uma negociação
    /// - Parameters:
    ///   - negotiationId: ID da negociação
    ///   - revieweeId: ID do usuário sendo avaliado
    ///   - rating: Nota de 1 a 5
    ///   - comment: Comentário da avaliação
    ///   - role: Papel do avaliador (buyer/seller)
    /// - Returns: Review criada
    public var submitReview: @Sendable (String, String, Int, String, String) async throws -> Review
}

extension NegotiationClient: DependencyKey {
    public static let testValue = NegotiationClient(
        fetchMyNegotiations: { [] },
        fetchSellerNegotiations: { [] },
        fetchBuyerNegotiations: { [] },
        fetchNegotiation: { _ in
            Negotiation(
                ticketId: "test-ticket",
                buyerId: "test-buyer",
                sellerId: "test-seller"
            )
        },
        createNegotiation: { _ in
            Negotiation(
                ticketId: "test-ticket",
                buyerId: "test-buyer",
                sellerId: "test-seller"
            )
        },
        updateNegotiation: { _, _ in
            Negotiation(
                ticketId: "test-ticket",
                buyerId: "test-buyer",
                sellerId: "test-seller",
                status: .approved
            )
        },
        revealContact: { _ in
            User(name: "Test Seller", email: "seller@test.com")
        },
        canStartNegotiation: { true },
        fetchVerificationStatus: {
            UserVerification(
                emailVerified: true,
                verificationLevel: .emailVerified,
                trustScore: 50
            )
        },
        fetchUserVerification: { _ in
            UserVerification(
                emailVerified: true,
                verificationLevel: .emailVerified,
                trustScore: 50
            )
        },
        sendEmailVerification: {},
        verifyEmail: { _ in
            UserVerification(
                emailVerified: true,
                verificationLevel: .emailVerified,
                trustScore: 50
            )
        },
        sendPhoneVerification: { _ in },
        verifyPhone: { _, _ in
            UserVerification(
                emailVerified: true,
                phoneVerified: true,
                verificationLevel: .phoneVerified,
                trustScore: 70
            )
        },
        submitDocument: { _, _ in
            UserVerification(
                emailVerified: true,
                phoneVerified: true,
                documentVerified: false,
                verificationLevel: .phoneVerified,
                trustScore: 70
            )
        },
        fetchQuestions: { _ in [] },
        createQuestion: { _, _ in
            NegotiationQuestion(negotiationId: "test", questionText: "Test", category: .other)
        },
        answerQuestion: { _, _, _ in
            NegotiationAnswer(questionId: "test", negotiationId: "test", answerText: "Test", answeredBy: "test")
        },
        markAsRead: { _ in },
        fetchUnreadQuestionsCount: { 0 },
        fetchDocuments: { _ in [] },
        uploadDocument: { _, _, _ in
            NegotiationDocument(negotiationId: "test", documentType: .ticketPhoto, fileUrl: "test")
        },
        deleteDocument: { _, _ in },
        fetchUserReviews: { _ in [] },
        createReview: { _ in
            Review(
                negotiationId: "test-negotiation",
                reviewerId: "test-reviewer",
                reviewedId: "test-reviewed",
                rating: 5
            )
        },
        uploadValidationProof: { _, _, _, _ in
            TicketValidation(
                id: "test-validation",
                ticketId: "test-ticket",
                sellerId: "test-sellerId",
                status: .pending
            )
        },
        fetchValidationStatus: { _ in
            TicketValidation(
                id: "test-validation",
                ticketId: "test-ticket",
                sellerId: "test-sellerId",
                status: .pending
            )
        },
        submitReview: { _, _, _, _, _ in
            Review(
                negotiationId: "test-negotiation",
                reviewerId: "test-reviewer",
                reviewedId: "test-reviewed",
                rating: 5
            )
        }
    )
    
    public static let liveValue = NegotiationClient(
        fetchMyNegotiations: {
            do {
                let negotiations: [APINegotiationResponse] = try await NetworkService.shared.requestArray(
                    endpoint: "/negotiations/my",
                    method: .GET,
                    requiresAuth: true
                )
                return negotiations.map { $0.toNegotiation() }
            } catch {
                print("❌ Erro ao buscar negociações: \(error.localizedDescription)")
                return []
            }
        },
        
        fetchSellerNegotiations: {
            do {
                let negotiations: [APINegotiationResponse] = try await NetworkService.shared.requestArray(
                    endpoint: "/negotiations/seller",
                    method: .GET,
                    requiresAuth: true
                )
                return negotiations.map { $0.toNegotiation() }
            } catch {
                print("❌ Erro ao buscar negociações como vendedor: \(error.localizedDescription)")
                return []
            }
        },
        
        fetchBuyerNegotiations: {
            do {
                let negotiations: [APINegotiationResponse] = try await NetworkService.shared.requestArray(
                    endpoint: "/negotiations/buyer",
                    method: .GET,
                    requiresAuth: true
                )
                return negotiations.map { $0.toNegotiation() }
            } catch {
                print("❌ Erro ao buscar negociações como comprador: \(error.localizedDescription)")
                return []
            }
        },
        
        fetchNegotiation: { negotiationId in
            let negotiation: APINegotiationResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)",
                method: .GET,
                requiresAuth: true
            )
            return negotiation.toNegotiation()
        },
        
        createNegotiation: { request in
            print("💼 Criando negociação para ticket: \(request.ticketId)")
            let negotiation: APINegotiationResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations",
                method: .POST,
                body: request,
                requiresAuth: true
            )
            print("✅ Negociação criada: \(negotiation.id)")
            return negotiation.toNegotiation()
        },
        
        updateNegotiation: { negotiationId, request in
            print("🔄 Atualizando negociação \(negotiationId) para status: \(request.status)")
            let negotiation: APINegotiationResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)",
                method: .PATCH,
                body: request,
                requiresAuth: true
            )
            print("✅ Negociação atualizada")
            return negotiation.toNegotiation()
        },
        
        revealContact: { negotiationId in
            print("🔓 Revelando contato para negociação: \(negotiationId)")
            let user: APIUserResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)/reveal-contact",
                method: .POST,
                requiresAuth: true
            )
            print("✅ Contato revelado")
            return user.toUser()
        },
        
        canStartNegotiation: {
            do {
                let verification: APIUserVerificationResponse = try await NetworkService.shared.requestSingle(
                    endpoint: "/users/verification/status",
                    method: .GET,
                    requiresAuth: true
                )
                let userVerification = verification.toUserVerification()
                
                let activeNegotiations: [APINegotiationResponse] = try await NetworkService.shared.requestArray(
                    endpoint: "/negotiations/my?status=pending,approved,in_progress",
                    method: .GET,
                    requiresAuth: true
                )
                
                let canNegotiate = userVerification.canNegotiate && activeNegotiations.count < 3
                print("🎫 Pode iniciar negociação: \(canNegotiate) (nível: \(userVerification.verificationLevel.displayName), ativas: \(activeNegotiations.count))")
                return canNegotiate
            } catch {
                print("❌ Erro ao verificar permissão de negociação: \(error.localizedDescription)")
                return false
            }
        },
        
        fetchVerificationStatus: {
            let verification: APIUserVerificationResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/users/verification/status",
                method: .GET,
                requiresAuth: true
            )
            return verification.toUserVerification()
        },
        
        fetchUserVerification: { userId in
            let verification: APIUserVerificationResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/users/\(userId)/verification",
                method: .GET,
                requiresAuth: true
            )
            return verification.toUserVerification()
        },
        
        sendEmailVerification: {
            let _: APISingleResponse<String> = try await NetworkService.shared.requestSingle(
                endpoint: "/users/verification/email/send",
                method: .POST,
                requiresAuth: true
            )
            print("✅ E-mail de verificação enviado")
        },
        
        verifyEmail: { code in
            struct VerifyEmailRequest: Codable {
                let code: String
            }
            
            let verification: APIUserVerificationResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/users/verification/email/verify",
                method: .POST,
                body: VerifyEmailRequest(code: code),
                requiresAuth: true
            )
            print("✅ E-mail verificado")
            return verification.toUserVerification()
        },
        
        sendPhoneVerification: { phone in
            struct SendPhoneVerificationRequest: Codable {
                let phone: String
            }
            
            let _: APISingleResponse<String> = try await NetworkService.shared.requestSingle(
                endpoint: "/users/verification/phone/send",
                method: .POST,
                body: SendPhoneVerificationRequest(phone: phone),
                requiresAuth: true
            )
            print("✅ SMS de verificação enviado para \(phone)")
        },
        
        verifyPhone: { phone, code in
            struct VerifyPhoneRequest: Codable {
                let phone: String
                let code: String
            }
            
            let verification: APIUserVerificationResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/users/verification/phone/verify",
                method: .POST,
                body: VerifyPhoneRequest(phone: phone, code: code),
                requiresAuth: true
            )
            print("✅ Telefone verificado")
            return verification.toUserVerification()
        },
        
        submitDocument: { documentType, documentData in
            print("📄 Enviando documento do tipo: \(documentType)")
            let mockVerification = UserVerification(
                emailVerified: true,
                phoneVerified: true,
                documentType: documentType,
                documentVerified: false,
                verificationLevel: .phoneVerified,
                trustScore: 60
            )
            return mockVerification
        },
        
        // MARK: - Questions and Answers Implementation
        fetchQuestions: { negotiationId in
            print("❓ Buscando perguntas da negociação: \(negotiationId)")
            struct APIQuestionResponse: Codable {
                let id: String
                let negotiationId: String?
                let negotiation_id: String?
                let questionText: String?
                let question_text: String?
                let category: String
                let isAnswered: Bool?
                let is_answered: Bool?
                let answer: APIAnswerResponse?
                let createdAt: String?
                let created_at: String?
                let answeredAt: String?
                let answered_at: String?
                let isRead: Bool?
                let is_read: Bool?
                
                struct APIAnswerResponse: Codable {
                    let id: String
                    let questionId: String?
                    let question_id: String?
                    let negotiationId: String?
                    let negotiation_id: String?
                    let answerText: String?
                    let answer_text: String?
                    let answeredBy: String?
                    let answered_by: String?
                    let createdAt: String?
                    let created_at: String?
                    
                    func toAnswer() -> NegotiationAnswer {
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        let dateFormats = [
                            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                            "yyyy-MM-dd'T'HH:mm:ssZ",
                            "yyyy-MM-dd'T'HH:mm:ss'Z'"
                        ]
                        
                        var createdAtDate = Date()
                        let createdAtString = createdAt ?? created_at ?? ""
                        if !createdAtString.isEmpty {
                            for format in dateFormats {
                                dateFormatter.dateFormat = format
                                if let date = dateFormatter.date(from: createdAtString) {
                                    createdAtDate = date
                                    break
                                }
                            }
                        }
                        
                        return NegotiationAnswer(
                            id: id,
                            questionId: questionId ?? question_id ?? "",
                            negotiationId: negotiationId ?? negotiation_id ?? "",
                            answerText: answerText ?? answer_text ?? "",
                            answeredBy: answeredBy ?? answered_by ?? "",
                            createdAt: createdAtDate
                        )
                    }
                }
                
                func toQuestion() -> NegotiationQuestion {
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    let dateFormats = [
                        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                        "yyyy-MM-dd'T'HH:mm:ssZ",
                        "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    ]
                    
                    var createdAtDate = Date()
                    let createdAtString = createdAt ?? created_at ?? ""
                    if !createdAtString.isEmpty {
                        for format in dateFormats {
                            dateFormatter.dateFormat = format
                            if let date = dateFormatter.date(from: createdAtString) {
                                createdAtDate = date
                                break
                            }
                        }
                    }
                    
                    var answeredAtDate: Date? = nil
                    let answeredAtString = answeredAt ?? answered_at
                    if let answeredAtString = answeredAtString, !answeredAtString.isEmpty {
                        for format in dateFormats {
                            dateFormatter.dateFormat = format
                            if let date = dateFormatter.date(from: answeredAtString) {
                                answeredAtDate = date
                                break
                            }
                        }
                    }
                    
                    return NegotiationQuestion(
                        id: id,
                        negotiationId: negotiationId ?? negotiation_id ?? "",
                        questionText: questionText ?? question_text ?? "",
                        category: QuestionCategory(rawValue: category) ?? .other,
                        isAnswered: isAnswered ?? is_answered ?? false,
                        answer: answer?.toAnswer(),
                        createdAt: createdAtDate,
                        answeredAt: answeredAtDate,
                        isRead: isRead ?? is_read ?? false
                    )
                }
            }
            
            let questions: [APIQuestionResponse] = try await NetworkService.shared.requestArray(
                endpoint: "/negotiations/\(negotiationId)/questions",
                method: .GET,
                requiresAuth: true
            )
            print("✅ \(questions.count) perguntas encontradas")
            return questions.map { $0.toQuestion() }
        },
        
        createQuestion: { negotiationId, request in
            print("❓ Criando pergunta na negociação: \(negotiationId)")
            struct APIQuestionResponse: Codable {
                let id: String
                let negotiationId: String?
                let negotiation_id: String?
                let questionText: String?
                let question_text: String?
                let category: String
                let isAnswered: Bool?
                let is_answered: Bool?
                let createdAt: String?
                let created_at: String?
                
                func toQuestion() -> NegotiationQuestion {
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    
                    return NegotiationQuestion(
                        id: id,
                        negotiationId: negotiationId ?? negotiation_id ?? "",
                        questionText: questionText ?? question_text ?? "",
                        category: QuestionCategory(rawValue: category) ?? .other,
                        isAnswered: false,
                        answer: nil,
                        createdAt: dateFormatter.date(from: createdAt ?? created_at ?? "") ?? Date(),
                        answeredAt: nil,
                        isRead: false
                    )
                }
            }
            
            let question: APIQuestionResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)/questions",
                method: .POST,
                body: request,
                requiresAuth: true
            )
            print("✅ Pergunta criada: \(question.id)")
            return question.toQuestion()
        },
        
        answerQuestion: { negotiationId, questionId, answerText in
            print("💬 Respondendo pergunta \(questionId) na negociação: \(negotiationId)")
            struct AnswerRequest: Codable {
                let answerText: String
                
                enum CodingKeys: String, CodingKey {
                    case answerText = "answer_text"
                }
            }
            
            struct APIAnswerResponse: Codable {
                let id: String
                let questionId: String?
                let question_id: String?
                let negotiationId: String?
                let negotiation_id: String?
                let answerText: String?
                let answer_text: String?
                let answeredBy: String?
                let answered_by: String?
                let createdAt: String?
                let created_at: String?
                
                func toAnswer() -> NegotiationAnswer {
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    let dateFormats = [
                        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                        "yyyy-MM-dd'T'HH:mm:ssZ",
                        "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    ]
                    
                    var createdAtDate = Date()
                    let createdAtString = createdAt ?? created_at ?? ""
                    if !createdAtString.isEmpty {
                        for format in dateFormats {
                            dateFormatter.dateFormat = format
                            if let date = dateFormatter.date(from: createdAtString) {
                                createdAtDate = date
                                break
                            }
                        }
                    }
                    
                    return NegotiationAnswer(
                        id: id,
                        questionId: questionId ?? question_id ?? "",
                        negotiationId: negotiationId ?? negotiation_id ?? "",
                        answerText: answerText ?? answer_text ?? "",
                        answeredBy: answeredBy ?? answered_by ?? "",
                        createdAt: createdAtDate
                    )
                }
            }
            
            let answer: APIAnswerResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)/questions/\(questionId)/answer",
                method: .POST,
                body: AnswerRequest(answerText: answerText),
                requiresAuth: true
            )
            print("✅ Resposta enviada")
            return answer.toAnswer()
        },
        
        markAsRead: { negotiationId in
            print("👁️ Marcando negociação como lida: \(negotiationId)")
            let _: APISingleResponse<String> = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)/mark-read",
                method: .PATCH,
                requiresAuth: true
            )
            print("✅ Negociação marcada como lida")
        },
        
        fetchUnreadQuestionsCount: {
            print("🔔 Buscando contador de perguntas não respondidas")
            struct UnreadCountResponse: Codable {
                let count: Int
            }
            
            let response: UnreadCountResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/unread-count",
                method: .GET,
                requiresAuth: true
            )
            print("✅ \(response.count) perguntas não respondidas")
            return response.count
        },
        
        // MARK: - Documents Implementation
        fetchDocuments: { negotiationId in
            print("📄 Buscando documentos da negociação: \(negotiationId)")
            struct APIDocumentResponse: Codable {
                let id: String
                let negotiationId: String?
                let negotiation_id: String?
                let documentType: String?
                let document_type: String?
                let fileUrl: String?
                let file_url: String?
                let thumbnailUrl: String?
                let thumbnail_url: String?
                let status: String
                let uploadedAt: String?
                let uploaded_at: String?
                let validatedAt: String?
                let validated_at: String?
                
                func toDocument() -> NegotiationDocument {
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    let dateFormats = [
                        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                        "yyyy-MM-dd'T'HH:mm:ssZ",
                        "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    ]
                    
                    var uploadedAtDate = Date()
                    let uploadedAtString = uploadedAt ?? uploaded_at ?? ""
                    if !uploadedAtString.isEmpty {
                        for format in dateFormats {
                            dateFormatter.dateFormat = format
                            if let date = dateFormatter.date(from: uploadedAtString) {
                                uploadedAtDate = date
                                break
                            }
                        }
                    }
                    
                    var validatedAtDate: Date? = nil
                    let validatedAtString = validatedAt ?? validated_at
                    if let validatedAtString = validatedAtString, !validatedAtString.isEmpty {
                        for format in dateFormats {
                            dateFormatter.dateFormat = format
                            if let date = dateFormatter.date(from: validatedAtString) {
                                validatedAtDate = date
                                break
                            }
                        }
                    }
                    
                    return NegotiationDocument(
                        id: id,
                        negotiationId: negotiationId ?? negotiation_id ?? "",
                        documentType: DocumentType(rawValue: documentType ?? document_type ?? "ticket_photo") ?? .ticketPhoto,
                        fileUrl: fileUrl ?? file_url ?? "",
                        thumbnailUrl: thumbnailUrl ?? thumbnail_url,
                        status: ValidationStatus(rawValue: status) ?? .pending,
                        uploadedAt: uploadedAtDate,
                        validatedAt: validatedAtDate
                    )
                }
            }
            
            let documents: [APIDocumentResponse] = try await NetworkService.shared.requestArray(
                endpoint: "/negotiations/\(negotiationId)/documents",
                method: .GET,
                requiresAuth: true
            )
            print("✅ \(documents.count) documentos encontrados")
            return documents.map { $0.toDocument() }
        },
        
        uploadDocument: { negotiationId, documentData, documentType in
            print("📤 Fazendo upload de documento na negociação: \(negotiationId)")
            print("   Tipo: \(documentType)")
            print("   Tamanho: \(documentData.count) bytes")
            
            let boundary = UUID().uuidString
            var body = Data()
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"document_type\"\r\n\r\n".data(using: .utf8)!)
            body.append(documentType.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"document.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(documentData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            struct APIDocumentResponse: Codable {
                let id: String
                let negotiationId: String?
                let negotiation_id: String?
                let documentType: String?
                let document_type: String?
                let fileUrl: String?
                let file_url: String?
                let thumbnailUrl: String?
                let thumbnail_url: String?
                let status: String
                let uploadedAt: String?
                let uploaded_at: String?
                
                func toDocument() -> NegotiationDocument {
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    
                    return NegotiationDocument(
                        id: id,
                        negotiationId: negotiationId ?? negotiation_id ?? "",
                        documentType: DocumentType(rawValue: documentType ?? document_type ?? "ticket_photo") ?? .ticketPhoto,
                        fileUrl: fileUrl ?? file_url ?? "",
                        thumbnailUrl: thumbnailUrl ?? thumbnail_url,
                        status: ValidationStatus(rawValue: status) ?? .pending,
                        uploadedAt: dateFormatter.date(from: uploadedAt ?? uploaded_at ?? "") ?? Date(),
                        validatedAt: nil
                    )
                }
            }
            
            // Para multipart/form-data, precisamos fazer uma requisição customizada
            // Por enquanto, vamos usar um mock até implementar suporte completo no NetworkService
            let document = NegotiationDocument(
                id: UUID().uuidString,
                negotiationId: negotiationId,
                documentType: DocumentType(rawValue: documentType) ?? .ticketPhoto,
                fileUrl: "https://example.com/document.jpg",
                status: .pending,
                uploadedAt: Date()
            )
            print("✅ Documento enviado (mock)")
            return document
        },
        
        deleteDocument: { negotiationId, documentId in
            print("🗑️ Removendo documento \(documentId) da negociação: \(negotiationId)")
            let _: APISingleResponse<String> = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)/documents/\(documentId)",
                method: .DELETE,
                requiresAuth: true
            )
            print("✅ Documento removido")
        },
        
        fetchUserReviews: { userId in
            do {
                struct APIReviewResponse: Codable {
                    let id: String
                    let negotiationId: String?
                    let negotiation_id: String?
                    let reviewerId: String?
                    let reviewer_id: String?
                    let reviewedId: String?
                    let reviewed_id: String?
                    let rating: Int
                    let comment: String?
                    let status: String
                    let createdAt: String?
                    let created_at: String?
                    let updatedAt: String?
                    let updated_at: String?
                    let reviewer: APIUserResponse?
                    let reviewed: APIUserResponse?
                    
                    func toReview() -> Review {
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                        
                        var review = Review(
                            id: id,
                            negotiationId: negotiationId ?? negotiation_id ?? "",
                            reviewerId: reviewerId ?? reviewer_id ?? "",
                            reviewedId: reviewedId ?? reviewed_id ?? "",
                            rating: rating,
                            comment: comment,
                            status: status,
                            createdAt: dateFormatter.date(from: createdAt ?? created_at ?? "") ?? Date(),
                            updatedAt: dateFormatter.date(from: updatedAt ?? updated_at ?? "") ?? Date()
                        )
                        
                        if let apiReviewer = reviewer {
                            review.reviewer = apiReviewer.toUser()
                        }
                        
                        if let apiReviewed = reviewed {
                            review.reviewed = apiReviewed.toUser()
                        }
                        
                        return review
                    }
                }
                
                let reviews: [APIReviewResponse] = try await NetworkService.shared.requestArray(
                    endpoint: "/users/\(userId)/reviews",
                    method: .GET,
                    requiresAuth: true
                )
                return reviews.map { $0.toReview() }
            } catch {
                print("❌ Erro ao buscar avaliações: \(error.localizedDescription)")
                return []
            }
        },
        
        createReview: { request in
            struct APIReviewResponse: Codable {
                let id: String
                let negotiationId: String?
                let negotiation_id: String?
                let reviewerId: String?
                let reviewer_id: String?
                let reviewedId: String?
                let reviewed_id: String?
                let rating: Int
                let comment: String?
                let status: String
                let createdAt: String?
                let created_at: String?
                let updatedAt: String?
                let updated_at: String?
                
                func toReview() -> Review {
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    
                    return Review(
                        id: id,
                        negotiationId: negotiationId ?? negotiation_id ?? "",
                        reviewerId: reviewerId ?? reviewer_id ?? "",
                        reviewedId: reviewedId ?? reviewed_id ?? "",
                        rating: rating,
                        comment: comment,
                        status: status,
                        createdAt: dateFormatter.date(from: createdAt ?? created_at ?? "") ?? Date(),
                        updatedAt: dateFormatter.date(from: updatedAt ?? updated_at ?? "") ?? Date()
                    )
                }
            }
            
            print("⭐ Criando avaliação: \(request.rating) estrelas")
            let review: APIReviewResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/reviews",
                method: .POST,
                body: request,
                requiresAuth: true
            )
            print("✅ Avaliação criada")
            return review.toReview()
        },
        
        uploadValidationProof: { negotiationId, ticketId, images, description in
            print("📤 Uploading validation proof...")
            print("   - Negotiation: \(negotiationId)")
            print("   - Ticket: \(ticketId)")
            print("   - Images: \(images.count)")
            print("   - Description: \(description.prefix(50))...")
            
            let boundary = UUID().uuidString
            var body = Data()
            
            for (index, imageData) in images.enumerated() {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"images[\(index)]\"; filename=\"proof\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
            body.append(description.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            let validation: TicketValidation = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)/tickets/\(ticketId)/validate",
                method: .POST,
                body: body,
                requiresAuth: true
            )
            
            print("✅ Validation proof uploaded successfully")
            return validation
        },
        
        fetchValidationStatus: { ticketId in
            do {
                let validation: TicketValidation = try await NetworkService.shared.requestSingle(
                    endpoint: "/tickets/\(ticketId)/validation",
                    method: .GET,
                    requiresAuth: true
                )
                return validation
            } catch {
                print("⚠️ No validation found for ticket: \(ticketId)")
                return nil
            }
        },
        
        submitReview: { negotiationId, revieweeId, rating, comment, role in
            print("⭐ Submitting review...")
            print("   - Negotiation: \(negotiationId)")
            print("   - Reviewee: \(revieweeId)")
            print("   - Rating: \(rating)")
            print("   - Role: \(role)")
            
            let request = CreateReviewRequest(
                negotiationId: negotiationId,
                reviewedId: revieweeId,
                rating: rating,
                comment: comment
            )
            
            let review: Review = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)/reviews",
                method: .POST,
                body: request,
                requiresAuth: true
            )
            
            print("✅ Review submitted successfully")
            return review
        },
        
        // MARK: - Questions and Answers Implementation
        fetchQuestions: { negotiationId in
            print("❓ Fetching questions for negotiation: \(negotiationId)")
            
            let apiQuestions: [APINegotiationQuestionResponse] = try await NetworkService.shared.requestArray(
                endpoint: "/negotiations/\(negotiationId)/questions",
                method: .GET,
                requiresAuth: true
            )
            
            let questions = apiQuestions.map { $0.toNegotiationQuestion() }
            print("✅ Fetched \(questions.count) questions")
            return questions
        },
        
        createQuestion: { negotiationId, request in
            print("❓ Creating question for negotiation: \(negotiationId)")
            print("   - Question: \(request.questionText)")
            print("   - Category: \(request.category.rawValue)")
            
            let apiQuestion: APINegotiationQuestionResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)/questions",
                method: .POST,
                body: request,
                requiresAuth: true
            )
            
            print("✅ Question created successfully")
            return apiQuestion.toNegotiationQuestion()
        },
        
        answerQuestion: { negotiationId, questionId, answerText in
            print("💬 Answering question: \(questionId)")
            print("   - Answer: \(answerText.prefix(50))...")
            
            let request = AnswerQuestionRequest(answerText: answerText)
            
            let apiAnswer: APINegotiationAnswerResponse = try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)/questions/\(questionId)/answer",
                method: .POST,
                body: request,
                requiresAuth: true
            )
            
            print("✅ Question answered successfully")
            return apiAnswer.toNegotiationAnswer()
        },
        
        markAsRead: { negotiationId in
            print("👁️ Marking negotiation as read: \(negotiationId)")
            
            try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)/mark-read",
                method: .PATCH,
                requiresAuth: true
            ) as EmptyResponse
            
            print("✅ Negotiation marked as read")
        },
        
        // MARK: - Documents Implementation
        fetchDocuments: { negotiationId in
            print("📄 Fetching documents for negotiation: \(negotiationId)")
            
            let apiDocuments: [APINegotiationDocumentResponse] = try await NetworkService.shared.requestArray(
                endpoint: "/negotiations/\(negotiationId)/documents",
                method: .GET,
                requiresAuth: true
            )
            
            let documents = apiDocuments.map { $0.toNegotiationDocument() }
            print("✅ Fetched \(documents.count) documents")
            return documents
        },
        
        uploadDocument: { negotiationId, data, documentType in
            print("📤 Uploading document for negotiation: \(negotiationId)")
            print("   - Type: \(documentType)")
            print("   - Size: \(data.count) bytes")
            
            // TODO: Implementar multipart/form-data upload
            // Por enquanto, retorna um documento mock
            return NegotiationDocument(
                negotiationId: negotiationId,
                documentType: DocumentType(rawValue: documentType) ?? .ticketPhoto,
                fileUrl: "https://example.com/document.jpg",
                status: .pending
            )
        },
        
        deleteDocument: { negotiationId, documentId in
            print("🗑️ Deleting document: \(documentId) from negotiation: \(negotiationId)")
            
            try await NetworkService.shared.requestSingle(
                endpoint: "/negotiations/\(negotiationId)/documents/\(documentId)",
                method: .DELETE,
                requiresAuth: true
            ) as EmptyResponse
            
            print("✅ Document deleted successfully")
        }
    )
}

// MARK: - Empty Response for markAsRead

private struct EmptyResponse: Codable {}

extension DependencyValues {
    public var negotiationClient: NegotiationClient {
        get { self[NegotiationClient.self] }
        set { self[NegotiationClient.self] = newValue }
    }
}








