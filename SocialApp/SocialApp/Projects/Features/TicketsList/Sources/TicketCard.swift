import SwiftUI
import SharedModels

struct TicketCard: View {
    let ticket: Ticket
    let onTap: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "ticket")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                    .padding(8)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center) {
                        Text(ticket.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        Spacer()

                        Button(action: onFavorite) {
                            Image(systemName: ticket.isFavorited ? "heart.fill" : "heart")
                                .foregroundColor(ticket.isFavorited ? .red : .secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    HStack(spacing: 8) {
                        Text(ticket.ticketType.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Capsule())

                        Text(ticket.status.displayName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    HStack(alignment: .firstTextBaseline) {
                        Text(formatPrice(ticket.price))
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        if let discount = ticket.discountPercentage {
                            Text(String(format: "-%.0f%%", discount))
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.15))
                                .clipShape(Capsule())
                        }

                        Spacer()

                        Text("Válido até \(formatDate(ticket.validUntil))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
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
