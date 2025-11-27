import Foundation

// MARK: - Generic API Response Wrappers

public struct APIResponse<T: Codable>: Codable {
  public let data: T
  public let message: String?
  public let success: Bool
  
  public init(data: T, message: String? = nil, success: Bool = true) {
    self.data = data
    self.message = message
    self.success = success
  }
}

public struct APIListResponse<T: Codable>: Codable {
  public let data: [T]
  public let pagination: PaginationInfo?
  public let success: Bool
  public let message: String?
  
  public init(
    data: [T],
    pagination: PaginationInfo? = nil,
    success: Bool = true,
    message: String? = nil
  ) {
    self.data = data
    self.pagination = pagination
    self.success = success
    self.message = message
  }
  
  enum CodingKeys: String, CodingKey {
    case data, pagination, success, message
  }
}

public struct APISingleResponse<T: Codable>: Codable {
  public let data: T
  public let success: Bool
  public let message: String?
  
  public init(data: T, success: Bool = true, message: String? = nil) {
    self.data = data
    self.success = success
    self.message = message
  }
  
  enum CodingKeys: String, CodingKey {
    case data, success, message
  }
}

// MARK: - Error Models

public struct APIError: Error, Codable, Equatable {
  public let message: String
  public let code: Int
  
  public init(message: String, code: Int) {
    self.message = message
    self.code = code
  }
}

public struct APIErrorResponse: Codable {
  public let error: String?
  public let message: String?
  public let details: String?
  public let code: Int?
  public let success: Bool?
  
  public var finalMessage: String {
    return error ?? message ?? details ?? "Erro desconhecido"
  }
  
  public var finalCode: Int {
    return code ?? 400
  }
}

// MARK: - Pagination

public struct PaginationInfo: Codable, Equatable {
  public let total: Int
  public let page: Int
  public let limit: Int
  public let totalPages: Int
  
  public init(total: Int, page: Int = 1, limit: Int = 20, totalPages: Int = 1) {
    self.total = total
    self.page = page
    self.limit = limit
    self.totalPages = totalPages
  }
  
  enum CodingKeys: String, CodingKey {
    case total, page, limit
    case totalPages = "total_pages"
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    total = (try? container.decode(Int.self, forKey: .total)) ?? 0
    page = (try? container.decode(Int.self, forKey: .page)) ?? 1
    limit = (try? container.decode(Int.self, forKey: .limit)) ?? 20
    totalPages = (try? container.decode(Int.self, forKey: .totalPages)) ?? 1
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(total, forKey: .total)
    try container.encode(page, forKey: .page)
    try container.encode(limit, forKey: .limit)
    try container.encode(totalPages, forKey: .totalPages)
  }
}

