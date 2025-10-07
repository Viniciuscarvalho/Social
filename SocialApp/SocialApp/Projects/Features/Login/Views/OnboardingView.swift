import SwiftUI

struct OnboardingView: View {
    let onSignUpTapped: () -> Void
    let onSignInTapped: () -> Void
    
    @State private var currentPage = 0
    
    init(onSignUpTapped: @escaping () -> Void = {}, onSignInTapped: @escaping () -> Void = {}) {
        self.onSignUpTapped = onSignUpTapped
        self.onSignInTapped = onSignInTapped
    }
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            VStack {
                // Header
                VStack(spacing: 4) {
                    Text("SocialClub")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white)
                    
                    Text("Negocie seus ingressos")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Ticket Image Placeholder
                Image(systemName: "ticket.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .foregroundColor(.gray.opacity(0.3))
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Bottom Card
                VStack(alignment: .leading, spacing: 20) {
                    Text("Onde você encontra alguém para \nficar com seu ingresso")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Explore.")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Aqui você vai achar alguém que queira ficar \ncom seu ingresso, sem precisar sair de casa.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Button(action: onSignUpTapped) {
                            Text("Cadastre-se")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.black)
                                .cornerRadius(25)
                        }
                        .padding(.top, 8)
                        
                        Button(action: onSignInTapped) {
                            Text("Já possui conta?")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Text("Entrar")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
            }
        }
    }
}

#Preview {
    OnboardingView(
        onSignUpTapped: { print("Sign up tapped") },
        onSignInTapped: { print("Sign in tapped") }
    )
}
