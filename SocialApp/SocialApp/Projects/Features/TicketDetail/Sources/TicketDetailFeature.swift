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
        case loadSellerProfile(UUID)
        case sellerProfile(SellerProfileFeature.Action)
    }
    
    @Dependency(\.ticketsClient) var ticketsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .onAppear(ticketId, ticket):
                state.currentTicketId = ticketId
                
                // ✅ Se já temos o ticket simples, usa os dados sem fazer chamada API
                if let existingTicket = ticket {
                    print("✅ Usando ticket já carregado: \(existingTicket.name)")
                    state.ticket = existingTicket
                    
                    // ✅ Só carrega detalhes completos se realmente precisar de mais informações
                    // Por exemplo, se não temos informações do vendedor
                    if existingTicket.sellerId.isEmpty {
                        print("🔄 Carregando detalhes completos pois faltam informações do vendedor")
                        return .send(.loadTicketDetail(ticketId))
                    } else {
                        print("✅ Dados suficientes, não fazendo chamada API")
                        return .none
                    }
                } else {
                    print("🔄 Ticket não fornecido, fazendo chamada API para detalhes")
                    return .send(.loadTicketDetail(ticketId))
                }
                
            case let .loadTicketDetail(ticketId):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        print("🎫 Carregando detalhes do ticket: \(ticketId)")
                        let ticketDetail = try await ticketsClient.fetchTicketDetail(ticketId)
                        print("✅ Detalhes do ticket carregados: \(ticketDetail.event.name)")
                        await send(.ticketDetailResponse(.success(ticketDetail)))
                    } catch {
                        print("❌ Erro ao carregar detalhes do ticket: \(error.localizedDescription)")
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error)
                        await send(.ticketDetailResponse(.failure(networkError)))
                    }
                }
                
            case let .ticketDetailResponse(.success(ticketDetail)):
                state.isLoading = false
                state.ticketDetail = ticketDetail
                return .none
                
            case let .ticketDetailResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .purchaseTicket(ticketId):
                state.isPurchasing = true
                return .run { send in
                    do {
                        print("💰 Iniciando compra do ticket: \(ticketId)")
                        try await Task.sleep(for: .seconds(2))
                        var ticketDetail = try await ticketsClient.fetchTicketDetail(ticketId)
                        ticketDetail.status = .sold
                        print("✅ Ticket comprado com sucesso")
                        await send(.purchaseResponse(.success(ticketDetail)))
                    } catch {
                        print("❌ Erro ao comprar ticket: \(error.localizedDescription)")
                        await send(.purchaseResponse(.failure(NetworkError.unknown(error))))
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
                
            case let .loadSellerProfile(sellerId):
                state.sellerProfile = SellerProfileFeature.State()
                return .send(.sellerProfile(.loadProfileById(sellerId.uuidString)))
                
            case .sellerProfile:
                return .none
            }
        }
    }
}
