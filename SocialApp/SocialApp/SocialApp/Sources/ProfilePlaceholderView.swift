import SwiftUI

struct ProfilePlaceholderView: View {
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        VStack(spacing: 30) {
            // Header do perfil
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
            }
            
            // Seção de configurações
            VStack(spacing: 16) {
                Text("Configurações")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                // Botão de troca de tema
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        themeManager.toggleColorScheme()
                    }
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: themeIcon)
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 28, height: 28)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Aparência")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text(themeManager.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
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
    
    private var themeIcon: String {
        switch themeManager.colorScheme {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .none:
            return "circle.lefthalf.striped.horizontal"
        }
    }
}
