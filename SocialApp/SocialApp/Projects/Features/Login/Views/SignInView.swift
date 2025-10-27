import SwiftUI
import ComposableArchitecture

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
                    Text("Sign In")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Let's get you back in.")
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
                            TextField("Enter your email", text: .init(
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
                                Text("Enter valid email")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 16)
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if isPasswordVisible {
                                    TextField("Enter password", text: .init(
                                        get: { store.password },
                                        set: { store.send(.passwordChanged($0)) }
                                    ))
                                } else {
                                    SecureField("Enter password", text: .init(
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
                                Text("Enter valid password")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 16)
                            }
                        }
                        
                        // Forgot Password Link
                        HStack {
                            Spacer()
                            Button(action: { showForgotPassword = true }) {
                                Text("Forgot Password")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Sign In Button
                        Button(action: {
                            store.send(.signInTapped(email: store.email, password: store.password))
                        }) {
                            Text("Sign In")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(AppColors.primary)
                                .cornerRadius(12)
                        }
                        .disabled(store.email.isEmpty || store.password.isEmpty || !isValidEmail(store.email) || store.password.count < 6)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Or Sign In With
                        VStack(spacing: 16) {
                            HStack {
                                VStack(spacing: 0) { Color(.systemGray3).frame(height: 1) }
                                Text("Or sign in with")
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
                                        Text("Google")
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
                                        Text("Apple")
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
                    Text("Don't have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Button(action: { showSignUp = true }) {
                        Text("Sign Up")
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
                            Text(step == .success ? "" : "Back")
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
                Text("Reset Password")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Enter your email to receive a password reset link.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("Enter your email", text: $email)
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
                Text("Continue")
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
                Text("Create New Password")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Set a strong password to secure your account.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            // New Password
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if isPasswordVisible {
                        TextField("Enter new password", text: $newPassword)
                    } else {
                        SecureField("Enter new password", text: $newPassword)
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
                        TextField("Enter confirm password", text: $confirmPassword)
                    } else {
                        SecureField("Enter confirm password", text: $confirmPassword)
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
                Text("Reset Password")
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
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(.green)
                    )
                
                VStack(alignment: .center, spacing: 8) {
                    Text("Successful")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Your new password has been set successfully!")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.primary)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}

