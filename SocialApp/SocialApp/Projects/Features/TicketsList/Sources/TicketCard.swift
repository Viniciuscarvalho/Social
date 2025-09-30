import SwiftUI

public struct TicketCard: View {
    let ticket: Ticket
    let onTap: () -> Void
    
    public init(ticket: Ticket, onTap: @escaping () -> Void) {
        self.ticket = ticket
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 18) {
                // Ticket type icon with improved styling
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue.opacity(0.1))
                            .frame(width: 50, height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.blue.opacity(0.3), lineWidth: 1)
                            )
                        
                        Image(systemName: "ticket.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    Text(ticket.ticketType.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(width: 66)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(ticket.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Text("R$ \(ticket.price, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        if let discountPercentage = ticket.discountPercentage {
                            Text("-\(discountPercentage, specifier: "%.0f")%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(.green.opacity(0.15))
                                        .overlay(
                                            Capsule()
                                                .stroke(.green.opacity(0.4), lineWidth: 0.8)
                                        )
                                )
                                .foregroundColor(.green)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text("Válido até: \(ticket.validUntil, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(ticket.status.color).opacity(0.15))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(Color(ticket.status.color), lineWidth: 2)
                            )
                        
                        Circle()
                            .fill(Color(ticket.status.color))
                            .frame(width: 12, height: 12)
                    }
                    
                    Text(ticket.status.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray6).opacity(0.5), lineWidth: 0.8)
        )
    }

    private func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ \(value)"
    }

    private func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.locale = Locale(identifier: "pt_BR")
        return df.string(from: date)
    }
}
