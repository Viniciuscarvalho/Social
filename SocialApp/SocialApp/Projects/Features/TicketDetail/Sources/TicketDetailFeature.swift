import ComposableArchitecture
import Foundation

@Reducer
public struct TicketDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var ticketDetail: TicketDetail?
        public var isLoading: Bool = false
        public var errorMessage: String?
        public var isPurchasing: Bool = false
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear(UUID)
        case loadTicketDetail(UUID)
        case ticketDetailResponse(Result<TicketDetail, APIError>)
        case purchaseTicket(UUID)
        case purchaseResponse(Result<TicketDetail, APIError>)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .onAppear(ticketId):
                return .send(.loadTicketDetail(ticketId))
                
            case let .loadTicketDetail(ticketId):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        try await Task.sleep(for: .seconds(1))
                        let ticketDetail = SharedMockData.sampleTicketDetail(for: ticketId)
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
                
            case let .purchaseTicket(ticketId):
                state.isPurchasing = true
                return .run { send in
                    do {
                        try await Task.sleep(for: .seconds(2))
                        var ticketDetail = SharedMockData.sampleTicketDetail(for: ticketId)
                        ticketDetail.status = .sold
                        await send(.purchaseResponse(.success(ticketDetail)))
                    } catch {
                        await send(.purchaseResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                    }
                }
                
            case let .purchaseResponse(.success(ticketDetail)):
                state.isPurchasing = false
                state.ticketDetail = ticketDetail
                return .none
                
            case let .purchaseResponse(.failure(error)):
                state.isPurchasing = false
                state.errorMessage = error.message
                return .none
            }
        }
    }
}
