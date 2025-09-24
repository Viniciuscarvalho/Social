import SwiftUI

struct FavoritesPlaceholderView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Favoritos")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Seus eventos e ingressos favoritos aparecerão aqui.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Text("Em desenvolvimento")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            .navigationTitle("Favoritos")
        }
    }
}
