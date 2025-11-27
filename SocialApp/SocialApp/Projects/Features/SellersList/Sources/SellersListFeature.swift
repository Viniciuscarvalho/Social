import ComposableArchitecture
import Foundation

// MARK: - SellersListFeature

@Reducer
public struct SellersListFeature {
    @ObservableState
    public struct State: Equatable {
        public var eventId: UUID
        public var event: Event?
        public var sellers: [SellerWithTickets] = []
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        // MARK: - Derived State
        public var hasSellers: Bool {
            !sellers.isEmpty
        }
        
        public var hasEvent: Bool {
            event != nil
        }
        
        public init(eventId: UUID, event: Event? = nil) {
            self.eventId = eventId
            self.event = event
        }
    }
    
    public enum Action: Equatable {
        // MARK: - Lifecycle
        case onAppear
        case onDisappear
        
        // MARK: - Data Loading
        case loadSellers
        case sellersResponse(Result<[SellerWithTickets], NetworkError>)
        
        // MARK: - User Interactions
        case sellerTapped(String) // sellerId
        case startNegotiation(String, String) // sellerId, ticketId
        
        // MARK: - Navigation
        case delegate(Delegate)
        
        // MARK: - Error Handling
        case dismissError
        
        // MARK: - Delegate
        public enum Delegate: Equatable {
            case navigateToSellerProfile(String)
            case navigateToNegotiation(String, String) // sellerId, ticketId
        }
    }
    
    @Dependency(\.ticketsClient) var ticketsClient
    @Dependency(\.userClient) var userClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.loadSellers)
                }
                
            case .loadSellers:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [eventId = state.eventId] send in
                    do {
                        print("🛒 Carregando vendedores para evento: \(eventId)")
                        
                        // Usar método otimizado do TicketsClient
                        // Este método tenta usar o endpoint otimizado /events/{eventId}/sellers
                        // e faz fallback para o método manual se necessário
                        let sellersWithTickets = try await ticketsClient.fetchSellersByEvent(eventId)
                        print("✅ \(sellersWithTickets.count) vendedores carregados com sucesso")
                        
                        await send(.sellersResponse(.success(sellersWithTickets)))
                    } catch {
                        print("❌ Erro ao carregar vendedores: \(error.localizedDescription)")
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.sellersResponse(.failure(networkError)))
                    }
                }
                
            case let .sellersResponse(.success(sellers)):
                state.isLoading = false
                state.sellers = sellers
                print("✅ \(sellers.count) vendedores carregados com sucesso")
                return .none
                
            case let .sellersResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.userFriendlyMessage
                print("❌ Erro ao carregar vendedores: \(error.userFriendlyMessage)")
                return .none
                
            case let .sellerTapped(sellerId):
                return .run { send in
                    await send(.delegate(.navigateToSellerProfile(sellerId)))
                }
                
            case let .startNegotiation(sellerId, ticketId):
                return .run { send in
                    await send(.delegate(.navigateToNegotiation(sellerId, ticketId)))
                }
            
            case .onDisappear:
                return .none
            
            case .delegate:
                return .none
            
            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}

