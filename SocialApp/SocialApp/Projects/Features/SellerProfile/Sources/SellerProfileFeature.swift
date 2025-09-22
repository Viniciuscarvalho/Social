import ComposableArchitecture
import Foundation
import SharedModels

@Reducer
public struct SellerProfileFeature {
    @ObservableState
    public struct State: Equatable {
        public var profile: SellerProfile?
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadProfile
        case profileResponse(Result<SellerProfile, APIError>)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadProfile)
                
            case .loadProfile:
                state.isLoading = true
                return .run { send in
                    do {
                        try await Task.sleep(for: .seconds(1))
                        let profile = SellerProfile(name: "Richard A. Bachmann", title: "UX/UX Designer")
                        await send(.profileResponse(.success(profile)))
                    } catch {
                        await send(.profileResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                    }
                }
                
            case let .profileResponse(.success(profile)):
                state.isLoading = false
                state.profile = profile
                return .none
                
            case let .profileResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.message
                return .none
            }
        }
    }
}
