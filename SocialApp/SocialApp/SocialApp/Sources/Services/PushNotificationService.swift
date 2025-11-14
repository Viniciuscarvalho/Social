import Foundation
import UserNotifications
import UIKit

/// Serviço para gerenciar notificações push usando Firebase Cloud Messaging
public class PushNotificationService: NSObject, ObservableObject {
    public static let shared = PushNotificationService()
    
    @Published public var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published public var deviceToken: String?
    @Published public var fcmToken: String?
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Verifica o status atual de autorização
    public func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                print("📱 Push Notification Status: \(settings.authorizationStatus.description)")
            }
        }
    }
    
    /// Solicita permissão para enviar notificações
    public func requestAuthorization() async throws -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .badge, .sound, .providesAppNotificationSettings]
            )
            
            DispatchQueue.main.async {
                self.authorizationStatus = granted ? .authorized : .denied
            }
            
            if granted {
                print("✅ Push notifications authorized")
                await registerForRemoteNotifications()
            } else {
                print("❌ Push notifications denied")
            }
            
            return granted
        } catch {
            print("❌ Error requesting authorization: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Registra para receber notificações remotas
    @MainActor
    private func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
        print("📱 Registered for remote notifications")
    }
    
    // MARK: - Token Management
    
    /// Configura o device token recebido do APNs
    public func setDeviceToken(_ deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
        print("📱 Device Token: \(tokenString)")
        
        // TODO: Enviar token para o Firebase quando integrado
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    /// Configura o FCM token do Firebase
    public func setFCMToken(_ token: String) {
        self.fcmToken = token
        print("🔥 FCM Token: \(token)")
        
        // Enviar para backend
        Task {
            await sendTokenToBackend(token)
        }
    }
    
    private func sendTokenToBackend(_ token: String) async {
        do {
            struct TokenRequest: Codable {
                let token: String
                let platform: String = "ios"
            }
            
            let _: EmptyResponse = try await NetworkService.shared.request(
                endpoint: "/users/push-token",
                method: .POST,
                body: TokenRequest(token: token),
                requiresAuth: true
            )
            
            print("✅ Token enviado para backend")
        } catch {
            print("❌ Erro ao enviar token: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Notification Handling
    
    /// Handle notification quando app está em foreground
    public func handleForegroundNotification(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        print("📬 Foreground notification received:")
        print("   Title: \(notification.request.content.title)")
        print("   Body: \(notification.request.content.body)")
        print("   UserInfo: \(userInfo)")
        
        // Parse notification data
        if let data = parseNotificationData(userInfo) {
            postNotificationReceived(data)
        }
    }
    
    /// Handle notification tap (app aberto via notificação)
    public func handleNotificationTap(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        print("👆 Notification tapped:")
        print("   UserInfo: \(userInfo)")
        
        // Parse notification data
        if let data = parseNotificationData(userInfo) {
            handleDeepLink(data)
        }
    }
    
    // MARK: - Deep Linking
    
    private func handleDeepLink(_ data: NotificationData) {
        print("🔗 Handling deep link for type: \(data.type)")
        
        // Postar notificação local para navegação
        NotificationCenter.default.post(
            name: .navigateFromPushNotification,
            object: nil,
            userInfo: ["data": data]
        )
    }
    
    private func postNotificationReceived(_ data: NotificationData) {
        NotificationCenter.default.post(
            name: .pushNotificationReceived,
            object: nil,
            userInfo: ["data": data]
        )
    }
    
    // MARK: - Data Parsing
    
    private func parseNotificationData(_ userInfo: [AnyHashable: Any]) -> NotificationData? {
        guard let typeString = userInfo["type"] as? String,
              let type = NotificationData.NotificationType(rawValue: typeString) else {
            print("⚠️ Unknown notification type")
            return nil
        }
        
        let id = userInfo["id"] as? String ?? ""
        let title = userInfo["title"] as? String ?? ""
        let body = userInfo["body"] as? String ?? ""
        
        return NotificationData(
            type: type,
            id: id,
            title: title,
            body: body,
            additionalData: userInfo as? [String: Any]
        )
    }
    
    // MARK: - Badge Management
    
    /// Limpa o badge do app
    @MainActor
    public func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("🔔 Badge cleared")
    }
    
    /// Define o badge number
    @MainActor
    public func setBadge(_ count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
        print("🔔 Badge set to: \(count)")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationService: UNUserNotificationCenterDelegate {
    /// Chamado quando notificação chega com app em foreground
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handleForegroundNotification(notification)
        
        // Mostrar banner, som e badge mesmo em foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Chamado quando usuário toca na notificação
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleNotificationTap(response)
        completionHandler()
    }
}

// MARK: - Supporting Types

public struct NotificationData: Codable {
    let type: NotificationType
    let id: String
    let title: String
    let body: String
    let additionalData: [String: Any]?
    
    public enum NotificationType: String, Codable {
        case negotiationApproved = "negotiation_approved"
        case negotiationRejected = "negotiation_rejected"
        case negotiationRequest = "negotiation_request"
        case contactRevealed = "contact_revealed"
        case validationApproved = "validation_approved"
        case validationRejected = "validation_rejected"
        case reviewReceived = "review_received"
    }
    
    enum CodingKeys: String, CodingKey {
        case type, id, title, body
    }
    
    public init(type: NotificationType, id: String, title: String, body: String, additionalData: [String: Any]?) {
        self.type = type
        self.id = id
        self.title = title
        self.body = body
        self.additionalData = additionalData
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(NotificationType.self, forKey: .type)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        additionalData = nil
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
    }
}

private struct EmptyResponse: Codable {}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateFromPushNotification = Notification.Name("navigateFromPushNotification")
    static let pushNotificationReceived = Notification.Name("pushNotificationReceived")
}

// MARK: - Extensions

extension UNAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - Dependency Key

import ComposableArchitecture

extension PushNotificationService: TestDependencyKey {
    public static var testValue: PushNotificationService {
        return PushNotificationService.shared
    }
}

extension DependencyValues {
    public var pushNotificationService: PushNotificationService {
        get { self[PushNotificationService.self] }
        set { self[PushNotificationService.self] = newValue }
    }
}










