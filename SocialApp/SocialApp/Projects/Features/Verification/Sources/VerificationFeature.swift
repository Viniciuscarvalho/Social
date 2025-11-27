import ComposableArchitecture
import Foundation

@Reducer
public struct VerificationFeature {
    // MARK: - Verification Type
    public enum VerificationType: Equatable {
        case signup // Verificação completa para nova conta (3 etapas)
        case passwordReset(userEmail: String) // Apenas email para reset de senha
    }
    
    @ObservableState
    public struct State: Equatable {
        // MARK: - Verification Flow State
        public var verificationType: VerificationType
        public var currentStep: VerificationStep = .email
        public var completedSteps: Set<VerificationStep> = []
        public var verification: UserVerification?
        public var errorMessage: String?
        public var showingErrorAlert: Bool = false
        public var isCompleted: Bool = false
        
        // MARK: - Child Features State
        public var emailVerification: EmailVerificationFeature.State
        public var phoneVerification: PhoneVerificationFeature.State
        public var documentVerification: DocumentVerificationFeature.State
        
        public init(userEmail: String = "", verificationType: VerificationType = .signup) {
            self.verificationType = verificationType
            self.emailVerification = EmailVerificationFeature.State(email: userEmail)
            self.phoneVerification = PhoneVerificationFeature.State()
            self.documentVerification = DocumentVerificationFeature.State()
        }
        
        // MARK: - Computed Properties for Steps
        public var visibleSteps: [VerificationStep] {
            switch verificationType {
            case .signup:
                return [.email, .phone, .document]
            case .passwordReset:
                return [.email] // Apenas email para reset
            }
        }
        
        // MARK: - Computed Properties
        public var progress: Double {
            let total = visibleSteps.count
            let completed = completedSteps.count
            return total > 0 ? Double(completed) / Double(total) : 0
        }
        
        public var progressPercentage: String {
            return String(format: "%.0f%%", progress * 100)
        }
        
        public var currentStepNumber: Int {
            let visibleOrder = visibleSteps.firstIndex(of: currentStep).map { $0 + 1 } ?? 1
            return visibleOrder
        }
        
        public var totalSteps: Int {
            return visibleSteps.count
        }
        
        public var currentStepTitle: String {
            switch currentStep {
            case .email:
                if case .passwordReset = verificationType {
                    return "Resetar Senha"
                }
                return "Verificação de E-mail"
            case .phone: return "Verificação de Telefone"
            case .document: return "Verificação de Documento"
            }
        }
        
        public var currentStepDescription: String {
            switch currentStep {
            case .email:
                if case .passwordReset = verificationType {
                    return "Digite o código enviado para seu e-mail"
                }
                return "Confirme seu endereço de e-mail"
            case .phone: return "Confirme seu número de telefone"
            case .document: return "Envie uma cópia do seu documento"
            }
        }
    }
    
    // MARK: - Verification Steps
    public enum VerificationStep: String, CaseIterable, Equatable, Hashable {
        case email = "Email"
        case phone = "Telefone"
        case document = "Documento"
        
        var order: Int {
            switch self {
            case .email: return 0
            case .phone: return 1
            case .document: return 2
            }
        }
    }
    
    // MARK: - Actions
    public enum Action: Equatable {
        // MARK: - Lifecycle
        case onAppear
        case onDisappear
        case dismiss
        
        // MARK: - Navigation
        case nextStep
        case previousStep
        case skipStep
        case goToStep(VerificationStep)
        
        // MARK: - Verification Completion
        case verificationCompleted(UserVerification)
        case verificationFailed(String)
        
        // MARK: - Child Feature Actions
        case emailVerification(EmailVerificationFeature.Action)
        case phoneVerification(PhoneVerificationFeature.Action)
        case documentVerification(DocumentVerificationFeature.Action)
        
        // MARK: - Navigation
        case delegate(Delegate)
        
        // MARK: - Error Handling
        case dismissErrorAlert
        
        // MARK: - Delegate
        public enum Delegate: Equatable {
            case verificationCompleted(UserVerification)
            case verificationCancelled
        }
    }
    
    @Dependency(\.negotiationClient) var negotiationClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.emailVerification, action: \.emailVerification) {
            EmailVerificationFeature()
        }
        
        Scope(state: \.phoneVerification, action: \.phoneVerification) {
            PhoneVerificationFeature()
        }
        
        Scope(state: \.documentVerification, action: \.documentVerification) {
            DocumentVerificationFeature()
        }
        
        Reduce { state, action in
            switch action {
            // MARK: - Lifecycle
            case .onAppear:
                print("📋 VerificationFeature inicializado - começando com etapa de email")
                return .none
            
            case .onDisappear:
                return .none
                
            case .dismiss:
                print("❌ Fluxo de verificação cancelado pelo usuário")
                return .run { send in
                    await send(.delegate(.verificationCancelled))
                }
                
            // MARK: - Navigation
            case .nextStep:
                let currentIndex = state.visibleSteps.firstIndex(of: state.currentStep) ?? -1
                if currentIndex + 1 < state.visibleSteps.count {
                    let nextStep = state.visibleSteps[currentIndex + 1]
                    state.currentStep = nextStep
                    print("➡️ Próxima etapa: \(nextStep.rawValue)")
                } else {
                    // Finalizou todas as etapas visíveis
                    state.isCompleted = true
                    print("✅ Todas as etapas de verificação completadas!")
                    
                    if let verification = state.verification {
                        return .run { send in
                            await send(.delegate(.verificationCompleted(verification)))
                        }
                    }
                }
                return .none
                
            case .previousStep:
                let currentIndex = state.visibleSteps.firstIndex(of: state.currentStep) ?? -1
                if currentIndex > 0 {
                    let previousStep = state.visibleSteps[currentIndex - 1]
                    state.currentStep = previousStep
                    print("⬅️ Etapa anterior: \(previousStep.rawValue)")
                    return .none
                }
                return .none
                
            case .skipStep:
                print("⏭️ Pulando etapa: \(state.currentStep.rawValue)")
                return .run { send in
                    await send(.nextStep)
                }
                
            case let .goToStep(step):
                state.currentStep = step
                print("📍 Navegando para etapa: \(step.rawValue)")
                return .none
                
            // MARK: - Verification Results
            case let .verificationCompleted(verification):
                state.verification = verification
                state.completedSteps.insert(state.currentStep)
                state.errorMessage = nil
                
                print("✅ Etapa completada: \(state.currentStep.rawValue)")
                print("   Nível de verificação: \(verification.verificationLevel.displayName)")
                
                // Automaticamente vai para próxima etapa
                return .run { send in
                    try? await Task.sleep(for: .milliseconds(500))
                    await send(.nextStep)
                }
                
            case let .verificationFailed(error):
                state.errorMessage = error
                state.showingErrorAlert = true
                print("❌ Erro na verificação: \(error)")
                return .none
                
            case .dismissErrorAlert:
                state.showingErrorAlert = false
                state.errorMessage = nil
                return .none
                
            // MARK: - Email Verification Delegate
            case let .emailVerification(.delegate(.verificationCompleted(verification))):
                print("📧 Email verificado com sucesso!")
                return .run { send in
                    await send(.verificationCompleted(verification))
                }
                
            case .emailVerification(.delegate(.dismiss)):
                print("📧 Email verification cancelado")
                return .run { send in
                    await send(.dismiss)
                }
                
            case .emailVerification:
                return .none
                
            // MARK: - Phone Verification Delegate
            case let .phoneVerification(.delegate(.verificationCompleted(verification))):
                print("📱 Telefone verificado com sucesso!")
                return .run { send in
                    await send(.verificationCompleted(verification))
                }
                
            case .phoneVerification(.delegate(.dismiss)):
                print("📱 Phone verification cancelado")
                return .run { send in
                    await send(.dismiss)
                }
                
            case .phoneVerification:
                return .none
                
            // MARK: - Document Verification Delegate
            case let .documentVerification(.delegate(.verificationSubmitted(verification))):
                print("📄 Documento enviado com sucesso!")
                return .run { send in
                    await send(.verificationCompleted(verification))
                }
                
            case .documentVerification(.delegate(.dismiss)):
                print("📄 Document verification cancelado")
                return .run { send in
                    await send(.dismiss)
                }
                
            case .documentVerification:
                return .none
                
            // MARK: - Delegate
            case .delegate:
                return .none
            }
        }
    }
}

