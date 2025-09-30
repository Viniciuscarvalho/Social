import ComposableArchitecture
import Foundation

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
        case loadProfileById(UUID)
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
                state.errorMessage = nil
                return .run { send in
                    do {
                        try await Task.sleep(for: .seconds(1))
                        let profile = SellerProfile(name: "Richard A. Bachmann", title: "UX/UX Designer")
                        await send(.profileResponse(.success(profile)))
                    } catch {
                        await send(.profileResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                    }
                }
                
            case let .loadProfileById(profileId):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        try await Task.sleep(for: .seconds(1))
                        
                        // Cria tickets de exemplo para o vendedor
                        let sampleTickets = [
                            Ticket(
                                eventId: UUID(),
                                sellerId: profileId,
                                name: "Rock in Rio 2024",
                                price: 250.0,
                                ticketType: .vip,
                                validUntil: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
                            ),
                            Ticket(
                                eventId: UUID(),
                                sellerId: profileId,
                                name: "Festival de Verão",
                                price: 120.0,
                                ticketType: .general,
                                validUntil: Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date()
                            ),
                            Ticket(
                                eventId: UUID(),
                                sellerId: profileId,
                                name: "Show Acústico",
                                price: 85.0,
                                ticketType: .student,
                                validUntil: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date()
                            )
                        ]
                        
                        var profile = SellerProfile(
                            name: "João Silva",
                            title: "Vendedor Oficial de Ingressos",
                            profileImageURL: nil
                        )
                        profile.followersCount = 1243
                        profile.followingCount = 89
                        profile.ticketsCount = sampleTickets.count
                        profile.isVerified = true
                        profile.tickets = sampleTickets
                        
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
