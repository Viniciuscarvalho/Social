import ComposableArchitecture
import Foundation

@Reducer
public struct AddTicketFeature {
    @ObservableState
    public struct State: Equatable {
        public var ticketName: String = ""
        public var ticketType: TicketType = .general
        public var price: String = ""
        public var description: String = ""
        public var selectedEventId: UUID?
        public var quantity: Int = 1
        public var validUntil: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        
        public var isPublishing: Bool = false
        public var errorMessage: String?
        public var publishSuccess: Bool = false
        
        public var isFormValid: Bool {
            !ticketName.isEmpty && 
            !price.isEmpty && 
            Double(price) != nil &&
            selectedEventId != nil
        }
        
        public init() {}
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case setTicketName(String)
        case setTicketType(TicketType)
        case setPrice(String)
        case setDescription(String)
        case setSelectedEvent(UUID?)
        case setQuantity(Int)
        case setValidUntil(Date)
        case publishTicket
        case publishTicketResponse(Result<Ticket, APIError>)
        case dismissSuccess
    }
    
    @Dependency(\.ticketsClient) var ticketsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .setTicketName(name):
                state.ticketName = name
                return .none
                
            case let .setTicketType(type):
                state.ticketType = type
                return .none
                
            case let .setPrice(price):
                state.price = price
                return .none
                
            case let .setDescription(description):
                state.description = description
                return .none
                
            case let .setSelectedEvent(eventId):
                state.selectedEventId = eventId
                return .none
                
            case let .setQuantity(quantity):
                state.quantity = max(1, quantity)
                return .none
                
            case let .setValidUntil(date):
                state.validUntil = date
                return .none
                
            case .publishTicket:
                guard state.isFormValid,
                      let eventId = state.selectedEventId,
                      let priceValue = Double(state.price) else {
                    state.errorMessage = "Por favor, preencha todos os campos obrigatórios"
                    return .none
                }
                
                state.isPublishing = true
                state.errorMessage = nil
                
                return .run { [state] send in
                    do {
                        print("📝 Publicando novo ticket...")
                        
                        // Criar novo ticket
                        let newTicket = Ticket(
                            eventId: eventId,
                            sellerId: UUID(), // TODO: Usar ID do usuário atual
                            name: state.ticketName,
                            price: priceValue,
                            ticketType: state.ticketType,
                            validUntil: state.validUntil
                        )
                        
                        // Chamar API para criar ticket
                        let createdTicket = try await ticketsClient.createTicket(newTicket)
                        
                        print("✅ Ticket publicado com sucesso: \(createdTicket.name)")
                        await send(.publishTicketResponse(.success(createdTicket)))
                    } catch {
                        print("❌ Erro ao publicar ticket: \(error.localizedDescription)")
                        let apiError = error as? APIError ?? APIError(message: error.localizedDescription, code: 500)
                        await send(.publishTicketResponse(.failure(apiError)))
                    }
                }
                
            case let .publishTicketResponse(.success(ticket)):
                state.isPublishing = false
                state.publishSuccess = true
                print("🎉 Ticket \(ticket.name) publicado com sucesso!")
                
                // Limpar formulário após sucesso
                state.ticketName = ""
                state.price = ""
                state.description = ""
                state.quantity = 1
                state.selectedEventId = nil
                
                return .none
                
            case let .publishTicketResponse(.failure(error)):
                state.isPublishing = false
                state.errorMessage = error.message
                return .none
                
            case .dismissSuccess:
                state.publishSuccess = false
                return .none
            }
        }
    }
}
