import ComposableArchitecture
import SwiftUI

public struct SellerProfileView: View {
    @Bindable var store: StoreOf<SellerProfileFeature>
    
    public init(store: StoreOf<SellerProfileFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            if store.isLoading {
                loadingView
            } else if let profile = store.profile {
                profileContentView(profile)
            } else {
                errorView
            }
        }
        .navigationTitle("Vendedor")
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Carregando perfil...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private func profileContentView(_ profile: SellerProfile) -> some View {
        VStack(spacing: 20) {
            // Profile Image
            AsyncImage(url: URL(string: profile.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    )
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            
            // Profile Info
            VStack(spacing: 8) {
                Text(profile.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                if let title = profile.title {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if profile.isVerified {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                        Text("Verified")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Stats
            HStack(spacing: 40) {
                VStack {
                    Text("\(profile.followersCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Seguidores")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(profile.followingCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Seguindo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(profile.ticketsCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Ingressos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Tickets do Vendedor
            if !profile.tickets.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ingressos Disponíveis")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(profile.tickets.prefix(5)) { ticket in
                                ticketCardView(ticket)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func ticketCardView(_ ticket: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ticket.ticketType.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
                
                Spacer()
                
                Text("$\(Int(ticket.price))")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Text(ticket.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "circle.fill")
                    .font(.caption2)
                    .foregroundColor(ticket.status == .available ? .green : .orange)
                
                Text(ticket.status.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .frame(width: 160)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Erro ao carregar perfil")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Tentar Novamente") {
                store.send(.loadProfile)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
