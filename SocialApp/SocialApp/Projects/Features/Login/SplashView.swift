import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                Text("SocialClub")
                    .font(.system(size: 48, weight: .light, design: .default))
                    .foregroundColor(.white)
                
                Text("Onde você encontra alguém para ficar com seu ingresso")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .padding(.top, 30)
            }
        }
    }
}
