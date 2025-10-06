import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreeToTerms = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
                // Header com botão de voltar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                .padding(.top, 10)
                
                VStack(spacing: 4) {
                    Text("SocialClub")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white)
                    
                    Text("Onde você encontra alguém para \nficar com seu ingresso")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
                
                Spacer()
                
                // Form Card
                VStack(alignment: .leading, spacing: 20) {
                    Text("Cadastre-se")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    VStack(spacing: 16) {
                        CustomTextField(placeholder: "Nome", text: $name)
                        CustomTextField(placeholder: "Email", text: $email)
                        CustomTextField(placeholder: "Senha", text: $password, isSecure: true)
                        CustomTextField(placeholder: "Confirme a Senha", text: $confirmPassword, isSecure: true)
                    }
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            agreeToTerms.toggle()
                        }) {
                            Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreeToTerms ? .black : .gray)
                                .font(.system(size: 20))
                        }
                        
                        Text("Eu aceito ")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        +
                        Text("Termos e Condições")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    Button(action: handleSignUp) {
                        Text("Cadastrar")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.black)
                            .cornerRadius(25)
                    }
                    .padding(.top, 8)
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
    }
    
    func handleSignUp() {
        guard !name.isEmpty else {
            alertMessage = "Por favor, insira seu nome"
            showAlert = true
            return
        }
        
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
        
        guard password == confirmPassword else {
            alertMessage = "As senhas não coincidem"
            showAlert = true
            return
        }
        
        guard agreeToTerms else {
            alertMessage = "Você precisa concordar com os Termos e Condições"
            showAlert = true
            return
        }
        
        authManager.signUp(name: name, email: email, password: password)
        dismiss()
    }
}
