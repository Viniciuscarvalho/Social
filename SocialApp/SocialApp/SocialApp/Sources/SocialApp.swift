import ComposableArchitecture
import FirebaseCore
import FirebaseMessaging
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configurar Firebase
        FirebaseApp.configure()
        
        // Configurar Messaging delegate
        Messaging.messaging().delegate = self
        
        // Solicitar autorização de notificações
        UNUserNotificationCenter.current().delegate = PushNotificationService.shared
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Passar token para Firebase
        Messaging.messaging().apnsToken = deviceToken
        
        PushNotificationService.shared.setDeviceToken(deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken else { return }
        print("🔥 FCM Token: \(token)")
        
        // Enviar para backend
        PushNotificationService.shared.setFCMToken(token)
    }
}
@main
struct SocialApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let store = Store(initialState: SocialAppFeature.State()) {
        SocialAppFeature()
    }

    var body: some Scene {
        WindowGroup {
            SocialAppView(store: store)
                .backgroundProtection()
                .onAppear {
                    Task {
                        try? await PushNotificationService.shared.requestAuthorization()
                    }
                }
            .environment(ThemeManager.shared)
        }
    }
}
