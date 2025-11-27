import SwiftUI
import DesignSystem

struct SplashView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            DSGradients.backgroundMain
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Imagem do splash - responsiva para todos os tamanhos de tela
                Image("splash")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        maxWidth: horizontalSizeClass == .compact ? .infinity : 400,
                        maxHeight: UIScreen.main.bounds.height * 0.4
                    )
                    .padding(.horizontal, 24)
                    .clipped()
                
                Spacer()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .padding(.bottom, 30)
            }
        }
    }
}
