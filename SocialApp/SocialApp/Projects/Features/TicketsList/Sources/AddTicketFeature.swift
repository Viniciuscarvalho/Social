import ComposableArchitecture
import Foundation

@Reducer
public struct AddTicketFeature {
    @ObservableState
    public struct State: Equatable {
        var ticketName: String = ""
        var ticketType: String = ""
        var price: String = ""
        var description: String = ""
        
        public init() {}
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case setTicketName(String)
        case setTicketType(String)
        case setPrice(String)
        case setDescription(String)
        case publishTicket
    }
    
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
                
            case .publishTicket:
                // Lógica para publicar o ingresso
                return .none
            }
        }
    }
}
