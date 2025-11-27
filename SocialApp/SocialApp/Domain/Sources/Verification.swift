import Foundation

// MARK: - Verification Level

public enum VerificationLevel: String, Codable, Equatable {
  case unverified = "unverified"
  case emailVerified = "email_verified"
  case phoneVerified = "phone_verified"
  case documentVerified = "document_verified"
  case fullyVerified = "fully_verified"
  
  public var displayName: String {
    switch self {
    case .unverified: return "Não Verificado"
    case .emailVerified: return "E-mail Verificado"
    case .phoneVerified: return "Telefone Verificado"
    case .documentVerified: return "Documento Verificado"
    case .fullyVerified: return "Totalmente Verificado"
    }
  }
  
  public var level: Int {
    switch self {
    case .unverified: return 0
    case .emailVerified: return 1
    case .phoneVerified: return 2
    case .documentVerified: return 3
    case .fullyVerified: return 4
    }
  }
  
  public var canNegotiate: Bool {
    return level >= 1
  }
}

// MARK: - User Verification Domain Model

public struct UserVerification: Codable, Identifiable, Equatable {
  public var id: String
  public var emailVerified: Bool
  public var emailVerifiedAt: Date?
  public var phoneVerified: Bool
  public var phoneVerifiedAt: Date?
  public var phoneNumber: String?
  public var documentType: String?
  public var documentFileUrl: String?
  public var documentVerified: Bool
  public var documentVerifiedAt: Date?
  public var documentVerifiedBy: String?
  public var verificationLevel: VerificationLevel
  public var trustScore: Int
  public var createdAt: Date
  public var updatedAt: Date
  
  public init(
    id: String = UUID().uuidString,
    emailVerified: Bool = false,
    emailVerifiedAt: Date? = nil,
    phoneVerified: Bool = false,
    phoneVerifiedAt: Date? = nil,
    phoneNumber: String? = nil,
    documentType: String? = nil,
    documentFileUrl: String? = nil,
    documentVerified: Bool = false,
    documentVerifiedAt: Date? = nil,
    documentVerifiedBy: String? = nil,
    verificationLevel: VerificationLevel = .unverified,
    trustScore: Int = 0,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.id = id
    self.emailVerified = emailVerified
    self.emailVerifiedAt = emailVerifiedAt
    self.phoneVerified = phoneVerified
    self.phoneVerifiedAt = phoneVerifiedAt
    self.phoneNumber = phoneNumber
    self.documentType = documentType
    self.documentFileUrl = documentFileUrl
    self.documentVerified = documentVerified
    self.documentVerifiedAt = documentVerifiedAt
    self.documentVerifiedBy = documentVerifiedBy
    self.verificationLevel = verificationLevel
    self.trustScore = trustScore
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
  
  public var canNegotiate: Bool {
    return verificationLevel.canNegotiate
  }
  
  enum CodingKeys: String, CodingKey {
    case id
    case emailVerified = "email_verified"
    case emailVerifiedAt = "email_verified_at"
    case phoneVerified = "phone_verified"
    case phoneVerifiedAt = "phone_verified_at"
    case phoneNumber = "phone_number"
    case documentType = "document_type"
    case documentFileUrl = "document_file_url"
    case documentVerified = "document_verified"
    case documentVerifiedAt = "document_verified_at"
    case documentVerifiedBy = "document_verified_by"
    case verificationLevel = "verification_level"
    case trustScore = "trust_score"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
}

// MARK: - Validation Status

public enum ValidationStatus: String, Codable, Equatable {
  case pending = "pending"
  case approved = "approved"
  case rejected = "rejected"
  case inReview = "in_review"
  
  public var displayName: String {
    switch self {
    case .pending: return "Aguardando Envio"
    case .approved: return "Aprovado"
    case .rejected: return "Rejeitado"
    case .inReview: return "Em Análise"
    }
  }
  
  public var iconName: String {
    switch self {
    case .pending: return "clock.fill"
    case .approved: return "checkmark.seal.fill"
    case .rejected: return "xmark.seal.fill"
    case .inReview: return "magnifyingglass"
    }
  }
}

// MARK: - Ticket Validation Domain Model

public struct TicketValidation: Codable, Identifiable, Equatable {
  public var id: String
  public var ticketId: String
  public var sellerId: String
  public var status: ValidationStatus
  public var submittedAt: Date?
  public var validatedAt: Date?
  public var validatedBy: String?
  public var autoValidationScore: Int?
  public var rejectionReason: String?
  public var adminNotes: String?
  public var createdAt: Date
  public var updatedAt: Date
  public var proofs: [ValidationProof]?
  
  public init(
    id: String = UUID().uuidString,
    ticketId: String,
    sellerId: String,
    status: ValidationStatus = .pending,
    submittedAt: Date? = nil,
    validatedAt: Date? = nil,
    validatedBy: String? = nil,
    autoValidationScore: Int? = nil,
    rejectionReason: String? = nil,
    adminNotes: String? = nil,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.id = id
    self.ticketId = ticketId
    self.sellerId = sellerId
    self.status = status
    self.submittedAt = submittedAt
    self.validatedAt = validatedAt
    self.validatedBy = validatedBy
    self.autoValidationScore = autoValidationScore
    self.rejectionReason = rejectionReason
    self.adminNotes = adminNotes
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
  
  enum CodingKeys: String, CodingKey {
    case id, status
    case ticketId = "ticket_id"
    case sellerId = "seller_id"
    case submittedAt = "submitted_at"
    case validatedAt = "validated_at"
    case validatedBy = "validated_by"
    case autoValidationScore = "auto_validation_score"
    case rejectionReason = "rejection_reason"
    case adminNotes = "admin_notes"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case proofs
  }
}

// MARK: - Validation Proof Domain Model

public struct ValidationProof: Codable, Identifiable, Equatable {
  public var id: String
  public var validationId: String
  public var proofType: String
  public var fileUrl: String
  public var uploadedAt: Date
  public var isVerified: Bool
  public var moderatedAt: Date?
  public var moderatedBy: String?
  public var moderationNotes: String?
  
  public init(
    id: String = UUID().uuidString,
    validationId: String,
    proofType: String,
    fileUrl: String,
    uploadedAt: Date = Date(),
    isVerified: Bool = false,
    moderatedAt: Date? = nil,
    moderatedBy: String? = nil,
    moderationNotes: String? = nil
  ) {
    self.id = id
    self.validationId = validationId
    self.proofType = proofType
    self.fileUrl = fileUrl
    self.uploadedAt = uploadedAt
    self.isVerified = isVerified
    self.moderatedAt = moderatedAt
    self.moderatedBy = moderatedBy
    self.moderationNotes = moderationNotes
  }
  
  enum CodingKeys: String, CodingKey {
    case id
    case validationId = "validation_id"
    case proofType = "proof_type"
    case fileUrl = "file_url"
    case uploadedAt = "uploaded_at"
    case isVerified = "is_verified"
    case moderatedAt = "moderated_at"
    case moderatedBy = "moderated_by"
    case moderationNotes = "moderation_notes"
  }
}

