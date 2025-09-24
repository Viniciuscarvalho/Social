import ComposableArchitecture
import SwiftUI
import SharedModels

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
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(profile.followingCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Following")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(profile.ticketsCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Tickets")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
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
