import Foundation
import SharedModels

public protocol SellerProfileService {
    func fetchProfile() async throws -> SellerProfile
    func fetchProfileById(_ id: UUID) async throws -> SellerProfile
}

public struct SellerProfileFeature {
    public struct State: Equatable {
        public var profile: SellerProfile?
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadProfile
        case loadProfileById(UUID)
        case profileResponse(Result<SellerProfile, APIError>)
    }
    
    private let sellerProfileService: SellerProfileService
    
    public init(sellerProfileService: SellerProfileService) {
        self.sellerProfileService = sellerProfileService
    }
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return Effect.send(.loadProfile)
            
        case .loadProfile:
            state.isLoading = true
            return Effect.run { send in
                do {
                    let profile = try await sellerProfileService.fetchProfile()
                    await send(.profileResponse(.success(profile)))
                } catch {
                    await send(.profileResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                }
            }
            
        case let .loadProfileById(profileId):
            state.isLoading = true
            return Effect.run { send in
                do {
                    let profile = try await sellerProfileService.fetchProfileById(profileId)
                    await send(.profileResponse(.success(profile)))
                } catch {
                    await send(.profileResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                }
            }
            
        case let .profileResponse(.success(profile)):
            state.isLoading = false
            state.profile = profile
            return Effect.none
            
        case let .profileResponse(.failure(error)):
            state.isLoading = false
            state.errorMessage = error.message
            return Effect.none
        }
    }
}
