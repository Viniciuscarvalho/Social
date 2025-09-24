import SwiftUI

struct EventDetailDestinationView: View {
    let eventId: UUID
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Event placeholder image
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        VStack {
                            Image(systemName: "calendar.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            Text("Event Image")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Detalhes do Evento")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Event ID: \(eventId.uuidString.prefix(8))...")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(title: "Nome", value: "Sample Event Name")
                        InfoRow(title: "Local", value: "Sample Venue")
                        InfoRow(title: "Data", value: "Em breve")
                        InfoRow(title: "Preço", value: "$240")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                    
                    Text("Esta tela será implementada com dados reais do evento em breve.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                }
            }
            .padding()
        }
        .navigationTitle("Evento")
        .navigationBarTitleDisplayMode(.large)
    }
}
