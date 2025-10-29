import ComposableArchitecture
import Foundation

@Reducer
public struct TicketDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var ticketDetail: TicketDetail?
        public var ticket: Ticket? // ✅ Ticket simples opcional
        public var sellerProfile: SellerProfileFeature.State?
        public var isLoading: Bool = false
        public var errorMessage: String?
        public var isPurchasing: Bool = false
        public var currentTicketId: UUID?
        
        public init(ticket: Ticket? = nil) {
            self.ticket = ticket
        }
    }
    
    public enum Action: Equatable {
        case onAppear(UUID, Ticket?) // ✅ Agora recebe o ticket opcional
        case loadTicketDetail(UUID)
        case ticketDetailResponse(Result<TicketDetail, NetworkError>)
        case purchaseTicket(UUID)
        case purchaseResponse(Result<TicketDetail, NetworkError>)
        case validateTicket
        case validationResponse(Result<Bool, NetworkError>)
        case loadSellerProfile(UUID)
        case sellerProfile(SellerProfileFeature.Action)
    }
    
    @Dependency(\.ticketsClient) var ticketsClient
    @Dependency(\.eventsClient) var eventsClient
    @Dependency(\.userClient) var userClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .onAppear(ticketId, ticket):
                state.currentTicketId = ticketId
                
                // Sempre armazena o ticket se tiver
                if let existingTicket = ticket {
                    state.ticket = existingTicket
                    print("🎫 TicketDetailFeature: Ticket recebido com preço R$ \(existingTicket.price)")
                }
                
                // Sempre carrega detalhes completos (evento + vendedor), mas usaremos o preço do ticket
                return .run { send in
                    await send(.loadTicketDetail(ticketId))
                }
            
            case let .loadTicketDetail(ticketId):
                state.isLoading = true
                state.errorMessage = nil
                
                // Se temos um ticket com preço, vamos usar esse preço após carregar
                let ticketPrice = state.ticket?.price
                let ticketStatus = state.ticket?.status
                
                return .run { send in
                    do {
                        let ticketDetail = try await ticketsClient.fetchTicketDetail(ticketId)
                        
                        // ✅ CRÍTICO: Se temos um ticket com preço, usar esse preço
                        var finalDetail = ticketDetail
                        if let price = ticketPrice {
                            print("💰 Atualizando preço do TicketDetail: API=\(ticketDetail.price) → Ticket=\(price)")
                            finalDetail.price = price
                        }
                        
                        // Também atualizar status se disponível
                        if let status = ticketStatus {
                            finalDetail.status = status
                        }
                        
                        await send(.ticketDetailResponse(.success(finalDetail)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.ticketDetailResponse(.failure(networkError)))
                    }
                }
                
            case let .ticketDetailResponse(.success(ticketDetail)):
                state.isLoading = false
                state.ticketDetail = ticketDetail
                print("✅ TicketDetail carregado com preço final: R$ \(ticketDetail.price)")
                return .none
                
            case let .ticketDetailResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .purchaseTicket(ticketId):
                state.isPurchasing = true
                return .run { send in
                    do {
                        try await Task.sleep(for: .seconds(2))
                        var ticketDetail = try await ticketsClient.fetchTicketDetail(ticketId)
                        ticketDetail.status = .sold
                        await send(.purchaseResponse(.success(ticketDetail)))
                    } catch {
                        await send(.purchaseResponse(.failure(NetworkError.unknown(error.localizedDescription))))
                    }
                }
                
            case let .purchaseResponse(.success(ticketDetail)):
                state.isPurchasing = false
                state.ticketDetail = ticketDetail
                return .none
                
            case let .purchaseResponse(.failure(error)):
                state.isPurchasing = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .validateTicket:
                return .run { send in
                    do {
                        try await Task.sleep(for: .seconds(1))
                        await send(.validationResponse(.success(true)))
                    } catch {
                        await send(.validationResponse(.failure(NetworkError.unknown(error.localizedDescription))))
                    }
                }
                
            case let .validationResponse(.success(isValid)):
                return .none
                
            case let .validationResponse(.failure(error)):
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .loadSellerProfile(sellerId):
                // Inicializa o state do SellerProfileFeature com o sellerId
                state.sellerProfile = SellerProfileFeature.State(sellerId: sellerId.uuidString)
                // Dispara a ação para carregar o vendedor
                return .run { send in
                    await send(.sellerProfile(.onAppear))
                }
                
            case .sellerProfile:
                // As ações do SellerProfileFeature serão tratadas pelo Scope
                return .none
            }
        }
        .ifLet(\.sellerProfile, action: \.sellerProfile) {
            SellerProfileFeature()
        }
    }
}
