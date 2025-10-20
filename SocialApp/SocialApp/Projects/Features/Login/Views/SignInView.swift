import SwiftUI
import ComposableArchitecture

struct SignInView: View {
    @Bindable var store: StoreOf<SignInForm>
    @State private var showSignUp = false
    
    var body: some View {
        ZStack {
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
                        CustomTextField(
                            placeholder: "Email", 
                            text: .init(
                                get: { store.email },
                                set: { store.send(.emailChanged($0)) }
                            )
                        )
                        CustomTextField(
                            placeholder: "Senha", 
                            text: .init(
                                get: { store.password },
                                set: { store.send(.passwordChanged($0)) }
                            ),
                            isSecure: true
                        )
                    }
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            store.send(.rememberMeToggled)
                        }) {
                            Image(systemName: store.rememberMe ? "checkmark.square.fill" : "square")
                                .foregroundColor(store.rememberMe ? .black : .gray)
                                .font(.system(size: 20))
                        }
                        
                        Text("Lembrar-se")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        store.send(.signInTapped(email: store.email, password: store.password))
                    }) {
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
                    
                    // Botão de teste temporário para debug
                    Button(action: {
                        Task {
                            do {
                                let authClient = AuthClient.liveValue
                                try await authClient.testCredentials(store.email, store.password)
                            } catch {
                                print("❌ Erro no teste de credenciais: \(error)")
                            }
                        }
                    }) {
                        Text("🧪 Testar Credenciais (Debug)")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(15)
                    }
                    .padding(.top, 8)
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
            }
        }
        .alert("Atenção", isPresented: .init(
            get: { store.showAlert },
            set: { _ in store.send(.alertDismissed) }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(store.alertMessage)
        }
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView(store: Store(initialState: SignUpForm.State()) {
                SignUpForm()
            })
        }
    }
}

