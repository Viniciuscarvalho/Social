import ComposableArchitecture
import Foundation

// MARK: - Ticket Creation Steps

public enum TicketCreationStep: Int, CaseIterable, Equatable {
    case details = 0      // Etapa 1: Detalhes (eventId, título, descrição)
    case pricing = 1      // Etapa 2: Preço e Quantidade
    case validity = 2     // Etapa 3: Validade
    case media = 3        // Etapa 4: Mídia (opcional)
    case review = 4       // Etapa 5: Revisão e Publicação
    
    public var title: String {
        switch self {
        case .details: return "Detalhes do Ingresso"
        case .pricing: return "Preço e Quantidade"
        case .validity: return "Validade"
        case .media: return "Fotos (Opcional)"
        case .review: return "Revisão"
        }
    }
    
    public var description: String {
        switch self {
        case .details: return "Informe o evento e os detalhes do ingresso"
        case .pricing: return "Defina o preço e a quantidade disponível"
        case .validity: return "Escolha a data de validade do ingresso"
        case .media: return "Adicione fotos do ingresso (opcional)"
        case .review: return "Revise e publique seu ingresso"
        }
    }
}

@Reducer
public struct AddTicketFeature {
    @ObservableState
    public struct State: Equatable {
        // Step Management
        public var currentStep: TicketCreationStep = .details
        
        // Ticket Data
        public var ticketName: String = ""
        public var ticketType: TicketType = .general
        public var price: String = ""
        public var originalPrice: String = ""
        public var description: String = ""
        public var selectedEventId: UUID?
        public var quantity: Int = 1
        public var currencyCode: String = "BRL"
        public var validUntil: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        public var selectedImageUrls: [String] = []
        
        // UI State
        public var availableEvents: [Event] = []
        public var isLoadingEvents: Bool = false
        public var isPublishing: Bool = false
        public var errorMessage: String?
        public var publishSuccess: Bool = false
        
        // Step Validation
        public var isCurrentStepValid: Bool {
            switch currentStep {
            case .details:
                return isDetailsStepValid
            case .pricing:
                return isPricingStepValid
            case .validity:
                return isValidityStepValid
            case .media:
                return true // Mídia é opcional
            case .review:
                return isFormValid
            }
        }
        
        public var isDetailsStepValid: Bool {
            return !ticketName.isEmpty && selectedEventId != nil
        }
        
        public var isPricingStepValid: Bool {
            guard !price.isEmpty,
                  let priceValue = AddTicketFeature.parsePrice(price),
                  priceValue > 0 else {
                return false
            }
            
            // Validar originalPrice se fornecido
            if !originalPrice.isEmpty {
                guard let originalPriceValue = AddTicketFeature.parsePrice(originalPrice),
                      originalPriceValue > priceValue else {
                    return false
                }
            }
            
            return quantity > 0
        }
        
        public var isValidityStepValid: Bool {
            return validUntil > Date()
        }
        
        public var isFormValid: Bool {
            return isDetailsStepValid && 
                   isPricingStepValid && 
                   isValidityStepValid
        }
        
        // Navigation
        public var canGoNext: Bool {
            return isCurrentStepValid && currentStep != .review
        }
        
        public var canGoBack: Bool {
            return currentStep != .details
        }
        
        public init(selectedEventId: UUID? = nil) {
            self.selectedEventId = selectedEventId
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case loadEvents
        case eventsLoaded([Event])
        case eventsLoadFailed(String)
        
        // Step Navigation
        case nextStep
        case previousStep
        case goToStep(TicketCreationStep)
        
        // Publishing
        case publishTicket
        case publishTicketResponse(Result<Ticket, APIError>)
        case dismissSuccess
        case setSelectedEventId(UUID?)
        case clearError
    }
    
    @Dependency(\.ticketsClient) var ticketsClient
    @Dependency(\.userClient) var userClient
    @Dependency(\.eventsClient) var eventsClient
    
    public init() {}
    
    // Função estática para parsear preço brasileiro (R$ 120,00 -> 120.0)
    public static func parsePrice(_ priceString: String) -> Double? {
        // Remove caracteres não numéricos exceto vírgula e ponto
        let cleaned = priceString.replacingOccurrences(of: "[^0-9,.]", with: "", options: .regularExpression)
        
        // Se tem vírgula, assume formato brasileiro (120,00)
        if cleaned.contains(",") {
            let parts = cleaned.components(separatedBy: ",")
            if parts.count == 2 {
                let integerPart = parts[0].replacingOccurrences(of: ".", with: "") // Remove pontos de milhares
                let decimalPart = parts[1]
                return Double("\(integerPart).\(decimalPart)")
            }
        }
        
        // Se tem ponto, pode ser formato americano (120.00) ou brasileiro com milhares (1.200,00)
        if cleaned.contains(".") {
            let parts = cleaned.components(separatedBy: ".")
            if parts.count == 2 {
                // Se a segunda parte tem 2 dígitos, é formato americano
                if parts[1].count == 2 {
                    return Double(cleaned)
                } else {
                    // Senão, é formato brasileiro com milhares
                    return Double(parts.joined().replacingOccurrences(of: ",", with: "."))
                }
            }
        }
        
        // Tenta converter diretamente
        return Double(cleaned)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                // Apenas carrega eventos se necessário
                if state.selectedEventId == nil {
                    return .send(.loadEvents)
                }
                return .none
                
            case .loadEvents:
                state.isLoadingEvents = true
                return .run { send in
                    do {
                        let events = try await eventsClient.fetchEvents()
                        await send(.eventsLoaded(events))
                    } catch {
                        await send(.eventsLoadFailed(error.localizedDescription))
                    }
                }
                
            case let .eventsLoaded(events):
                state.isLoadingEvents = false
                state.availableEvents = events
                return .none
                
            case let .eventsLoadFailed(errorMessage):
                state.isLoadingEvents = false
                state.errorMessage = "Erro ao carregar eventos: \(errorMessage)"
                return .none
                
            // MARK: - Step Navigation
                
            case .nextStep:
                guard state.isCurrentStepValid else {
                    state.errorMessage = "Por favor, preencha todos os campos obrigatórios"
                    return .none
                }
                
                if let nextStep = TicketCreationStep(rawValue: state.currentStep.rawValue + 1) {
                    state.currentStep = nextStep
                    state.errorMessage = nil
                }
                return .none
                
            case .previousStep:
                if let previousStep = TicketCreationStep(rawValue: state.currentStep.rawValue - 1) {
                    state.currentStep = previousStep
                    state.errorMessage = nil
                }
                return .none
                
            case let .goToStep(step):
                state.currentStep = step
                state.errorMessage = nil
                return .none
                
            // MARK: - Publishing
                
            case .publishTicket:
                // Validação
                guard state.isFormValid else {
                    state.errorMessage = "Por favor, preencha todos os campos obrigatórios"
                    return .none
                }
                
                guard let eventId = state.selectedEventId else {
                    state.errorMessage = "Selecione um evento"
                    return .none
                }
                
                guard let priceValue = AddTicketFeature.parsePrice(state.price) else {
                    state.errorMessage = "Preço inválido. Use formato: 120,00 ou 120.00"
                    return .none
                }
                
                // Validar originalPrice se fornecido
                var originalPriceValue: Double? = nil
                if !state.originalPrice.isEmpty {
                    guard let parsedOriginalPrice = AddTicketFeature.parsePrice(state.originalPrice) else {
                        state.errorMessage = "Preço original inválido. Use formato: 120,00 ou 120.00"
                        return .none
                    }
                    originalPriceValue = parsedOriginalPrice
                }
                
                // Verificar autenticação - token é obrigatório agora
                guard let _ = UserDefaults.standard.string(forKey: "authToken") else {
                    state.errorMessage = "Usuário não está logado. Faça login novamente."
                    return .none
                }
                
                state.isPublishing = true
                state.errorMessage = nil
                
                return .run { [state] send in
                    let createRequest = CreateTicketRequest(
                        eventId: eventId.uuidString,
                        name: state.ticketName,
                        description: state.description.isEmpty ? nil : state.description,
                        price: priceValue,
                        originalPrice: originalPriceValue,
                        ticketType: state.ticketType,
                        validUntil: state.validUntil,
                        quantity: state.quantity,
                        currencyCode: state.currencyCode
                    )
                    
                    do {
                        let createdTicket = try await ticketsClient.createTicket(createRequest)
                        await send(.publishTicketResponse(.success(createdTicket)))
                    } catch {
                        let apiError = APIError(
                            message: error.localizedDescription,
                            code: (error as? NetworkError)?.errorDescription?.hash ?? 500
                        )
                        await send(.publishTicketResponse(.failure(apiError)))
                    }
                }
                
            case let .publishTicketResponse(.success(ticket)):
                state.isPublishing = false
                state.publishSuccess = true
                state.errorMessage = nil
                
                // Limpar formulário após sucesso
                state.currentStep = .details
                state.ticketName = ""
                state.price = ""
                state.originalPrice = ""
                state.description = ""
                state.quantity = 1
                state.selectedImageUrls = []
                
                // Notificar outras features via NotificationCenter
                print("📢 Notificando criação de ticket: \(ticket.id)")
                NotificationCenter.default.post(
                    name: NSNotification.Name("TicketCreated"),
                    object: nil,
                    userInfo: ["ticket": ticket]
                )
                
                return .none
                
            case let .publishTicketResponse(.failure(error)):
                state.isPublishing = false
                state.errorMessage = error.message
                return .none
                
            case .dismissSuccess:
                state.publishSuccess = false
                return .none
                
            case let .setSelectedEventId(eventId):
                state.selectedEventId = eventId
                return .none
                
            case .clearError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}
