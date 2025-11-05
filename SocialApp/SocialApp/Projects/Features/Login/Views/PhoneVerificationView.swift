import SwiftUI
import ComposableArchitecture

public struct PhoneVerificationView: View {
    @Bindable var store: StoreOf<PhoneVerificationFeature>
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCodeFieldFocused: Bool
    
    public init(store: StoreOf<PhoneVerificationFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Content
                ScrollView {
                    VStack(spacing: 32) {
                        // Icon
                        iconSection
                        
                        // Title and description
                        textSection
                        
                        // Phone input or code input
                        if !store.isCodeSent {
                            phoneInputSection
                        } else {
                            codeInputSection
                        }
                        
                        // Resend code button
                        if store.isCodeSent {
                            resendSection
                        }
                        
                        // Action button
                        actionButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .alert("Erro", isPresented: $store.showingErrorAlert) {
            Button("OK") {
                store.send(.dismissErrorAlert)
            }
        } message: {
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
        }
        .overlay(
            Group {
                if store.verificationSuccess {
                    successOverlay
                }
            }
        )
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Icon Section
    
    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.green.opacity(0.3), Color.teal.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
            
            Image(systemName: "phone.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Text Section
    
    private var textSection: some View {
        VStack(spacing: 12) {
            Text(store.isCodeSent ? "Verificar Telefone" : "Adicionar Telefone")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(store.isCodeSent ? 
                 "Digite o código enviado por SMS para\n\(store.phoneNumber)" :
                 "Digite seu número de telefone para receber\no código de verificação"
            )
            .font(.system(size: 15))
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
        }
    }
    
    // MARK: - Phone Input Section
    
    private var phoneInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Número de Telefone")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            HStack(spacing: 12) {
                // Country code
                HStack(spacing: 4) {
                    Text("🇧🇷")
                        .font(.system(size: 24))
                    Text("+55")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
                
                // Phone number field
                TextField("(11) 99999-9999", text: $store.phoneNumber)
                    .keyboardType(.phonePad)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                            )
                    )
                    .onChange(of: store.phoneNumber) { oldValue, newValue in
                        // Format phone number
                        let digits = newValue.filter { $0.isNumber }
                        if digits.count <= 11 {
                            store.phoneNumber = formatPhoneNumber(digits)
                        } else {
                            store.phoneNumber = oldValue
                        }
                    }
            }
        }
    }
    
    private func formatPhoneNumber(_ digits: String) -> String {
        guard !digits.isEmpty else { return "" }
        
        var formatted = ""
        let count = digits.count
        
        if count <= 2 {
            formatted = "(\(digits)"
        } else if count <= 6 {
            let area = digits.prefix(2)
            let number = digits.dropFirst(2)
            formatted = "(\(area)) \(number)"
        } else if count <= 10 {
            let area = digits.prefix(2)
            let first = digits.dropFirst(2).prefix(4)
            let second = digits.dropFirst(6)
            formatted = "(\(area)) \(first)-\(second)"
        } else {
            let area = digits.prefix(2)
            let first = digits.dropFirst(2).prefix(5)
            let second = digits.dropFirst(7)
            formatted = "(\(area)) \(first)-\(second)"
        }
        
        return formatted
    }
    
    // MARK: - Code Input Section
    
    private var codeInputSection: some View {
        VStack(spacing: 16) {
            // Code input field
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                store.verificationCode.count > index ? Color.green : Color.white.opacity(0.3),
                                lineWidth: 2
                            )
                            .frame(width: 48, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                            )
                        
                        if store.verificationCode.count > index {
                            Text(String(store.verificationCode[store.verificationCode.index(store.verificationCode.startIndex, offsetBy: index)]))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            
            // Hidden text field for input
            TextField("", text: $store.verificationCode)
                .keyboardType(.numberPad)
                .focused($isCodeFieldFocused)
                .opacity(0)
                .frame(height: 0)
                .onChange(of: store.verificationCode) { oldValue, newValue in
                    // Limitar a 6 dígitos
                    if newValue.count > 6 {
                        store.verificationCode = String(newValue.prefix(6))
                    }
                    // Apenas números
                    store.verificationCode = newValue.filter { $0.isNumber }
                }
            
            // Tap to focus
            Color.clear
                .frame(height: 1)
                .contentShape(Rectangle())
                .onTapGesture {
                    isCodeFieldFocused = true
                }
        }
        .onAppear {
            isCodeFieldFocused = true
        }
    }
    
    // MARK: - Resend Section
    
    private var resendSection: some View {
        VStack(spacing: 8) {
            if store.countdown > 0 {
                Text("Reenviar código em \(store.countdownText)")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            } else {
                Button {
                    store.send(.sendVerificationCode)
                } label: {
                    Text("Não recebeu o código?")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    + Text(" ")
                    + Text("Reenviar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                }
                .disabled(store.isSendingCode)
            }
        }
    }
    
    // MARK: - Action Button
    
    private var actionButton: some View {
        Button {
            if store.isCodeSent {
                store.send(.verifyCode)
            } else {
                store.send(.sendVerificationCode)
            }
        } label: {
            HStack {
                if store.isSendingCode || store.isVerifying {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                    Text(store.isSendingCode ? "Enviando..." : "Verificando...")
                } else {
                    Text(store.isCodeSent ? "Verificar" : "Enviar Código")
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: (store.isCodeSent ? store.canVerify : store.canSendCode) ? 
                        [Color.green, Color.teal] : [Color.gray, Color.gray.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .disabled(store.isCodeSent ? !store.canVerify : !store.canSendCode)
    }
    
    // MARK: - Success Overlay
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Telefone Verificado!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Seu número foi verificado com sucesso")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
            )
            .padding(40)
        }
    }
}

#Preview {
    PhoneVerificationView(
        store: Store(
            initialState: PhoneVerificationFeature.State()
        ) {
            PhoneVerificationFeature()
        }
    )
}



