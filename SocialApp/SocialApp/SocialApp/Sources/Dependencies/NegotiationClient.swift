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
                return [] // Fallback vazio
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
                
                // Verifica se tem nível mínimo e menos de 3 negociações ativas
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
            // TODO: Implementar upload de imagem para documento
            // Por enquanto, simular sucesso
            print("📄 Enviando documento do tipo: \(documentType)")
            
            // Simular resposta de sucesso
            let mockVerification = UserVerification(
                emailVerified: true,
                phoneVerified: true,
                documentType: documentType,
                documentVerified: false, // Aguardando moderação
                verificationLevel: .phoneVerified,
                trustScore: 60
            )
            
            return mockVerification
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
        }
    )
    
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
        fetchUserReviews: { _ in [] },
        createReview: { _ in
            Review(
                negotiationId: "test-negotiation",
                reviewerId: "test-reviewer",
                reviewedId: "test-reviewed",
                rating: 5
            )
        },
        
        // MARK: - Validation Implementation
        
        uploadValidationProof: { negotiationId, ticketId, images, description in
            print("📤 Uploading validation proof...")
            print("   - Negotiation: \(negotiationId)")
            print("   - Ticket: \(ticketId)")
            print("   - Images: \(images.count)")
            print("   - Description: \(description.prefix(50))...")
            
            // Preparar request multipart/form-data
            let boundary = UUID().uuidString
            var body = Data()
            
            // Adicionar imagens
            for (index, imageData) in images.enumerated() {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"images[\(index)]\"; filename=\"proof\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
            
            // Adicionar description
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
            body.append(description.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            let validation = try await NetworkService.shared.request(
                endpoint: "/negotiations/\(negotiationId)/tickets/\(ticketId)/validate",
                method: .POST,
                body: body,
                contentType: "multipart/form-data; boundary=\(boundary)",
                requiresAuth: true
            )
            
            print("✅ Validation proof uploaded successfully")
            return validation
        },
        
        fetchValidationStatus: { ticketId in
            do {
                let validation: TicketValidation = try await NetworkService.shared.request(
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
        
        // MARK: - Review Implementation
        
        submitReview: { negotiationId, revieweeId, rating, comment, role in
            print("⭐ Submitting review...")
            print("   - Negotiation: \(negotiationId)")
            print("   - Reviewee: \(revieweeId)")
            print("   - Rating: \(rating)")
            print("   - Role: \(role)")
            
            let request = CreateReviewRequest(
                negotiationId: negotiationId,
                revieweeId: revieweeId,
                rating: rating,
                comment: comment
            )
            
            let review: Review = try await NetworkService.shared.request(
                endpoint: "/negotiations/\(negotiationId)/reviews",
                method: .POST,
                body: request,
                requiresAuth: true
            )
            
            print("✅ Review submitted successfully")
            return review
        }
    )
}

extension DependencyValues {
    public var negotiationClient: NegotiationClient {
        get { self[NegotiationClient.self] }
        set { self[NegotiationClient.self] = newValue }
    }
}

