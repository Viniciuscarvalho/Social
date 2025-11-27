import SwiftUI
import DesignSystem

/// Card de vendedor mostrado quando o usuário tem tickets
struct SellerCardView: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        DSCard {
            DSListCell(
                icon: "person.badge.shield.checkmark.fill",
                iconColor: DSColors.primary,
                title: "Perfil de Vendedor",
                subtitle: "\(user.ticketsCount) ingresso\(user.ticketsCount == 1 ? "" : "s") disponível\(user.ticketsCount == 1 ? "" : "eis")",
                accessory: .chevron
            ) {
                onTap()
            }
        }
        .dsSlideAnimation(isVisible: true, from: .leading)
    }
}

