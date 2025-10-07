import ComposableArchitecture
import Foundation

@Reducer
public struct SellerProfileFeature {
    @ObservableState
    public struct State: Equatable {
        public var profile: User?
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadProfile
        case loadProfileById(String)
        case profileResponse(Result<User, APIError>)
    }
    
    @Dependency(\.usersClient) var usersClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadProfile)
                
            case .loadProfile:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    let result = await usersClient.fetchCurrentUser()
                    await send(.profileResponse(result))
                }
                
            case let .loadProfileById(userId):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    let result = await usersClient.getUserTickets(userId)
                    await send(.profileResponse(result))
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
