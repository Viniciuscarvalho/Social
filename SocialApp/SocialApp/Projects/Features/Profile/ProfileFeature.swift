import ComposableArchitecture
import Foundation

@Reducer
public struct ProfileFeature {
    @ObservableState
    public struct State: Equatable {
        public var user: User?
        public var isLoading = false
        public var showingEditProfile = false
        public var showingImagePicker = false
        public var notificationsEnabled = true
        public var emailNotifications = true
        public var pushNotifications = false
        public var error: String?
        
        public init() {}
    }
    
    public enum Action: Equatable {
        // Lifecycle
        case onAppear
        case loadUserProfile
        case userProfileResponse(Result<User, Error>)
        
        // Profile editing
        case editProfileTapped
        case setShowingEditProfile(Bool)
        case updateProfile(User)
        case updateProfileResponse(Result<User, Error>)
        
        // Image picker
        case changeProfileImageTapped
        case setShowingImagePicker(Bool)
        case profileImageSelected(Data)
        case uploadProfileImageResponse(Result<String, Error>)
        
        // Settings
        case toggleNotifications(Bool)
        case toggleEmailNotifications(Bool)
        case togglePushNotifications(Bool)
        
        // Navigation
        case myTicketsTapped
        case favoritesTapped
        case supportTapped
        case privacySettingsTapped
        case languageSettingsTapped
        
        // Account actions
        case signOutTapped
        
        // Error handling
        case dismissError
    }
    
    public init() {}
    
    @Dependency(\.userClient) var userClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            // MARK: - Lifecycle
                
            case .onAppear:
                return .send(.loadUserProfile)
                
            case .loadUserProfile:
                // Se já temos dados do usuário, não precisa recarregar
                guard state.user == nil && !state.isLoading else { return .none }
                
                state.isLoading = true
                state.error = nil
                
                return .run { send in
                    do {
                        let user = try await userClient.getCurrentUser()
                        await send(.userProfileResponse(.success(user)))
                    } catch {
                        await send(.userProfileResponse(.failure(error)))
                    }
                }
                
            case let .userProfileResponse(.success(user)):
                state.isLoading = false
                state.user = user
                state.error = nil
                return .none
                
            case let .userProfileResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
            
            // MARK: - Profile Editing
            case .editProfileTapped:
                state.showingEditProfile = true
                return .none
                
            case let .setShowingEditProfile(isShowing):
                state.showingEditProfile = isShowing
                return .none
                
            case let .updateProfile(updatedUser):
                state.isLoading = true
                state.error = nil
                
                return .run { send in
                    do {
                        let user = try await userClient.updateUserProfile(updatedUser)
                        await send(.updateProfileResponse(.success(user)))
                    } catch {
                        await send(.updateProfileResponse(.failure(error)))
                    }
                }
                
            case let .updateProfileResponse(.success(user)):
                state.isLoading = false
                state.user = user
                state.showingEditProfile = false
                state.error = nil
                return .none
                
            case let .updateProfileResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
            
            // MARK: - Image Picker
            case .changeProfileImageTapped:
                state.showingImagePicker = true
                return .none
                
            case let .setShowingImagePicker(isShowing):
                state.showingImagePicker = isShowing
                return .none
                
            case let .profileImageSelected(imageData):
                state.showingImagePicker = false
                state.isLoading = true
                state.error = nil
                
                return .run { send in
                    do {
                        let imageURL = try await userClient.uploadProfileImage(imageData)
                        await send(.uploadProfileImageResponse(.success(imageURL)))
                    } catch {
                        await send(.uploadProfileImageResponse(.failure(error)))
                    }
                }
                
            case let .uploadProfileImageResponse(.success(imageURL)):
                state.isLoading = false
                if var user = state.user {
                    user.profileImageURL = imageURL
                    state.user = user
                }
                return .none
                
            case let .uploadProfileImageResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
            
            // MARK: - Settings
            case let .toggleNotifications(enabled):
                state.notificationsEnabled = enabled
                // TODO: Persist setting
                return .none
                
            case let .toggleEmailNotifications(enabled):
                state.emailNotifications = enabled
                // TODO: Persist setting
                return .none
                
            case let .togglePushNotifications(enabled):
                state.pushNotifications = enabled
                // TODO: Persist setting
                return .none
            
            // MARK: - Navigation
            case .myTicketsTapped:
                // Handle navigation to tickets
                return .none
                
            case .favoritesTapped:
                // Handle navigation to favorites
                return .none
                
            case .supportTapped:
                // Handle navigation to support
                return .none
                
            case .privacySettingsTapped:
                // Handle navigation to privacy settings
                return .none
                
            case .languageSettingsTapped:
                // Handle navigation to language settings
                return .none
            
            // MARK: - Account Actions
            case .signOutTapped:
                // O signOut será tratado pelo SocialAppFeature
                return .none
            
            // MARK: - Error Handling
            case .dismissError:
                state.error = nil
                return .none
            }
        }
    }
}

// MARK: - Error Extension

extension ProfileFeature.Action {
    public static func == (lhs: ProfileFeature.Action, rhs: ProfileFeature.Action) -> Bool {
        switch (lhs, rhs) {
        case (.onAppear, .onAppear),
             (.loadUserProfile, .loadUserProfile),
             (.editProfileTapped, .editProfileTapped),
             (.changeProfileImageTapped, .changeProfileImageTapped),
             (.myTicketsTapped, .myTicketsTapped),
             (.favoritesTapped, .favoritesTapped),
             (.supportTapped, .supportTapped),
             (.privacySettingsTapped, .privacySettingsTapped),
             (.languageSettingsTapped, .languageSettingsTapped),
             (.signOutTapped, .signOutTapped),
             (.dismissError, .dismissError):
            return true
            
        case let (.setShowingEditProfile(lhs), .setShowingEditProfile(rhs)),
             let (.setShowingImagePicker(lhs), .setShowingImagePicker(rhs)),
             let (.toggleNotifications(lhs), .toggleNotifications(rhs)),
             let (.toggleEmailNotifications(lhs), .toggleEmailNotifications(rhs)),
             let (.togglePushNotifications(lhs), .togglePushNotifications(rhs)):
            return lhs == rhs
            
        case let (.updateProfile(lhs), .updateProfile(rhs)):
            return lhs == rhs
            
        case let (.profileImageSelected(lhs), .profileImageSelected(rhs)):
            return lhs == rhs
            
        case let (.userProfileResponse(.success(lhs)), .userProfileResponse(.success(rhs))),
             let (.updateProfileResponse(.success(lhs)), .updateProfileResponse(.success(rhs))):
            return lhs == rhs
            
        case let (.uploadProfileImageResponse(.success(lhs)), .uploadProfileImageResponse(.success(rhs))):
            return lhs == rhs
            
        case (.userProfileResponse(.failure), .userProfileResponse(.failure)),
             (.updateProfileResponse(.failure), .updateProfileResponse(.failure)),
             (.uploadProfileImageResponse(.failure), .uploadProfileImageResponse(.failure)):
            return true
            
        default:
            return false
        }
    }
}

