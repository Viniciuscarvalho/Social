import SwiftUI

struct ProfilePlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Perfil")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Gerencie sua conta, preferências e histórico de compras.")
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
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.large)
    }
}
