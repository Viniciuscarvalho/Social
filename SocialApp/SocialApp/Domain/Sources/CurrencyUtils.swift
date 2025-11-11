import Foundation

// MARK: - Currency Utilities

public struct CurrencyUtils {
    
    // MARK: - Currency Information
    
    public enum Currency: String, CaseIterable {
        case BRL = "BRL"
        case USD = "USD"
        case EUR = "EUR"
        
        public var symbol: String {
            switch self {
            case .BRL: return "R$"
            case .USD: return "$"
            case .EUR: return "€"
            }
        }
        
        public var name: String {
            switch self {
            case .BRL: return "Real Brasileiro"
            case .USD: return "Dólar Americano"
            case .EUR: return "Euro"
            }
        }
        
        public var flag: String {
            switch self {
            case .BRL: return "🇧🇷"
            case .USD: return "🇺🇸"
            case .EUR: return "🇪🇺"
            }
        }
        
        public var locale: Locale {
            switch self {
            case .BRL: return Locale(identifier: "pt_BR")
            case .USD: return Locale(identifier: "en_US")
            case .EUR: return Locale(identifier: "de_DE")
            }
        }
    }
    
    // MARK: - Formatting
    
    /// Formata um valor numérico para moeda
    public static func format(_ value: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        
        if let currency = Currency(rawValue: currencyCode) {
            formatter.locale = currency.locale
        } else {
            formatter.locale = Locale.current
        }
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    /// Formata um valor com símbolo customizado
    public static func formatWithSymbol(_ value: Double, currencyCode: String) -> String {
        guard let currency = Currency(rawValue: currencyCode) else {
            return format(value, currencyCode: currencyCode)
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.locale = currency.locale
        
        if let formattedNumber = numberFormatter.string(from: NSNumber(value: value)) {
            return "\(currency.symbol) \(formattedNumber)"
        }
        
        return "\(currency.symbol) \(value)"
    }
    
    // MARK: - Parsing
    
    /// Converte uma string de preço para Double
    /// Suporta formatos: "R$ 120,00", "120,00", "120.00", "$120.00"
    public static func parse(_ priceString: String) -> Double? {
        // Remove espaços e símbolos de moeda
        var cleaned = priceString.trimmingCharacters(in: .whitespaces)
        cleaned = cleaned.replacingOccurrences(of: "R$", with: "")
        cleaned = cleaned.replacingOccurrences(of: "$", with: "")
        cleaned = cleaned.replacingOccurrences(of: "€", with: "")
        cleaned = cleaned.trimmingCharacters(in: .whitespaces)
        
        // Remove tudo exceto números, vírgula e ponto
        cleaned = cleaned.replacingOccurrences(of: "[^0-9,.]", with: "", options: .regularExpression)
        
        // Formato brasileiro: 1.200,50
        if cleaned.contains(",") {
            let parts = cleaned.components(separatedBy: ",")
            if parts.count == 2 {
                let integerPart = parts[0].replacingOccurrences(of: ".", with: "")
                let decimalPart = parts[1]
                if let value = Double("\(integerPart).\(decimalPart)") {
                    return value
                }
            }
        }
        
        // Formato americano: 1,200.50 ou 120.50
        if cleaned.contains(".") {
            let parts = cleaned.components(separatedBy: ".")
            if parts.count == 2 {
                // Se a parte decimal tem 2 dígitos, é formato americano
                if parts[1].count == 2 {
                    let integerPart = parts[0].replacingOccurrences(of: ",", with: "")
                    return Double("\(integerPart).\(parts[1])")
                }
            }
        }
        
        // Tenta conversão direta
        return Double(cleaned)
    }
    
    // MARK: - Validation
    
    /// Valida se uma string representa um valor monetário válido
    public static func isValid(_ priceString: String) -> Bool {
        guard let value = parse(priceString) else {
            return false
        }
        return value >= 0
    }
    
    /// Valida se o preço está dentro de um range
    public static func isValid(_ priceString: String, min: Double, max: Double) -> Bool {
        guard let value = parse(priceString) else {
            return false
        }
        return value >= min && value <= max
    }
    
    // MARK: - Conversion
    
    /// Calcula a porcentagem de desconto
    public static func discountPercentage(original: Double, current: Double) -> Double {
        guard original > 0, current < original else { return 0 }
        return ((original - current) / original) * 100
    }
    
    /// Aplica desconto percentual
    public static func applyDiscount(_ value: Double, discount: Double) -> Double {
        return value * (1 - discount / 100)
    }
    
    /// Calcula o total de um preço multiplicado por quantidade
    public static func calculateTotal(price: Double, quantity: Int) -> Double {
        return price * Double(quantity)
    }
}

// MARK: - Currency Extension for String

public extension String {
    /// Converte string para valor monetário
    var currencyValue: Double? {
        return CurrencyUtils.parse(self)
    }
    
    /// Verifica se string é um valor monetário válido
    var isValidCurrency: Bool {
        return CurrencyUtils.isValid(self)
    }
}

// MARK: - Currency Extension for Double

public extension Double {
    /// Formata Double como moeda
    func formatted(currency: String) -> String {
        return CurrencyUtils.format(self, currencyCode: currency)
    }
    
    /// Formata Double como moeda com símbolo
    func formattedWithSymbol(currency: String) -> String {
        return CurrencyUtils.formatWithSymbol(self, currencyCode: currency)
    }
}




