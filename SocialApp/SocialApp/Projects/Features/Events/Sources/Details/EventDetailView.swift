import SwiftUI
import ComposableArchitecture

public struct EventDetailView: View {
    @Bindable var store: StoreOf<EventDetailFeature>
    let eventId: UUID
    let event: Event? // ✅ Evento opcional para evitar chamada API
    
    public init(store: StoreOf<EventDetailFeature>, eventId: UUID, event: Event? = nil) {
        self.store = store
        self.eventId = eventId
        self.event = event
    }
    
    public var body: some View {
        Group {
            if store.isLoading {
                loadingView
            } else if let event = store.event {
                eventContentView(event)
            } else {
                errorView
            }
        }
        .onAppear {
            print("🎪 EventDetailView apareceu para evento: \(eventId)")
            store.send(.onAppear(eventId, event)) // ✅ Passa o evento se tiver
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Carregando evento...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
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
                    
                    // Botão Ingressos Disponíveis
                    Button {
                        store.send(.viewAvailableTickets)
                    } label: {
                        HStack {
                            Image(systemName: "ticket.fill")
                            Text("Ingressos Disponíveis")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 100) // Espaço para não ser coberto pela tabBar
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    store.send(.toggleFavorite)
                } label: {
                    Image(systemName: store.isFavorited ? "heart.fill" : "heart")
                        .foregroundColor(store.isFavorited ? .red : .gray)
                        .imageScale(.large)
                }
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
            
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Tentar Novamente") {
                store.send(.onAppear(eventId, event))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
