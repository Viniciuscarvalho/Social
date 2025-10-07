import ComposableArchitecture
import Foundation

/// Feature para visualizar o perfil de OUTRO usuário (vendedor)
/// 
/// **Diferença de ProfileFeature:**
/// - ProfileFeature: Perfil do usuário LOGADO (pode editar, configurações)
/// - SellerProfileFeature: Perfil de OUTRO usuário (apenas visualização)
///
/// **Uso:**
/// Quando usuário clica no vendedor de um ticket para ver:
/// - Informações públicas do vendedor
/// - Tickets que ele está vendendo
/// - Avaliações e reputação
///
/// **Read-only**: Não permite edições, apenas visualização
@Reducer
public struct SellerProfileFeature {
    @ObservableState
    public struct State: Equatable {
        public var sellerId: String?
        public var profile: User?
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init(sellerId: String? = nil) {
            self.sellerId = sellerId
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadProfileById(String)
        case profileResponse(Result<User, APIError>)
    }
    
    @Dependency(\.userClient) var userClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let sellerId = state.sellerId else {
                    state.errorMessage = "ID do vendedor não fornecido"
                    return .none
                }
                return .send(.loadProfileById(sellerId))
                
            case let .loadProfileById(userId):
                state.isLoading = true
                state.errorMessage = nil
                state.sellerId = userId
                
                print("👤 Carregando perfil do vendedor: \(userId)")
                
                return .run { send in
                    do {
                        let user = try await userClient.getUserProfile(userId)
                        print("✅ Perfil do vendedor carregado: \(user.name)")
                        await send(.profileResponse(.success(user)))
                    } catch {
                        print("❌ Erro ao carregar perfil do vendedor: \(error)")
                        let apiError = error as? APIError ?? APIError(message: error.localizedDescription, code: 500)
                        await send(.profileResponse(.failure(apiError)))
                    }
                }
                
            case let .profileResponse(.success(user)):
                state.isLoading = false
                state.profile = user
                return .none
                
            case let .profileResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.message
                return .none
            }
        }
    }
}
