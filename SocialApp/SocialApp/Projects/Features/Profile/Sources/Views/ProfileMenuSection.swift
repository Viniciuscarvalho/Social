import SwiftUI
import DesignSystem

/// Seção de menu do perfil com todas as opções
struct ProfileMenuSection: View {
    let onMyTicketsTapped: () -> Void
    let onFavoritesTapped: () -> Void
    let onThemeSelectionTapped: () -> Void
    let onSupportTapped: () -> Void
    let onSignOutTapped: () -> Void
    
    var body: some View {
        VStack(spacing: DSSpacing.sm) {
            // Tickets
            DSListCell(
                icon: "qrcode",
                iconColor: DSColors.accentGreen,
                title: "Ingressos",
                subtitle: "Seus ingressos e QR Codes",
                accessory: .chevron
            ) {
                onMyTicketsTapped()
            }
            .dsEnterAnimation(isVisible: true, delay: 0.1)
            
            // Favoritos
            DSListCell(
                icon: "heart.fill",
                iconColor: .pink,
                title: "Meus Favoritos",
                subtitle: "Eventos que você favoritou",
                accessory: .chevron
            ) {
                onFavoritesTapped()
            }
            .dsEnterAnimation(isVisible: true, delay: 0.2)
            
            // Seleção de Tema
            DSListCell(
                icon: "paintbrush.fill",
                iconColor: DSColors.primary,
                title: "Aparência",
                subtitle: "Tema: \(Theme.shared.displayName)",
                accessory: .chevron
            ) {
                onThemeSelectionTapped()
            }
            .dsEnterAnimation(isVisible: true, delay: 0.3)
            
            // Mais (usando ação de suporte existente)
            DSListCell(
                icon: "ellipsis.circle.fill",
                iconColor: DSColors.secondary,
                title: "More",
                subtitle: "FAQ, Política de Privacidade e contato",
                accessory: .chevron
            ) {
                onSupportTapped()
            }
            .dsEnterAnimation(isVisible: true, delay: 0.4)
            
            // Logout
            DSListCell(
                icon: "rectangle.portrait.and.arrow.right",
                iconColor: DSColors.error,
                title: "Logout",
                subtitle: nil,
                accessory: .chevron
            ) {
                onSignOutTapped()
            }
            .dsEnterAnimation(isVisible: true, delay: 0.5)
        }
    }
}

