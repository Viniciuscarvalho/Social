import ComposableArchitecture
import Foundation

@Reducer
public struct NegotiationsListFeature {
    @ObservableState
    public struct State: Equatable {
        public var negotiations: [Negotiation] = []
        public var isLoading: Bool = false
        public var isRefreshing: Bool = false
        public var errorMessage: String?
        public var showingErrorAlert: Bool = false
        public var selectedNegotiationId: String?
        public var unreadQuestionsCount: Int = 0
        
        public init() {}
        
        public var hasNegotiations: Bool {
            !negotiations.isEmpty
        }
        
        public var unreadCount: Int {
            negotiations.reduce(0) { count, negotiation in
                count + negotiation.unreadQuestionsCount
            }
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadNegotiations
        case negotiationsResponse(Result<[Negotiation], NetworkError>)
        case refreshRequested
        case negotiationSelected(String)
        case dismissErrorAlert
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case negotiationSelected(String)
            case negotiationRead(String) // negotiationId
        }
    }
    
    @Dependency(\.negotiationClient) var negotiationClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Carrega negociações se lista estiver vazia
                guard state.negotiations.isEmpty else {
                    return .none
                }
                return .run { send in
                    await send(.loadNegotiations)
                }
                
            case .loadNegotiations:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    do {
                        let negotiations = try await negotiationClient.fetchMyNegotiations()
                        await send(.negotiationsResponse(.success(negotiations)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.negotiationsResponse(.failure(networkError)))
                    }
                }
                
            case let .negotiationsResponse(.success(negotiations)):
                state.isLoading = false
                state.isRefreshing = false
                state.negotiations = negotiations
                state.unreadQuestionsCount = negotiations.reduce(0) { $0 + $1.unreadQuestionsCount }
                print("✅ Negociações carregadas: \(negotiations.count)")
                return .none
                
            case let .negotiationsResponse(.failure(error)):
                state.isLoading = false
                state.isRefreshing = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao carregar negociações: \(error.userFriendlyMessage)")
                return .none
                
            case .refreshRequested:
                state.isRefreshing = true
                return .run { send in
                    await send(.loadNegotiations)
                }
                
            case let .negotiationSelected(negotiationId):
                state.selectedNegotiationId = negotiationId
                return .run { send in
                    await send(.delegate(.negotiationSelected(negotiationId)))
                }
                
            case .dismissErrorAlert:
                state.showingErrorAlert = false
                state.errorMessage = nil
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

