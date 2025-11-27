import SwiftUI
import ComposableArchitecture
import DesignSystem

struct SignInView: View {
    @Bindable var store: StoreOf<SignInForm>
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var isPasswordVisible = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "signin.title"))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(String(localized: "signin.subtitle"))
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
                
                // Form
                ScrollView {
                    VStack(spacing: 16) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            TextField(String(localized: "signin.email.placeholder"), text: .init(
                                get: { store.email },
                                set: { store.send(.emailChanged($0)) }
                            ))
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(store.email.isEmpty ? Color.clear : isValidEmail(store.email) ? Color.green : Color.red, lineWidth: 1)
                            )
                            
                            if !store.email.isEmpty && !isValidEmail(store.email) {
                                Text(String(localized: "signin.email.invalid"))
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 16)
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if isPasswordVisible {
                                    TextField(String(localized: "signin.password.placeholder"), text: .init(
                                        get: { store.password },
                                        set: { store.send(.passwordChanged($0)) }
                                    ))
                                } else {
                                    SecureField(String(localized: "signin.password.placeholder"), text: .init(
                                        get: { store.password },
                                        set: { store.send(.passwordChanged($0)) }
                                    ))
                                }
                                
                                Button(action: { isPasswordVisible.toggle() }) {
                                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.trailing, 12)
                            }
                            .padding(.vertical, 12)
                            .padding(.leading, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(store.password.isEmpty ? Color.clear : store.password.count >= 6 ? Color.green : Color.red, lineWidth: 1)
                            )
                            
                            if !store.password.isEmpty && store.password.count < 6 {
                                Text(String(localized: "signin.password.invalid"))
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 16)
                            }
                        }
                        
                        // Forgot Password Link
                        HStack {
                            Spacer()
                            Button(action: { showForgotPassword = true }) {
                                Text(String(localized: "signin.forgotPassword"))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Sign In Button
                        Button(action: {
                            store.send(.signInTapped(email: store.email, password: store.password))
                        }) {
                            Text(String(localized: "signin.cta"))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(DSColors.primary)
                                .cornerRadius(12)
                        }
                        .disabled(store.email.isEmpty || store.password.isEmpty || !isValidEmail(store.email) || store.password.count < 6)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Or Sign In With
                        VStack(spacing: 16) {
                            HStack {
                                VStack(spacing: 0) { Color(.systemGray3).frame(height: 1) }
                                Text(String(localized: "signin.orWith"))
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                VStack(spacing: 0) { Color(.systemGray3).frame(height: 1) }
                            }
                            .padding(.horizontal, 16)
                            
                            // Social Buttons
                            HStack(spacing: 16) {
                                Button(action: {}) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "globe")
                                        Text(String(localized: "signin.google"))
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .border(Color(.systemGray3), width: 1)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {}) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "apple.logo")
                                        Text(String(localized: "signin.apple"))
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .border(Color(.systemGray3), width: 1)
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 24)
                    }
                    .padding(.bottom, 32)
                }
                
                Spacer()
                
                // Sign Up Link
                HStack(spacing: 4) {
                    Text(String(localized: "signin.link.noAccount"))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Button(action: { showSignUp = true }) {
                        Text(String(localized: "signin.link.signUp"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.bottom, 20)
            }
        }
        .alert("Erro", isPresented: .init(
            get: { store.showAlert },
            set: { _ in store.send(.alertDismissed) }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(store.alertMessage)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView(store: Store(initialState: SignUpForm.State()) {
                SignUpForm()
            })
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var step: ForgotPasswordStep = .email
    @State private var email = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    enum ForgotPasswordStep {
        case email
        case createPassword
        case success
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        if step == .email {
                            dismiss()
                        } else {
                            withAnimation {
                                step = step == .createPassword ? .email : .createPassword
                            }
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text(step == .success ? "" : String(localized: "common.back"))
                        }
                        .foregroundColor(.blue)
                    }
                    .opacity(step == .success ? 0 : 1)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        switch step {
                        case .email:
                            emailStepContent
                        case .createPassword:
                            createPasswordStepContent
                        case .success:
                            successStepContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
                
                Spacer()
            }
        }
    }
    
    private var emailStepContent: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "signin.reset.title"))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(String(localized: "signin.reset.subtitle"))
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextField(String(localized: "signin.email.placeholder"), text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(email.isEmpty ? Color.clear : isValidEmail(email) ? Color.green : Color.red, lineWidth: 1)
                    )
            }
            
            Button(action: {
                withAnimation {
                    step = .createPassword
                }
            }) {
                Text(String(localized: "signin.reset.continue"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.primary)
                    .cornerRadius(12)
            }
            .disabled(email.isEmpty || !isValidEmail(email))
            
            Spacer()
        }
    }
    
    private var createPasswordStepContent: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "signin.create.title"))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(String(localized: "signin.create.subtitle"))
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            // New Password
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if isPasswordVisible {
                        TextField(String(localized: "signin.newPassword.placeholder"), text: $newPassword)
                    } else {
                        SecureField(String(localized: "signin.newPassword.placeholder"), text: $newPassword)
                    }
                    
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing, 12)
                }
                .padding(.vertical, 12)
                .padding(.leading, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(newPassword.isEmpty ? Color.clear : newPassword.count >= 6 ? Color.green : Color.red, lineWidth: 1)
                )
            }
            
            // Confirm Password
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if isConfirmPasswordVisible {
                        TextField(String(localized: "signin.confirmNewPassword.placeholder"), text: $confirmPassword)
                    } else {
                        SecureField(String(localized: "signin.confirmNewPassword.placeholder"), text: $confirmPassword)
                    }
                    
                    Button(action: { isConfirmPasswordVisible.toggle() }) {
                        Image(systemName: isConfirmPasswordVisible ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing, 12)
                }
                .padding(.vertical, 12)
                .padding(.leading, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(confirmPassword.isEmpty ? Color.clear : confirmPassword == newPassword ? Color.green : Color.red, lineWidth: 1)
                )
            }
            
            Button(action: {
                withAnimation {
                    step = .success
                }
            }) {
                Text(String(localized: "signin.reset.cta"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.primary)
                    .cornerRadius(12)
            }
            .disabled(newPassword.isEmpty || confirmPassword.isEmpty || newPassword != confirmPassword || newPassword.count < 6)
            
            Spacer()
        }
    }
    
    private var successStepContent: some View {
        SuccessView(
            icon: "check_successfull",
            iconColor: .green,
            useCustomIcon: true,
            title: String(localized: "success.password_reset.title"),
            message: String(localized: "success.password_reset.message"),
            buttonTitle: String(localized: "success.password_reset.button"),
            buttonAction: {
                dismiss()
            }
        )
        .padding(40)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}

