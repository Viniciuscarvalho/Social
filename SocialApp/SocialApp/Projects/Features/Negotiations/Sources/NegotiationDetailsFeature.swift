import ComposableArchitecture
import Foundation

@Reducer
public struct NegotiationDetailsFeature {
    @ObservableState
    public struct State: Equatable {
        var negotiationId: String
        var negotiation: Negotiation?
        var isLoading: Bool = false
        var isUpdating: Bool = false
        var showingContactReveal: Bool = false
        var showingRejectSheet: Bool = false
        var rejectionReason: String = ""
        var errorMessage: String?
        var showingErrorAlert: Bool = false
        
        // Estado do vendedor revelado
        var revealedSeller: User?
        var isRevealingContact: Bool = false
        
        public init(negotiationId: String) {
            self.negotiationId = negotiationId
        }
        
        public init(negotiation: Negotiation) {
            self.negotiationId = negotiation.id
            self.negotiation = negotiation
        }
        
        var currentUserId: String {
            UserDefaults.standard.string(forKey: "currentUserId") ?? ""
        }
        
        var isBuyer: Bool {
            guard let negotiation = negotiation else { return false }
            return negotiation.buyerId == currentUserId
        }
        
        var isSeller: Bool {
            guard let negotiation = negotiation else { return false }
            return negotiation.sellerId == currentUserId
        }
        
        var canApprove: Bool {
            guard let negotiation = negotiation else { return false }
            return isSeller && negotiation.status == .pending && !isUpdating
        }
        
        var canReject: Bool {
            guard let negotiation = negotiation else { return false }
            return isSeller && negotiation.status == .pending && !isUpdating
        }
        
        var canRevealContact: Bool {
            guard let negotiation = negotiation else { return false }
            return isBuyer && negotiation.status == .approved && !negotiation.isExpired
        }
        
        var canCancel: Bool {
            guard let negotiation = negotiation else { return false }
            return (isBuyer || isSeller) && 
                   (negotiation.status == .pending || negotiation.status == .approved) && 
                   !isUpdating
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case loadNegotiation
        case negotiationResponse(Result<Negotiation, NetworkError>)
        case approveNegotiation
        case rejectNegotiation
        case showRejectSheet
        case hideRejectSheet
        case cancelNegotiation
        case updateResponse(Result<Negotiation, NetworkError>)
        case revealContact
        case revealContactResponse(Result<User, NetworkError>)
        case dismissErrorAlert
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case negotiationUpdated(Negotiation)
            case dismiss
        }
    }
    
    @Dependency(\.negotiationClient) var negotiationClient
    @Dependency(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Se já temos a negociação, não precisa carregar novamente
                guard state.negotiation == nil else {
                    return .none
                }
                return .run { send in
                    await send(.loadNegotiation)
                }
                
            case .loadNegotiation:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        let negotiation = try await negotiationClient.fetchNegotiation(negotiationId)
                        await send(.negotiationResponse(.success(negotiation)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.negotiationResponse(.failure(networkError)))
                    }
                }
                
            case let .negotiationResponse(.success(negotiation)):
                state.isLoading = false
                state.negotiation = negotiation
                print("✅ Negociação carregada: \(negotiation.id) - Status: \(negotiation.status.displayName)")
                return .none
                
            case let .negotiationResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao carregar negociação: \(error.userFriendlyMessage)")
                return .none
                
            case .approveNegotiation:
                guard state.canApprove else { return .none }
                
                state.isUpdating = true
                state.errorMessage = nil
                
                let request = UpdateNegotiationRequest(status: .approved)
                
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        let negotiation = try await negotiationClient.updateNegotiation(negotiationId, request)
                        await send(.updateResponse(.success(negotiation)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.updateResponse(.failure(networkError)))
                    }
                }
                
            case .showRejectSheet:
                state.showingRejectSheet = true
                return .none
                
            case .hideRejectSheet:
                state.showingRejectSheet = false
                state.rejectionReason = ""
                return .none
                
            case .rejectNegotiation:
                guard state.canReject else { return .none }
                guard !state.rejectionReason.isEmpty else {
                    state.errorMessage = "Por favor, informe o motivo da recusa"
                    state.showingErrorAlert = true
                    return .none
                }
                
                state.isUpdating = true
                state.errorMessage = nil
                state.showingRejectSheet = false
                
                let request = UpdateNegotiationRequest(
                    status: .rejected,
                    rejectionReason: state.rejectionReason
                )
                
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        let negotiation = try await negotiationClient.updateNegotiation(negotiationId, request)
                        await send(.updateResponse(.success(negotiation)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.updateResponse(.failure(networkError)))
                    }
                }
                
            case .cancelNegotiation:
                guard state.canCancel else { return .none }
                
                state.isUpdating = true
                state.errorMessage = nil
                
                let request = UpdateNegotiationRequest(status: .cancelled)
                
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        let negotiation = try await negotiationClient.updateNegotiation(negotiationId, request)
                        await send(.updateResponse(.success(negotiation)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.updateResponse(.failure(networkError)))
                    }
                }
                
            case let .updateResponse(.success(negotiation)):
                state.isUpdating = false
                state.negotiation = negotiation
                state.rejectionReason = ""
                print("✅ Negociação atualizada: \(negotiation.status.displayName)")
                
                return .run { send in
                    await send(.delegate(.negotiationUpdated(negotiation)))
                }
                
            case let .updateResponse(.failure(error)):
                state.isUpdating = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao atualizar negociação: \(error.userFriendlyMessage)")
                return .none
                
            case .revealContact:
                guard state.canRevealContact else {
                    state.errorMessage = "Não é possível revelar o contato neste momento"
                    state.showingErrorAlert = true
                    return .none
                }
                
                state.isRevealingContact = true
                state.errorMessage = nil
                
                // TODO: Implementar autenticação biométrica aqui
                
                return .run { [negotiationId = state.negotiationId] send in
                    do {
                        let seller = try await negotiationClient.revealContact(negotiationId)
                        await send(.revealContactResponse(.success(seller)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.revealContactResponse(.failure(networkError)))
                    }
                }
                
            case let .revealContactResponse(.success(seller)):
                state.isRevealingContact = false
                state.revealedSeller = seller
                state.showingContactReveal = true
                print("✅ Contato revelado: \(seller.name)")
                return .none
                
            case let .revealContactResponse(.failure(error)):
                state.isRevealingContact = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao revelar contato: \(error.userFriendlyMessage)")
                return .none
                
            case .dismissErrorAlert:
                state.showingErrorAlert = false
                state.errorMessage = nil
                return .none
                
            case .binding:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

