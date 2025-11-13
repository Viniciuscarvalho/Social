import ComposableArchitecture
import Foundation

@Reducer
public struct PhoneVerificationFeature {
    @ObservableState
    public struct State: Equatable {
        var phoneNumber: String = ""
        var verificationCode: String = ""
        var isCodeSent: Bool = false
        var isSendingCode: Bool = false
        var isVerifying: Bool = false
        var countdown: Int = 0
        var errorMessage: String?
        var showingErrorAlert: Bool = false
        var verificationSuccess: Bool = false
        
        public init(phoneNumber: String = "") {
            self.phoneNumber = phoneNumber
        }
        
        var canSendCode: Bool {
            let digits = phoneNumber.filter { $0.isNumber }
            return digits.count >= 10 && !isSendingCode && countdown == 0
        }
        
        var canVerify: Bool {
            return isCodeSent && verificationCode.count == 6 && !isVerifying
        }
        
        var countdownText: String {
            guard countdown > 0 else { return "" }
            let minutes = countdown / 60
            let seconds = countdown % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
        
        var formattedPhoneNumber: String {
            // Remove formatting to get only digits
            return phoneNumber.filter { $0.isNumber }
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case sendVerificationCode
        case sendCodeResponse(Result<Void, NetworkError>)
        case verifyCode
        case verifyCodeResponse(Result<UserVerification, NetworkError>)
        case startCountdown
        case countdownTick
        case dismissErrorAlert
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case verificationCompleted(UserVerification)
            case dismiss
        }
    }
    
    @Dependency(\.negotiationClient) var negotiationClient
    @Dependency(\.continuousClock) var clock
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .sendVerificationCode:
                guard state.canSendCode else { return .none }
                
                state.isSendingCode = true
                state.errorMessage = nil
                
                // Formata o número com +55
                let fullPhoneNumber = "+55\(state.formattedPhoneNumber)"
                
                return .run { send in
                    do {
                        try await negotiationClient.sendPhoneVerification(fullPhoneNumber)
                        await send(.sendCodeResponse(.success(())))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.sendCodeResponse(.failure(networkError)))
                    }
                }
                
            case .sendCodeResponse(.success):
                state.isSendingCode = false
                state.isCodeSent = true
                print("✅ Código SMS enviado para: +55\(state.formattedPhoneNumber)")
                
                return .run { send in
                    await send(.startCountdown)
                }
                
            case let .sendCodeResponse(.failure(error)):
                state.isSendingCode = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao enviar SMS: \(error.userFriendlyMessage)")
                return .none
                
            case .startCountdown:
                state.countdown = 60 // 1 minuto
                
                return .run { send in
                    while true {
                        try await clock.sleep(for: .seconds(1))
                        await send(.countdownTick)
                    }
                }
                .cancellable(id: CancelID.countdown, cancelInFlight: true)
                
            case .countdownTick:
                if state.countdown > 0 {
                    state.countdown -= 1
                } else {
                    return .cancel(id: CancelID.countdown)
                }
                return .none
                
            case .verifyCode:
                guard state.canVerify else { return .none }
                
                state.isVerifying = true
                state.errorMessage = nil
                
                let phone = "+55\(state.formattedPhoneNumber)"
                let code = state.verificationCode
                
                return .run { send in
                    do {
                        let verification = try await negotiationClient.verifyPhone(phone, code)
                        await send(.verifyCodeResponse(.success(verification)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.verifyCodeResponse(.failure(networkError)))
                    }
                }
                
            case let .verifyCodeResponse(.success(verification)):
                state.isVerifying = false
                state.verificationSuccess = true
                print("✅ Telefone verificado com sucesso!")
                
                return .run { send in
                    await send(.delegate(.verificationCompleted(verification)))
                    try? await Task.sleep(for: .seconds(1.5))
                    await send(.delegate(.dismiss))
                }
                
            case let .verifyCodeResponse(.failure(error)):
                state.isVerifying = false
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao verificar código: \(error.userFriendlyMessage)")
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
    
    private enum CancelID {
        case countdown
    }
}










