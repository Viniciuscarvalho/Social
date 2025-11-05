import SwiftUI

/// Banner para exibir o status de validação de um ingresso
public struct ValidationStatusBanner: View {
    let validation: TicketValidation?
    let onUploadTapped: (() -> Void)?
    let onViewDetailsTapped: (() -> Void)?
    
    public init(
        validation: TicketValidation?,
        onUploadTapped: (() -> Void)? = nil,
        onViewDetailsTapped: (() -> Void)? = nil
    ) {
        self.validation = validation
        self.onUploadTapped = onUploadTapped
        self.onViewDetailsTapped = onViewDetailsTapped
    }
    
    public var body: some View {
        Group {
            if let validation = validation {
                validationBanner(validation)
            } else {
                noValidationBanner
            }
        }
    }
    
    // MARK: - Validation Banner
    
    private func validationBanner(_ validation: TicketValidation) -> some View {
        HStack(spacing: 12) {
            // Status icon
            statusIcon(for: validation.status)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(statusTitle(for: validation.status))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Text(statusDescription(for: validation.status))
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
                
                if validation.status == .rejected, let reason = validation.rejectionReason {
                    Text("Motivo: \(reason)")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }
            
            Spacer()
            
            // Action button
            if let action = actionButton(for: validation.status) {
                action
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor(for: validation.status))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor(for: validation.status), lineWidth: 1)
        )
    }
    
    // MARK: - No Validation Banner
    
    private var noValidationBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Validação Pendente")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Envie provas do seu ingresso para validação")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            if let onUploadTapped = onUploadTapped {
                Button(action: onUploadTapped) {
                    Text("Enviar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange)
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Status Components
    
    private func statusIcon(for status: TicketValidation.ValidationStatus) -> some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor(for: status))
                .frame(width: 40, height: 40)
            
            Image(systemName: iconName(for: status))
                .font(.system(size: 18))
                .foregroundColor(iconColor(for: status))
        }
    }
    
    private func actionButton(for status: TicketValidation.ValidationStatus) -> some View? {
        switch status {
        case .pending:
            return AnyView(
                Button(action: { onViewDetailsTapped?() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.secondaryText)
                }
            )
            
        case .approved:
            return AnyView(
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16))
                    Text("Verificado")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.green.opacity(0.1))
                )
            )
            
        case .rejected:
            if let onUploadTapped = onUploadTapped {
                return AnyView(
                    Button(action: onUploadTapped) {
                        Text("Reenviar")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red)
                            )
                    }
                )
            }
            return nil
        }
    }
    
    // MARK: - Status Text
    
    private func statusTitle(for status: TicketValidation.ValidationStatus) -> String {
        switch status {
        case .pending: return "Em Análise"
        case .approved: return "Validado"
        case .rejected: return "Rejeitado"
        }
    }
    
    private func statusDescription(for status: TicketValidation.ValidationStatus) -> String {
        switch status {
        case .pending:
            return "Suas provas estão sendo analisadas pela nossa equipe"
        case .approved:
            return "Ingresso verificado e aprovado"
        case .rejected:
            return "As provas enviadas foram rejeitadas"
        }
    }
    
    // MARK: - Colors
    
    private func backgroundColor(for status: TicketValidation.ValidationStatus) -> Color {
        switch status {
        case .pending: return Color.blue.opacity(0.05)
        case .approved: return Color.green.opacity(0.05)
        case .rejected: return Color.red.opacity(0.05)
        }
    }
    
    private func borderColor(for status: TicketValidation.ValidationStatus) -> Color {
        switch status {
        case .pending: return Color.blue.opacity(0.3)
        case .approved: return Color.green.opacity(0.3)
        case .rejected: return Color.red.opacity(0.3)
        }
    }
    
    private func iconBackgroundColor(for status: TicketValidation.ValidationStatus) -> Color {
        switch status {
        case .pending: return Color.blue.opacity(0.2)
        case .approved: return Color.green.opacity(0.2)
        case .rejected: return Color.red.opacity(0.2)
        }
    }
    
    private func iconColor(for status: TicketValidation.ValidationStatus) -> Color {
        switch status {
        case .pending: return .blue
        case .approved: return .green
        case .rejected: return .red
        }
    }
    
    private func iconName(for status: TicketValidation.ValidationStatus) -> String {
        switch status {
        case .pending: return "clock.fill"
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // No validation
        ValidationStatusBanner(
            validation: nil,
            onUploadTapped: {}
        )
        
        // Pending
        ValidationStatusBanner(
            validation: TicketValidation(
                id: "1",
                ticketId: "ticket-1",
                proofs: [],
                status: .pending,
                submittedAt: Date(),
                reviewedAt: nil,
                rejectionReason: nil
            ),
            onViewDetailsTapped: {}
        )
        
        // Approved
        ValidationStatusBanner(
            validation: TicketValidation(
                id: "2",
                ticketId: "ticket-2",
                proofs: [],
                status: .approved,
                submittedAt: Date(),
                reviewedAt: Date(),
                rejectionReason: nil
            )
        )
        
        // Rejected
        ValidationStatusBanner(
            validation: TicketValidation(
                id: "3",
                ticketId: "ticket-3",
                proofs: [],
                status: .rejected,
                submittedAt: Date(),
                reviewedAt: Date(),
                rejectionReason: "Imagem ilegível"
            ),
            onUploadTapped: {}
        )
    }
    .padding()
    .background(AppColors.background)
}



