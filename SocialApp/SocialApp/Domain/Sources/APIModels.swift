import Foundation

// MARK: - API Wrapper Response Models
// A API pode retornar dados envolvidos em estruturas wrapper

public struct APIListResponse<T: Codable>: Codable {
    let data: [T]?
    let items: [T]?
    let results: [T]?
    let tickets: [T]? // Para endpoint específico de tickets
    let events: [T]?  // Para endpoint específico de events
    let users: [T]?   // Para endpoint específico de users
    let success: Bool?
    let message: String?
    
    // Computed property para obter os dados independente da estrutura
    var finalData: [T] {
        return data ?? items ?? results ?? tickets ?? events ?? users ?? []
    }
}

public struct APISingleResponse<T: Codable>: Codable {
    let data: T?
    let item: T?
    let result: T?
    let ticket: T?  // Para endpoint específico de ticket
    let event: T?   // Para endpoint específico de event
    let user: T?    // Para endpoint específico de user
    let success: Bool?
    let message: String?
    
    // Computed property para obter o dado independente da estrutura
    var finalData: T? {
        return data ?? item ?? result ?? ticket ?? event ?? user
    }
}

// MARK: - API Response Models
// Estes modelos representam exatamente a estrutura que a API retorna

public struct APIEventResponse: Codable {
    let id: String
    let name: String
    let description: String?
    let imageURL: String?
    let image_url: String? // Para compatibilidade com snake_case
    let startPrice: Double?
    let start_price: Double? // Para compatibilidade com snake_case  
    let location: APILocationResponse
    let category: String
    let isRecommended: Bool?
    let is_recommended: Bool? // Para compatibilidade com snake_case
    let rating: Double?
    let reviewCount: Int?
    let review_count: Int? // Para compatibilidade com snake_case
    let createdAt: String?
    let created_at: String? // Para compatibilidade com snake_case
    let eventDate: String?
    let event_date: String? // Para compatibilidade com snake_case
    
    // Computed properties para conversão
    var finalImageURL: String? {
        return imageURL ?? image_url
    }
    
    var finalStartPrice: Double {
        return startPrice ?? start_price ?? 0.0
    }
    
    var finalIsRecommended: Bool {
        return isRecommended ?? is_recommended ?? false
    }
    
    var finalReviewCount: Int? {
        return reviewCount ?? review_count
    }
    
    var finalCreatedAt: String? {
        return createdAt ?? created_at
    }
    
    var finalEventDate: String? {
        return eventDate ?? event_date
    }
}

public struct APILocationResponse: Codable {
    let name: String
    let address: String?
    let city: String
    let state: String
    let country: String
    let coordinate: APICoordinateResponse?
    let coordinates: APICoordinateResponse? // Para compatibilidade
    
    var finalCoordinate: APICoordinateResponse {
        return coordinate ?? coordinates ?? APICoordinateResponse(latitude: 0.0, longitude: 0.0)
    }
}

public struct APICoordinateResponse: Codable {
    let latitude: Double
    let longitude: Double
}

public struct APITicketResponse: Codable {
    let id: String
    let eventId: String?
    let event_id: String? // Para compatibilidade com snake_case
    let sellerId: String?
    let seller_id: String? // Para compatibilidade com snake_case
    let name: String
    let price: Double
    let originalPrice: Double?
    let original_price: Double? // Para compatibilidade com snake_case
    let ticketType: String?
    let ticket_type: String? // Para compatibilidade com snake_case
    let status: String
    let validUntil: String?
    let valid_until: String? // Para compatibilidade com snake_Case
    let createdAt: String?
    let created_at: String? // Para compatibilidade com snake_case
    let isFavorited: Bool?
    let is_favorited: Bool? // Para compatibilidade com snake_case
    
    // Computed properties para conversão
    var finalEventId: String {
        return eventId ?? event_id ?? ""
    }
    
    var finalSellerId: String {
        return sellerId ?? seller_id ?? ""
    }
    
    var finalOriginalPrice: Double? {
        return originalPrice ?? original_price
    }
    
    var finalTicketType: String {
        return ticketType ?? ticket_type ?? "general"
    }
    
    var finalValidUntil: String {
        return validUntil ?? valid_until ?? ""
    }
    
    var finalCreatedAt: String {
        return createdAt ?? created_at ?? ""
    }
    
    var finalIsFavorited: Bool {
        return isFavorited ?? is_favorited ?? false
    }
}

// MARK: - TicketDetail API Response Model

public struct APITicketDetailResponse: Codable {
    let id: String
    let ticketId: String // ✅ Campo que estava causando o erro de decodificação
    let ticket_id: String? // Para compatibilidade com snake_case
    let event: APIEventResponse
    let seller: APIUserResponse
    let price: Double
    let quantity: Int
    let ticketType: String?
    let ticket_type: String? // Para compatibilidade com snake_case
    let validUntil: String?
    let valid_until: String? // Para compatibilidade com snake_case
    let isTransferable: Bool?
    let is_transferable: Bool? // Para compatibilidade com snake_case
    let qrCode: String?
    let qr_code: String? // Para compatibilidade com snake_case
    let purchaseDate: String?
    let purchase_date: String? // Para compatibilidade com snake_case
    let status: String
    
    // Computed properties para conversão
    var finalTicketId: String {
        return ticketId.isEmpty ? (ticket_id ?? id) : ticketId
    }
    
    var finalTicketType: String {
        return ticketType ?? ticket_type ?? "general"
    }
    
    var finalValidUntil: String {
        return validUntil ?? valid_until ?? ""
    }
    
    var finalIsTransferable: Bool {
        return isTransferable ?? is_transferable ?? true
    }
    
    var finalQrCode: String? {
        return qrCode ?? qr_code
    }
    
    var finalPurchaseDate: String? {
        return purchaseDate ?? purchase_date
    }
}

public struct APIUserResponse: Codable {
    let id: String
    let name: String
    let title: String?
    let profileImageURL: String?
    let profile_image_url: String? // Para compatibilidade com snake_case
    let email: String?
    let followersCount: Int?
    let followers_count: Int? // Para compatibilidade com snake_case
    let followingCount: Int?
    let following_count: Int? // Para compatibilidade com snake_case
    let ticketsCount: Int?
    let tickets_count: Int? // Para compatibilidade com snake_case
    let isVerified: Bool?
    let is_verified: Bool? // Para compatibilidade com snake_case
    let tickets: [APITicketResponse]?
    let createdAt: String?
    let created_at: String? // Para compatibilidade com snake_case
    
    // Computed properties para conversão
    var finalProfileImageURL: String? {
        return profileImageURL ?? profile_image_url
    }
    
    var finalFollowersCount: Int {
        return followersCount ?? followers_count ?? 0
    }
    
    var finalFollowingCount: Int {
        return followingCount ?? following_count ?? 0
    }
    
    var finalTicketsCount: Int {
        return ticketsCount ?? tickets_count ?? 0
    }
    
    var finalIsVerified: Bool {
        return isVerified ?? is_verified ?? false
    }
    
    var finalCreatedAt: String? {
        return createdAt ?? created_at
    }
}

// MARK: - Mappers para conversão dos modelos da API para os modelos de domínio

extension APIEventResponse {
    func toEvent() -> Event {
        var event = Event(
            name: self.name,
            description: self.description,
            imageURL: self.finalImageURL,
            startPrice: self.finalStartPrice,
            location: self.location.toLocation(),
            category: EventCategory(rawValue: self.category) ?? .culture,
            isRecommended: self.finalIsRecommended
        )
        
        event.id = self.id
        event.rating = self.rating
        event.reviewCount = self.finalReviewCount
        
        // Parse das datas
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Tenta diferentes formatos de data
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ", // ISO 8601 com milissegundos
            "yyyy-MM-dd'T'HH:mm:ssZ",     // ISO 8601 sem milissegundos
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", // ISO 8601 com milissegundos e Z literal
            "yyyy-MM-dd'T'HH:mm:ss'Z'",   // ISO 8601 sem milissegundos e Z literal
            "yyyy-MM-dd HH:mm:ss",        // Formato simples
            "yyyy-MM-dd"                  // Apenas data
        ]
        
        if let createdAtString = self.finalCreatedAt {
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: createdAtString) {
                    event.createdAt = date
                    break
                }
            }
        }
        
        if let eventDateString = self.finalEventDate {
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: eventDateString) {
                    event.eventDate = date
                    break
                }
            }
        }
        
        return event
    }
}

extension APILocationResponse {
    func toLocation() -> Location {
        return Location(
            name: self.name,
            address: self.address,
            city: self.city,
            state: self.state,
            country: self.country,
            coordinate: self.finalCoordinate.toCoordinate()
        )
    }
}

extension APICoordinateResponse {
    func toCoordinate() -> Coordinate {
        return Coordinate(latitude: self.latitude, longitude: self.longitude)
    }
}

extension APITicketResponse {
    func toTicket() -> Ticket {
        var ticket = Ticket(
            eventId: self.finalEventId,
            sellerId: self.finalSellerId,
            name: self.name,
            price: self.price,
            ticketType: TicketType(rawValue: self.finalTicketType) ?? .general,
            validUntil: Date() // Placeholder, será substituído abaixo
        )
        
        ticket.id = self.id
        ticket.originalPrice = self.finalOriginalPrice
        ticket.status = TicketStatus(rawValue: self.status) ?? .available
        ticket.isFavorited = self.finalIsFavorited
        
        // Parse das datas
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        if !self.finalValidUntil.isEmpty {
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: self.finalValidUntil) {
                    ticket.validUntil = date
                    break
                }
            }
        }
        
        if !self.finalCreatedAt.isEmpty {
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: self.finalCreatedAt) {
                    ticket.createdAt = date
                    break
                }
            }
        }
        
        return ticket
    }
}

extension APIUserResponse {
    func toUser() -> User {
        var user = User(
            name: self.name,
            title: self.title,
            profileImageURL: self.finalProfileImageURL,
            email: self.email
        )
        
        user.id = self.id
        user.followersCount = self.finalFollowersCount
        user.followingCount = self.finalFollowingCount
        user.ticketsCount = self.finalTicketsCount
        user.isVerified = self.finalIsVerified
        
        // Converte os tickets se existirem
        if let apiTickets = self.tickets {
            user.tickets = apiTickets.map { $0.toTicket() }
        }
        
        // Parse da data de criação
        if let createdAtString = self.finalCreatedAt, !createdAtString.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            let dateFormats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                "yyyy-MM-dd'T'HH:mm:ssZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                "yyyy-MM-dd'T'HH:mm:ss'Z'",
                "yyyy-MM-dd HH:mm:ss",
                "yyyy-MM-dd"
            ]
            
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: createdAtString) {
                    user.createdAt = date
                    break
                }
            }
        }
        
        return user
    }
}

// MARK: - APITicketDetailResponse Extension

extension APITicketDetailResponse {
    func toTicketDetail() -> TicketDetail {
        var ticketDetail = TicketDetail(
            ticketId: self.finalTicketId,
            event: self.event.toEvent(),
            seller: self.seller.toUser(),
            price: self.price,
            quantity: self.quantity,
            ticketType: TicketType(rawValue: self.finalTicketType) ?? .general,
            validUntil: Date() // Placeholder, será substituído abaixo
        )
        
        ticketDetail.id = self.id
        ticketDetail.isTransferable = self.finalIsTransferable
        ticketDetail.qrCode = self.finalQrCode
        ticketDetail.status = TicketStatus(rawValue: self.status) ?? .available
        
        // Parse das datas
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        if !self.finalValidUntil.isEmpty {
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: self.finalValidUntil) {
                    ticketDetail.validUntil = date
                    break
                }
            }
        }
        
        if let purchaseDateString = self.finalPurchaseDate, !purchaseDateString.isEmpty {
            for format in dateFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: purchaseDateString) {
                    ticketDetail.purchaseDate = date
                    break
                }
            }
        }
        
        return ticketDetail
    }
}

// MARK: - Request Models

public struct PurchaseTicketRequest: Codable {
    let ticketId: String
    
    enum CodingKeys: String, CodingKey {
        case ticketId = "ticket_id"
    }
}

public struct FavoriteTicketRequest: Codable {
    let ticketId: String
    
    enum CodingKeys: String, CodingKey {
        case ticketId = "ticket_id"
    }
}

public struct UserUpdateRequest: Codable {
    let name: String?
    let title: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case title
        case email
    }
}
