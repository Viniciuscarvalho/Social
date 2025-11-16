import SwiftUI

/// Componente visual que mostra o progresso da negociação através das fases
public struct NegotiationStateMachineView: View {
    let negotiation: Negotiation
    
    public init(negotiation: Negotiation) {
        self.negotiation = negotiation
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Título
            Text("Progresso da Negociação")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Etapas
            HStack(spacing: 0) {
                ForEach(Step.allCases, id: \.self) { step in
                    StepIndicatorView(
                        step: step,
                        currentStep: currentStep,
                        isLast: step == Step.allCases.last
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Current Step Logic
    
    private var currentStep: Step {
        // Ordem de verificação: do mais avançado para o menos avançado
        
        // 1. Contato Revelado: Se tem accessToken (indica que contato foi revelado)
        if negotiation.status == .approved && negotiation.accessToken != nil {
            return .contactRevealed
        }
        
        // 2. Aprovação: Se negociação foi aprovada
        if negotiation.status == .approved {
            return .approval
        }
        
        // 3. Verificação: Se tem documentos enviados
        if let documents = negotiation.documents, !documents.isEmpty {
            return .verification
        }
        
        // 4. Perguntas: Se tem perguntas ou está em andamento
        if let questions = negotiation.questions, !questions.isEmpty {
            return .questions
        }
        
        // Estado inicial - sempre começa em perguntas
        return .questions
    }
    
    // MARK: - Steps Enum
    
    enum Step: Int, CaseIterable {
        case questions = 0
        case verification = 1
        case approval = 2
        case contactRevealed = 3
        
        var title: String {
            switch self {
            case .questions: return "Perguntas"
            case .verification: return "Verificação"
            case .approval: return "Aprovação"
            case .contactRevealed: return "Contato"
            }
        }
        
        var icon: String {
            switch self {
            case .questions: return "questionmark.circle.fill"
            case .verification: return "doc.text.fill"
            case .approval: return "checkmark.circle.fill"
            case .contactRevealed: return "person.crop.circle.fill"
            }
        }
    }
}

// MARK: - Step Indicator View

struct StepIndicatorView: View {
    let step: NegotiationStateMachineView.Step
    let currentStep: NegotiationStateMachineView.Step
    let isLast: Bool
    
    private var stepState: StepState {
        if step.rawValue < currentStep.rawValue {
            return .completed
        } else if step.rawValue == currentStep.rawValue {
            return .active
        } else {
            return .pending
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Step Circle
            VStack(spacing: 8) {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(stepState.backgroundColor)
                        .frame(width: 40, height: 40)
                    
                    // Icon or checkmark
                    if stepState == .completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: step.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(stepState.foregroundColor)
                    }
                    
                    // Active pulse animation
                    if stepState == .active {
                        Circle()
                            .stroke(stepState.backgroundColor, lineWidth: 2)
                            .frame(width: 40, height: 40)
                            .scaleEffect(1.2)
                            .opacity(0.5)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: stepState == .active
                            )
                    }
                }
                
                    // Label
                Text(step.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(stepState == .active ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 60)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityValue(accessibilityValue)
            
            // Connector Line
            if !isLast {
                GeometryReader { geometry in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 20))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: 20))
                    }
                    .stroke(
                        stepState == .completed || (stepState == .active && currentStep.rawValue > step.rawValue) ?
                        Color.green : Color.gray.opacity(0.3),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                }
                .frame(height: 2)
            }
        }
    }
    
    // MARK: - Accessibility
    
    private var accessibilityLabel: String {
        switch stepState {
        case .pending:
            return "\(step.title) - Pendente"
        case .active:
            return "\(step.title) - Em andamento"
        case .completed:
            return "\(step.title) - Concluído"
        }
    }
    
    private var accessibilityValue: String {
        switch stepState {
        case .pending:
            return "Aguardando"
        case .active:
            return "Etapa atual"
        case .completed:
            return "Finalizado"
        }
    }
    
    // MARK: - Step State
    
    enum StepState {
        case pending
        case active
        case completed
        
        var backgroundColor: Color {
            switch self {
            case .pending: return Color.gray.opacity(0.3)
            case .active: return Color(red: 0.5, green: 0.3, blue: 0.9)
            case .completed: return Color.green
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .pending: return .gray
            case .active: return .white
            case .completed: return .white
            }
        }
    }
}

// MARK: - Negotiation Extension

extension Negotiation {
    var revealedSeller: User? {
        // Por enquanto, não temos essa propriedade no modelo
        // Será verificado através do canRevealContact e status
        return nil
    }
    
    var hasDocuments: Bool {
        guard let documents = documents else { return false }
        return !documents.isEmpty
    }
}

