import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSignUp = false
    
    var body: some View {
        ZStack {
            // Gradiente de fundo mais visível
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Header
                VStack(spacing: 8) {
                    Text("SocialClub")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white)
                    
                    Text("Onde você encontra alguém para \nficar com seu ingresso")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Form Card
                VStack(alignment: .leading, spacing: 20) {
                    Text("Bem vindo.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    VStack(spacing: 16) {
                        CustomTextField(placeholder: "Email", text: $email)
                        CustomTextField(placeholder: "Senha", text: $password, isSecure: true)
                    }
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            rememberMe.toggle()
                        }) {
                            Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                .foregroundColor(rememberMe ? .black : .gray)
                                .font(.system(size: 20))
                        }
                        
                        Text("Lembrar-se")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: handleSignIn) {
                        Text("Entrar")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.black)
                            .cornerRadius(25)
                    }
                    .padding(.top, 8)
                    
                    Button(action: {
                        showSignUp = true
                    }) {
                        Text("Não possui conta?")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text("Sign up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
            }
        }
        .alert("Atenção", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView()
                .environmentObject(authManager)
        }
    }
    
    func handleSignIn() {
        guard !email.isEmpty else {
            alertMessage = "Por favor, insira seu email"
            showAlert = true
            return
        }
        
        guard !password.isEmpty else {
            alertMessage = "Por favor, insira sua senha"
            showAlert = true
            return
        }
        
        authManager.signIn(email: email, password: password)
    }
}

