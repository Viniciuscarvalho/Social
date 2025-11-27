import Foundation
import Domain

// MARK: - Negotiation Request Models

public struct CreateNegotiationRequest: Codable {
    public let ticketId: String
    public let proposedPrice: Double?
    
    public init(ticketId: String, proposedPrice: Double? = nil) {
        self.ticketId = ticketId
        self.proposedPrice = proposedPrice
    }
    
    enum CodingKeys: String, CodingKey {
        case ticketId = "ticket_id"
        case proposedPrice = "proposed_price"
    }
}

public struct UpdateNegotiationRequest: Codable {
    public let status: String
    public let rejectionReason: String?
    
    public init(status: NegotiationStatus, rejectionReason: String? = nil) {
        self.status = status.rawValue
        self.rejectionReason = rejectionReason
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case rejectionReason = "rejection_reason"
    }
}

// MARK: - Question Request Models

public struct CreateQuestionRequest: Codable {
    public let questionText: String
    public let category: QuestionCategory
    
    public init(questionText: String, category: QuestionCategory) {
        self.questionText = questionText
        self.category = category
    }
    
    enum CodingKeys: String, CodingKey {
        case questionText = "question_text"
        case category
    }
}

public struct AnswerQuestionRequest: Codable {
    public let answerText: String
    
    public init(answerText: String) {
        self.answerText = answerText
    }
    
    enum CodingKeys: String, CodingKey {
        case answerText = "answer_text"
    }
}

// MARK: - Document Request Models

public struct UploadDocumentRequest: Codable {
    public let documentType: DocumentType
    public let description: String?
    
    public init(documentType: DocumentType, description: String? = nil) {
        self.documentType = documentType
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case documentType = "document_type"
        case description
    }
}

// MARK: - Review Request Models

public struct CreateReviewRequest: Codable {
    public let negotiationId: String
    public let reviewedId: String
    public let rating: Int
    public let comment: String?
    
    public init(negotiationId: String, reviewedId: String, rating: Int, comment: String? = nil) {
        self.negotiationId = negotiationId
        self.reviewedId = reviewedId
        self.rating = rating
        self.comment = comment
    }
    
    enum CodingKeys: String, CodingKey {
        case rating, comment
        case negotiationId = "negotiation_id"
        case reviewedId = "reviewed_id"
    }
}

// MARK: - API Negotiation Response Models

public struct APINegotiationResponse: Codable {
    public let id: String
    public let ticketId: String?
    public let ticket_id: String?
    public let buyerId: String?
    public let buyer_id: String?
    public let sellerId: String?
    public let seller_id: String?
    public let status: String
    public let proposedPrice: Double?
    public let proposed_price: Double?
    public let escrowCode: String?
    public let escrow_code: String?
    public let accessToken: String?
    public let access_token: String?
    public let validUntil: String?
    public let valid_until: String?
    public let rejectionReason: String?
    public let rejection_reason: String?
    public let adminNotes: String?
    public let admin_notes: String?
    public let createdAt: String?
    public let created_at: String?
    public let approvedAt: String?
    public let approved_at: String?
    public let completedAt: String?
    public let completed_at: String?
    public let cancelledAt: String?
    public let cancelled_at: String?
    public let updatedAt: String?
    public let updated_at: String?
    public let questionsCount: Int?
    public let questions_count: Int?
    public let answeredQuestionsCount: Int?
    public let answered_questions_count: Int?
    public let hasUnreadUpdates: Bool?
    public let has_unread_updates: Bool?
    public let lastViewedAt: String?
    public let last_viewed_at: String?
    public let ticket: APITicketResponse?
    public let buyer: APIUserResponse?
    public let seller: APIUserResponse?
    
    // Computed properties para conversão
    public var finalTicketId: String {
        return ticketId ?? ticket_id ?? ""
    }
    
    public var finalBuyerId: String {
        return buyerId ?? buyer_id ?? ""
    }
    
    public var finalSellerId: String {
        return sellerId ?? seller_id ?? ""
    }
    
    public var finalProposedPrice: Double? {
        return proposedPrice ?? proposed_price
    }
    
    public var finalEscrowCode: String? {
        return escrowCode ?? escrow_code
    }
    
    public var finalAccessToken: String? {
        return accessToken ?? access_token
    }
    
    public var finalValidUntil: String? {
        return validUntil ?? valid_until
    }
    
    public var finalRejectionReason: String? {
        return rejectionReason ?? rejection_reason
    }
    
    public var finalAdminNotes: String? {
        return adminNotes ?? admin_notes
    }
    
    public var finalCreatedAt: String? {
        return createdAt ?? created_at
    }
    
    public var finalApprovedAt: String? {
        return approvedAt ?? approved_at
    }
    
    public var finalCompletedAt: String? {
        return completedAt ?? completed_at
    }
    
    public var finalCancelledAt: String? {
        return cancelledAt ?? cancelled_at
    }
    
    public var finalUpdatedAt: String? {
        return updatedAt ?? updated_at
    }
    
    public var finalQuestionsCount: Int? {
        return questionsCount ?? questions_count
    }
    
    public var finalAnsweredQuestionsCount: Int? {
        return answeredQuestionsCount ?? answered_questions_count
    }
    
    public var finalHasUnreadUpdates: Bool? {
        return hasUnreadUpdates ?? has_unread_updates
    }
    
    public var finalLastViewedAt: String? {
        return lastViewedAt ?? last_viewed_at
    }
}

// MARK: - API Negotiation Question Response

public struct APINegotiationQuestionResponse: Codable {
    public let id: String
    public let negotiationId: String?
    public let negotiation_id: String?
    public let askedBy: String?
    public let asked_by: String?
    public let questionText: String?
    public let question_text: String?
    public let category: String
    public let isAnswered: Bool?
    public let is_answered: Bool?
    public let answer: APINegotiationAnswerResponse?
    public let createdAt: String?
    public let created_at: String?
    public let answeredAt: String?
    public let answered_at: String?
    public let isRead: Bool?
    public let is_read: Bool?
    
    public var finalNegotiationId: String {
        return negotiationId ?? negotiation_id ?? ""
    }
    
    public var finalAskedBy: String {
        return askedBy ?? asked_by ?? ""
    }
    
    public var finalQuestionText: String {
        return questionText ?? question_text ?? ""
    }
    
    public var finalIsAnswered: Bool {
        return isAnswered ?? is_answered ?? false
    }
    
    public var finalCreatedAt: String? {
        return createdAt ?? created_at
    }
    
    public var finalAnsweredAt: String? {
        return answeredAt ?? answered_at
    }
    
    public var finalIsRead: Bool {
        return isRead ?? is_read ?? false
    }
}

// MARK: - API Negotiation Answer Response

public struct APINegotiationAnswerResponse: Codable {
    public let id: String
    public let questionId: String?
    public let question_id: String?
    public let negotiationId: String?
    public let negotiation_id: String?
    public let answerText: String?
    public let answer_text: String?
    public let answeredBy: String?
    public let answered_by: String?
    public let createdAt: String?
    public let created_at: String?
    public let updatedAt: String?
    public let updated_at: String?
    
    public var finalQuestionId: String {
        return questionId ?? question_id ?? ""
    }
    
    public var finalNegotiationId: String {
        return negotiationId ?? negotiation_id ?? ""
    }
    
    public var finalAnswerText: String {
        return answerText ?? answer_text ?? ""
    }
    
    public var finalAnsweredBy: String {
        return answeredBy ?? answered_by ?? ""
    }
    
    public var finalCreatedAt: String? {
        return createdAt ?? created_at
    }
    
    public var finalUpdatedAt: String? {
        return updatedAt ?? updated_at
    }
}

// MARK: - API Negotiation Document Response

public struct APINegotiationDocumentResponse: Codable {
    public let id: String
    public let negotiationId: String?
    public let negotiation_id: String?
    public let uploadedBy: String?
    public let uploaded_by: String?
    public let documentType: String?
    public let document_type: String?
    public let fileUrl: String?
    public let file_url: String?
    public let thumbnailUrl: String?
    public let thumbnail_url: String?
    public let status: String
    public let uploadedAt: String?
    public let uploaded_at: String?
    public let validatedAt: String?
    public let validated_at: String?
    public let updatedAt: String?
    public let updated_at: String?
    public let isVerified: Bool?
    public let is_verified: Bool?
    
    public var finalNegotiationId: String {
        return negotiationId ?? negotiation_id ?? ""
    }
    
    public var finalUploadedBy: String {
        return uploadedBy ?? uploaded_by ?? ""
    }
    
    public var finalDocumentType: String {
        return documentType ?? document_type ?? "ticket_photo"
    }
    
    public var finalFileUrl: String {
        return fileUrl ?? file_url ?? ""
    }
    
    public var finalThumbnailUrl: String? {
        return thumbnailUrl ?? thumbnail_url
    }
    
    public var finalUploadedAt: String? {
        return uploadedAt ?? uploaded_at
    }
    
    public var finalValidatedAt: String? {
        return validatedAt ?? validated_at
    }
    
    public var finalUpdatedAt: String? {
        return updatedAt ?? updated_at
    }
    
    public var finalIsVerified: Bool? {
        return isVerified ?? is_verified
    }
}

// MARK: - Mappers

extension APINegotiationResponse {
    public func toNegotiation() -> Negotiation {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss'Z'"
        ]
        
        func parseDate(_ dateString: String?) -> Date? {
            guard let dateString = dateString else { return nil }
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: dateString) {
                    return date
                }
            }
            return nil
        }
        
        var negotiation = Negotiation(
            id: id,
            ticketId: finalTicketId,
            buyerId: finalBuyerId,
            sellerId: finalSellerId,
            status: NegotiationStatus(rawValue: status) ?? .pending,
            proposedPrice: finalProposedPrice,
            escrowCode: finalEscrowCode,
            accessToken: finalAccessToken,
            validUntil: parseDate(finalValidUntil),
            rejectionReason: finalRejectionReason,
            adminNotes: finalAdminNotes,
            createdAt: parseDate(finalCreatedAt) ?? Date(),
            approvedAt: parseDate(finalApprovedAt),
            completedAt: parseDate(finalCompletedAt),
            cancelledAt: parseDate(finalCancelledAt),
            updatedAt: parseDate(finalUpdatedAt),
            questionsCount: finalQuestionsCount,
            answeredQuestionsCount: finalAnsweredQuestionsCount,
            hasUnreadUpdates: finalHasUnreadUpdates,
            lastViewedAt: parseDate(finalLastViewedAt)
        )
        
        // Parse expanded objects
        if let apiTicket = ticket {
            negotiation.ticket = apiTicket.toTicket()
        }
        
        if let apiBuyer = buyer {
            negotiation.buyer = apiBuyer.toUser()
        }
        
        if let apiSeller = seller {
            negotiation.seller = apiSeller.toUser()
        }
        
        return negotiation
    }
}

extension APINegotiationQuestionResponse {
    public func toNegotiationQuestion() -> NegotiationQuestion {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss'Z'"
        ]
        
        func parseDate(_ dateString: String?) -> Date? {
            guard let dateString = dateString else { return nil }
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: dateString) {
                    return date
                }
            }
            return nil
        }
        
        return NegotiationQuestion(
            id: id,
            negotiationId: finalNegotiationId,
            askedBy: finalAskedBy,
            questionText: finalQuestionText,
            category: QuestionCategory(rawValue: category) ?? .other,
            isAnswered: finalIsAnswered,
            answer: answer?.toNegotiationAnswer(),
            createdAt: parseDate(finalCreatedAt) ?? Date(),
            answeredAt: parseDate(finalAnsweredAt),
            isRead: finalIsRead
        )
    }
}

extension APINegotiationAnswerResponse {
    public func toNegotiationAnswer() -> NegotiationAnswer {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss'Z'"
        ]
        
        func parseDate(_ dateString: String?) -> Date? {
            guard let dateString = dateString else { return nil }
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: dateString) {
                    return date
                }
            }
            return nil
        }
        
        return NegotiationAnswer(
            id: id,
            questionId: finalQuestionId,
            negotiationId: finalNegotiationId,
            answerText: finalAnswerText,
            answeredBy: finalAnsweredBy,
            createdAt: parseDate(finalCreatedAt) ?? Date(),
            updatedAt: parseDate(finalUpdatedAt)
        )
    }
}

extension APINegotiationDocumentResponse {
    public func toNegotiationDocument() -> NegotiationDocument {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss'Z'"
        ]
        
        func parseDate(_ dateString: String?) -> Date? {
            guard let dateString = dateString else { return nil }
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: dateString) {
                    return date
                }
            }
            return nil
        }
        
        return NegotiationDocument(
            id: id,
            negotiationId: finalNegotiationId,
            uploadedBy: finalUploadedBy,
            documentType: DocumentType(rawValue: finalDocumentType) ?? .ticketPhoto,
            fileUrl: finalFileUrl,
            thumbnailUrl: finalThumbnailUrl,
            status: ValidationStatus(rawValue: status) ?? .pending,
            uploadedAt: parseDate(finalUploadedAt) ?? Date(),
            validatedAt: parseDate(finalValidatedAt),
            updatedAt: parseDate(finalUpdatedAt),
            isVerified: finalIsVerified
        )
    }
}

