import Foundation

// Estrutura para armazenar dados do perfil do vendedor em cache
private struct CachedProfileData {
    let seller: User
    let tickets: [TicketWithEvent]
    let timestamp: Date
    
    var age: TimeInterval {
        Date().timeIntervalSince(timestamp)
    }
    
    // Cache válido por 5 minutos
    var isValid: Bool {
        age < 300 // 5 minutos
    }
}

public final class SellerProfileCache {
    public static let shared = SellerProfileCache()
    
    private let queue = DispatchQueue(label: "SellerProfileCache.queue", attributes: .concurrent)
    private var cache: [String: CachedProfileData] = [:]
    
    private struct Keys {
        static let all = "__all__"
    }
    
    private init() {}
    
    // MARK: - Métodos públicos
    
    /// Verifica se existe cache válido para um sellerId
    public func hasValidCache(for sellerId: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            queue.async {
                if let cached = self.cache[sellerId], cached.isValid {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    /// Obtém dados do cache se válidos
    public func getCachedProfile(for sellerId: String) async -> CachedProfileData? {
        return await withCheckedContinuation { continuation in
            queue.async {
                if let cached = self.cache[sellerId], cached.isValid {
                    continuation.resume(returning: cached)
                } else {
                    // Remove cache inválido
                    if self.cache[sellerId] != nil {
                        self.cache.removeValue(forKey: sellerId)
                    }
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    /// Salva perfil do vendedor no cache
    public func cacheProfile(
        sellerId: String,
        seller: User,
        tickets: [TicketWithEvent]
    ) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) {
                let cached = CachedProfileData(
                    seller: seller,
                    tickets: tickets,
                    timestamp: Date()
                )
                self.cache[sellerId] = cached
                continuation.resume()
            }
        }
    }
    
    /// Invalida cache para um sellerId específico
    public func invalidateCache(for sellerId: String) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) {
                self.cache.removeValue(forKey: sellerId)
                continuation.resume()
            }
        }
    }
    
    /// Limpa todo o cache
    public func invalidateAll() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
    
    /// Backwards-compatible name used em alguns pontos do app
    public func clearAll() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) {
                self.cache.removeAll()
                continuation.resume()
            }
        }
    }
    
    // MARK: - Métodos legados (mantidos para compatibilidade)
    
    public func set(_ value: Any?, for sellerId: String) {
        queue.async(flags: .barrier) {
            if value == nil {
                self.cache.removeValue(forKey: sellerId)
            }
            // Método legado - não faz nada se value não for CachedProfileData
        }
    }
    
    public func get(for sellerId: String) -> Any? {
        var value: Any?
        queue.sync {
            value = self.cache[sellerId]
        }
        return value
    }
}


