import Foundation
import SharedModels

public protocol TicketDetailService {
    func fetchTicketDetail(_ ticketId: UUID) async throws -> TicketDetail
    func purchaseTicket(_ ticketId: UUID) async throws -> TicketDetail
}

public struct TicketDetailFeature {
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
    
    private let ticketDetailService: TicketDetailService
    
    public init(ticketDetailService: TicketDetailService) {
        self.ticketDetailService = ticketDetailService
    }
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .onAppear(ticketId):
            return Effect.send(.loadTicketDetail(ticketId))
            
        case let .loadTicketDetail(ticketId):
            state.isLoading = true
            return Effect.run { send in
                do {
                    let ticketDetail = try await ticketDetailService.fetchTicketDetail(ticketId)
                    await send(.ticketDetailResponse(.success(ticketDetail)))
                } catch {
                    await send(.ticketDetailResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                }
            }
            
        case let .ticketDetailResponse(.success(ticketDetail)):
            state.isLoading = false
            state.ticketDetail = ticketDetail
            return Effect.none
            
        case let .ticketDetailResponse(.failure(error)):
            state.isLoading = false
            state.errorMessage = error.message
            return Effect.none
            
        case let .purchaseTicket(ticketId):
            state.isPurchasing = true
            return Effect.run { send in
                do {
                    let purchasedTicket = try await ticketDetailService.purchaseTicket(ticketId)
                    await send(.purchaseResponse(.success(purchasedTicket)))
                } catch {
                    await send(.purchaseResponse(.failure(APIError(message: error.localizedDescription, code: 500))))
                }
            }
            
        case let .purchaseResponse(.success(ticketDetail)):
            state.isPurchasing = false
            state.ticketDetail = ticketDetail
            return Effect.none
            
        case let .purchaseResponse(.failure(error)):
            state.isPurchasing = false
            state.errorMessage = error.message
            return Effect.none
        }
    }
}
