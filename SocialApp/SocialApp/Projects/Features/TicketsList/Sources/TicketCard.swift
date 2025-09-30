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
            HStack(spacing: 16) {
                // Ticket type icon
                VStack {
                    Image(systemName: "ticket")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text(ticket.ticketType.displayName)
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticket.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("R$ \(ticket.price, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let discountPercentage = ticket.discountPercentage {
                            Text("-\(discountPercentage, specifier: "%.0f")%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text("Válido até: \(ticket.validUntil, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Circle()
                        .fill(Color(ticket.status.color))
                        .frame(width: 12, height: 12)
                    Text(ticket.status.displayName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
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
