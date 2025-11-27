import SwiftUI
import DesignSystem

/// Rodapé do perfil com versão e copyright
struct ProfileFooterView: View {
    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            Text("Versão 1.0.0")
                .font(DSTypography.caption1())
                .foregroundColor(DSColors.textTertiary)
            
            Text("© 2025 SocialApp")
                .font(DSTypography.caption1())
                .foregroundColor(DSColors.textTertiary)
        }
        .padding(.top, DSSpacing.l)
    }
}

