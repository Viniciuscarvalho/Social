import SwiftUI

/// Componente para exibir o trust score e nível de verificação do usuário
public struct TrustScoreBadge: View {
    let verificationLevel: VerificationLevel
    let trustScore: Int
    let showDetails: Bool
    
    public init(
        verificationLevel: VerificationLevel,
        trustScore: Int,
        showDetails: Bool = false
    ) {
        self.verificationLevel = verificationLevel
        self.trustScore = trustScore
        self.showDetails = showDetails
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            // Ícone de verificação
            Image(systemName: verificationIcon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(verificationColor)
            
            if showDetails {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verificationLevel.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 10))
                            .foregroundColor(trustScoreColor)
                        
                        Text("Score: \(trustScore)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            } else {
                Text(verificationLevel.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, showDetails ? 10 : 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1.5)
        )
    }
    
    private var verificationIcon: String {
        switch verificationLevel {
        case .unverified:
            return "xmark.shield"
        case .emailVerified:
            return "envelope.badge.shield.half.filled"
        case .phoneVerified:
            return "phone.badge.checkmark"
        case .documentVerified:
            return "doc.badge.checkmark"
        case .fullyVerified:
            return "checkmark.seal.fill"
        }
    }
    
    private var verificationColor: Color {
        switch verificationLevel {
        case .unverified:
            return Color.gray
        case .emailVerified:
            return Color.blue
        case .phoneVerified:
            return Color.green
        case .documentVerified:
            return Color.purple
        case .fullyVerified:
            return Color.green
        }
    }
    
    private var trustScoreColor: Color {
        if trustScore >= 80 {
            return Color.green
        } else if trustScore >= 50 {
            return Color.orange
        } else {
            return Color.red
        }
    }
    
    private var backgroundColor: Color {
        verificationColor.opacity(0.1)
    }
    
    private var borderColor: Color {
        verificationColor.opacity(0.3)
    }
}

/// Componente compacto para exibir apenas o ícone de verificação
public struct VerificationBadge: View {
    let verificationLevel: VerificationLevel
    let size: CGFloat
    
    public init(verificationLevel: VerificationLevel, size: CGFloat = 20) {
        self.verificationLevel = verificationLevel
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: size, height: size)
            
            Image(systemName: verificationIcon)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundColor(verificationColor)
        }
    }
    
    private var verificationIcon: String {
        switch verificationLevel {
        case .unverified:
            return "xmark"
        case .emailVerified:
            return "envelope.fill"
        case .phoneVerified:
            return "phone.fill"
        case .documentVerified:
            return "doc.text.fill"
        case .fullyVerified:
            return "checkmark.seal.fill"
        }
    }
    
    private var verificationColor: Color {
        switch verificationLevel {
        case .unverified:
            return Color.gray
        case .emailVerified:
            return Color.blue
        case .phoneVerified:
            return Color.green
        case .documentVerified:
            return Color.purple
        case .fullyVerified:
            return Color.green
        }
    }
    
    private var backgroundColor: Color {
        verificationColor.opacity(0.2)
    }
}

#Preview {
    VStack(spacing: 16) {
        // Trust Score Badges
        TrustScoreBadge(
            verificationLevel: .unverified,
            trustScore: 0
        )
        
        TrustScoreBadge(
            verificationLevel: .emailVerified,
            trustScore: 40
        )
        
        TrustScoreBadge(
            verificationLevel: .phoneVerified,
            trustScore: 65
        )
        
        TrustScoreBadge(
            verificationLevel: .documentVerified,
            trustScore: 85
        )
        
        TrustScoreBadge(
            verificationLevel: .fullyVerified,
            trustScore: 95
        )
        
        Divider()
        
        // Com detalhes
        TrustScoreBadge(
            verificationLevel: .fullyVerified,
            trustScore: 95,
            showDetails: true
        )
        
        Divider()
        
        // Verification Badges (compactos)
        HStack(spacing: 12) {
            VerificationBadge(verificationLevel: .unverified)
            VerificationBadge(verificationLevel: .emailVerified)
            VerificationBadge(verificationLevel: .phoneVerified)
            VerificationBadge(verificationLevel: .documentVerified)
            VerificationBadge(verificationLevel: .fullyVerified)
        }
    }
    .padding()
}

