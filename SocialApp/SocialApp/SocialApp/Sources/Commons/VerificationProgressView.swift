import SwiftUI

/// Componente que exibe o progresso de verificação do usuário
public struct VerificationProgressView: View {
    let verification: UserVerification?
    let onEmailTapped: () -> Void
    let onPhoneTapped: () -> Void
    let onDocumentTapped: () -> Void
    
    public init(
        verification: UserVerification?,
        onEmailTapped: @escaping () -> Void,
        onPhoneTapped: @escaping () -> Void,
        onDocumentTapped: @escaping () -> Void
    ) {
        self.verification = verification
        self.onEmailTapped = onEmailTapped
        self.onPhoneTapped = onPhoneTapped
        self.onDocumentTapped = onDocumentTapped
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Verificação de Conta")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                    
                    if let verification = verification {
                        Text("Nível: \(verification.verificationLevel.displayName)")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                Spacer()
                
                // Trust Score Badge
                if let verification = verification {
                    TrustScoreBadge(
                        verificationLevel: verification.verificationLevel,
                        trustScore: verification.trustScore
                    )
                }
            }
            
            // Progress Bar
            if let verification = verification {
                progressBar(verification)
            }
            
            // Verification Steps
            VStack(spacing: 12) {
                verificationStep(
                    icon: "envelope.fill",
                    title: "Verificar E-mail",
                    isVerified: verification?.emailVerified ?? false,
                    action: onEmailTapped
                )
                
                verificationStep(
                    icon: "phone.fill",
                    title: "Verificar Telefone",
                    isVerified: verification?.phoneVerified ?? false,
                    isEnabled: verification?.emailVerified ?? false,
                    action: onPhoneTapped
                )
                
                verificationStep(
                    icon: "doc.text.fill",
                    title: "Enviar Documento",
                    isVerified: verification?.documentVerified ?? false,
                    isEnabled: verification?.phoneVerified ?? false,
                    action: onDocumentTapped
                )
            }
            
            // Benefits section
            benefitsSection
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
        .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Progress Bar
    
    private func progressBar(_ verification: UserVerification) -> some View {
        let progress = calculateProgress(verification)
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Progresso")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
    
    private func calculateProgress(_ verification: UserVerification) -> Double {
        var steps = 0.0
        let totalSteps = 3.0
        
        if verification.emailVerified { steps += 1 }
        if verification.phoneVerified { steps += 1 }
        if verification.documentVerified { steps += 1 }
        
        return steps / totalSteps
    }
    
    // MARK: - Verification Step
    
    private func verificationStep(
        icon: String,
        title: String,
        isVerified: Bool,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isVerified ? Color.green.opacity(0.2) : 
                              (isEnabled ? AppColors.primary.opacity(0.2) : Color.gray.opacity(0.2)))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isVerified ? .green : 
                                        (isEnabled ? AppColors.primary : Color.gray))
                }
                
                // Title
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isEnabled ? AppColors.primaryText : AppColors.tertiaryText)
                
                Spacer()
                
                // Status
                if isVerified {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(isEnabled ? AppColors.secondaryText : Color.gray)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? Color.clear : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isVerified ? Color.green.opacity(0.3) : 
                        (isEnabled ? AppColors.border : Color.gray.opacity(0.2)),
                        lineWidth: 1
                    )
            )
        }
        .disabled(!isEnabled || isVerified)
    }
    
    // MARK: - Benefits Section
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Benefícios da Verificação")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.secondaryText)
            
            HStack(spacing: 8) {
                benefitTag(icon: "lock.shield.fill", text: "Mais Segurança")
                benefitTag(icon: "star.fill", text: "Maior Confiança")
            }
        }
    }
    
    private func benefitTag(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(AppColors.primary)
            
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(AppColors.primary.opacity(0.1))
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        // Não verificado
        VerificationProgressView(
            verification: UserVerification(
                emailVerified: false,
                phoneVerified: false,
                documentVerified: false,
                verificationLevel: .unverified,
                trustScore: 0
            ),
            onEmailTapped: {},
            onPhoneTapped: {},
            onDocumentTapped: {}
        )
        
        // Parcialmente verificado
        VerificationProgressView(
            verification: UserVerification(
                emailVerified: true,
                phoneVerified: true,
                documentVerified: false,
                verificationLevel: .phoneVerified,
                trustScore: 65
            ),
            onEmailTapped: {},
            onPhoneTapped: {},
            onDocumentTapped: {}
        )
        
        // Totalmente verificado
        VerificationProgressView(
            verification: UserVerification(
                emailVerified: true,
                phoneVerified: true,
                documentVerified: true,
                verificationLevel: .fullyVerified,
                trustScore: 95
            ),
            onEmailTapped: {},
            onPhoneTapped: {},
            onDocumentTapped: {}
        )
    }
    .padding()
    .background(AppColors.background)
}



