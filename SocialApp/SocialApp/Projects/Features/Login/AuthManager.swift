import Foundation

final class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isFirstLaunch = true
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isAuthenticated = true
        }
        
        isFirstLaunch = UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == false
    }
    
    func signUp(name: String, email: String, password: String) {
        let user = User(name: name, email: email)
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            currentUser = user
            isAuthenticated = true
            isFirstLaunch = false
        }
    }
    
    func signIn(email: String, password: String) {
        let user = User( name: "User", email: email)
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
            currentUser = user
            isAuthenticated = true
        }
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
        currentUser = nil
        isAuthenticated = false
    }
}
