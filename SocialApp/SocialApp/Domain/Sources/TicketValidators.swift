import Foundation

// MARK: - Ticket Validators

public struct TicketValidators {
    
    // MARK: - Name Validation
    
    public struct NameValidation {
        public let isValid: Bool
        public let errorMessage: String?
        
        public init(isValid: Bool, errorMessage: String? = nil) {
            self.isValid = isValid
            self.errorMessage = errorMessage
        }
    }
    
    /// Valida o nome/título do ingresso
    public static func validateName(_ name: String) -> NameValidation {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Verifica se está vazio
        guard !trimmed.isEmpty else {
            return NameValidation(isValid: false, errorMessage: "O título do ingresso é obrigatório")
        }
        
        // Verifica comprimento mínimo
        guard trimmed.count >= 3 else {
            return NameValidation(isValid: false, errorMessage: "O título deve ter pelo menos 3 caracteres")
        }
        
        // Verifica comprimento máximo
        guard trimmed.count <= 60 else {
            return NameValidation(isValid: false, errorMessage: "O título não pode ter mais de 60 caracteres")
        }
        
        return NameValidation(isValid: true)
    }
    
    // MARK: - Description Validation
    
    public struct DescriptionValidation {
        public let isValid: Bool
        public let errorMessage: String?
        
        public init(isValid: Bool, errorMessage: String? = nil) {
            self.isValid = isValid
            self.errorMessage = errorMessage
        }
    }
    
    /// Valida a descrição do ingresso (opcional)
    public static func validateDescription(_ description: String) -> DescriptionValidation {
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Se estiver vazio, é válido (campo opcional)
        if trimmed.isEmpty {
            return DescriptionValidation(isValid: true)
        }
        
        // Verifica comprimento máximo
        guard trimmed.count <= 500 else {
            return DescriptionValidation(isValid: false, errorMessage: "A descrição não pode ter mais de 500 caracteres")
        }
        
        return DescriptionValidation(isValid: true)
    }
    
    // MARK: - Price Validation
    
    public struct PriceValidation {
        public let isValid: Bool
        public let errorMessage: String?
        public let parsedValue: Double?
        
        public init(isValid: Bool, errorMessage: String? = nil, parsedValue: Double? = nil) {
            self.isValid = isValid
            self.errorMessage = errorMessage
            self.parsedValue = parsedValue
        }
    }
    
    /// Valida o preço do ingresso
    public static func validatePrice(_ priceString: String, min: Double = 0.01, max: Double = 999999.99) -> PriceValidation {
        let trimmed = priceString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Verifica se está vazio
        guard !trimmed.isEmpty else {
            return PriceValidation(isValid: false, errorMessage: "O preço é obrigatório")
        }
        
        // Tenta parsear o preço
        guard let price = CurrencyUtils.parse(trimmed) else {
            return PriceValidation(isValid: false, errorMessage: "Formato de preço inválido. Use: 120,00 ou 120.00")
        }
        
        // Verifica se está no range válido
        guard price >= min else {
            return PriceValidation(isValid: false, errorMessage: "O preço deve ser maior que \(CurrencyUtils.format(min, currencyCode: "BRL"))")
        }
        
        guard price <= max else {
            return PriceValidation(isValid: false, errorMessage: "O preço não pode ser maior que \(CurrencyUtils.format(max, currencyCode: "BRL"))")
        }
        
        return PriceValidation(isValid: true, parsedValue: price)
    }
    
    /// Valida o preço original em relação ao preço de venda
    public static func validateOriginalPrice(_ originalPriceString: String, salePrice: Double) -> PriceValidation {
        let trimmed = originalPriceString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Se estiver vazio, é válido (campo opcional)
        if trimmed.isEmpty {
            return PriceValidation(isValid: true)
        }
        
        // Tenta parsear
        guard let originalPrice = CurrencyUtils.parse(trimmed) else {
            return PriceValidation(isValid: false, errorMessage: "Formato de preço original inválido")
        }
        
        // Verifica se é maior que o preço de venda
        guard originalPrice > salePrice else {
            return PriceValidation(isValid: false, errorMessage: "O preço original deve ser maior que o preço de venda")
        }
        
        return PriceValidation(isValid: true, parsedValue: originalPrice)
    }
    
    // MARK: - Quantity Validation
    
    public struct QuantityValidation {
        public let isValid: Bool
        public let errorMessage: String?
        
        public init(isValid: Bool, errorMessage: String? = nil) {
            self.isValid = isValid
            self.errorMessage = errorMessage
        }
    }
    
    /// Valida a quantidade de ingressos
    public static func validateQuantity(_ quantity: Int, min: Int = 1, max: Int = 999) -> QuantityValidation {
        guard quantity >= min else {
            return QuantityValidation(isValid: false, errorMessage: "A quantidade mínima é \(min)")
        }
        
        guard quantity <= max else {
            return QuantityValidation(isValid: false, errorMessage: "A quantidade máxima é \(max)")
        }
        
        return QuantityValidation(isValid: true)
    }
    
    // MARK: - Date Validation
    
    public struct DateValidation {
        public let isValid: Bool
        public let errorMessage: String?
        
        public init(isValid: Bool, errorMessage: String? = nil) {
            self.isValid = isValid
            self.errorMessage = errorMessage
        }
    }
    
    /// Valida a data de validade do ingresso
    public static func validateValidUntil(_ date: Date, minimumHours: Int = 1) -> DateValidation {
        let now = Date()
        
        // Verifica se a data está no passado
        guard date > now else {
            return DateValidation(isValid: false, errorMessage: "A data de validade deve ser no futuro")
        }
        
        // Verifica se há tempo mínimo suficiente
        let minimumDate = Calendar.current.date(byAdding: .hour, value: minimumHours, to: now) ?? now
        guard date >= minimumDate else {
            return DateValidation(isValid: false, errorMessage: "A data de validade deve ser de pelo menos \(minimumHours) hora(s) a partir de agora")
        }
        
        // Verifica se não está muito distante no futuro (2 anos)
        let maxDate = Calendar.current.date(byAdding: .year, value: 2, to: now) ?? date
        guard date <= maxDate else {
            return DateValidation(isValid: false, errorMessage: "A data de validade não pode ser maior que 2 anos")
        }
        
        return DateValidation(isValid: true)
    }
    
    // MARK: - Event ID Validation
    
    public struct EventIDValidation {
        public let isValid: Bool
        public let errorMessage: String?
        
        public init(isValid: Bool, errorMessage: String? = nil) {
            self.isValid = isValid
            self.errorMessage = errorMessage
        }
    }
    
    /// Valida se um evento foi selecionado
    public static func validateEventID(_ eventId: UUID?) -> EventIDValidation {
        guard eventId != nil else {
            return EventIDValidation(isValid: false, errorMessage: "Você deve selecionar um evento")
        }
        
        return EventIDValidation(isValid: true)
    }
    
    // MARK: - Complete Form Validation
    
    public struct FormValidation {
        public let isValid: Bool
        public let errors: [String]
        
        public init(isValid: Bool, errors: [String] = []) {
            self.isValid = isValid
            self.errors = errors
        }
    }
    
    /// Valida um formulário completo de criação de ingresso
    public static func validateTicketForm(
        name: String,
        description: String,
        priceString: String,
        originalPriceString: String,
        quantity: Int,
        validUntil: Date,
        eventId: UUID?
    ) -> FormValidation {
        var errors: [String] = []
        
        // Valida nome
        let nameValidation = validateName(name)
        if !nameValidation.isValid, let error = nameValidation.errorMessage {
            errors.append(error)
        }
        
        // Valida descrição
        let descValidation = validateDescription(description)
        if !descValidation.isValid, let error = descValidation.errorMessage {
            errors.append(error)
        }
        
        // Valida preço
        let priceValidation = validatePrice(priceString)
        if !priceValidation.isValid, let error = priceValidation.errorMessage {
            errors.append(error)
        }
        
        // Valida preço original se fornecido
        if !originalPriceString.isEmpty, let salePrice = priceValidation.parsedValue {
            let originalValidation = validateOriginalPrice(originalPriceString, salePrice: salePrice)
            if !originalValidation.isValid, let error = originalValidation.errorMessage {
                errors.append(error)
            }
        }
        
        // Valida quantidade
        let quantityValidation = validateQuantity(quantity)
        if !quantityValidation.isValid, let error = quantityValidation.errorMessage {
            errors.append(error)
        }
        
        // Valida data
        let dateValidation = validateValidUntil(validUntil)
        if !dateValidation.isValid, let error = dateValidation.errorMessage {
            errors.append(error)
        }
        
        // Valida evento
        let eventValidation = validateEventID(eventId)
        if !eventValidation.isValid, let error = eventValidation.errorMessage {
            errors.append(error)
        }
        
        return FormValidation(isValid: errors.isEmpty, errors: errors)
    }
}






