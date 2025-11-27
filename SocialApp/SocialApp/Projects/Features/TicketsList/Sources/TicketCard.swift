import SwiftUI
import DesignSystem

public struct TicketCard: View {
    let ticket: Ticket
    let onTap: () -> Void
    var onDelete: (() -> Void)? = nil
    
    public init(ticket: Ticket, onTap: @escaping () -> Void, onDelete: (() -> Void)? = nil) {
        self.ticket = ticket
        self.onTap = onTap
        self.onDelete = onDelete
    }
    
    public var body: some View {
        DSCard {
            Button(action: onTap) {
                HStack(spacing: DSSpacing.m) {
                    // Ícone colorido à esquerda
                    ZStack {
                        RoundedRectangle(cornerRadius: DSRadius.small)
                            .fill(ticketTypeBackgroundColor(ticket.ticketType))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: ticketTypeIcon(ticket.ticketType))
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(ticketTypeColor(ticket.ticketType))
                    }
                    
                    // Informações no meio
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text(ticket.name)
                            .font(DSTypography.body(weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                            .lineLimit(2)
                        
                        // Descrição baseada no tipo de ticket
                        Text(ticketDescription(for: ticket.ticketType))
                            .font(DSTypography.footnote())
                            .foregroundColor(DSColors.textSecondary)
                            .lineLimit(1)
                        
                        HStack(spacing: DSSpacing.xxs) {
                            Image(systemName: "calendar")
                                .font(.system(size: 11))
                                .foregroundColor(DSColors.textSecondary)
                            Text("Valid until \(formatShortDate(ticket.validUntil))")
                                .font(DSTypography.caption1())
                                .foregroundColor(DSColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Preço à direita
                    Text("$\(Int(ticket.price))")
                        .font(DSTypography.headline(weight: .bold))
                        .foregroundColor(DSColors.primary)
                }
            }
            .buttonStyle(.plain)
        }
        .swipeActions(edge: .trailing) {
            if let onDelete = onDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Deletar", systemImage: "trash.fill")
                }
            }
        }
    }
    
    private func ticketTypeIcon(_ type: TicketType) -> String {
        switch type {
        case .vip:
            return "crown.fill"
        case .general:
            return "person.3.fill"
        case .earlyBird:
            return "sunrise.fill"
        case .group:
            return "person.2.fill"
        case .student:
            return "graduationcap.fill"
        case .senior:
            return "star.fill"
        }
    }
    
    private func ticketTypeColor(_ type: TicketType) -> Color {
        switch type {
        case .vip:
            return Color.purple
        case .general:
            return Color.green
        case .earlyBird:
            return Color.orange
        case .group:
            return Color.blue
        case .student:
            return Color.indigo
        case .senior:
            return Color.cyan
        }
    }
    
    private func ticketTypeBackgroundColor(_ type: TicketType) -> Color {
        switch type {
        case .vip:
            return Color.purple.opacity(0.15)
        case .general:
            return Color.green.opacity(0.15)
        case .earlyBird:
            return Color.orange.opacity(0.15)
        case .group:
            return Color.blue.opacity(0.15)
        case .student:
            return Color.indigo.opacity(0.15)
        case .senior:
            return Color.cyan.opacity(0.15)
        }
    }
    
    
    private func formatShortDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        df.locale = Locale(identifier: "en_US")
        return df.string(from: date)
    }
    
    private func ticketDescription(for type: TicketType) -> String {
        switch type {
        case .vip:
            return "Front row access with meet & greet"
        case .general:
            return "Standing area - Pista access"
        case .earlyBird:
            return "Early bird special pricing"
        case .group:
            return "Group discount available"
        case .student:
            return "Student discount with valid ID"
        case .senior:
            return "Senior citizen discount"
        }
    }
}
