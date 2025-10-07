import ComposableArchitecture
import SwiftUI

struct SignUpView: View {
    @Bindable var store: StoreOf<SignUpForm>
    @Environment(\.dismiss) var dismiss
    
    @State private var agreeToTerms = false
    
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
                        CustomTextField(
                            placeholder: "Nome", 
                            text: .init(
                                get: { store.name },
                                set: { store.send(.nameChanged($0)) }
                            )
                        )
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
                        CustomTextField(
                            placeholder: "Confirme a Senha", 
                            text: .init(
                                get: { store.confirmPassword },
                                set: { store.send(.confirmPasswordChanged($0)) }
                            ),
                            isSecure: true
                        )
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
                    
                    Button(action: {
                        guard agreeToTerms else {
                            store.send(.showAlert("Você precisa concordar com os Termos e Condições"))
                            return
                        }
                        store.send(.signUpTapped(name: store.name, email: store.email, password: store.password))
                        dismiss()
                    }) {
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
        .alert("Atenção", isPresented: .init(
            get: { store.showAlert },
            set: { _ in store.send(.alertDismissed) }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(store.alertMessage)
        }
    }
}
