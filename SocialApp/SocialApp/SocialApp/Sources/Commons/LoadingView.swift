import SwiftUI

/// View genérica para estados de carregamento
public struct LoadingView: View {
    let message: String
    let showSpinner: Bool
    
    public init(
        message: String = "Carregando...",
        showSpinner: Bool = true
    ) {
        self.message = message
        self.showSpinner = showSpinner
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            if showSpinner {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.blue)
            }
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

/// View de loading com overlay (para usar sobre outras views)
public struct LoadingOverlay: View {
    let message: String
    let backgroundColor: Color
    
    public init(
        message: String = "Carregando...",
        backgroundColor: Color = Color.black.opacity(0.3)
    ) {
        self.message = message
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.7))
            )
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        LoadingView(message: "Carregando eventos...")
            .frame(height: 200)
        
        LoadingView(message: "Salvando dados...", showSpinner: false)
            .frame(height: 200)
    }
    .padding()
}

#Preview("Overlay") {
    ZStack {
        // Conteúdo de exemplo
        VStack {
            Text("Conteúdo da tela")
                .font(.title)
            Text("Esta seria a tela normal")
                .foregroundColor(.secondary)
        }
        
        // Loading overlay
        LoadingOverlay(message: "Processando...")
    }
}


