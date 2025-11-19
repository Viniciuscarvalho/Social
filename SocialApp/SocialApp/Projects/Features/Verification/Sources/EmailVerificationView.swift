import SwiftUI
import ComposableArchitecture

public struct EmailVerificationView: View {
    @Bindable var store: StoreOf<EmailVerificationFeature>
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCodeFieldFocused: Bool
    
    public init(store: StoreOf<EmailVerificationFeature>) {
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
                        
                        // Code input or send button
                        if store.isCodeSent {
                            codeInputSection
                        } else {
                            sendCodeButton
                        }
                        
                        // Resend code button
                        if store.isCodeSent {
                            resendSection
                        }
                        
                        // Verify button
                        if store.isCodeSent {
                            verifyButton
                        }
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
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
            
            Image(systemName: "envelope.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Text Section
    
    private var textSection: some View {
        VStack(spacing: 12) {
            Text(String(localized: "emailverify.title"))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(String(format: String(localized: "emailverify.subtitle"), store.email))
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Send Code Button
    
    private var sendCodeButton: some View {
        Button {
            store.send(.sendVerificationCode)
        } label: {
            HStack {
                if store.isSendingCode {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                    Text("Enviando...")
                } else {
                    Text("Enviar Código")
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .disabled(store.isSendingCode)
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
                                store.verificationCode.count > index ? Color.blue : Color.white.opacity(0.3),
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
            TextField("", text: Binding(
                get: { store.verificationCode },
                set: { newValue in
                    store.send(.updateVerificationCode(newValue))
                }
            ))
                .keyboardType(.numberPad)
                .focused($isCodeFieldFocused)
                .opacity(0)
                .frame(height: 0)
            
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
                    Text(String(localized: "emailverify.resend.prompt"))
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    + Text(" ")
                    + Text(String(localized: "emailverify.resend.cta"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .disabled(store.isSendingCode)
            }
        }
    }
    
    // MARK: - Verify Button
    
    private var verifyButton: some View {
        Button {
            store.send(.verifyCode)
        } label: {
            HStack {
                if store.isVerifying {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                    Text("Verificando...")
                } else {
                    Text(String(localized: "emailverify.cta"))
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: store.canVerify ? [Color.blue, Color.purple] : [Color.gray, Color.gray.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .disabled(!store.canVerify)
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
                
                Text("E-mail Verificado!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Sua conta foi verificada com sucesso")
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

