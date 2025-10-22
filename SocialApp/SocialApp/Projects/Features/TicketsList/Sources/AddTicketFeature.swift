import ComposableArchitecture
import Foundation

@Reducer
public struct AddTicketFeature {
    @ObservableState
    public struct State: Equatable {
        public var ticketName: String = ""
        public var ticketType: TicketType = .general
        public var price: String = ""
        public var originalPrice: String = ""
        public var description: String = ""
        public var selectedEventId: UUID?
        public var quantity: Int = 1
        public var validUntil: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        
        public var availableEvents: [Event] = []
        public var isLoadingEvents: Bool = false
        public var isPublishing: Bool = false
        public var errorMessage: String?
        public var publishSuccess: Bool = false
        
        public var isFormValid: Bool {
            return !ticketName.isEmpty && 
                   !price.isEmpty && 
                   AddTicketFeature.parsePrice(price) != nil &&
                   selectedEventId != nil
            // sellerId removido da validação - vem automaticamente do JWT
        }
        
        public init(selectedEventId: UUID? = nil) {
            self.selectedEventId = selectedEventId
            // sellerId removido - não é mais necessário
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case loadEvents
        case eventsLoaded([Event])
        case eventsLoadFailed(String)
        case publishTicket
        case publishTicketResponse(Result<Ticket, APIError>)
        case dismissSuccess
        case setSelectedEventId(UUID?)
        case clearError
        // Removidas as ações de fetch do usuário - não são mais necessárias
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
                        // sellerId removido - será injetado automaticamente do JWT
                        name: state.ticketName,
                        price: priceValue,
                        originalPrice: originalPriceValue,
                        ticketType: state.ticketType,
                        validUntil: state.validUntil
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
                state.ticketName = ""
                state.price = ""
                state.originalPrice = ""
                state.description = ""
                state.quantity = 1
                
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
