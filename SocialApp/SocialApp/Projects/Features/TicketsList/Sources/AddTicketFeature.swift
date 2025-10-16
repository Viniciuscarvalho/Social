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
        
        public var availableEvents: [Event] = []
        public var isLoadingEvents: Bool = false
        public var isPublishing: Bool = false
        public var errorMessage: String?
        public var publishSuccess: Bool = false
        
        public var isFormValid: Bool {
            !ticketName.isEmpty && 
            !price.isEmpty && 
            Double(price) != nil &&
            selectedEventId != nil
        }
        
        public init(selectedEventId: UUID? = nil) {
            self.selectedEventId = selectedEventId
            print("🎫 AddTicketFeature.State inicializado com selectedEventId: \(selectedEventId?.uuidString ?? "nil")")
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case loadEvents
        case eventsLoaded([Event])
        case eventsLoadFailed(String)
        case publishTicket
        case publishTicketResponse(Result<Ticket, APIError>)
        case dismissSuccess
        case setSelectedEventId(UUID?)
        
        // Implementação manual de Equatable
        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.binding(let action1), .binding(let action2)):
                return action1 == action2
            case (.onAppear, .onAppear),
                 (.loadEvents, .loadEvents),
                 (.publishTicket, .publishTicket),
                 (.dismissSuccess, .dismissSuccess):
                return true
            case let (.eventsLoaded(events1), .eventsLoaded(events2)):
                return events1 == events2
            case let (.eventsLoadFailed(message1), .eventsLoadFailed(message2)):
                return message1 == message2
            case let (.publishTicketResponse(result1), .publishTicketResponse(result2)):
                switch (result1, result2) {
                case (.success(let ticket1), .success(let ticket2)):
                    return ticket1 == ticket2
                case (.failure(let error1), .failure(let error2)):
                    return error1 == error2
                default:
                    return false
                }
            case let (.setSelectedEventId(uuid1), .setSelectedEventId(uuid2)):
                return uuid1 == uuid2
            default:
                return false
            }
        }
    }
    
    @Dependency(\.ticketsClient) var ticketsClient
    @Dependency(\.userClient) var userClient
    @Dependency(\.eventsClient) var eventsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                // Carrega eventos se não houver evento selecionado
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
                print("✅ Carregados \(events.count) eventos para seleção")
                return .none
                
            case let .eventsLoadFailed(errorMessage):
                state.isLoadingEvents = false
                state.errorMessage = "Erro ao carregar eventos: \(errorMessage)"
                return .none
                
            case .publishTicket:
                print("📋 Dados do formulário:")
                print("   Nome: \(state.ticketName)")
                print("   Tipo: \(state.ticketType.displayName)")
                print("   Preço: \(state.price)")
                print("   Descrição: \(state.description)")
                print("   Event ID: \(state.selectedEventId?.uuidString ?? "nil")")
                
                guard state.isFormValid,
                      let eventId = state.selectedEventId,
                      let priceValue = Double(state.price) else {
                    state.errorMessage = "Por favor, preencha todos os campos obrigatórios"
                    print("❌ Validação falhou!")
                    return .none
                }
                
                state.isPublishing = true
                state.errorMessage = nil
                
                return .run { [state] send in
                    do {
                        print("📝 Publicando novo ticket...")
                        
                        // Buscar usuário atual para pegar o sellerId
                        let currentUser = try await userClient.fetchCurrentUser()
                        
                        // Criar novo ticket
                        let newTicket = Ticket(
                            eventId: eventId.uuidString,  // Converter UUID para String
                            sellerId: currentUser.id,      // Usar ID do usuário atual
                            name: state.ticketName,
                            price: priceValue,
                            ticketType: state.ticketType,
                            validUntil: state.validUntil
                        )
                        
                        print("🎫 Criando ticket para evento: \(eventId.uuidString)")
                        print("👤 Vendedor: \(currentUser.name) (ID: \(currentUser.id))")
                        
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
                
            case let .setSelectedEventId(eventId):
                print("🎫 AddTicketFeature - setSelectedEventId: \(eventId?.uuidString ?? "nil")")
                state.selectedEventId = eventId
                return .none
            }
        }
    }
}
