import ComposableArchitecture
import FirebaseCore
import FirebaseMessaging
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    // Flag para controlar se Push Notifications estão habilitadas
    // TODO: Remover este flag quando Push Notifications forem configuradas no Apple Developer Panel
    private static let isPushNotificationsEnabled = false
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configurar Firebase
        FirebaseApp.configure()
        print("🔥 Firebase configurado com sucesso")
        
        // Configurar Messaging delegate apenas se Push Notifications estiverem habilitadas
        if Self.isPushNotificationsEnabled {
            Messaging.messaging().delegate = self
            print("📱 Messaging delegate configurado")
        } else {
            print("⏭️  Push Notifications desabilitadas por enquanto (desenvolvimento)")
        }
        
        // Configurar delegate de notificações apenas se habilitadas
        if Self.isPushNotificationsEnabled {
            UNUserNotificationCenter.current().delegate = PushNotificationService.shared
        }
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        if Self.isPushNotificationsEnabled {
            // Passar token para Firebase
            Messaging.messaging().apnsToken = deviceToken
            PushNotificationService.shared.setDeviceToken(deviceToken)
            print("📱 Device token registrado: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        if Self.isPushNotificationsEnabled {
            print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken else { return }
        
        if Self.isPushNotificationsEnabled {
            print("🔥 FCM Token: \(token)")
            // Enviar para backend
            PushNotificationService.shared.setFCMToken(token)
        }
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
                    // TODO: Habilitar solicitar autorização de Push Notifications quando configuradas
                    // Task {
                    //     try? await PushNotificationService.shared.requestAuthorization()
                    // }
                    print("⏭️  Solicitação de Push Notifications desabilitada (desenvolvimento)")
                }
            .environment(ThemeManager.shared)
        }
    }
}
