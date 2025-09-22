import ComposableArchitecture
import Foundation
import SharedModels

@Reducer
public struct TicketDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var ticketDetail: TicketDetail?
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear(UUID)
        case loadTicketDetail(UUID)
        case ticketDetailResponse(Result<TicketDetail, APIError>)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .onAppear(ticketId):
                return .send(.loadTicketDetail(ticketId))
                
            case let .loadTicketDetail(ticketId):
                state.isLoading = true
                return .run { send in
                    do {
                        try await Task.sleep(for: .seconds(1))
                        // Mock ticket detail
                        let event = MockEventData.sampleEvents[0]
                        let seller = SellerProfile(name: "João Silva")
                        let ticketDetail = TicketDetail(
                            ticketId: ticketId,
                            event: event,
                            seller: seller,
                            price: 240.0,
                            quantity: 1,
                            ticketType: .general,
                            validUntil: Date().addingTimeInterval(86400 * 30)
                        )
                        await send(.ticketDetailResponse(.success(ticketDetail)))
                    } catch {
                        await send(.ticketDetailResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                    }
                }
                
            case let .ticketDetailResponse(.success(ticketDetail)):
                state.isLoading = false
                state.ticketDetail = ticketDetail
                return .none
                
            case let .ticketDetailResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.message
                return .none
            }
        }
    }
}
