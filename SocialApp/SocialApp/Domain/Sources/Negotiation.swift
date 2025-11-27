import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - Negotiation Status

public enum NegotiationStatus: String, Codable, Equatable {
  case pending = "pending"
  case approved = "approved"
  case rejected = "rejected"
  case cancelled = "cancelled"
  case inProgress = "in_progress"
  case completed = "completed"
  case disputed = "disputed"
  
  public var displayName: String {
    switch self {
    case .pending: return "Aguardando Resposta"
    case .approved: return "Aprovada"
    case .rejected: return "Recusada"
    case .cancelled: return "Cancelada"
    case .inProgress: return "Em Andamento"
    case .completed: return "Concluída"
    case .disputed: return "Em Disputa"
    }
  }
  
  public var iconName: String {
    switch self {
    case .pending: return "clock.fill"
    case .approved: return "checkmark.circle.fill"
    case .rejected: return "xmark.circle.fill"
    case .cancelled: return "slash.circle.fill"
    case .inProgress: return "arrow.triangle.2.circlepath"
    case .completed: return "checkmark.seal.fill"
    case .disputed: return "exclamationmark.triangle.fill"
    }
  }
}

// MARK: - Negotiation Domain Model

public struct Negotiation: Codable, Identifiable, Equatable {
  public var id: String
  public var ticketId: String
  public var buyerId: String
  public var sellerId: String
  public var status: NegotiationStatus
  public var proposedPrice: Double?
  public var escrowCode: String?
  public var accessToken: String?
  public var validUntil: Date?
  public var rejectionReason: String?
  public var adminNotes: String?
  public var createdAt: Date
  public var approvedAt: Date?
  public var completedAt: Date?
  public var cancelledAt: Date?
  public var updatedAt: Date?
  public var questionsCount: Int?
  public var answeredQuestionsCount: Int?
  public var hasUnreadUpdates: Bool?
  public var lastViewedAt: Date?
  
  public var ticket: Ticket?
  public var buyer: User?
  public var seller: User?
  public var questions: [NegotiationQuestion]?
  public var documents: [NegotiationDocument]?
  
  public init(
    id: String = UUID().uuidString,
    ticketId: String,
    buyerId: String,
    sellerId: String,
    status: NegotiationStatus = .pending,
    proposedPrice: Double? = nil,
    escrowCode: String? = nil,
    accessToken: String? = nil,
    validUntil: Date? = nil,
    rejectionReason: String? = nil,
    adminNotes: String? = nil,
    createdAt: Date = Date(),
    approvedAt: Date? = nil,
    completedAt: Date? = nil,
    cancelledAt: Date? = nil,
    updatedAt: Date? = nil,
    questionsCount: Int? = nil,
    answeredQuestionsCount: Int? = nil,
    hasUnreadUpdates: Bool? = nil,
    lastViewedAt: Date? = nil
  ) {
    self.id = id
    self.ticketId = ticketId
    self.buyerId = buyerId
    self.sellerId = sellerId
    self.status = status
    self.proposedPrice = proposedPrice
    self.escrowCode = escrowCode
    self.accessToken = accessToken
    self.validUntil = validUntil
    self.rejectionReason = rejectionReason
    self.adminNotes = adminNotes
    self.createdAt = createdAt
    self.approvedAt = approvedAt
    self.completedAt = completedAt
    self.cancelledAt = cancelledAt
    self.updatedAt = updatedAt
    self.questionsCount = questionsCount
    self.answeredQuestionsCount = answeredQuestionsCount
    self.hasUnreadUpdates = hasUnreadUpdates
    self.lastViewedAt = lastViewedAt
  }
  
  public var isExpired: Bool {
    guard let validUntil = validUntil else { return false }
    return Date() > validUntil
  }
  
  public var canRevealContact: Bool {
    return status == .approved && !isExpired
  }
  
  public var hasUnreadQuestions: Bool {
    guard let questions = questions else { return false }
    return questions.contains { !$0.isRead && $0.isAnswered }
  }
  
  public var unreadQuestionsCount: Int {
    guard let questions = questions else { return 0 }
    return questions.filter { !$0.isRead && $0.isAnswered }.count
  }
  
  public var unansweredQuestionsCount: Int {
    guard let questions = questions else { return 0 }
    return questions.filter { !$0.isAnswered }.count
  }
  
  public var lastMessagePreview: String? {
    guard let questions = questions, !questions.isEmpty else { return nil }
    let sortedQuestions = questions.sorted { $0.createdAt > $1.createdAt }
    if let lastQuestion = sortedQuestions.first {
      if let answer = lastQuestion.answer {
        return answer.answerText
      }
      return lastQuestion.questionText
    }
    return nil
  }
  
  public var lastMessageDate: Date? {
    guard let questions = questions, !questions.isEmpty else { return createdAt }
    let sortedQuestions = questions.sorted { $0.createdAt > $1.createdAt }
    if let lastQuestion = sortedQuestions.first {
      if let answer = lastQuestion.answer {
        return answer.createdAt
      }
      return lastQuestion.createdAt
    }
    return createdAt
  }
  
  enum CodingKeys: String, CodingKey {
    case id, status, ticket, buyer, seller
    case ticketId = "ticket_id"
    case buyerId = "buyer_id"
    case sellerId = "seller_id"
    case proposedPrice = "proposed_price"
    case escrowCode = "escrow_code"
    case accessToken = "access_token"
    case validUntil = "valid_until"
    case rejectionReason = "rejection_reason"
    case adminNotes = "admin_notes"
    case createdAt = "created_at"
    case approvedAt = "approved_at"
    case completedAt = "completed_at"
    case cancelledAt = "cancelled_at"
    case updatedAt = "updated_at"
    case questionsCount = "questions_count"
    case answeredQuestionsCount = "answered_questions_count"
    case hasUnreadUpdates = "has_unread_updates"
    case lastViewedAt = "last_viewed_at"
  }
}

// MARK: - Question Category

public enum QuestionCategory: String, Codable, CaseIterable, Equatable {
  case authenticity = "authenticity"
  case conditions = "conditions"
  case delivery = "delivery"
  case payment = "payment"
  case other = "other"
  
  public var displayName: String {
    switch self {
    case .authenticity: return "Autenticidade"
    case .conditions: return "Condições"
    case .delivery: return "Entrega"
    case .payment: return "Pagamento"
    case .other: return "Outros"
    }
  }
  
  public var icon: String {
    switch self {
    case .authenticity: return "checkmark.seal.fill"
    case .conditions: return "doc.text.fill"
    case .delivery: return "shippingbox.fill"
    case .payment: return "creditcard.fill"
    case .other: return "ellipsis.circle.fill"
    }
  }
}

#if canImport(SwiftUI)
extension QuestionCategory {
  public var color: Color {
    switch self {
    case .authenticity: return .blue
    case .conditions: return .purple
    case .delivery: return .orange
    case .payment: return .green
    case .other: return .gray
    }
  }
}
#endif

// MARK: - Negotiation Question

public struct NegotiationQuestion: Codable, Identifiable, Equatable {
  public var id: String
  public var negotiationId: String
  public var askedBy: String
  public var questionText: String
  public var category: QuestionCategory
  public var isAnswered: Bool
  public var answer: NegotiationAnswer?
  public var createdAt: Date
  public var answeredAt: Date?
  public var isRead: Bool
  
  public init(
    id: String = UUID().uuidString,
    negotiationId: String,
    askedBy: String = "",
    questionText: String,
    category: QuestionCategory,
    isAnswered: Bool = false,
    answer: NegotiationAnswer? = nil,
    createdAt: Date = Date(),
    answeredAt: Date? = nil,
    isRead: Bool = false
  ) {
    self.id = id
    self.negotiationId = negotiationId
    self.askedBy = askedBy
    self.questionText = questionText
    self.category = category
    self.isAnswered = isAnswered
    self.answer = answer
    self.createdAt = createdAt
    self.answeredAt = answeredAt
    self.isRead = isRead
  }
  
  enum CodingKeys: String, CodingKey {
    case id, category, answer
    case negotiationId = "negotiation_id"
    case askedBy = "asked_by"
    case questionText = "question_text"
    case isAnswered = "is_answered"
    case createdAt = "created_at"
    case answeredAt = "answered_at"
    case isRead = "is_read"
  }
}

// MARK: - Negotiation Answer

public struct NegotiationAnswer: Codable, Identifiable, Equatable {
  public var id: String
  public var questionId: String
  public var negotiationId: String
  public var answerText: String
  public var answeredBy: String
  public var createdAt: Date
  public var updatedAt: Date?
  
  public init(
    id: String = UUID().uuidString,
    questionId: String,
    negotiationId: String,
    answerText: String,
    answeredBy: String,
    createdAt: Date = Date(),
    updatedAt: Date? = nil
  ) {
    self.id = id
    self.questionId = questionId
    self.negotiationId = negotiationId
    self.answerText = answerText
    self.answeredBy = answeredBy
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
  
  enum CodingKeys: String, CodingKey {
    case id, createdAt
    case questionId = "question_id"
    case negotiationId = "negotiation_id"
    case answerText = "answer_text"
    case answeredBy = "answered_by"
    case updatedAt = "updated_at"
  }
}

// MARK: - Document Type

public enum DocumentType: String, Codable, Equatable {
  case ticketPhoto = "ticket_photo"
  case idDocument = "id_document"
  
  public var displayName: String {
    switch self {
    case .ticketPhoto: return "Foto do Ingresso"
    case .idDocument: return "Documento de Identidade"
    }
  }
  
  public var icon: String {
    switch self {
    case .ticketPhoto: return "ticket.fill"
    case .idDocument: return "person.text.rectangle.fill"
    }
  }
}

// MARK: - Negotiation Document

public struct NegotiationDocument: Codable, Identifiable, Equatable {
  public var id: String
  public var negotiationId: String
  public var uploadedBy: String
  public var documentType: DocumentType
  public var fileUrl: String
  public var thumbnailUrl: String?
  public var status: ValidationStatus
  public var uploadedAt: Date
  public var validatedAt: Date?
  public var updatedAt: Date?
  public var isVerified: Bool?
  
  public init(
    id: String = UUID().uuidString,
    negotiationId: String,
    uploadedBy: String = "",
    documentType: DocumentType,
    fileUrl: String,
    thumbnailUrl: String? = nil,
    status: ValidationStatus = .pending,
    uploadedAt: Date = Date(),
    validatedAt: Date? = nil,
    updatedAt: Date? = nil,
    isVerified: Bool? = nil
  ) {
    self.id = id
    self.negotiationId = negotiationId
    self.uploadedBy = uploadedBy
    self.documentType = documentType
    self.fileUrl = fileUrl
    self.thumbnailUrl = thumbnailUrl
    self.status = status
    self.uploadedAt = uploadedAt
    self.validatedAt = validatedAt
    self.updatedAt = updatedAt
    self.isVerified = isVerified
  }
  
  enum CodingKeys: String, CodingKey {
    case id, status
    case negotiationId = "negotiation_id"
    case uploadedBy = "uploaded_by"
    case documentType = "document_type"
    case fileUrl = "file_url"
    case thumbnailUrl = "thumbnail_url"
    case uploadedAt = "uploaded_at"
    case validatedAt = "validated_at"
    case updatedAt = "updated_at"
    case isVerified = "is_verified"
  }
}

