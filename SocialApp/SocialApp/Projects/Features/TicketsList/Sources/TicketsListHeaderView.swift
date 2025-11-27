import SwiftUI
import DesignSystem

/// Header da lista de tickets
struct TicketsListHeaderView: View {
    var body: some View {
        HStack {
            Text("Ingressos")
                .font(DSTypography.title1(weight: .bold))
                .foregroundColor(DSColors.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, DSSpacing.m)
        .padding(.top, DSSpacing.m)
        .padding(.bottom, DSSpacing.l)
    }
}

