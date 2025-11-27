import Foundation
import Domain

// MARK: - API Ticket Detail Response

public struct APITicketDetailResponse: Codable {
    public let id: String
    public let ticketId: String? // Agora opcional pois nem sempre a API retorna
    public let ticket_id: String? // Para compatibilidade com snake_case
    public let event: APIEventResponse
    public let seller: APIUserResponse
    public let name: String?
    public let description: String?
    public let price: Double
    public let quantity: Int
    public let currencyCode: String?
    public let currency_code: String? // Para compatibilidade com snake_case
    public let ticketType: String?
    public let ticket_type: String? // Para compatibilidade com snake_case
    public let validUntil: String?
    public let valid_until: String? // Para compatibilidade com snake_case
    public let isTransferable: Bool?
    public let is_transferable: Bool? // Para compatibilidade com snake_case
    public let qrCode: String?
    public let qr_code: String? // Para compatibilidade com snake_case
    public let purchaseDate: String?
    public let purchase_date: String? // Para compatibilidade com snake_case
    public let imageUrls: [String]?
    public let image_urls: [String]? // Para compatibilidade com snake_case
    public let status: String
    
    // Custom init para decodificação flexível
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        ticketId = try? container.decode(String.self, forKey: .ticketId)
        ticket_id = try? container.decode(String.self, forKey: .ticket_id)
        event = try container.decode(APIEventResponse.self, forKey: .event)
        seller = try container.decode(APIUserResponse.self, forKey: .seller)
        name = try? container.decode(String.self, forKey: .name)
        description = try? container.decode(String.self, forKey: .description)
        price = try container.decode(Double.self, forKey: .price)
        quantity = (try? container.decode(Int.self, forKey: .quantity)) ?? 1
        currencyCode = try? container.decode(String.self, forKey: .currencyCode)
        currency_code = try? container.decode(String.self, forKey: .currency_code)
        ticketType = try? container.decode(String.self, forKey: .ticketType)
        ticket_type = try? container.decode(String.self, forKey: .ticket_type)
        validUntil = try? container.decode(String.self, forKey: .validUntil)
        valid_until = try? container.decode(String.self, forKey: .valid_until)
        isTransferable = try? container.decode(Bool.self, forKey: .isTransferable)
        is_transferable = try? container.decode(Bool.self, forKey: .is_transferable)
        qrCode = try? container.decode(String.self, forKey: .qrCode)
        qr_code = try? container.decode(String.self, forKey: .qr_code)
        purchaseDate = try? container.decode(String.self, forKey: .purchaseDate)
        purchase_date = try? container.decode(String.self, forKey: .purchase_date)
        imageUrls = try? container.decode([String].self, forKey: .imageUrls)
        image_urls = try? container.decode([String].self, forKey: .image_urls)
        status = (try? container.decode(String.self, forKey: .status)) ?? "available"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, ticketId, ticket_id, event, seller, name, description, price, quantity
        case currencyCode, currency_code, ticketType, ticket_type, validUntil, valid_until
        case isTransferable, is_transferable, qrCode, qr_code
        case purchaseDate, purchase_date, imageUrls, image_urls, status
    }
    
    // Computed properties para conversão
    public var finalTicketId: String {
        // Usa ticketId, depois ticket_id, depois id como fallback
        return ticketId ?? ticket_id ?? id
    }
    
    public var finalTicketType: String {
        return ticketType ?? ticket_type ?? "general"
    }
    
    public var finalValidUntil: String {
        return validUntil ?? valid_until ?? ""
    }
    
    public var finalIsTransferable: Bool {
        return isTransferable ?? is_transferable ?? true
    }
    
    public var finalQrCode: String? {
        return qrCode ?? qr_code
    }
    
    public var finalPurchaseDate: String? {
        return purchaseDate ?? purchase_date
    }
    
    public var finalCurrencyCode: String {
        return currencyCode ?? currency_code ?? "BRL"
    }
    
    public var finalImageUrls: [String]? {
        return imageUrls ?? image_urls
    }
}

// MARK: - Sellers API Models

/// Resposta da API para listar vendedores por evento
/// Endpoint: GET /api/v1/events/{eventId}/sellers
public struct APISellersByEventResponse: Codable {
    public let sellers: [APISellerSummary]?
    
    public init(sellers: [APISellerSummary]?) {
        self.sellers = sellers
    }
}

/// Resumo de vendedor com informações agregadas de tickets
public struct APISellerSummary: Codable {
    public let id: String
    public let name: String
    public let photo: String?
    public let profile_image_url: String? // Para compatibilidade com snake_case
    public let ticketsCount: Int?
    public let tickets_count: Int? // Para compatibilidade com snake_case
    public let minPrice: Double?
    public let min_price: Double? // Para compatibilidade com snake_case
    public let maxPrice: Double?
    public let max_price: Double? // Para compatibilidade com snake_case
    public let isVerified: Bool?
    public let is_verified: Bool? // Para compatibilidade com snake_case
    
    // Computed properties
    public var finalPhoto: String? {
        return photo ?? profile_image_url
    }
    
    public var finalTicketsCount: Int {
        return ticketsCount ?? tickets_count ?? 0
    }
    
    public var finalMinPrice: Double {
        return minPrice ?? min_price ?? 0.0
    }
    
    public var finalMaxPrice: Double {
        return maxPrice ?? max_price ?? 0.0
    }
    
    public var finalIsVerified: Bool {
        return isVerified ?? is_verified ?? false
    }
}

/// Resposta da API para listar ingressos por vendedor
/// Endpoint: GET /api/v1/sellers/{sellerId}/tickets
public struct APITicketsBySellerResponse: Codable {
    public let tickets: [APITicketResponse]?
    
    public init(tickets: [APITicketResponse]?) {
        self.tickets = tickets
    }
}

// MARK: - Mappers

extension APITicketDetailResponse {
    public func toTicketDetail() -> TicketDetail {
        var ticketDetail = TicketDetail(
            ticketId: self.finalTicketId,
            event: self.event.toEvent(),
            seller: self.seller.toUser(),
            name: self.name,
            description: self.description,
            price: self.price,
            quantity: self.quantity,
            currencyCode: self.finalCurrencyCode,
            ticketType: TicketType(rawValue: self.finalTicketType) ?? .general,
            validUntil: Date(), // Placeholder, será substituído abaixo
            imageUrls: self.finalImageUrls
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

