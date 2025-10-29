import Foundation

/// Sistema de cache para perfis de vendedores
/// Armazena dados do vendedor e seus tickets em memória para evitar requests desnecessários
actor SellerProfileCache {
    static let shared = SellerProfileCache()
    
    private var cache: [String: CachedProfile] = [:]
    private let cacheValidityDuration: TimeInterval = 1800 // 30 minutos
    
    private init() {}
    
    struct CachedProfile {
        let sellerId: String
        let seller: User
        let tickets: [TicketWithEvent]
        let timestamp: Date
        
        var isValid: Bool {
            Date().timeIntervalSince(timestamp) < 1800
        }
        
        var age: TimeInterval {
            Date().timeIntervalSince(timestamp)
        }
    }
    
    /// Busca dados do cache
    func getCachedProfile(for sellerId: String) -> CachedProfile? {
        guard let cached = cache[sellerId], cached.isValid else {
            return nil
        }
        return cached
    }
    
    /// Armazena dados no cache
    func cacheProfile(sellerId: String, seller: User, tickets: [TicketWithEvent]) {
        let cached = CachedProfile(
            sellerId: sellerId,
            seller: seller,
            tickets: tickets,
            timestamp: Date()
        )
        cache[sellerId] = cached
    }
    
    /// Invalida cache de um vendedor específico
    func invalidateCache(for sellerId: String) {
        cache.removeValue(forKey: sellerId)
    }
    
    /// Limpa todo o cache
    func clearAll() {
        cache.removeAll()
    }
    
    /// Verifica se existe cache válido
    func hasValidCache(for sellerId: String) -> Bool {
        guard let cached = cache[sellerId] else {
            return false
        }
        return cached.isValid
    }
}

