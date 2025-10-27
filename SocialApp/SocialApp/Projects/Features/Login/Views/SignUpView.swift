import ComposableArchitecture
import SwiftUI

struct SignUpView: View {
    @Bindable var store: StoreOf<SignUpForm>
    @Environment(\.dismiss) var dismiss
    
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var showInterests = false
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sign Up")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Hello! Welcome, fill your details")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                
                // Form
                ScrollView {
                    VStack(spacing: 16) {
                        // First Name
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Enter your first name", text: $firstName)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // Last Name
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Enter your last name", text: $lastName)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // Phone Number
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Enter phone number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // Email
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
                        
                        // Password
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
                        
                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if isConfirmPasswordVisible {
                                    TextField("Confirm password", text: .init(
                                        get: { store.confirmPassword },
                                        set: { store.send(.confirmPasswordChanged($0)) }
                                    ))
                                } else {
                                    SecureField("Confirm password", text: .init(
                                        get: { store.confirmPassword },
                                        set: { store.send(.confirmPasswordChanged($0)) }
                                    ))
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
                                    .stroke(store.confirmPassword.isEmpty ? Color.clear : store.confirmPassword == store.password ? Color.green : Color.red, lineWidth: 1)
                            )
                            
                            if !store.confirmPassword.isEmpty && store.confirmPassword != store.password {
                                Text("Passwords don't match")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 16)
                            }
                        }
                        
                        // Sign Up Button
                        Button(action: {
                            showInterests = true
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(AppColors.primary)
                                .cornerRadius(12)
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                
                Spacer()
                
                // Sign In Link
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Button(action: { dismiss() }) {
                        Text("Sign In")
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
        .fullScreenCover(isPresented: $showInterests) {
            SelectInterestsView(
                onInterestsSelected: { interests in
                    // Save interests and proceed
                    store.send(.signUpTapped(name: "\(firstName) \(lastName)", email: store.email, password: store.password))
                    saveInterests(interests)
                    dismiss()
                }
            )
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !phoneNumber.isEmpty &&
        !store.email.isEmpty &&
        !store.password.isEmpty &&
        !store.confirmPassword.isEmpty &&
        isValidEmail(store.email) &&
        store.password.count >= 6 &&
        store.password == store.confirmPassword
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
    
    private func saveInterests(_ interests: [String]) {
        if let encoded = try? JSONEncoder().encode(interests) {
            UserDefaults.standard.set(encoded, forKey: "userInterests")
        }
    }
}
