import ComposableArchitecture
import Foundation

@Reducer
public struct NegotiationReviewFeature {
    @ObservableState
    public struct State: Equatable {
        var negotiationId: String
        var revieweeId: String // ID da pessoa sendo avaliada
        var revieweeName: String // Nome da pessoa sendo avaliada
        var role: ReviewRole // Comprador ou vendedor
        
        var rating: Int = 0
        var comment: String = ""
        var isSubmitting: Bool = false
        var errorMessage: String?
        var showingErrorAlert: Bool = false
        var submitSuccess: Bool = false
        
        // Limites
        let maxCommentLength: Int = 500
        let minCommentLength: Int = 10
        
        public enum ReviewRole: String, Codable, Equatable {
            case buyer = "buyer"
            case seller = "seller"
            
            var displayName: String {
                switch self {
                case .buyer: return "Comprador"
                case .seller: return "Vendedor"
                }
            }
        }
        
        public init(
            negotiationId: String,
            revieweeId: String,
            revieweeName: String,
            role: ReviewRole
        ) {
            self.negotiationId = negotiationId
            self.revieweeId = revieweeId
            self.revieweeName = revieweeName
            self.role = role
        }
        
        var canSubmit: Bool {
            return rating > 0 &&
                   comment.count >= minCommentLength &&
                   comment.count <= maxCommentLength &&
                   !isSubmitting
        }
        
        var commentCountText: String {
            return "\(comment.count)/\(maxCommentLength)"
        }
        
        var isCommentValid: Bool {
            return comment.isEmpty || 
                   (comment.count >= minCommentLength && comment.count <= maxCommentLength)
        }
        
        var commentHelperText: String {
            if comment.isEmpty {
                return "Mínimo de \(minCommentLength) caracteres"
            } else if comment.count < minCommentLength {
                return "Faltam \(minCommentLength - comment.count) caracteres"
            } else {
                return "Descreva sua experiência"
            }
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case setRating(Int)
        case submitReview
        case submitResponse(Result<Review, NetworkError>)
        case dismissErrorAlert
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case reviewSubmitted(Review)
            case dismiss
        }
    }
    
    @Dependency(\.negotiationClient) var negotiationClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                print("⭐ ReviewFormView apareceu")
                print("   - Avaliando: \(state.revieweeName)")
                print("   - Papel: \(state.role.displayName)")
                return .none
                
            case let .setRating(rating):
                guard rating >= 0 && rating <= 5 else { return .none }
                state.rating = rating
                print("⭐ Rating definido: \(rating)")
                return .none
                
            case .submitReview:
                guard state.canSubmit else { return .none }
                
                state.isSubmitting = true
                state.errorMessage = nil
                
                let negotiationId = state.negotiationId
                let revieweeId = state.revieweeId
                let rating = state.rating
                let comment = state.comment
                let role = state.role
                
                print("📝 Enviando avaliação...")
                print("   - Rating: \(rating)")
                print("   - Comentário: \(comment.prefix(50))...")
                
                return .run { send in
                    do {
                        let review = try await negotiationClient.submitReview(
                            negotiationId: negotiationId,
                            revieweeId: revieweeId,
                            rating: rating,
                            comment: comment,
                            role: role.rawValue
                        )
                        
                        print("✅ Avaliação enviada com sucesso!")
                        await send(.submitResponse(.success(review)))
                    } catch {
                        print("❌ Erro ao enviar avaliação: \(error.localizedDescription)")
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.submitResponse(.failure(networkError)))
                    }
                }
                
            case let .submitResponse(.success(review)):
                state.isSubmitting = false
                state.submitSuccess = true
                print("✅ Avaliação registrada: ID \(review.id)")
                
                return .run { send in
                    await send(.delegate(.reviewSubmitted(review)))
                    try? await Task.sleep(for: .seconds(1.5))
                    await send(.delegate(.dismiss))
                }
                
            case let .submitResponse(.failure(error)):
                state.isSubmitting = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao enviar avaliação: \(error.userFriendlyMessage)")
                return .none
                
            case .dismissErrorAlert:
                state.showingErrorAlert = false
                state.errorMessage = nil
                return .none
                
            case .binding(\.$comment):
                // Limitar caracteres automaticamente
                if state.comment.count > state.maxCommentLength {
                    state.comment = String(state.comment.prefix(state.maxCommentLength))
                }
                return .none
                
            case .binding:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}







