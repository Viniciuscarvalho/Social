import ComposableArchitecture
import Foundation

@Reducer
public struct NegotiationRequestFeature {
    @ObservableState
    public struct State: Equatable {
        var ticketId: String
        var ticketName: String
        var sellerName: String
        var ticketPrice: Double
        
        var proposedPrice: String = ""
        var canNegotiate: Bool = false
        var isCheckingPermissions: Bool = false
        var isSubmitting: Bool = false
        var showingSuccessAlert: Bool = false
        var showingErrorAlert: Bool = false
        var errorMessage: String?
        
        // Informações de verificação do usuário
        var userVerification: UserVerification?
        var activeNegotiationsCount: Int = 0
        
        public init(
            ticketId: String,
            ticketName: String,
            sellerName: String,
            ticketPrice: Double
        ) {
            self.ticketId = ticketId
            self.ticketName = ticketName
            self.sellerName = sellerName
            self.ticketPrice = ticketPrice
        }
        
        var canSubmit: Bool {
            return canNegotiate && !isSubmitting
        }
        
        var formattedProposedPrice: Double? {
            return Double(proposedPrice.replacingOccurrences(of: ",", with: "."))
        }
        
        var verificationMessage: String {
            guard let verification = userVerification else {
                return "Verificando permissões..."
            }
            
            if !verification.canNegotiate {
                return "Você precisa verificar seu e-mail para iniciar negociações"
            }
            
            if activeNegotiationsCount >= 3 {
                return "Você atingiu o limite de 3 negociações ativas simultâneas"
            }
            
            return "Você pode iniciar uma negociação"
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case checkPermissions
        case permissionsResponse(Result<(verification: UserVerification, activeCount: Int), NetworkError>)
        case submitNegotiation
        case submitResponse(Result<Negotiation, NetworkError>)
        case dismissSuccessAlert
        case dismissErrorAlert
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case negotiationCreated(Negotiation)
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
                return .run { send in
                    await send(.checkPermissions)
                }
                
            case .checkPermissions:
                state.isCheckingPermissions = true
                state.errorMessage = nil
                
                return .run { send in
                    do {
                        let verification = try await negotiationClient.fetchVerificationStatus()
                        let canNegotiate = try await negotiationClient.canStartNegotiation()
                        
                        // Buscar contagem de negociações ativas
                        let negotiations = try await negotiationClient.fetchMyNegotiations()
                        let activeCount = negotiations.filter { 
                            $0.status == .pending || $0.status == .approved || $0.status == .inProgress 
                        }.count
                        
                        await send(.permissionsResponse(.success((verification, activeCount))))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.permissionsResponse(.failure(networkError)))
                    }
                }
                
            case let .permissionsResponse(.success((verification, activeCount))):
                state.isCheckingPermissions = false
                state.userVerification = verification
                state.activeNegotiationsCount = activeCount
                state.canNegotiate = verification.canNegotiate && activeCount < 3
                print("✅ Verificação concluída: nível \(verification.verificationLevel.displayName), \(activeCount) negociações ativas")
                return .none
                
            case let .permissionsResponse(.failure(error)):
                state.isCheckingPermissions = false
                state.canNegotiate = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao verificar permissões: \(error.userFriendlyMessage)")
                return .none
                
            case .submitNegotiation:
                guard state.canSubmit else {
                    state.errorMessage = "Você não tem permissão para iniciar esta negociação"
                    state.showingErrorAlert = true
                    return .none
                }
                
                state.isSubmitting = true
                state.errorMessage = nil
                
                let request = CreateNegotiationRequest(
                    ticketId: state.ticketId,
                    proposedPrice: state.formattedProposedPrice
                )
                
                return .run { send in
                    do {
                        let negotiation = try await negotiationClient.createNegotiation(request)
                        await send(.submitResponse(.success(negotiation)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.submitResponse(.failure(networkError)))
                    }
                }
                
            case let .submitResponse(.success(negotiation)):
                state.isSubmitting = false
                state.showingSuccessAlert = true
                print("✅ Negociação criada: \(negotiation.id)")
                
                return .run { send in
                    // Notificar o delegate e aguardar um pouco antes de fechar
                    await send(.delegate(.negotiationCreated(negotiation)))
                    try? await Task.sleep(for: .seconds(1.5))
                    await send(.delegate(.dismiss))
                }
                
            case let .submitResponse(.failure(error)):
                state.isSubmitting = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao criar negociação: \(error.userFriendlyMessage)")
                return .none
                
            case .dismissSuccessAlert:
                state.showingSuccessAlert = false
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




