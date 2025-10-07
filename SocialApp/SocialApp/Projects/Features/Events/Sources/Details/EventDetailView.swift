import SwiftUI
import ComposableArchitecture

struct EventDetailView: View {
    @Dependency(\.eventsClient) private var eventsClient
    let eventId: String
    @State private var event: Event?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Carregando evento...")
            } else if let event = event {
                eventContentView(event)
            } else {
                errorView
            }
        }
        .navigationTitle("Detalhes do Evento")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadEvent()
        }
    }
    
    private func loadEvent() async {
        do {
            let loadedEvent = try await eventsClient.fetchEvent(eventId)
            self.event = loadedEvent
            self.isLoading = false
        } catch {
            self.errorMessage = (error as? APIError)?.message ?? error.localizedDescription
            self.isLoading = false
        }
    }
    
    @ViewBuilder
    private func eventContentView(_ event: Event) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event Image
                AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                }
                .frame(height: 200)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(event.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let description = event.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Location
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(event.location.name)
                                .fontWeight(.semibold)
                            Text("\(event.location.city), \(event.location.state)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Price and Rating
                    HStack {
                        VStack(alignment: .leading) {
                            Text("A partir de")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(Int(event.startPrice))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        if let rating = event.rating {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", rating))
                                    .fontWeight(.semibold)
                                Text("(\(event.reviewCount ?? 0))")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Category
                    HStack {
                        Text(event.category.icon)
                        Text(event.category.displayName)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Erro ao carregar evento")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
