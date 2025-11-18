import ComposableArchitecture
import Foundation

@Reducer
public struct EmailVerificationFeature {
    @ObservableState
    public struct State: Equatable {
        public var email: String
        public var isCodeSent: Bool = false
        public var verificationCode: String = ""
        public var isSendingCode: Bool = false
        public var isVerifying: Bool = false
        public var countdown: Int = 0
        public var showingErrorAlert: Bool = false
        public var errorMessage: String?
        public var verificationSuccess: Bool = false
        
        public init(email: String = "") {
            self.email = email
        }
        
        public var canVerify: Bool {
            verificationCode.count == 6 && !isVerifying
        }
        
        public var countdownText: String {
            let minutes = countdown / 60
            let seconds = countdown % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    public enum Action {
        case onAppear
        case sendVerificationCode
        case verifyCode
        case codeSent
        case updateCountdown(Int)
        case verificationSucceeded(UserVerification)
        case codeVerificationFailed(String)
        case dismissErrorAlert
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case verificationCompleted(UserVerification)
            case dismiss
        }
    }
    
    @Dependency(\.authClient) var authClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .sendVerificationCode:
                state.isSendingCode = true
                return .run { [email = state.email] send in
                    // TODO: Implementar chamada real à API
                    try? await Task.sleep(for: .seconds(1))
                    await send(.codeSent)
                }
                
            case .codeSent:
                state.isSendingCode = false
                state.isCodeSent = true
                state.countdown = 60 // 60 segundos
                return .run { send in
                    // Iniciar countdown
                    for i in (1...60).reversed() {
                        try? await Task.sleep(for: .seconds(1))
                        await send(.updateCountdown(i))
                    }
                }
                
            case let .updateCountdown(value):
                state.countdown = value
                return .none
                
            case .verifyCode:
                guard state.canVerify else { return .none }
                state.isVerifying = true
                return .run { [code = state.verificationCode] send in
                    // TODO: Implementar verificação real do código
                    try? await Task.sleep(for: .seconds(1))
                    // Simula sucesso
                    let verification = UserVerification(
                        emailVerified: true,
                        phoneVerified: false,
                        verificationLevel: .emailVerified
                    )
                    await send(.verificationSucceeded(verification))
                }
                
            case let .verificationSucceeded(verification):
                state.isVerifying = false
                state.verificationSuccess = true
                return .run { send in
                    await send(.delegate(.verificationCompleted(verification)))
                }
                
            case let .codeVerificationFailed(error):
                state.isVerifying = false
                state.errorMessage = error
                state.showingErrorAlert = true
                return .none
                
            case .dismissErrorAlert:
                state.showingErrorAlert = false
                state.errorMessage = nil
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
