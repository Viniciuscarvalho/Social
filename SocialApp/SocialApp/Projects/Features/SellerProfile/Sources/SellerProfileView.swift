import ComposableArchitecture
import SwiftUI

public struct SellerProfileView: View {
    @Bindable var store: StoreOf<SellerProfileFeature>
    
    public init(store: StoreOf<SellerProfileFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "0f0f1e")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if store.isLoading {
                loadingView
            } else if let profile = store.profile {
                ScrollView {
                    VStack(spacing: 16) {
                        profileHeaderView(profile)
                        statsCardsView(profile)
                        
                        if !profile.tickets.isEmpty {
                            ticketsSection(profile)
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            } else {
                errorView
            }
        }
        .navigationTitle("Vendedor")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            store.send(.loadProfileById(ticketDetail.seller.id))
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            Text("Carregando perfil...")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private func profileHeaderView(_ profile: User) -> some View {
        HStack(spacing: 16) {
            // Profile Image
            AsyncImage(url: URL(string: profile.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4a90e2"), Color(hex: "357abd")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 70, height: 70)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
            )
            
            // Profile Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(profile.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if profile.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "4a90e2"))
                    }
                }
                
                if let title = profile.title {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Text("Seja bem-vindo")
                    .font(.caption)
                    .foregroundColor(Color(hex: "a0f064"))
            }
            
            Spacer()
            
            // Trophy Icon
            Image(systemName: "trophy.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "a0f064"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func statsCardsView(_ profile: User) -> some View {
        VStack(spacing: 12) {
            statsCard(
                title: "Seguidores",
                value: "\(profile.followersCount)",
                total: profile.followingCount + profile.followersCount,
                progress: Double(profile.followersCount) / Double(max(profile.followersCount + profile.followingCount, 1)),
                color: Color(hex: "a0f064"),
                showSeeAll: false
            )
            
            statsCard(
                title: "Ingressos",
                value: "\(profile.ticketsCount)",
                total: profile.ticketsCount + 50,
                progress: Double(profile.ticketsCount) / Double(max(profile.ticketsCount + 50, 1)),
                color: Color(hex: "4a90e2"),
                showSeeAll: true
            )
        }
    }
    
    private func statsCard(title: String, value: String, total: Int, progress: Double, color: Color, showSeeAll: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                if showSeeAll {
                    Text("Ver tudo")
                        .font(.caption)
                        .foregroundColor(color)
                }
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("/ \(total)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 4)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .foregroundColor(color)
                    .padding(.bottom, 4)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func ticketsSection(_ profile: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ingressos Disponíveis")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Ver tudo")
                    .font(.caption)
                    .foregroundColor(Color(hex: "4a90e2"))
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                ForEach(profile.tickets.prefix(3)) { ticket in
                    ticketRowView(ticket)
                }
            }
        }
    }
    
    private func ticketRowView(_ ticket: Ticket) -> some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(Color(hex: "4a90e2").opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "ticket.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "4a90e2"))
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(ticket.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(ticket.ticketType.displayName)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 3, height: 3)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(ticket.status == .available ? Color(hex: "a0f064") : .orange)
                            .frame(width: 6, height: 6)
                        
                        Text(ticket.status.displayName)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            Spacer()
            
            // Price and Arrow
            HStack(spacing: 8) {
                Text("$\(Int(ticket.price))")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Erro ao carregar perfil")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Button("Tentar Novamente") {
                store.send(.loadProfile)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "4a90e2"))
        }
        .padding()
    }
}


